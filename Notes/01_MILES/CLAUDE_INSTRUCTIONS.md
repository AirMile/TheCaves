# 🤖 CLAUDE INSTRUCTIONS - Roguelite Project

## Voor jou om aan te passen in Claude settings:

### Project Context
```
Project: Roguelite game (Brotato/Vampire Survivors inspired)
Team: Miles (tech lead) & Jade (art lead)
Engine: Godot 4.3
Language: GDScript with static typing
Target: 60 FPS with 100+ enemies
Timeline: August 2025 intensive, then 1 day/week
Work hours: Flexible (afternoons/evenings, not mornings)
Communication: Discord (NOT WhatsApp)
```

### Tools & Platforms
```
Version Control: Git/GitHub (public repo for Claude Code)
Task Management: Trello (color-coded priorities)
Visual Planning: Miro (moodboards, concepts)
Documentation: Obsidian (this vault)
Art Tools: Aseprite/Krita/Procreate
IDE: VS Code with Godot extensions
AI Assistant: Claude Code
Speech-to-text: Voicy (sometimes inaccurate)
```

### Code Conventions
```
Commit format: type: description
  - feat: new feature
  - fix: bug fix
  - art: art assets
  - docs: documentation
  - perf: performance
  - refactor: code restructuring

Branch naming:
  - feature/player-movement
  - art/enemy-sprites
  - fix/collision-bug

File naming:
  - Sprites: entity_name_state_size.png
  - Scripts: snake_case.gd
  - Scenes: PascalCase.tscn

GDScript style:
  - Static typing: var health: int = 100
  - Private with underscore: func _process()
  - Signals: signal health_changed
  - Small functions (<20 lines)
```

### Communication Preferences
```
Language: Nederlands with English technical terms
Code comments: English
Error handling: Solution first, then explanation
Updates: Daily via Discord templates
Documentation: Always in Markdown
Code generation: Complete functional files
```

### Technical Requirements
```
ALWAYS consider:
- Performance for 100+ enemies (object pooling)
- Component-based architecture
- Multiplayer-ready structure
- Controller + keyboard input
- Mobile performance (future)

Key patterns:
- Object pooling for enemies/projectiles
- LOD system for distant enemies
- State machines for AI
- Event bus for decoupling
- Composition over inheritance
```

### Art Guidelines
```
Style: Neon cave painting aesthetic
Background: Very dark (near black)
Sprites: 32x32 baseline (testing 16/32/64)
Animations: 10-12 FPS, 4-8 frames
Glow: Built-in Godot, custom shaders later
Format: PNG transparent, power-of-2 dimensions
Pipeline: Concept → Pixel art → Animation → Export
```

### Update Workflow
```
Daily updates:
1. Miles uses speech-to-text templates
2. Sends to Claude: "Update vault with [template]"
3. Claude updates all relevant files
4. Posts summary in Discord format

Auto-updates:
- TODO.md status changes
- Daily_Updates/ new files
- Known issues documentation
- Progress metrics
```

### Trello Color System
```
Cover colors (priority):
- Red: CRITICAL (today/tomorrow)
- Orange: IMPORTANT (this week)
- Yellow: SHOULD DO (this sprint)
- Green: COULD DO (if time)
- Grey: NICE TO HAVE (bonus)

Labels (time estimates):
- Grey: 15 minutes
- Green: 1 hour
- Yellow: 1 day
- Orange: 3 days
- Red: 5+ days
```

### Project Boundaries
```
August MUST have:
- Playable 10-15 minute runs
- 3+ enemy types
- Basic upgrade system
- Auto-attack + manual ability
- Stable 60 FPS

NOT in August:
- Multiplayer
- Steam integration
- Multiple characters
- Procedural generation
- Perfect balance
```

### Speech-to-Text Corrections
```
Common Voicy errors to auto-correct:
- "road light" → "roguelite"
- "cloud" → "Claude"
- Formatting issues (nieuwe regel, etc)
- Dutch/English mixing

Keep original if unclear, note [?] for review
```

### File Organization
```
Always use numbered folders:
- 00_START/ (general info)
- 01_MILES/ (Miles-specific)
- 02_JADE/ (Jade-specific)
- 03_SHARED/ (team shared)

Templates in Templates/
Guides in Development_Guides/
Daily updates in Daily_Updates/YYYY-MM-DD.md
```

### Response Style
```
For Miles:
- Direct, practical solutions
- Code examples when relevant
- Performance considerations
- Git commands included
- Dutch with English terms

For documentation:
- Clear headers
- Code blocks with language
- Bullet points for lists
- Tables for comparisons
- Emoji for visual clarity
```

### Context File Usage
```
Location: .claude-context
Update: When project status changes
Include: In every new conversation
Command: "Update context" triggers update
Keep: Under 500 lines
```

### Important URLs
```
These will exist after setup:
- GitHub: github.com/[username]/roguelite
- Trello: trello.com/b/[board-id]
- Miro: miro.com/app/board/[board-id]
- Discord: [private server invite]
```

---

## COPY THIS TO CLAUDE CUSTOM INSTRUCTIONS:

You are assisting with a Godot 4.3 roguelite game project. The team works flexibly (afternoons/evenings), uses Discord for communication, and Obsidian for documentation. 

**IMPORTANT**: 
- Use filesystem MCP for all file operations in: C:\Users\mzeil\Documents\Notes 2025\Roguelite
- This directory will later change to the game repository
- Miles uses Voicy speech-to-text which makes errors - auto-correct obvious mistakes
- Always respond in Dutch with English technical terms

Key technical requirements:
- Optimize for 100+ enemies using object pooling
- Component-based architecture
- Controller + keyboard support from day 1
- 32x32 pixel sprites with neon glow aesthetic

When receiving updates via speech-to-text templates:
1. Update relevant documentation files using filesystem MCP
2. Maintain TODO.md status
3. Create daily update files
4. Format for Discord posting
5. Auto-correct Voicy errors (road light → roguelite, etc.)

Provide complete, functional code examples. Consider performance in every suggestion.

---

*Paste everything above into your Claude project settings!*