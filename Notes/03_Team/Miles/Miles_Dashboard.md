# 👨‍💻 Miles Dashboard

## 📋 My Current Tasks
<!-- Embed from sprint board -->
### This Sprint
- [ ] #11 Refactor project structure
- [ ] #12 Setup neon shader system
- [ ] #13 Implement player movement (WASD + Controller)
- [ ] Setup feature branch workflow

### Blocked/Waiting
- [ ] Waiting for Jade's art style confirmation for shader parameters

---

## 🔗 Quick Links

### Development
- [[Git_Workflow|Git Commands & Workflow]]
- [[Godot_Best_Practices|Godot Best Practices]]
- [[Performance_Guidelines|Performance Optimization]]
- [[Architecture_Overview|System Architecture]]

### Current Focus
- [[Neon_Prototype_Spec|Neon System Design]]
- [[Player_Movement_Design|Movement Mechanics]]

### References
- [Godot Shaders Docs](https://docs.godotengine.org/en/stable/tutorials/shaders/index.html)
- [GDScript Style Guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)

---

## 📝 Recent Notes & Decisions

### 2024-12-19 - Project Structure
- Decided on feature branch workflow
- Will use `feature/` prefix for all feature branches
- Main branch = stable, dev branch = integration

### Code Standards Agreed
```gdscript
# Use static typing
var player_speed: float = 300.0
var health: int = 100

# Component-based architecture
# Small functions (<20 lines)
# Clear naming conventions
```

---

## 🎯 Learning Goals This Sprint
- [ ] Master Godot's shader system
- [ ] Understand performance profiling
- [ ] Learn GitHub Issues workflow with Jade

---

## 💭 Ideas & Experiments
- Try compute shaders for mass enemy rendering?
- Particle pooling system for neon trails
- Dynamic music intensity based on enemy count

---

## 📊 Performance Benchmarks
| Test | Target | Current | Status |
|------|--------|---------|--------|
| FPS (100 enemies) | 60 | TBD | 🔄 |
| Memory usage | <500MB | TBD | 🔄 |
| Load time | <3s | TBD | 🔄 |

---

## 🗓️ Schedule & Availability
- **Mornings**: ❌ Not available
- **Afternoons**: ✅ Focus time (14:00-18:00)
- **Evenings**: ✅ Available for collaboration

---

*[[HOME|← Back to Home]] | [[Jade_Dashboard|View Jade's Dashboard →]]*