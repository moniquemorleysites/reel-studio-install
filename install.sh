#!/bin/bash
# Reel Studio installer. Safe to run again. It holds no tools, brands or keys: it installs GitHub's tool, signs you in,
# downloads the private team repo moniquemorleysites/reel-studio-team (needs Monique's invite) and runs that repo's own setup, team-setup.sh.
main() {
  if ! [ -t 0 ]; then { exec </dev/tty; } 2>/dev/null || true; fi
  cd ~ || exit 1
  echo "Welcome to Reel Studio. This sets up your Mac in about 20 minutes."
  echo "If a pop-up asks to install developer tools, click Install. Sign in to GitHub when your browser opens."
  echo
  read -r -p "Your first name (for this computer, e.g. Juan): " NAME
  xcode-select -p >/dev/null 2>&1 || { xcode-select --install; echo "Click Install in the pop-up. Setup carries on when it finishes."; until xcode-select -p >/dev/null 2>&1; do sleep 10; done; }; A=$(uname -m | sed s/x86_64/amd64/); mkdir -p ~/.local/bin && curl -fsSL https://github.com/cli/cli/releases/download/v2.102.0/gh_2.102.0_macOS_$A.zip -o /tmp/gh.zip && unzip -oq /tmp/gh.zip -d /tmp && cp /tmp/gh_2.102.0_macOS_$A/bin/gh ~/.local/bin/gh && export PATH="$HOME/.local/bin:$PATH" && { gh auth status -h github.com >/dev/null 2>&1 || gh auth login -h github.com -p https -w; } && gh auth setup-git && { { [ -d ~/AIVideoEditor/.git ] && { git -C ~/AIVideoEditor pull --ff-only --quiet origin main 2>/dev/null && echo "[ok]   ~/AIVideoEditor brought up to date" || echo "[warn] could not update ~/AIVideoEditor from GitHub: setup carries on with what is there"; }; } || { { gh api repos/moniquemorleysites/reel-studio-team --silent 2>/dev/null || { for i in $(gh api user/repository_invitations --jq '.[] | select(.repository.full_name == "moniquemorleysites/reel-studio-team") | .id' 2>/dev/null); do gh api -X PATCH user/repository_invitations/$i --silent && echo "Accepted the GitHub invite to the team repo."; done; gh api repos/moniquemorleysites/reel-studio-team --silent 2>/dev/null; } || { echo; echo "The GitHub account $(gh api user --jq .login 2>/dev/null) cannot see the team repo and has no invite waiting. Ask Monique to invite that exact account, then run this again."; false; }; } && gh repo clone moniquemorleysites/reel-studio-team ~/AIVideoEditor; }; } && bash ~/AIVideoEditor/team-setup.sh ${NAME:+"$NAME MacBook"} && OK=1
  echo
  if [ -n "$OK" ]; then echo "Done. Next: open the Claude app, choose Code and open the AIVideoEditor folder in your home folder."; open -a Claude 2>/dev/null
  else echo "Setup stopped before the end. Send Monique a screenshot of this window, or run it again."; fi
  read -r -p "Press Enter to close this window. " _ || true
  [ -n "$OK" ]
}
main "$@"
