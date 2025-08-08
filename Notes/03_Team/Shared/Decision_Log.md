# 📋 Decision Log - Important Project Decisions

This document tracks all important technical and design decisions made during development.

---

## 2024-12-19: Project Refactoring

### Decision: Restructure Obsidian Vault
**Context**: Original structure was messy and hard to navigate
**Decision**: Implement numbered folder structure with clear separation
**Rationale**: 
- Better organization for growing project
- Clear separation between team members
- Easier to find documents

**Impact**: 
- All team members need to update bookmarks
- Links in documents need updating

---

## 2024-12-19: Version Control Strategy

### Decision: Use Feature Branches
**Context**: Both team members new to branching
**Options Considered**:
1. Work directly on main
2. Single dev branch
3. Feature branches

**Decision**: Feature branches with naming convention `feature/[name]`
**Rationale**:
- Prevents breaking main branch
- Allows parallel development
- Good learning opportunity

**Impact**:
- Slightly more complex workflow
- Need to learn pull requests
- Better code quality control

---

## 2024-12-18: Visual Style Direction

### Decision: Neon Cave Paintings Aesthetic
**Context**: Need unique visual identity
**Options Considered**:
1. Pixel art retro
2. Hand-drawn style
3. Neon glow effects

**Decision**: Neon glowing cave paintings on dark background
**Rationale**:
- Unique aesthetic
- Good for gameplay clarity
- Matches psychedelic mood goal

**Impact**:
- Performance considerations for glow
- Need shader expertise
- Art pipeline more complex

---

## 2024-12-17: Technology Stack

### Decision: Godot 4.3 over Unity
**Context**: Choosing game engine
**Options Considered**:
1. Unity
2. Godot
3. Custom engine

**Decision**: Godot 4.3
**Rationale**:
- Better 2D renderer for our needs
- Open source, no licensing
- Better for learning
- Good shader support for neon effects

**Impact**:
- Team needs to learn GDScript
- Less tutorials available
- Better performance for 2D

---

## 2024-12-16: Team Roles

### Decision: Hybrid Roles (Both Do Art & Code)
**Context**: Small team of 2 people
**Options Considered**:
1. Strict separation (Miles code, Jade art)
2. Both do everything equally
3. Lead roles with flexibility

**Decision**: Lead roles with flexibility
- Miles: Code lead, but does some art
- Jade: Art lead, but learns coding

**Rationale**:
- More fun and engaging
- Better learning opportunity
- Prevents bottlenecks

**Impact**:
- Need good communication
- Potential style inconsistencies
- More complex planning

---

## Template for New Decisions

```markdown
## [Date]: [Decision Title]

### Decision: [What was decided]
**Context**: [Why decision was needed]
**Options Considered**:
1. [Option 1]
2. [Option 2]
3. [Option 3]

**Decision**: [Final choice]
**Rationale**: [Why this option]

**Impact**: 
- [Impact 1]
- [Impact 2]
```

---

## Decision Categories

### 🎨 Design Decisions
- Visual style ✅
- Game mechanics 🔄
- UI/UX approach 📅

### 💻 Technical Decisions
- Engine choice ✅
- Architecture patterns 🔄
- Performance targets 🔄

### 👥 Process Decisions
- Team roles ✅
- Git workflow ✅
- Communication tools 🔄

---

*Legend: ✅ Decided | 🔄 In Discussion | 📅 Planned*

---

*[[HOME|← Back to Home]] | [[03_Team/Shared|← Back to Shared]]*