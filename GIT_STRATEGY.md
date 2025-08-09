# 📝 Git Strategy for TheCaves Project

## 🎯 Strategy

**We track BOTH documentation AND Godot project files in Git**

### Why?
1. **Complete project** - Everything in one repository
2. **Team collaboration** - Everyone has the same setup
3. **Version control** - Track changes in code and scenes
4. **Backup** - Everything safe in Git
5. **Open source ready** - Easy to share

## 📁 What gets tracked

### ✅ YES in Git:
```
TheCaves/
├── Notes/                    # ✅ All documentation
│   └── [all docs]          # ✅ Obsidian vault
├── scenes/                   # ✅ Godot scenes (.tscn)
├── scripts/                  # ✅ GDScript files (.gd)
├── assets/                   # ✅ Sprites, audio, fonts
│   ├── sprites/             # ✅ PNG/SVG files
│   ├── audio/               # ✅ OGG/WAV files
│   └── shaders/             # ✅ Shader files
├── resources/                # ✅ Godot resources (.tres)
├── project.godot            # ✅ Project configuration
├── export_presets.cfg       # ✅ Export settings (CHECK FOR KEYS!)
├── icon.png                 # ✅ Project icon
├── default_env.tres         # ✅ Default environment
├── README.md                # ✅ Project readme
└── .gitignore              # ✅ Git configuration
```

### ❌ NOT in Git (automatically ignored):
```
TheCaves/
├── .godot/                  # ❌ Godot 4 cache (large!)
├── .import/                 # ❌ Godot 3 cache
├── builds/                  # ❌ Export builds
├── *.tmp                    # ❌ Temporary files
├── .vscode/                 # ❌ IDE settings
├── .DS_Store               # ❌ OS files
└── Notes/
    ├── .obsidian/          # ❌ Obsidian config/cache
    └── .trash/             # ❌ Obsidian trash folder
```

## 🔄 Daily Workflow

### For Miles & Jade:
```bash
# Start of the day
git pull                     # Get latest changes

# After making changes
git add .                    # Add everything (except .gitignore items)
git status                   # Check what you're going to commit
git commit -m "feat: added enemy spawning system"
git push

# For large binary files (sprites, audio)
# Consider using Git LFS (see below)
```

## ⚠️ Important Warnings

### 1. Export Presets
**ATTENTION**: `export_presets.cfg` can contain API keys!
- Steam API keys
- Google Play keys  
- iOS certificates
- AdMob IDs

**Always check before committing!**

### 2. Large Files
Godot assets can become large:
- **Sprites**: Use PNG compression
- **Audio**: OGG Vorbis recommended
- **3D Models**: Consider Git LFS

### 3. Binary Merge Conflicts
`.tscn` and `.tres` files are text, but can cause conflicts:
- **Communicate** who works on which scenes
- **Use prefabs** where possible
- **Pull often** to prevent conflicts

## 🚀 Git Large File Storage (LFS)

For large assets (optional):
```bash
# Install Git LFS
git lfs install

# Track large file types
git lfs track "*.png"
git lfs track "*.wav"
git lfs track "*.blend"

# Add .gitattributes
git add .gitattributes
git commit -m "chore: setup Git LFS"
```

## 📊 Repository Size Management

### Current size estimates:
- **Notes/**: ~5 MB (text only)
- **Scripts/**: ~1-5 MB (text)
- **Scenes/**: ~5-20 MB (text-based)
- **Assets/**: 10-500+ MB (binary files)
- **Total**: 20-500+ MB (depending on assets)

### Tips to keep it small:
1. **Compress images** before committing
2. **Use OGG** for audio (not WAV)
3. **Delete unused assets** regularly
4. **Git LFS** for files > 10MB
5. **Ignore builds** folder always

## 🏷️ Commit Message Conventions

```bash
# Features
git commit -m "feat(player): add dash ability"
git commit -m "feat(enemies): implement wave spawning"

# Bug fixes
git commit -m "fix(collision): player stuck in walls"

# Art/Assets
git commit -m "art(sprites): add enemy death animation"
git commit -m "audio(sfx): add explosion sounds"

# Documentation
git commit -m "docs: update performance guide"

# Performance
git commit -m "perf(rendering): optimize sprite batching"
```

## 🔧 Handling Godot-Specific Files

### Scene Files (.tscn)
- **Text-based** but large
- **Track changes** possible
- **Merge conflicts** can be complex
- **Tip**: Coordinate who edits what

### Resource Files (.tres)
- **Text-based** resources
- **Reusable** between scenes
- **Track changes** easy
- **Good for**: Materials, themes, etc.

### Import Files (.import)
- **Auto-generated** by Godot
- **Usually ignore** (can be regenerated)
- **Sometimes track** for consistency

## 💡 Best Practices

1. **Pull before starting work**
   ```bash
   git pull --rebase
   ```

2. **Commit often, push regularly**
   ```bash
   git add .
   git commit -m "wip: working on enemy AI"
   git push
   ```

3. **Use feature branches for large changes**
   ```bash
   git checkout -b feature/boss-fight
   # work on feature
   git push origin feature/boss-fight
   # create pull request
   ```

4. **Communicate via commit messages**
   - Clear descriptions
   - Reference issues: "fixes #12"
   - Tag teammate: "@Jade check this art"

## 🚨 Troubleshooting

### Large file rejected:
```bash
# Use Git LFS
git lfs track "*.png"
git add .gitattributes
git add large_file.png
git commit -m "art: add large sprite with LFS"
```

### Merge conflict in scene:
```bash
# Open both versions in Godot
# Manually merge changes
# Or: accept one version and redo changes
git checkout --theirs scenes/Level.tscn
# or
git checkout --ours scenes/Level.tscn
```

### Accidental commit of builds:
```bash
# Remove from Git but keep locally
git rm -r --cached builds/
git commit -m "fix: remove builds from tracking"
```

---

*This strategy tracks the complete project for best collaboration!*