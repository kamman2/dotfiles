#!/bin/bash
# sync-dotfiles.sh - Sync dotfiles from home directory to .dotfiles repo, commit, and push

DOTFILES_DIR="$HOME/.dotfiles"
HOME_DIR="$HOME"

# List of dotfiles to sync (files in .dotfiles that have counterparts in HOME_DIR)
DOTFILES=(
    ".tmux.conf"
    ".bashrc"
    ".bash_logout"
    ".profile"
    ".inputrc"
    ".asoundrc"
    ".Xmodmap"
    ".npmrc"
    ".gitconfig"
)

changed=false

# Sync each dotfile from home to .dotfiles
for f in "${DOTFILES[@]}"; do
    src="$HOME_DIR/$f"
    dst="$DOTFILES_DIR/$f"
    
    if [ -f "$src" ]; then
        # Only copy if source has changed
        if ! cmp -s "$src" "$dst"; then
            cp "$src" "$dst"
            changed=true
        fi
    fi
done

# Check for git changes and commit/push if there are any
cd "$DOTFILES_DIR"

if [ "$changed" = true ] || [ -n "$(git status --porcelain)" ]; then
    git add .
    
    # Generate a descriptive commit message
    changes=$(git diff --cached --name-status 2>/dev/null | head -20)
    msg="Auto-sync: $(date '+%Y-%m-%d') - dotfiles update"
    
    if [ -n "$(git diff --cached)" ]; then
        git commit -m "$msg"
        git push origin master 2>/dev/null
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Committed and pushed: $msg"
    fi
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] No changes to commit."
fi
