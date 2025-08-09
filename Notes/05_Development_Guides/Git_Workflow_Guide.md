# 🌳 Git Workflow Guide - Roguelite Project

## 📌 Why Use Branches?

### The Problem Without Branches
Imagine: Jade works on the ability system, you on enemy AI. Without branches:
- Your code constantly clashes
- A bug from Jade breaks your enemy system
- You can't go back to a working version
- Merge conflicts every time you pull

### The Solution With Branches
- **Isolation**: Everyone works in their own "sandbox"
- **Safety**: Main branch always stays stable
- **Review**: Check each other's code before merging
- **Rollback**: Easy to go back to previous version

## 🏗️ Branch Structure

```
main                    # ← Production version (always working!)
│
└── dev                 # ← Development version (merge features here)
    ├── feature/player-movement     # Miles works on this
    ├── feature/ability-system      # Jade works on this
    ├── feature/enemy-ai           # Miles later
    └── fix/performance-glow        # Bugfixes
```

## 📝 Step-by-Step Workflow

### 1️⃣ Project Setup (First time)
```bash
# Clone the repository
git clone https://github.com/[username]/roguelite-game.git
cd roguelite-game

# Create dev branch
git checkout -b dev
git push -u origin dev

# Set dev as default branch on GitHub
# (Via GitHub settings → Branches → Default branch)
```

### 2️⃣ Starting a New Feature
```bash
# Make sure you're on dev
git checkout dev
git pull origin dev

# Create new feature branch
git checkout -b feature/player-movement

# Now you can code!
```

### 3️⃣ During Work (Daily)
```bash
# Check which files you've modified
git status

# Stage your changes
git add .

# Commit with clear message
git commit -m "feat: add WASD movement with acceleration"

# Push to GitHub
git push origin feature/player-movement
```

### 4️⃣ Code Ready? Make a Pull Request

#### Via GitHub Website:
1. Go to your repository
2. Click "Pull requests" → "New pull request"
3. Base: `dev` ← Compare: `feature/player-movement`
4. Add description:
```markdown
## What does this PR do?
- Implements WASD movement
- Adds acceleration/deceleration
- Controller support for movement

## Testing
- [x] Tested with keyboard
- [x] Tested with controller
- [x] No bugs found

## Screenshots
[Add GIF of movement]
```

### 5️⃣ Review Process
```bash
# Jade checks your code
# She can add comments
# If everything is OK → Merge!

# After merge, update locally:
git checkout dev
git pull origin dev
git branch -d feature/player-movement  # Delete old branch
```

## 🏷️ Commit Message Conventions

### Format: `type: description`

**Types:**
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation
- `style:` Code formatting (no functionality)
- `refactor:` Code restructuring
- `perf:` Performance improvement
- `test:` Add test
- `chore:` Maintenance (git ignore, etc)

### Examples:
```bash
git commit -m "feat: add dash ability with cooldown"
git commit -m "fix: player stuck in wall collision"
git commit -m "docs: update README with controls"
git commit -m "perf: optimize glow shader rendering"
git commit -m "refactor: split player.gd into components"
```

## 🔄 Daily Workflow Example

### Morning
```bash
# Start your day with fresh code
git checkout dev
git pull origin dev
git checkout feature/your-feature
git merge dev  # Get latest updates
```

### Evening
```bash
# Commit your work
git add .
git commit -m "feat: progress on enemy spawning"
git push origin feature/your-feature

# Create PR when feature is ready
```

## ⚠️ Resolving Merge Conflicts

When Git says "CONFLICT":

```bash
# 1. Open the conflict file
# You'll see this:
<<<<<<< HEAD
your code
=======
jade's code
>>>>>>> feature/other

# 2. Decide what to keep:
# - Keep your code
# - Keep Jade's code  
# - Combine both

# 3. Remove the markers (<<<<, ====, >>>>)

# 4. Commit the solution
git add .
git commit -m "fix: resolve merge conflict in player.gd"
```

### Godot-Specific Conflicts

**Common Godot Conflicts:**
1. **Scene files (.tscn)**: Often better to recreate scene
2. **Project settings (project.godot)**: Carefully merge, test both settings
3. **Import files (.import)**: Usually safe to regenerate

**Prevention for Godot:**
- Communicate who works on which scenes
- Avoid simultaneous project.godot changes
- Use prefabs/inherited scenes where possible

## 🤖 Claude Code Integration

### Setup for PR Reviews
```bash
# In repository root, create .claude-instructions
echo "Review this PR for:
- Performance issues
- Code quality
- Godot best practices
- Possible bugs" > .claude-instructions

# For auto-review on PR:
claude-code review --pr
```

### For Merge Assistance
```bash
# If you have merge conflicts
claude-code merge --resolve

# For smart merging suggestions
claude-code merge --suggest
```

## 📋 Git Aliases (Quick Commands)

Add to `.gitconfig`:
```bash
[alias]
    st = status
    co = checkout
    br = branch
    cm = commit -m
    pu = push origin
    pl = pull origin
    feat = checkout -b feature/
    last = log -1 HEAD
```

Now you can type:
```bash
git st                    # Instead of: git status
git cm "fix: bug"        # Instead of: git commit -m "fix: bug"
git feat player-dash     # Instead of: git checkout -b feature/player-dash
```

## ❌ What NOT To Do

1. **NEVER** push directly to `main`
2. **NEVER** force push (except own feature branch)
3. **NEVER** commit large binary files (use Git LFS)
4. **NEVER** commit .godot/ folder
5. **NEVER** commit passwords/API keys in code

## 🆘 Need Help?

### Wrong branch?
```bash
git stash              # Save your work temporarily
git checkout dev       # Go to correct branch
git stash pop         # Get your work back
```

### Wrong commit message?
```bash
git commit --amend -m "new message"
```

### Too many commits? Squash them:
```bash
git rebase -i HEAD~3   # Combine last 3 commits
```

---

## 📚 Extra Resources

- [GitHub Flow Guide](https://guides.github.com/introduction/flow/)
- [Godot Git Plugin](https://github.com/godotengine/godot-git-plugin)
- [Git Cheat Sheet](https://education.github.com/git-cheat-sheet-education.pdf)

---

*💡 Tip: Print this guide or keep it open during development!*