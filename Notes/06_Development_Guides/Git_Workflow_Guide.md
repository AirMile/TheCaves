# 🌳 Git Workflow Guide - Roguelite Project

## 📌 Waarom Branches Gebruiken?

### Het Probleem Zonder Branches
Stel je voor: Jade werkt aan het ability system, jij aan enemy AI. Zonder branches:
- Jullie code botst constant
- Een bug van Jade breekt jouw enemy system
- Je kunt niet terug naar een werkende versie
- Merge conflicts elke keer als jullie pullen

### De Oplossing Met Branches
- **Isolatie**: Ieder werkt in eigen "sandbox"
- **Veiligheid**: Main branch blijft altijd stabiel
- **Review**: Check elkaars code voor het mergen
- **Rollback**: Makkelijk terug naar vorige versie

## 🏗️ Branch Structuur

```
main                    # ← Productie versie (altijd werkend!)
│
└── dev                 # ← Ontwikkel versie (hier merge je features)
    ├── feature/player-movement     # Miles werkt hieraan
    ├── feature/ability-system      # Jade werkt hieraan
    ├── feature/enemy-ai           # Miles later
    └── fix/performance-glow        # Bugfixes
```

## 📝 Stap-voor-Stap Workflow

### 1️⃣ Project Setup (Eerste keer)
```bash
# Clone de repository
git clone https://github.com/[username]/roguelite-game.git
cd roguelite-game

# Maak dev branch aan
git checkout -b dev
git push -u origin dev

# Stel dev als default branch in op GitHub
# (Via GitHub settings → Branches → Default branch)
```

### 2️⃣ Nieuwe Feature Starten
```bash
# Zorg dat je op dev bent
git checkout dev
git pull origin dev

# Maak nieuwe feature branch
git checkout -b feature/player-movement

# Nu kun je coderen!
```

### 3️⃣ Tijdens Het Werken (Dagelijks)
```bash
# Check welke files je hebt aangepast
git status

# Stage je changes
git add .

# Commit met duidelijke message
git commit -m "feat: add WASD movement with acceleration"

# Push naar GitHub
git push origin feature/player-movement
```

### 4️⃣ Code Klaar? Maak een Pull Request

#### Via GitHub Website:
1. Ga naar jullie repository
2. Klik "Pull requests" → "New pull request"
3. Base: `dev` ← Compare: `feature/player-movement`
4. Voeg beschrijving toe:
```markdown
## Wat doet deze PR?
- Implementeert WASD movement
- Voegt acceleration/deceleration toe
- Controller support voor movement

## Testing
- [x] Getest met keyboard
- [x] Getest met controller
- [x] Geen bugs gevonden

## Screenshots
[Voeg GIF toe van movement]
```

### 5️⃣ Review Process
```bash
# Jade checkt jouw code
# Ze kan comments toevoegen
# Als alles OK is → Merge!

# Na merge, lokaal updaten:
git checkout dev
git pull origin dev
git branch -d feature/player-movement  # Delete oude branch
```

## 🏷️ Commit Message Conventies

### Format: `type: description`

**Types:**
- `feat:` Nieuwe feature
- `fix:` Bug fix
- `docs:` Documentatie
- `style:` Code formatting (geen functionaliteit)
- `refactor:` Code restructuring
- `perf:` Performance verbetering
- `test:` Test toevoegen
- `chore:` Maintenance (git ignore, etc)

### Voorbeelden:
```bash
git commit -m "feat: add dash ability with cooldown"
git commit -m "fix: player stuck in wall collision"
git commit -m "docs: update README with controls"
git commit -m "perf: optimize glow shader rendering"
git commit -m "refactor: split player.gd into components"
```

## 🔄 Daily Workflow Voorbeeld

### Ochtend
```bash
# Start je dag met verse code
git checkout dev
git pull origin dev
git checkout feature/jouw-feature
git merge dev  # Krijg laatste updates
```

### Avond
```bash
# Commit je werk
git add .
git commit -m "feat: progress on enemy spawning"
git push origin feature/jouw-feature

# Maak PR als feature klaar is
```

## ⚠️ Merge Conflicts Oplossen

Als Git zegt "CONFLICT":

```bash
# 1. Open het conflict bestand
# Je ziet dit:
<<<<<<< HEAD
jouw code
=======
jade's code
>>>>>>> feature/other

# 2. Beslis wat te houden:
# - Houd jouw code
# - Houd Jade's code  
# - Combineer beide

# 3. Verwijder de markers (<<<<, ====, >>>>)

# 4. Commit de oplossing
git add .
git commit -m "fix: resolve merge conflict in player.gd"
```

### Godot-Specifieke Conflicts

**Common Godot Conflicts:**
1. **Scene files (.tscn)**: Vaak beter om scene opnieuw te maken
2. **Project settings (project.godot)**: Voorzichtig mergen, test beide settings
3. **Import files (.import)**: Meestal safe om te regenereren

**Prevention voor Godot:**
- Communiceer wie aan welke scenes werkt
- Vermijd simultane project.godot changes
- Gebruik prefabs/inherited scenes waar mogelijk

## 🤖 Claude Code Integration

### Setup voor PR Reviews
```bash
# In repository root, maak .claude-instructions
echo "Review deze PR voor:
- Performance issues
- Code quality
- Godot best practices
- Mogelijke bugs" > .claude-instructions

# Voor auto-review bij PR:
claude-code review --pr
```

### Voor Merge Assistance
```bash
# Als je merge conflicts hebt
claude-code merge --resolve

# Voor smart merging suggestions
claude-code merge --suggest
```

## 📋 Git Aliases (Snelle Commands)

Voeg toe aan `.gitconfig`:
```bash
[alias]
    st = status
    co = checkout
    br = branch
    cm = commit -m
    pu = push origin
    pl = pull origin
    feat = checkout -b feature/
    last = log -1 HEAD
```

Nu kun je typen:
```bash
git st                    # In plaats van: git status
git cm "fix: bug"        # In plaats van: git commit -m "fix: bug"
git feat player-dash     # In plaats van: git checkout -b feature/player-dash
```

## ❌ Wat NIET Te Doen

1. **NOOIT** direct op `main` pushen
2. **NOOIT** force push (behalve eigen feature branch)
3. **NOOIT** grote binary files committen (gebruik Git LFS)
4. **NOOIT** .godot/ folder committen
5. **NOOIT** passwords/API keys in code

## 🆘 Hulp Nodig?

### Verkeerde branch?
```bash
git stash              # Save je werk tijdelijk
git checkout dev       # Ga naar juiste branch
git stash pop         # Krijg je werk terug
```

### Verkeerde commit message?
```bash
git commit --amend -m "nieuwe message"
```

### Te veel commits? Squash ze:
```bash
git rebase -i HEAD~3   # Combineer laatste 3 commits
```

---

## 📚 Extra Resources

- [GitHub Flow Guide](https://guides.github.com/introduction/flow/)
- [Godot Git Plugin](https://github.com/godotengine/godot-git-plugin)
- [Git Cheat Sheet](https://education.github.com/git-cheat-sheet-education.pdf)

---

*💡 Tip: Print deze guide uit of houd 'm open tijdens development!*