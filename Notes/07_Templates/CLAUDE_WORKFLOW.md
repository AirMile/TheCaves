# 🎙️ CLAUDE UPDATE WORKFLOW

## Hoe werkt dit?

1. **Kopieer een template** uit deze folder
2. **Vul in met speech-to-text** (zet cursor op de ... en praat)
3. **Stuur naar Claude** met deze instructie:
   > "Update de Roguelite vault met deze informatie: [plak template]"
4. **Claude doet**: 
   - Maakt daily update file
   - Update TODO.md
   - Past relevante guides aan
   - Houdt progress bij

## 📋 Beschikbare Templates

### Voor dagelijkse updates:
- `DAILY_UPDATE_TEMPLATE.md` - Einde van werkdag
- `PROGRESS_CHECK_TEMPLATE.md` - Tussendoor progress delen
- `BLOCKER_TEMPLATE.md` - Als je vast zit
- `DISCOVERY_TEMPLATE.md` - Nieuwe dingen geleerd

### Voor specifieke situaties:
- `BUG_REPORT_TEMPLATE.md` - Bug gevonden
- `FEATURE_COMPLETE_TEMPLATE.md` - Feature af
- `MEETING_NOTES_TEMPLATE.md` - Na call met Jade
- `WEEK_REVIEW_TEMPLATE.md` - Week afsluiting

## 🗣️ Speech-to-Text Tips

### Zeg deze woorden voor formatting:
- "punt" = .
- "komma" = ,
- "nieuwe regel" = enter
- "dubbele punt" = :
- "streepje" = -

### Structuur woorden:
- "ten eerste" / "ten tweede" 
- "probleem is" / "oplossing was"
- "wat werkte" / "wat niet werkte"
- "blocker" / "opgelost"

## 🤖 Instructies voor Claude

### Standaard update instructie:
```
Update de Roguelite vault met deze informatie:
[PLAK TEMPLATE]

Doe het volgende:
1. Maak daily update file
2. Update TODO.md status
3. Update relevante guides als nodig
4. Check of documentatie moet worden aangepast
```

### Voor specifieke updates:
```
[BUG] Update vault, voeg toe aan known issues:
[PLAK BUG TEMPLATE]
```

```
[FEATURE] Update vault, markeer als complete:
[PLAK FEATURE TEMPLATE]
```

## ⏰ Flexibele Werk Momenten

**Geen vaste tijden!** Gebruik templates wanneer je werkt:
- Begin werk: Gebruik `PROGRESS_CHECK_TEMPLATE`
- Tijdens werk: Gebruik `BLOCKER_TEMPLATE` als nodig
- Einde werk: Gebruik `DAILY_UPDATE_TEMPLATE`
- Niet gewerkt: Skip die dag

## 📝 Voorbeeld Workflow

### Jij (spreekt in):
```
"Vandaag heb ik gewerkt aan player movement. 
Het WASD movement werkt nu goed, maar de controller 
input geeft nog problemen. Ik denk dat het aan de 
input mapping ligt. Morgen ga ik dat fixen en dan 
beginnen aan de dash mechanic. Oh ja, Git repository 
is aangemaakt en eerste commit is gepusht."
```

### Claude verwerkt naar:
- ✅ Daily update file aangemaakt
- ✅ TODO.md: "Player movement" → completed
- ✅ TODO.md: "Controller input" → in progress
- ✅ Known issue toegevoegd aan troubleshooting
- ✅ Git milestone gemarkeerd als done

## 🚀 Quick Start

1. Open `DAILY_UPDATE_TEMPLATE.md`
2. Kopieer de template
3. Vul in met speech-to-text
4. Stuur naar Claude
5. Claude update alles!

---

*Remember: Jij praat, Claude typt. Keep it simple!*