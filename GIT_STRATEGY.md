# 📝 Git Strategy voor TheCaves Project

## 🎯 Strategie

**We tracken BEIDE documentatie EN Godot project files in Git**

### Waarom?
1. **Complete project** - Alles in één repository
2. **Team collaboration** - Iedereen heeft dezelfde setup
3. **Version control** - Track changes in code en scenes
4. **Backup** - Alles veilig in Git
5. **Open source ready** - Makkelijk te delen

## 📁 Wat wordt getracked

### ✅ WEL in Git:
```
TheCaves/
├── Notes/                    # ✅ Alle documentatie
│   └── [alle docs]          # ✅ Obsidian vault
├── scenes/                   # ✅ Godot scenes (.tscn)
├── scripts/                  # ✅ GDScript files (.gd)
├── assets/                   # ✅ Sprites, audio, fonts
│   ├── sprites/             # ✅ PNG/SVG files
│   ├── audio/               # ✅ OGG/WAV files
│   └── shaders/             # ✅ Shader files
├── resources/                # ✅ Godot resources (.tres)
├── project.godot            # ✅ Project configuration
├── export_presets.cfg       # ✅ Export settings (CHECK VOOR KEYS!)
├── icon.png                 # ✅ Project icon
├── default_env.tres         # ✅ Default environment
├── README.md                # ✅ Project readme
└── .gitignore              # ✅ Git configuration
```

### ❌ NIET in Git (automatisch ignored):
```
TheCaves/
├── .godot/                  # ❌ Godot 4 cache (groot!)
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

### Voor Miles & Jade:
```bash
# Start van de dag
git pull                     # Get latest changes

# Na het maken van changes
git add .                    # Add alles (behalve .gitignore items)
git status                   # Check wat je gaat committen
git commit -m "feat: added enemy spawning system"
git push

# Voor grote binary files (sprites, audio)
# Overweeg Git LFS te gebruiken (zie onder)
```

## ⚠️ Belangrijke Waarschuwingen

### 1. Export Presets
**LET OP**: `export_presets.cfg` kan API keys bevatten!
- Steam API keys
- Google Play keys  
- iOS certificates
- AdMob IDs

**Check altijd voor je commit!**

### 2. Large Files
Godot assets kunnen groot worden:
- **Sprites**: Gebruik PNG compression
- **Audio**: OGG Vorbis recommended
- **3D Models**: Overweeg Git LFS

### 3. Binary Merge Conflicts
`.tscn` en `.tres` files zijn text, maar kunnen conflicts geven:
- **Communicate** wie aan welke scenes werkt
- **Use prefabs** waar mogelijk
- **Pull vaak** om conflicts te voorkomen

## 🚀 Git Large File Storage (LFS)

Voor grote assets (optional):
```bash
# Install Git LFS
git lfs install

# Track grote file types
git lfs track "*.png"
git lfs track "*.wav"
git lfs track "*.blend"

# Add .gitattributes
git add .gitattributes
git commit -m "chore: setup Git LFS"
```

## 📊 Repository Grootte Management

### Huidige grootte estimates:
- **Notes/**: ~5 MB (text only)
- **Scripts/**: ~1-5 MB (text)
- **Scenes/**: ~5-20 MB (text-based)
- **Assets/**: 10-500+ MB (binary files)
- **Total**: 20-500+ MB (afhankelijk van assets)

### Tips om klein te houden:
1. **Compress images** voor je commit
2. **Use OGG** voor audio (niet WAV)
3. **Delete unused assets** regelmatig
4. **Git LFS** voor files > 10MB
5. **Ignore builds** folder altijd

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
- **Text-based** maar groot
- **Track changes** mogelijk
- **Merge conflicts** kunnen complex zijn
- **Tip**: Coordinate wie wat edit

### Resource Files (.tres)
- **Text-based** resources
- **Reusable** tussen scenes
- **Track changes** makkelijk
- **Good for**: Materials, themes, etc.

### Import Files (.import)
- **Auto-generated** door Godot
- **Meestal ignore** (kunnen regenerated worden)
- **Soms track** voor consistency

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

3. **Use feature branches voor grote changes**
   ```bash
   git checkout -b feature/boss-fight
   # werk aan feature
   git push origin feature/boss-fight
   # maak pull request
   ```

4. **Communicate via commit messages**
   - Duidelijke descriptions
   - Reference issues: "fixes #12"
   - Tag teammate: "@Jade check deze art"

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
# Open beide versions in Godot
# Manually merge changes
# Of: accept één version en redo changes
git checkout --theirs scenes/Level.tscn
# of
git checkout --ours scenes/Level.tscn
```

### Accidental commit of builds:
```bash
# Remove from Git maar houd lokaal
git rm -r --cached builds/
git commit -m "fix: remove builds from tracking"
```

---

*Deze strategie tracked het complete project voor beste collaboration!*