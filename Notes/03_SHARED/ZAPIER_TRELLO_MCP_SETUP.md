# 🔗 Zapier + Trello MCP Setup Handleiding

## Overzicht
Deze handleiding legt uit hoe je Zapier MCP kunt instellen om Trello boards automatisch te beheren via AI prompts. Perfect voor student projecten en team collaboratie.

## Benodigdheden
- Claude Desktop geïnstalleerd
- Gratis Zapier account
- Gratis Trello account
- 15-20 minuten setup tijd

## Stap 1: Zapier Account Setup

### 1.1 Account Aanmaken
1. Ga naar [zapier.com](https://zapier.com)
2. Klik op "Sign up for free"
3. Gebruik je student email voor eventuele kortingen
4. Verifieer je email

### 1.2 MCP Access Activeren
1. Login naar je Zapier dashboard
2. Ga naar "Apps" in het linker menu
3. Zoek naar "Claude" of "MCP"
4. Klik "Connect" en volg de instructies

## Stap 2: Trello Connecten

### 2.1 Trello App Toevoegen
1. In Zapier dashboard: "Apps" → "Add connection"
2. Zoek "Trello" en klik erop
3. Klik "Connect a new account"
4. Login met je Trello credentials
5. Geef Zapier toegang tot je boards

### 2.2 Test Board Aanmaken
Maak een test board in Trello met deze lijsten:
- **To Do**
- **In Progress** 
- **Review**
- **Done**

## Stap 3: Claude Desktop Configureren

### 3.1 MCP Server Toevoegen
1. Open Claude Desktop
2. Ga naar `Settings` → `Developer` → `MCP`
3. Klik "Add Server"
4. Voeg deze configuratie toe:

```json
{
  "mcpServers": {
    "zapier": {
      "command": "node",
      "args": ["-e", "require('@anthropic-ai/mcp-server-zapier').default()"],
      "transport": {
        "type": "sse",
        "url": "https://api.zapier.com/v1/mcp/sse"
      },
      "env": {
        "ZAPIER_API_KEY": "YOUR_API_KEY_HERE"
      }
    }
  }
}
```

### 3.2 API Key Verkrijgen
1. In Zapier: `Profile` → `API Keys`
2. Klik "Create API Key"
3. Kopieer de key
4. Plak in de config waar `YOUR_API_KEY_HERE` staat

### 3.3 Configuratie Opslaan
1. Klik "Save Configuration"
2. Restart Claude Desktop
3. Check of de Zapier MCP server actief is (groene dot)

## Stap 4: Eerste Test

### 4.1 Basis Commands Testen
Probeer deze prompts in Claude:

```
Laat mijn Trello boards zien
```

```
Maak een nieuwe card in mijn [Board Name] met titel "Test Task"
```

```
Verplaats de card "Test Task" naar de In Progress lijst
```

### 4.2 Geavanceerde Commands
```
Maak een complete sprint planning voor ons game project met 10 taken verdeeld over To Do en In Progress
```

```
Laat alle taken zien die toegewezen zijn aan Jade
```

## Stap 5: Team Setup voor Jade

### 5.1 Jade Toegang Geven
1. In je Trello board: `Menu` → `Settings` → `Members`
2. Voeg Jade's email toe
3. Geef haar "Admin" rechten voor volledige toegang

### 5.2 Shared Zapier Workspace (Optioneel)
Voor geavanceerd gebruik:
1. Upgrade naar Zapier Teams (€20/maand, te delen)
2. Invite Jade naar je workspace
3. Beide kunnen dan MCP gebruiken

## Workflow Voorbeelden

### Daily Standup Automation
```
Maak een dagelijkse samenvatting van:
- Wat heeft Jade gisteren afgerond?
- Welke taken staan er vandaag gepland?
- Zijn er blockers in de Review lijst?
```

### Sprint Planning
```
Maak een 2-week sprint voor ons [Project Name]:
- 8 development taken voor mij
- 6 design taken voor Jade  
- Alle taken in To Do lijst met deadlines
```

### Progress Tracking
```
Genereer een voortgangsrapport:
- Hoeveel taken zijn deze week afgerond?
- Welke taken lopen achter op schema?
- Maak een overzicht voor onze docent
```

## Troubleshooting

### Probleem: MCP Server Start Niet
**Oplossing:**
1. Check of API key correct is
2. Restart Claude Desktop
3. Check internet connectie
4. Kijk in Claude logs: `Help` → `Show Logs`

### Probleem: Trello Access Denied
**Oplossing:**
1. Revoke en reconnect Trello in Zapier
2. Check board permissions
3. Zorg dat je admin rights hebt op het board

### Probleem: Commands Werken Niet
**Oplossing:**
1. Test met simpele commands eerst
2. Check of board naam correct gespeld is
3. Gebruik exacte lijst namen uit Trello

### Probleem: Rate Limiting
**Oplossing:**
- Free tier: 300 calls/maand
- Monitor usage in Zapier dashboard
- Upgrade naar paid plan bij heavy usage

## Best Practices

### Naming Conventions
- **Boards**: Project naam + jaar (bijv. "Game Dev 2025")
- **Cards**: [Type] Korte beschrijving (bijv. "[Bug] Player collision")
- **Labels**: Gebruik consistent kleur schema

### Team Workflow
1. **Morning**: AI standup summary
2. **During work**: Direct task updates via AI
3. **Evening**: Progress check met AI
4. **Weekly**: Sprint review automation

### Security Tips
- Bewaar API keys veilig
- Gebruik student emails voor accounts
- Review permissions regelmatig
- Backup belangrijke boards

## Kosten Overzicht

### Gratis Tier Limieten
- **Zapier**: 300 AI calls/maand
- **Trello**: Unlimited persoonlijke boards
- **Claude**: Standaard usage limits

### Upgrade Overwegingen
- Zapier Pro (€15/maand): 1000+ calls
- Trello Business (€5/maand): Geavanceerde features
- Alleen upgraden bij daadwerkelijke limieten

## Volgende Stappen

1. **Week 1**: Basic setup en test commands
2. **Week 2**: Team workflow ontwikkelen met Jade
3. **Week 3**: Geavanceerde automation rules
4. **Maand 1**: Evalueer en optimaliseer

## Handige Links
- [Zapier MCP Documentatie](https://zapier.com/mcp)
- [Trello API Reference](https://developer.atlassian.com/cloud/trello/)
- [Claude MCP Guide](https://docs.anthropic.com/mcp)

---

**Note**: Bewaar deze file in je Obsidian vault voor makkelijke referentie. Update de configuratie als er nieuwe features beschikbaar komen.