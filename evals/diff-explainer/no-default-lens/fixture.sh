#!/usr/bin/env bash
set -euo pipefail

git init -q -b main
git config user.name "Eval User"
git config user.email "eval@example.com"
git config commit.gpgsign false
git config core.excludesFile /dev/null

mkdir -p src/routes src/middleware

cat > package.json <<'JSON'
{
  "name": "notes-api",
  "type": "module",
  "dependencies": { "express": "^4.19.2", "bullmq": "^5.7.0", "ioredis": "^5.4.1" }
}
JSON

cat > src/app.js <<'JS'
import express from "express";
import notes from "./routes/notes.js";

const app = express();
app.use(express.json());
app.use("/notes", notes);
export default app;
JS

cat > src/routes/notes.js <<'JS'
import { Router } from "express";
import { db } from "../db.js";
import { sendDigest } from "../mailer.js";

const router = Router();

router.post("/", async (req, res) => {
  const note = await db.notes.insert({ userId: req.get("x-user-id"), body: req.body.body });
  await sendDigest(note.userId);
  res.status(201).json(note);
});

export default router;
JS

git add -A
git commit -q -m "Initial notes API"

git checkout -q -b queue-digest-email

cat > src/middleware/requireUser.js <<'JS'
export function requireUser(req, res, next) {
  const userId = req.get("x-user-id");
  if (!userId) return res.status(401).json({ error: "missing user" });
  req.userId = userId;
  next();
}
JS

cat > src/queue.js <<'JS'
import { Queue } from "bullmq";
import IORedis from "ioredis";

export const connection = new IORedis(process.env.REDIS_URL);
export const digests = new Queue("digests", { connection });
JS

cat > src/routes/notes.js <<'JS'
import { Router } from "express";
import { db } from "../db.js";
import { digests } from "../queue.js";
import { requireUser } from "../middleware/requireUser.js";

const router = Router();
router.use(requireUser);

router.post("/", async (req, res) => {
  const note = await db.notes.insert({ userId: req.userId, body: req.body.body });
  await digests.add("send", { userId: req.userId }, { jobId: `digest:${req.userId}` });
  res.status(201).json(note);
});

export default router;
JS

git add -A
git commit -q -F - <<'MSG'
Send the digest email from a queue, not the request

Creating a note waited on the mail provider, so p95 on POST /notes was
2.4s and a provider outage turned into 500s.

The jobId is per user, so ten notes in a row queue one digest, not ten.

Risk: BullMQ doesn't retry by default. A digest job that throws is gone.

Also moved the x-user-id check into a middleware, since the route was
writing notes with a null user when the header was missing.
MSG
