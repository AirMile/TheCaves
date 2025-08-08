# 📱 HOE WERKEN BOOKMARKS VOOR MARKDOWN?

## 🤔 Het Probleem
Markdown files (.md) zijn gewoon tekstbestanden. Je kunt ze niet direct "bookmarken" zoals een website.

## ✅ De Oplossingen

### OPTIE 1: Obsidian Mobile App (BESTE!)
1. **Download Obsidian** op je telefoon
2. **Open je vault** (Roguelite folder)
3. **Star ⭐ belangrijke files**:
   - Tik op de 3 dots bij een file
   - Kies "Star" 
   - Deze komen bovenaan in "Starred" sectie
4. **Quick Access**: Open app → Starred → Je checklist!

### OPTIE 2: Via Browser (GitHub)
1. **Push files naar GitHub**
2. **Open in browser**: github.com/[username]/roguelite
3. **Bookmark de URL** van:
   - `/01_MILES/DAILY_CHECKLIST.md`
   - `/01_MILES/QUICK_REFERENCE.md`
4. **Voordeel**: Werkt overal, altijd up-to-date

### OPTIE 3: Discord Pinned Message
1. **Kopieer content** van DAILY_CHECKLIST
2. **Post in Discord** in een privé channel
3. **Pin de message** (hold message → Pin)
4. **Update** de pinned message dagelijks

### OPTIE 4: Google Docs/Notion (Copy)
1. **Kopieer markdown** content
2. **Plak in Google Docs/Notion**
3. **Share link** met jezelf
4. **Bookmark** die link
5. **Nadeel**: Moet je handmatig updaten

## 🎯 Mijn Aanbeveling

### Voor Jou (Miles):
```
1. Obsidian Mobile (voor complete vault access)
2. GitHub bookmarks (voor quick reference)
3. Discord pins (voor templates)
```

### Concrete Stappen:
1. **NU**: Push alles naar GitHub
2. **MORGEN**: Install Obsidian Mobile
3. **STAR** deze files in Obsidian:
   - 01_MILES/DAILY_CHECKLIST.md
   - 01_MILES/QUICK_REFERENCE.md
   - Templates/DAILY_UPDATE_TEMPLATE.md

## 📱 Obsidian Mobile Setup

### iOS:
1. Download "Obsidian" van App Store
2. Open app
3. "Open folder as vault"
4. Kies sync methode (iCloud/Git)

### Android:
1. Download "Obsidian" van Play Store
2. Open app
3. "Open folder as vault"
4. Browse naar je folder (via cloud sync)

### Sync Opties:
- **Obsidian Sync** (€€ maar makkelijk)
- **Git** (gratis maar technical)
- **Google Drive/Dropbox** (gratis, manual sync)
- **Working Copy** (iOS) + Obsidian

## 🔥 Quick Hack voor NU

### Discord Mobile Workflow:
```
1. Maak een PRIVATE Discord server
2. Maak channel: #my-templates
3. Post deze messages:
   - DAILY_CHECKLIST content
   - Quick templates
   - Git commands
4. Pin alles
5. Open Discord → Pinned → Copy/paste!
```

## 📝 Voor Claude Code

### Gebruik de context file:
```bash
# In terminal:
cat .claude-context | claude-code context

# Of in VS Code:
# Open .claude-context
# Copy all
# Paste in Claude Code chat: "Here's my project context:"
```

### Auto-include context:
```json
// In .claude-code/config.json:
{
  "context": {
    "autoInclude": [".claude-context"],
    "persistent": true
  }
}
```

---

## 💡 TL;DR

**Bookmarks voor Markdown** = 
- Obsidian app (beste)
- GitHub links (makkelijkst)
- Discord pins (snelst)

**Voor morgen**: Push naar GitHub → bookmark die URLs!

---

*Questions? Het is inderdaad verwarrend - markdown files zijn geen webpages!*