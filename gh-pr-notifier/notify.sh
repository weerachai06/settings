#!/bin/bash

GH="$(which gh)"

PR_JSON=$("$GH" search prs --review-requested=@me --state=open --draft=false \
  --json "number,title,url,repository,updatedAt" 2>/dev/null)

COUNT=$(/usr/bin/python3 -c "import sys,json; print(len(json.load(sys.stdin)))" <<< "$PR_JSON" 2>/dev/null)

if [[ -z "$COUNT" || "$COUNT" -eq 0 ]]; then
  exit 0
fi

if [[ "$COUNT" -eq 1 ]]; then
  SUBTITLE=$(/usr/bin/python3 -c "
import sys, json
p = json.load(sys.stdin)[0]
print(f\"{p['repository']['nameWithOwner']} #{p['number']}\")
" <<< "$PR_JSON" 2>/dev/null)
  BODY=$(/usr/bin/python3 -c "
import sys, json
print(json.load(sys.stdin)[0]['title'])
" <<< "$PR_JSON" 2>/dev/null)
else
  SUBTITLE="${COUNT} PRs รอรีวิว"
  BODY=$(/usr/bin/python3 -c "
import sys, json
prs = json.load(sys.stdin)
lines = [f\"• {p['repository']['name']} #{p['number']}\" for p in prs[:5]]
if len(prs) > 5:
    lines.append(f\"  ...และอีก {len(prs)-5} รายการ\")
print('\n'.join(lines))
" <<< "$PR_JSON" 2>/dev/null)
fi

RESULT=$(/usr/bin/osascript -e "
set btn to button returned of (display alert \"🔍 GitHub PR Review\" message \"$SUBTITLE\" & \"\n\" & \"$BODY\" buttons {\"Dismiss\", \"Open GitHub\"} default button \"Open GitHub\")
btn" 2>/dev/null)

if [[ "$RESULT" == "Open GitHub" ]]; then
  open "https://github.com/pulls?q=is%3Aopen+is%3Apr+review-requested%3A%40me+archived%3Afalse+draft%3Afalse+"
fi
