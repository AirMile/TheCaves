# Git Workflow for Game Development

## 🌿 Branch Structure

### **Main Branches**
```
main: Production-ready releases only
dev: Integration branch, tested features
```

### **Feature Branches**  
```
feature/player-movement
feature/neon-shaders  
feature/enemy-ai
feature/audio-system
art/character-sprites
art/ui-design
fix/glow-performance
```

### **Naming Convention**
- `feature/`: New functionality
- `art/`: Asset creation and visual work
- `fix/`: Bug fixes
- `refactor/`: Code improvements without new features
- `docs/`: Documentation updates

## 🔄 Workflow Process

### **Daily Workflow**
```bash
# Start of day - sync with team
git checkout dev
git pull origin dev

# Create new feature branch  
git checkout -b feature/dash-ability

# Work on feature...
# Multiple commits during development
git add .
git commit -m "feat: add dash input detection"
git commit -m "feat: implement dash cooldown system"  
git commit -m "fix: dash collision detection"

# End of day - push work
git push origin feature/dash-ability
```

### **Feature Completion**
```bash
# Merge latest dev changes
git checkout dev
git pull origin dev
git checkout feature/dash-ability
git merge dev

# Test everything works
# Then merge to dev
git checkout dev  
git merge feature/dash-ability
git push origin dev

# Clean up
git branch -d feature/dash-ability
git push origin --delete feature/dash-ability
```

## 📝 Commit Message Format

### **Structure**
```
<type>(<scope>): <description>

[optional body]
[optional footer]
```

### **Types**
- `feat`: New feature  
- `fix`: Bug fix
- `art`: Art assets (sprites, animations)
- `audio`: Music, SFX
- `refactor`: Code restructuring
- `docs`: Documentation
- `test`: Testing additions
- `perf`: Performance improvements

### **Examples**
```
feat(player): add dash ability with cooldown
fix(enemies): crawler collision detection  
art(characters): add shaman idle animation
audio(sfx): implement spell casting sounds
perf(rendering): optimize glow shader performance
refactor(input): restructure controller handling
```

## 🚀 Release Process

### **Version Tagging**
```
v0.1.0: First playable prototype
v0.2.0: Core mechanics complete  
v0.3.0: Art integration complete
v1.0.0: Feature complete, ready for playtesting
```

### **Release Checklist**
```bash
# Before tagging release
git checkout main
git merge dev
git tag -a v0.1.0 -m "First playable prototype"
git push origin main
git push origin v0.1.0
```

## 🔒 Merge Conflicts Resolution

### **Common Conflicts**
1. **Scene files**: Godot .tscn files
2. **Project settings**: project.godot  
3. **Asset imports**: .import files

### **Resolution Strategy**
```bash
# When merge conflict occurs
git status  # See conflicted files

# For .tscn files: usually recreate scene
# For code files: manual merge
git add [resolved-files]
git commit -m "resolve: merge conflict in player scene"
```

### **Prevention**  
- **Small, frequent commits**
- **Clear feature separation** 
- **Communicate about shared files** (scenes, project settings)
- **Pull dev branch daily**

## 📁 .gitignore Template

```gitignore
# Godot 4 generated files  
.godot/
.import/
*.tmp

# Logs
logs/
*.log

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Art working files (keep originals elsewhere)
*.psd
*.ai  
*.sketch
*~.nib

# Audio working files
*.wav.asd
*.aif

# Build artifacts
builds/
exports/
```

## 🤝 Team Coordination

### **Before Starting Work**
```bash  
git checkout dev
git pull origin dev
# Check what teammate has pushed
git log --oneline -10
```

### **Communication Protocol**
- **Push daily** - even incomplete work
- **Slack/Discord updates** when pushing major changes
- **Don't work on same files** simultaneously if possible
- **Ask before big refactors**

### **Shared File Management**
**High-conflict files**:
- `project.godot` - coordinate project settings changes
- `Main.tscn` - avoid simultaneous scene modifications  
- Shared scripts - use dependency injection where possible

**Low-conflict files**:
- Individual sprite assets - own naming/folders  
- Separate scene files - character.tscn vs enemy.tscn
- Individual scripts - PlayerController.gd vs EnemyAI.gd

## 🆘 Emergency Procedures

### **Broke Main Branch**
```bash
# Reset to last working commit
git log --oneline main  # Find last good commit
git checkout main
git reset --hard [good-commit-hash]
git push --force origin main  # DANGEROUS - coordinate with team
```

### **Lost Work**
```bash
# Find lost commits
git reflog
git checkout [lost-commit-hash]
git checkout -b recover-lost-work
```

### **Corrupted Repository**
```bash
# Fresh clone as last resort  
git clone [repository-url] fresh-clone
# Manually copy current work
# Create branch and push changes
```

---

**Setup Instructions for Team**:
1. Clone repository: `git clone [url]`
2. Configure user: `git config user.name/email`  
3. Install Git GUI (optional): GitKraken, SourceTree, or VS Code integration
4. Test workflow with dummy commits
5. Establish communication protocol