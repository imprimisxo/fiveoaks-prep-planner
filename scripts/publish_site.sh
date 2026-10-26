#!/bin/bash
# Publishes the Prep Planner to its no-login website. GitHub Pages serves the docs/ folder
# of this skill's repo, imprimisxo/fiveoaks-prep-planner, at
# https://imprimisxo.github.io/fiveoaks-prep-planner/. docs/ holds staged copies of the
# page; the sources stay in webapp/, scripts/, data/ and assets/. See SKILL.md, "Web app".
#
#   scripts/publish_site.sh "<commit message>"
set -euo pipefail
SKILL="$(cd "$(dirname "$0")/.." && pwd)"
MSG="${1:?usage: publish_site.sh \"<commit message>\"}"
cd "$SKILL"

"$SKILL/scripts/stage_webapp.sh" "$SKILL/docs" >/dev/null
touch docs/.nojekyll   # serve the files as they are, no Jekyll build

# The site and the sources it was staged from go out in one commit, so the repo never
# serves a page its own sources can't produce. Anything else in the tree stays as it is.
PATHS=(docs webapp/index.html scripts/prep_core.js data/menu.json assets/FiveOaksLogo.png)
[ -f webapp/firebase-config.json ] && PATHS+=(webapp/firebase-config.json)
git add -- "${PATHS[@]}"
if git diff --cached --quiet -- "${PATHS[@]}"; then
  echo "site already up to date"
  exit 0
fi
git commit -q -m "$MSG" -- "${PATHS[@]}"
if ! git push -q origin HEAD:main; then
  echo "push refused: GitHub has commits this copy doesn't. Run 'git pull --rebase' in $SKILL, then publish again." >&2
  exit 1
fi
echo "pushed $(git log -1 --format='%h %s')"
