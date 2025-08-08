# 📐 CLASS DIAGRAM GUIDE - OOP Principles

## Voor Miro Setup

### 1. Maak Miro Board
- Titel: "Roguelite Class Architecture"
- Sections:
  - Core Classes
  - Components
  - Systems
  - Inheritance Tree

## 2. Class Diagram Requirements

### Volgens de assignment moet je tonen:
✅ **Correct verbindingen** tussen classes
✅ **Inheritance** relaties (extends)
✅ **Composition** relaties (has-a)
✅ **Properties** met types
✅ **Methods** met public/private

## 3. Basis Structure voor Roguelite

```mermaid
classDiagram
    Node <|-- Node2D
    Node2D <|-- GameObject
    GameObject <|-- Entity
    Entity <|-- Player
    Entity <|-- Enemy
    GameObject <|-- Projectile
    GameObject <|-- Pickup
    
    Player *-- HealthComponent
    Player *-- MovementComponent
    Player *-- InputComponent
    Player *-- AbilitySystem
    
    Enemy *-- HealthComponent
    Enemy *-- MovementComponent
    Enemy *-- AIComponent
    Enemy *-- AttackComponent
    
    class GameObject {
        #Vector2 position
        #float rotation
        #bool active
        +activate()
        +deactivate()
        #_ready()
        #_process(delta)
    }
    
    class Entity {
        #int max_health
        #int current_health
        #float speed
        #String entity_type
        +take_damage(amount: int)
        +heal(amount: int)
        +move(direction: Vector2)
        +die()
        -_calculate_damage(base: int)
    }
    
    class Player {
        -InputComponent input
        -AbilitySystem abilities
        +Vector2 aim_direction
        +handle_input()
        +use_ability(index: int)
        +upgrade(upgrade: Upgrade)
    }
    
    class Enemy {
        -AIComponent ai
        -float attack_range
        -int damage
        +set_target(target: Node2D)
        +attack()
        -_follow_target()
        -_check_attack_range()
    }
```

## 4. Component System (Composition)

```mermaid
classDiagram
    class Component {
        <<abstract>>
        #Node owner
        +initialize(owner: Node)
        +process(delta: float)
    }
    
    class HealthComponent {
        -int max_health
        -int current_health
        +signal died
        +signal health_changed
        +take_damage(amount: int)
        +heal(amount: int)
        +get_health_percentage() float
    }
    
    class MovementComponent {
        -float speed
        -float acceleration
        -Vector2 velocity
        +move(direction: Vector2)
        +apply_knockback(force: Vector2)
        -_apply_friction(delta: float)
    }
    
    class AIComponent {
        -Node2D target
        -float detection_range
        -String ai_state
        +set_target(target: Node2D)
        +update_ai(delta: float)
        -_calculate_path()
        -_check_line_of_sight()
    }
    
    Component <|-- HealthComponent
    Component <|-- MovementComponent
    Component <|-- AIComponent
```

## 5. System Classes

```mermaid
classDiagram
    class GameManager {
        <<Singleton>>
        -static GameManager instance
        -int current_wave
        -int score
        -float game_time
        +start_game()
        +end_game()
        +add_score(points: int)
        +get_instance() GameManager
    }
    
    class SpawnManager {
        <<Singleton>>
        -Array~Enemy~ enemy_pool
        -float spawn_rate
        -int enemies_per_wave
        +spawn_wave(wave_number: int)
        +get_enemy_from_pool() Enemy
        -_calculate_spawn_position() Vector2
    }
    
    class UpgradeManager {
        <<Singleton>>
        -Array~Upgrade~ available_upgrades
        -Dictionary active_upgrades
        +get_random_upgrades(count: int)
        +apply_upgrade(upgrade: Upgrade)
    }
```

## 6. Miro Formatting Tips

### Colors
- **Base classes**: Light blue
- **Game objects**: Green
- **Components**: Yellow
- **Managers**: Purple
- **Abstract**: Italic text

### Connections
- **Inheritance**: Solid arrow (△)
- **Composition**: Diamond arrow (◇)
- **Association**: Simple line (—)
- **Dependency**: Dashed arrow (-->)

### Visibility
- `+` Public
- `-` Private
- `#` Protected
- `~` Package

## 7. Export voor Assignment

1. Screenshot vanuit Miro
2. Export als PNG/PDF
3. Voeg toe aan documentatie
4. Commit: `docs: add OOP class diagram`

## 8. Checklist voor Assignment

- [ ] Alle classes hebben properties
- [ ] Alle classes hebben methods
- [ ] Public/private is aangegeven
- [ ] Inheritance relaties zijn duidelijk
- [ ] Composition relaties zijn duidelijk
- [ ] Types zijn gespecificeerd
- [ ] Diagram is leesbaar
- [ ] Voldoet aan OOP principles

## 9. Voor Claude Code Prompt

```markdown
Generate the base class structure from this diagram:
- GameObject base class
- Entity extends GameObject
- Player and Enemy extend Entity
- All components as separate classes
- Include all properties and methods as shown
- Follow Godot 4.3 best practices
```

---

*Gebruik dit als guide voor je Miro class diagram!*