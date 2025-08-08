# 🤖 Claude Code & AI Workflow Setup

## 📌 Wat is Claude Code?

Claude Code is een command-line tool die je direct vanuit je terminal AI-powered coding hulp geeft. Perfect voor:
- **Code generation**: Complete systems schrijven
- **Debugging**: Bugs vinden en fixen
- **Code review**: Pull requests checken
- **Refactoring**: Code verbeteren
- **Documentation**: Comments en docs genereren

## 🚀 Installation & Setup

### 1. Prerequisites
```bash
# Check of je Node.js hebt (v18+)
node --version

# Zo niet, installeer via:
# Windows: Download van nodejs.org
# Mac: brew install node
# Linux: sudo apt install nodejs
```

### 2. Claude Code Installeren
```bash
# Global install
npm install -g claude-code

# Verify installation
claude-code --version
```

### 3. API Key Setup
```bash
# Get API key van: https://console.anthropic.com
# Set environment variable

# Windows (PowerShell):
$env:ANTHROPIC_API_KEY = "sk-ant-..."

# Mac/Linux:
export ANTHROPIC_API_KEY="sk-ant-..."

# Of maak .env file in project root:
echo "ANTHROPIC_API_KEY=sk-ant-..." > .env
```

## 📁 Project Configuration

### 1. Initialize in Project
```bash
cd /path/to/roguelite-game
claude-code init

# Dit maakt:
# - .claude-code/config.json
# - .claudeignore
# - .claude-instructions
```

### 2. Configure voor Godot (.claude-code/config.json)
```json
{
  "project": {
    "name": "Roguelite Game",
    "type": "godot-game",
    "language": "gdscript",
    "version": "4.3"
  },
  "preferences": {
    "codeStyle": "godot-standard",
    "maxTokens": 4000,
    "temperature": 0.7
  },
  "context": {
    "includeFiles": [
      "*.gd",
      "*.tscn",
      "*.tres",
      "project.godot"
    ],
    "excludePatterns": [
      ".godot/**",
      "*.tmp",
      "builds/**"
    ]
  },
  "features": {
    "autoReview": true,
    "performanceCheck": true,
    "securityScan": false
  }
}
```

### 3. Project Instructions (.claude-instructions)
```markdown
# Roguelite Game - AI Assistant Instructions

## Project Overview
- Game Type: Top-down roguelite (Brotato/Vampire Survivors inspired)
- Engine: Godot 4.3
- Language: GDScript with static typing
- Target: 60 FPS with 100+ enemies on screen

## Code Standards

### GDScript Style:
- Use static typing: `var health: int = 100`
- Signals for communication between nodes
- Composition over inheritance
- Small functions (<20 lines)

### Performance Priorities:
1. Object pooling for enemies/projectiles
2. Efficient collision detection (layers)
3. Sprite batching where possible
4. LOD system for distant enemies

### Architecture:
- Scene structure: Scenes are components
- Autoload for: GameManager, InputManager, AudioManager
- State machines for: Player states, Enemy AI
- Event bus pattern for global events

## Current Focus
- Week 1: Foundation (movement, basic systems)
- Week 2: Combat mechanics
- Week 3: Enemy variety and upgrades
- Week 4: Polish and optimization

## Team Context
- Miles: Programming lead, systems architecture
- Jade: Art lead, ability design
- Both: Learning and experimenting

## AI Assistance Priorities
1. Performance optimization suggestions
2. Clean code architecture
3. Godot best practices
4. Bug prevention
5. Multiplayer-ready structure (future)
```

### 4. Ignore Patterns (.claudeignore)
```
# Godot
.godot/
.import/
*.tmp

# Builds
export_presets.cfg
builds/
*.exe
*.pck
*.zip

# Version Control
.git/
.gitignore

# IDE
.vscode/
.idea/
*.code-workspace

# OS
.DS_Store
Thumbs.db
desktop.ini

# Large Assets (tijdens development)
*.psd
*.blend
*.wav
*.mp3
```

## 🎮 Gebruik voor Game Development

### 1. Code Generation
```bash
# Generate een enemy spawn system
claude-code generate "enemy spawn system with waves and difficulty scaling"

# Generate met specifieke requirements
claude-code generate --file scripts/systems/SpawnManager.gd \
  "spawn system that handles 100+ enemies with object pooling"

# Generate from template
claude-code generate --template roguelite-spawner \
  "wave-based spawner with 5 enemy types"
```

### 2. Debugging
```bash
# Debug een specific probleem
claude-code debug "player gets stuck in walls"

# Debug een file
claude-code debug scripts/player/PlayerController.gd \
  --issue "movement feels sluggish"

# Debug met context
claude-code debug --include-scenes \
  "enemies not spawning after wave 3"
```

### 3. Code Review
```bash
# Review een file
claude-code review scripts/systems/UpgradeSystem.gd

# Review voor performance
claude-code review --focus performance \
  scripts/enemies/EnemyAI.gd

# Review een pull request
claude-code review --pr feature/ability-system

# Batch review
claude-code review scripts/**/*.gd --output review-report.md
```

### 4. Refactoring
```bash
# Refactor voor betere structure
claude-code refactor scripts/player/Player.gd \
  --improve "split into components"

# Refactor voor performance
claude-code refactor --optimize-for "mobile" \
  scripts/systems/ParticleManager.gd

# Extract methods
claude-code refactor --extract-methods \
  scripts/GameManager.gd
```

### 5. Documentation
```bash
# Generate docs voor een file
claude-code document scripts/systems/UpgradeSystem.gd

# Generate project README
claude-code document --readme

# Generate API documentation
claude-code document --api scripts/**/*.gd \
  --output docs/api.md
```

## 🔧 Advanced Features

### Custom Commands (.claude-code/commands.json)
```json
{
  "commands": {
    "optimize-enemy": {
      "description": "Optimize enemy script for performance",
      "template": "Review this enemy script for performance issues, especially for 100+ instances",
      "files": ["scripts/enemies/*.gd"]
    },
    "add-ability": {
      "description": "Add new ability to the game",
      "template": "Create a new ability with cooldown, visual effects, and upgrade path",
      "output": "scripts/abilities/",
      "params": ["name", "type", "cooldown"]
    },
    "balance-check": {
      "description": "Check game balance",
      "template": "Analyze damage values, health, and difficulty progression",
      "files": ["data/balance/*.json"]
    }
  }
}
```

Gebruik:
```bash
claude-code optimize-enemy EnemySwarm.gd
claude-code add-ability "Lightning Strike" "area" "5.0"
claude-code balance-check
```

### Git Hooks Integration
```bash
# .git/hooks/pre-commit
#!/bin/sh
claude-code review --staged --quick
if [ $? -ne 0 ]; then
  echo "Claude Code found issues. Fix before committing."
  exit 1
fi
```

### VS Code Integration
```json
// .vscode/tasks.json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Claude Review Current File",
      "type": "shell",
      "command": "claude-code review ${file}",
      "group": "test",
      "problemMatcher": []
    },
    {
      "label": "Claude Debug Selection",
      "type": "shell", 
      "command": "claude-code debug --selection '${selectedText}'",
      "group": "test"
    },
    {
      "label": "Claude Generate Function",
      "type": "shell",
      "command": "claude-code generate --append ${file} '${input:functionDescription}'",
      "group": "build"
    }
  ]
}
```

## 📊 Performance Monitoring

### Setup Performance Tracking
```bash
# Create performance baseline
claude-code performance --baseline

# Check current performance
claude-code performance --compare

# Get optimization suggestions
claude-code performance --suggest scripts/systems/
```

## 🎯 Workflow Examples

### Daily Development Flow
```bash
# Morning: Check wat je gaat bouwen
claude-code plan "implement dash ability with particles"

# During: Generate code
claude-code generate scripts/abilities/DashAbility.gd

# Debug issues
claude-code debug "dash goes through walls"

# Before commit: Review
claude-code review --staged

# End of day: Document
claude-code document --today
```

### Feature Development
```bash
# 1. Plan feature
claude-code plan "upgrade system with 20 upgrades"

# 2. Generate structure
claude-code scaffold upgrade-system

# 3. Implement
claude-code generate scripts/systems/UpgradeManager.gd

# 4. Test & Debug
claude-code test scripts/systems/UpgradeManager.gd

# 5. Optimize
claude-code optimize scripts/systems/UpgradeManager.gd

# 6. Document
claude-code document scripts/systems/UpgradeManager.gd
```

## ⚠️ Best Practices

### DO's:
- ✅ Review generated code before using
- ✅ Test in isolation first
- ✅ Keep context files updated
- ✅ Use for complex algorithms
- ✅ Let it handle boilerplate

### DON'Ts:
- ❌ Blindly trust all suggestions
- ❌ Generate entire game at once
- ❌ Skip testing generated code
- ❌ Ignore Godot conventions
- ❌ Share API key in repository

## 🆘 Troubleshooting

### Issue: "API Key not found"
```bash
# Check if set
echo $ANTHROPIC_API_KEY

# Set permanently (Windows)
setx ANTHROPIC_API_KEY "sk-ant-..."

# Set permanently (Mac/Linux)
echo 'export ANTHROPIC_API_KEY="sk-ant-..."' >> ~/.bashrc
source ~/.bashrc
```

### Issue: "Context too large"
```bash
# Reduce context size
claude-code config set maxTokens 2000

# Exclude large files
echo "*.png" >> .claudeignore
echo "*.ogg" >> .claudeignore
```

### Issue: "Timeout errors"
```bash
# Increase timeout
claude-code config set timeout 60

# Use streaming
claude-code generate --stream "complex system"
```

## 📚 Resources

- [Claude Code Docs](https://docs.anthropic.com/claude-code)
- [Godot + AI Workflow](https://godotengine.org/article/ai-assisted-development)
- [Team's Discord Channel](https://discord.gg/roguelite-dev)

---

*💡 Pro Tip: Start klein, test veel, itereer snel!*