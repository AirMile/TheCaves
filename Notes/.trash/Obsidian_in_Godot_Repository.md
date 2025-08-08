# Obsidian in Godot Repository - Smart Setup
## Waarom dit beter is

- 🎯 **Alles bij elkaar:** Code + documentatie in één plek
- 📋 **Versie sync:** Notes matchen met game versie
- 🔄 **Simpele workflow:** Één repository, één git workflow
- 👥 **Team standard:** Zo doen professionele teams het

## Repository Structuur Setup

### Bestaande Godot Repository Uitbreiden

```
your-roguelite-game/
├── project.godot
├── scenes/
├── scripts/
├── assets/
├── addons/
├── .gitignore
├── README.md
└── docs/                    ← NIEUWE FOLDER
    ├── .obsidian/           ← Obsidian configuratie
    ├── README.md            ← Docs overzicht
    ├── 01-Game-Design/
    │   ├── Core-Mechanics.md
    │   ├── Level-Design.md
    │   └── Player-Progression.md
    ├── 02-Technical/
    │   ├── Code-Architecture.md
    │   ├── Performance-Notes.md
    │   └── Bug-Reports.md
    ├── 03-Development/
    │   ├── Sprint-Planning.md
    │   ├── Meeting-Notes.md
    │   └── Task-Lists.md
    └── 04-Research/
        ├── Reference-Games.md
        ├── Inspiration.md
        └── Articles-Links.md
```

## Setup Stappen

### Stap 1: Docs Directory Maken

```bash
# Navigeer naar je Godot project root
cd "pad/naar/jouw-godot-project"

# Maak docs directory
mkdir docs
cd docs

# Maak subdirectories
mkdir "01-Game-Design" "02-Technical" "03-Development" "04-Research"
```

### Stap 2: Obsidian Vault Setup

1. **Open Obsidian**
2. **"Open folder as vault"**
3. **Selecteer:** `jouw-godot-project/docs/` folder
4. **Obsidian zet automatisch** `.obsidian/` config folder erin

### Stap 3: .gitignore Aanpassen

Voeg toe aan je **hoofdproject .gitignore:**

```gitignore
# Obsidian (persoonlijke instellingen)
docs/.obsidian/workspace*
docs/.obsidian/hotkeys.json
docs/.obsidian/core-plugins.json
docs/.obsidian/community-plugins.json

# Maar WEL committen:
# docs/.obsidian/app.json (basis settings)
# docs/.obsidian/appearance.json (theme settings)
```

### Stap 4: Starter Bestanden

Maak deze bestanden om te beginnen:

**docs/README.md:**

```markdown
# Roguelite Game Documentation

## Navigatie
- 📋 [Game Design](01-Game-Design/) - Core mechanics, progression
- ⚙️ [Technical](02-Technical/) - Code architecture, performance  
- 🔄 [Development](03-Development/) - Planning, meetings, tasks
- 🔍 [Research](04-Research/) - References, inspiration

## Quick Links
- [[Core-Mechanics]] - Gameplay fundamentals
- [[Code-Architecture]] - Technical overview
- [[Sprint-Planning]] - Current development focus

---
*Last updated: [datum]*
```

## Workflow Voordelen

### Voor Development:

```bash
# Start development sessie
git pull                    # Krijg alle updates (code + docs)
                           # Open Godot + Obsidian tegelijk
                           # Code in Godot, notes in Obsidian

# Einde sessie  
git add .                  # Voeg code ÉN docs toe
git commit -m "Added player dash + documented mechanic"
git push                   # Push alles tegelijk
```

### Voor Game Design:

- **Design decision** → direct documenteren in Obsidian
- **Code implementation** → link naar specific files/scenes
- **Playtesting notes** → direct bij relevante mechanics

## Smart Linking Strategies

### Godot → Obsidian Links

```markdown
# Player Movement Mechanic

## Implementation
- Script: `scripts/player/PlayerController.gd`
- Scene: `scenes/player/Player.tscn`
- Related: [[Jump-Mechanics]], [[Dash-System]]

## Design Notes
- Movement should feel responsive but not overpowered
- Dash cooldown balances mobility vs strategy
```

### Cross-Reference System

```markdown
# Code Architecture

## Player Systems
- [[Player-Movement]] → `PlayerController.gd`
- [[Player-Combat]] → `CombatSystem.gd` 
- [[Player-Progression]] → `ProgressionManager.gd`

## Game Systems  
- [[Level-Generation]] → `LevelGenerator.gd`
- [[Enemy-AI]] → `enemies/` folder
```

## Jade Collaboration

### Setup Voor Jade:

```bash
# Clone hele project (code + docs)
git clone https://github.com/jouw-username/roguelite-game.git

# Open Godot project normaal
# Open Obsidian → Open folder as vault → selecteer /docs/ folder
```

### Collaborative Workflow:

1. **Morning sync:** `git pull` (krijgt code + docs updates)
2. **Work session:** Godot voor code, Obsidian voor docs
3. **Evening sync:** `git commit` voor beide, `git push`

## Mobile Access (Bonus)

### GitHub Mobile:

- Browse naar `your-repo/docs/`
- Lees alle markdown files direct
- Perfect voor onderweg referenties

### Obsidian Mobile:

- Clone repo naar phone (via Git app)
- Open Obsidian mobile → vault in `/docs/` folder

## Best Practices

### File Naming:

```markdown
# ✅ Goed
Player-Movement.md
Combat-System.md  
Level-01-Design.md

# ❌ Vermijd
player movement.md (spaties)
combat.md (te algemeen)
```

### Git Commit Messages:

```bash
# Code + docs samen
"Added dash mechanic + documented design decisions"
"Fixed player collision + updated technical notes" 
"Refactored enemy AI + added behavior documentation"
```

### Cross-References:

```markdown
# In je docs, link naar code:
Implementation: `scripts/player/PlayerMovement.gd:45-67`

# In je code comments, link naar docs:
# See docs/01-Game-Design/Player-Movement.md for design rationale
```

## Troubleshooting

### Merge Conflicts:

- **Code conflicts:** Resolve in VS Code/Godot
- **Docs conflicts:** Resolve in Obsidian of VS Code
- **Beide tegelijk:** Handle systematically

### Large Binary Files:

```gitignore
# In je .gitignore voor docs:
docs/assets/*.png
docs/assets/*.jpg
# Link naar online images waar mogelijk
```

---

**Result:** Één repository, alles gesynchroniseerd, professionele workflow! 🚀