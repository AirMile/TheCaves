# 📋 Trello Workflow Guide

## 🎨 Prioriteit Systeem (Cover Kleuren)

### Cover Kleur = Prioriteit Level
- 🔴 **Rood**: CRITICAL - Moet vandaag/morgen af
- 🟠 **Oranje**: IMPORTANT - Deze week
- 🟡 **Geel**: SHOULD DO - Deze sprint
- 🟢 **Groen**: COULD DO - Als tijd over
- ⚫ **Grijs**: NICE TO HAVE - Bonus features

## ⏱️ Label Systeem (Tijd Estimates)

### Label Kleur = Geschatte Tijd
- ⚫ **Grijs**: 15 minuten (Quick fix)
- 🟢 **Groen**: 1 uur (Small task)
- 🟡 **Geel**: 1 dag (Medium task)
- 🟠 **Oranje**: 3 dagen (Large task)
- 🔴 **Rood**: 5+ dagen (Epic task)

## 📊 Board Structuur

```
[Doing] → [This Week] → [This Month] → [To Do] → [Done]
   ↓           ↓             ↓            ↓         ↓
Max 2-3    Max 10-15     Backlog    Ice Box   Archive
```

### Lijst Definities:
1. **Doing**: Waar je NU aan werkt (max 2-3 cards)
2. **This Week**: Gepland voor deze week
3. **This Month**: Augustus planning
4. **To Do**: Algemene backlog
5. **Done**: Completed (archief na 1 week)

## 📝 Card Template

### Titel Format:
```
[COMPONENT] Korte beschrijving
Voorbeelden:
[PLAYER] Implement dash mechanic
[ENEMY] Add swarm AI behavior
[UI] Create upgrade selection screen
[ART] Design tank enemy sprite
[AUDIO] Implement dynamic music system
```

### Description Template:
```markdown
## Doel
Wat moet deze task bereiken?

## Acceptatie Criteria
- [ ] Criterium 1
- [ ] Criterium 2
- [ ] Criterium 3

## Technical Notes
Belangrijke implementatie details

## Dependencies
- Heeft X nodig van Jade
- Wacht op Y systeem

## Testing
- Test met keyboard
- Test met controller
- Test performance met 50+ enemies
```

## 🔄 Daily Workflow

### Ochtend (10:00)
1. Check **Doing** lijst
2. Als leeg → Pull van **This Week**
3. Update card status
4. Post in Discord: "Working on: [card naam]"

### Middag Check-in
1. Update progress in card comments
2. Als blocked → Voeg rode "BLOCKED" label toe
3. Tag teamlid als hulp nodig

### Avond (20:00)
1. Cards naar **Done** als compleet
2. Update tijd tracking
3. Plan voor morgen

## 🏷️ Standaard Labels

### Type Labels
- `bug` - Something broken
- `feature` - New functionality
- `enhancement` - Improvement
- `refactor` - Code cleanup
- `art` - Visual assets
- `audio` - Sound/music
- `documentation` - Docs/comments

### Status Labels
- `blocked` - Waiting on something
- `in-review` - Needs checking
- `needs-testing` - Test required
- `ready` - Ready to implement

### Platform Labels
- `pc` - PC specific
- `controller` - Controller specific
- `performance` - Performance related

## 📊 Sprint Planning

### Week Start (Maandag)
```markdown
1. Review vorige week
   - Wat is Done?
   - Wat loopt over?
   
2. Plan deze week
   - Move cards naar "This Week"
   - Check priorities (kleuren)
   - Tijd estimates checken
   
3. Dependencies check
   - Wie heeft wat nodig?
   - Blocking issues?
```

### Week End (Vrijdag)
```markdown
1. Sprint Review
   - Cards completed: X
   - Velocity: Y hours
   - Blockers encountered
   
2. Retrospective
   - Wat ging goed?
   - Wat kan beter?
   - Action items
```

## 🔗 Trello Power-Ups

### Nuttige Power-Ups:
1. **Card Numbers** - Voor references
2. **Card Size** - Zie complexity in een oogopslag
3. **Custom Fields** - Voor story points
4. **Calendar** - Deadline visualization

## 🤝 Team Collaboration

### Card Assignment
- Assign jezelf wanneer je start
- Co-assign voor pair programming
- @mention voor vragen

### Comments Gebruik
```markdown
**Progress Update**: 
Player movement done, starting on dash

**Blocker**: 
Need enemy sprite from Jade before continuing

**Question**:
@Jade Welke resolutie voor projectiles?

**Review Request**:
@Miles Can you check the collision logic?
```

## 📈 Metrics Tracking

### Weekly Metrics
- Cards completed
- Hours worked  
- Bugs found/fixed
- Features shipped

### Card Flow Time
- Created → Doing: Response time
- Doing → Done: Cycle time
- Blocked time: Wait time

## ⚡ Quick Actions

### Keyboard Shortcuts
- `Space` - Assign self
- `L` - Add label
- `D` - Due date
- `C` - Archive card
- `Q` - Quick filter
- `F` - Filter cards
- `W` - Watch card

### Automation Rules
```
When card moved to "Doing"
→ Assign to mover
→ Add "in-progress" label

When card moved to "Done"  
→ Add completion date
→ Remove "blocked" label

When "blocked" label added
→ Card turns red
→ Notify team
```

## 🚨 Red Flags

Watch out voor:
- Te veel cards in "Doing" (WIP limit)
- Cards langer dan 3 dagen in "Doing"
- Te veel rode (critical) cards
- Geen updates voor 2+ dagen
- Time estimates consistent te laag

## 💡 Best Practices

1. **One card = One deliverable**
2. **Update minstens 1x per dag**
3. **Screenshots in comments**
4. **Link GitHub commits**
5. **Move cards immediately**
6. **Review before archiving**

---

*🎯 Remember: Trello is een tool, niet een taak. Keep it simple!*