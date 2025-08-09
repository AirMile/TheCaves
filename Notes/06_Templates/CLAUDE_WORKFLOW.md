# 🎙️ CLAUDE UPDATE WORKFLOW

## How does this work?

1. **Copy a template** from this folder
2. **Fill in with speech-to-text** (put cursor on the ... and talk)
3. **Send to Claude** with this instruction:
   > "Update the Roguelite vault with this information: [paste template]"
4. **Claude does**: 
   - Creates daily update file
   - Updates TODO.md
   - Adjusts relevant guides
   - Tracks progress

## 📋 Available Templates

### For daily updates:
- `DAILY_UPDATE_TEMPLATE.md` - End of workday
- `PROGRESS_CHECK_TEMPLATE.md` - Share progress in between
- `BLOCKER_TEMPLATE.md` - When you're stuck
- `DISCOVERY_TEMPLATE.md` - New things learned

### For specific situations:
- `BUG_REPORT_TEMPLATE.md` - Bug found
- `FEATURE_COMPLETE_TEMPLATE.md` - Feature completed
- `MEETING_NOTES_TEMPLATE.md` - After call with Jade
- `WEEK_REVIEW_TEMPLATE.md` - Week closure

## 🗣️ Speech-to-Text Tips

### Say these words for formatting:
- "period" = .
- "comma" = ,
- "new line" = enter
- "colon" = :
- "dash" = -

### Structure words:
- "first" / "second" 
- "problem is" / "solution was"
- "what worked" / "what didn't work"
- "blocker" / "solved"

## 🤖 Instructions for Claude

### Standard update instruction:
```
Update the Roguelite vault with this information:
[PASTE TEMPLATE]

Do the following:
1. Create daily update file
2. Update TODO.md status
3. Update relevant guides if needed
4. Check if documentation needs adjusting
```

### For specific updates:
```
[BUG] Update vault, add to known issues:
[PASTE BUG TEMPLATE]
```

```
[FEATURE] Update vault, mark as complete:
[PASTE FEATURE TEMPLATE]
```

## ⏰ Flexible Work Moments

**No fixed times!** Use templates when you work:
- Start work: Use `PROGRESS_CHECK_TEMPLATE`
- During work: Use `BLOCKER_TEMPLATE` if needed
- End work: Use `DAILY_UPDATE_TEMPLATE`
- Didn't work: Skip that day

## 📝 Example Workflow

### You (speak in):
```
"Today I worked on player movement. 
The WASD movement works well now, but the controller 
input still has problems. I think it's the 
input mapping. Tomorrow I'll fix that and then 
start on the dash mechanic. Oh yeah, Git repository 
is created and first commit is pushed."
```

### Claude processes to:
- ✅ Daily update file created
- ✅ TODO.md: "Player movement" → completed
- ✅ TODO.md: "Controller input" → in progress
- ✅ Known issue added to troubleshooting
- ✅ Git milestone marked as done

## 🚀 Quick Start

1. Open `DAILY_UPDATE_TEMPLATE.md`
2. Copy the template
3. Fill in with speech-to-text
4. Send to Claude
5. Claude updates everything!

---

*Remember: You talk, Claude types. Keep it simple!*