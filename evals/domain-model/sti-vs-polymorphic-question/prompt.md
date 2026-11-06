---
name: domain-model-sti-vs-polymorphic-question
description: A Rails modeling question about our gym shouldn't trigger the domain model skill.
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

Members and staff at our gym can both check in at the desk. Should Visit belong to them through a polymorphic association, or should Member and Staff be STI subclasses of one Person model?
