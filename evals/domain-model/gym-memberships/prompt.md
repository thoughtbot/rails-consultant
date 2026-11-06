---
description: The gym's process says "lapse" where the code says expire!, uses "check-in" for two things and "freeze"/"pause" for one, so the skill flags both, reads no code, and writes nothing.
max_turns: 80
timeout_seconds: 1800
allowed_tools: [Read, Glob, Grep, Skill, Bash, Write]
---

This repo is the members app for our climbing gym. I want a domain model of how memberships actually work, so here's how it goes today.

Someone joins at the front desk, pays a $50 signup fee, and we bill their card every month. Every time they come in they check in at the desk with their key fob. If a payment fails we email them, and if it's still not paid after 7 days the membership lapses and the fob stops working. A lapsed member can rejoin without the signup fee if it's within 60 days. Members can freeze for up to 3 months a year for an injury or travel. While someone's paused we don't bill them and their fob is off. And 30 days after someone joins, a coach does a check-in with them to see how they're getting on, unless they've already booked a lesson.
