# CLAUDE.md

Claude-specific guidance for working with TheCaves project.

## Communication Preferences
- **Language**: Always communicate in Dutch (Nederlands) with the user
- **Screenshots**: Always open and read screenshots from the repository path when provided by user

## Project Overview

**TheCaves**: Top-down roguelite (Brotato-inspired) built with Godot 4.3
**Target**: 60 FPS with 100+ enemies simultaneous  
**Language**: GDScript with static typing  
**Team**: Miles (Code) & Jade (Art)

## Critical Development Requirements

### Context7 Mandatory Usage
**ALWAYS use Context7 for ALL Godot-related tasks** - debugging, planning, coding, troubleshooting:
- **Primary library**: `/godotengine/godot-docs` - Official docs (13k+ snippets, Trust 9.9)
- **Usage**: `mcp__context7__get-library-docs` with specific topics before ANY Godot work
- **Scope**: Required for debugging, implementation planning, coding, error resolution, pattern verification
- **Purpose**: Ensure official patterns, avoid deprecated APIs, get up-to-date solutions

### Godot MCP Server
**🚨 CRITICAL**: Always use relative path `"."` for projectPath parameter in WSL2

**Key MCP Tools**:
- `run_project`, `stop_project`, `get_debug_output` - Debug workflow
- `add_node`, `create_scene` - Scene editing  
- `get_project_info`, `launch_editor` - Project management

## 🚨 CRITICAL: Debug Project Management

**MANDATORY WORKFLOW**: Always stop existing debug projects before starting new ones to prevent multiple debug instances accumulating.

```bash
# ALWAYS follow this sequence:
mcp__godot-mcp__stop_project              # Stop any existing
mcp__godot-mcp__run_project projectPath: "."     # Start new debug
mcp__godot-mcp__get_debug_output          # Check output
mcp__godot-mcp__stop_project              # Stop when done
```

**Problem Prevention**: Multiple "TheCaves (DEBUG)" windows cause memory leaks and confusion.
**Emergency Cleanup**: Use `./simple-cleanup.sh` and select "all" to preserve only the editor.  

## Performance Requirements
- **Target**: 60 FPS stable with 100-150 enemies + 200-300 projectiles
- **Memory**: < 500MB RAM, < 5000 collision pairs
- **Test requirement**: Always validate with 150 enemies + 200 projectiles

## Core Architecture Principles
1. **Object Pooling** - Pool all spawnable objects (enemies, projectiles, particles)
2. **Component-Based** - Use composition over inheritance for flexible upgrades
3. **Event-Driven** - EventBus for decoupled system communication  
4. **LOD System** - Distance-based performance scaling for enemies
5. **Static Typing** - Required for performance and maintainability

## Essential Coding Standards
- Cache node references: `@onready var player = get_node("/Player")`
- Use `distance_squared_to()` for distance comparisons (avoid sqrt)
- Never `instantiate()` during gameplay - use pools only
- No inter-enemy collision (performance killer)

## Documentation References
Detailed implementations available in:
- `Notes/06_Development_Guides/Godot_Best_Practices.md`
- `Notes/06_Development_Guides/Performance_Guidelines.md`  
- `Notes/PROJECT_INSTRUCTIONS.md` - Current focus
- `Notes/01_Design/Game_Design_Document.md` - Game mechanics