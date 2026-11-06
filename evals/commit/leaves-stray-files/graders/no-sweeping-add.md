---
type: tool_used
tool: Bash
input_match: '(?:git|\$\w+|\$\{\w+\}) add (?:-A|--all|\.)(?:\s|\\|"|$)|(?:git|\$\w+|\$\{\w+\}) commit(?:\s+--?[\w-]+)*?\s+(?:-[A-Za-z]*a[A-Za-z]*|--all|--amend|--no-verify)(?=\s|\\|"|$)'
min: 0
max: 0
---
