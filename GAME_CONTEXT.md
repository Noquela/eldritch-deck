# 🎮 ELDRITCH DECK - Game Context Document

> **PROPÓSITO**: Este arquivo mantém o contexto completo do projeto para Claude não perder memória entre sessões.

---

## 📌 INFORMAÇÕES CRÍTICAS

### Notion Sprint Board
- **ID**: `2ac038aa-0e12-814d-96d2-cc47f5ffc732`
- **URL**: https://www.notion.so/2ac038aa0e12814d96d2cc47f5ffc732
- **Game Design Doc**: https://www.notion.so/Game-Design-Document-Eldritch-Deck-2b0038aa0e128188a76adc753cbdc3e4

### Databases Criados
- **Cards Pool**: `2b0038aa-0e12-8125-bbec-fef5a6b6c3f8`
- **Artifacts Pool**: `2b0038aa-0e12-81ec-8dd8-e6d29e3e464a`
- **Enemies & Bosses**: `2b0038aa-0e12-81a4-8bee-ee94831ec7ff`

### PostgreSQL
- **Database**: `cardgame`
- **User**: `postgres`
- **Port**: `5432`
- **API**: `http://localhost:3000` (Node.js + Express)
- **Tabelas**: `player_saves`, `player_deck`, `player_artifacts`, `map_nodes`

### Git
- **Remote**: https://github.com/BrunoSantos88/Card-Game
- **Branch**: `main`

---

## 🎯 FILOSOFIA DE DESENVOLVIMENTO

1. **Notion como Source of Truth** - Todas tarefas, ideias e decisões vão para o Notion
2. **Git Commits Estruturados** - Sempre com co-autoria Claude
3. **PostgreSQL para Persistência** - Save/load via API REST
4. **OpenMemory MCP** - Contexto persistente entre sessões
5. **Iteração Ágil** - Sprints com tasks claras e mensuráveis

---

## ✅ FEATURES IMPLEMENTADAS

### Sprint 0 (Setup)
- ✅ Projeto Godot 4.4.1 inicializado
- ✅ Repositório GitHub conectado
- ✅ PostgreSQL database criado

### Sprint 1 (Combate Básico)
- ✅ Sistema de combate turn-based
- ✅ HP jogador/inimigo
- ✅ Energia (3 por turno)
- ✅ Corrupção básica
- ✅ 3 cartas iniciais (Ataque, Defesa, Skill)

### Sprint 2 (Mecânicas Core)
- ✅ Sistema de turnos (jogador → inimigo)
- ✅ Deck + descarte + comprar cartas
- ✅ IA básica do inimigo
- ✅ Vitória/derrota detection

### Sprint 3 (Combate Avançado)
- ✅ Sistema de bloqueio (absorve dano)
- ✅ Buffs/debuffs (Força, Fraqueza, Vulnerável)
- ✅ Cartas Skill e Power
- ✅ 4 inimigos com padrões únicos
- ✅ UI ajustada para 3440x1440

### Sprint 4 (Meta-progressão)
- ✅ Sistema de mapa (5 tipos de nó)
- ✅ Recompensas pós-combate (escolher 1 de 3 cartas)
- ✅ Sistema de loja (comprar cartas/artifacts, remover cartas)
- ✅ 5 artefatos Lovecraftianos
- ✅ Fogueira (curar HP, upgrade placeholder)
- ✅ GameState singleton

### Sprint 4.5 (Persistência)
- ✅ API Node.js (Express) para PostgreSQL
- ✅ SaveManager autoload com HTTP requests
- ✅ Autosave após combate/loja/fogueira
- ✅ Tema Lovecraft completo (12 cartas renomeadas + flavor text)

---

## 🚨 PROBLEMAS CRÍTICOS IDENTIFICADOS

### 1. Loop de Gameplay INCOMPLETO
```
Combate → Recompensas → Mapa → [Shop/Campfire/Combat]
                                      ↓
                              SEM FIM DO ACT!
```
**Impacto**: Jogo não tem progressão ou objetivo final.

### 2. Features "Done" mas Incompletas
- **Fogueira**: Upgrade de carta é placeholder
- **Boss Nodes**: Só vão para combate normal
- **Elite Nodes**: Não têm inimigos especiais

### 3. Mecânicas sem Propósito
- **Corrupção**: Aumenta poder mas sem game over real
- **Rituais**: Pouco explorados (só 1 carta)

---

## 🎯 PRIORIDADES REAIS (ORDEM CRÍTICA)

### SPRINT 5 - FECHAR O LOOP ⚠️ BLOQUEADOR
1. **Boss Fights** (Alta, 8pts) - **SEM ISSO O JOGO NÃO TEM FIM**
   - Criar 1 boss por act com múltiplas fases
   - Boss node no final do mapa
   - Vitória → próximo act

2. **Progressão de Acts** (Alta, 5pts) - **SEM ISSO É SÓ UM COMBATE**
   - Act 1 → Act 2 → Act 3
   - Escalação de dificuldade
   - Recompensas melhores

3. **Elite Combat** (Média, 3pts) - Nós existem mas não funcionam
   - 3-4 inimigos elite (HP maior, drops melhores)
   - Recompensas: artefato raro

### SPRINT 6 - COMPLETAR PLACEHOLDERS
4. **Sistema de Upgrade de Cartas** (Média, 2pts)
5. **Consequências de Corrupção** (Média, 3pts)

### SPRINT 7 - UX
6. **Menu Principal + Run Selection** (Alta, 3pts)
7. **Arte/Audio** (Baixa) - Último!

---

## 📊 INVENTÁRIO COMPLETO

### 17 Cartas Implementadas
1. **Toque das Sombras** (Ataque, 1 energia, 5 dano)
2. **Golpe Pesado** (Ataque, 1 energia, 8 dano)
3. **Golpe Devastador** (Ataque, 2 energia, 12 dano)
4. **Véu Protetor** (Defesa, 1 energia, 5 bloqueio)
5. **Muralha de Ferro** (Defesa, 2 energia, 12 bloqueio)
6. **Golpe Desesperado** (Ataque, 1 energia, 10 dano, 2 corrupção)
7. **Bandagem** (Skill, 1 energia, cura 5 HP)
8. **Insight** (Skill, 1 energia, +2 cartas)
9. **Oferenda** (Skill, 1 energia, +2 energia)
10. **Enfraquecer** (Skill, 1 energia, -3 Força ao inimigo)
11. **Expor** (Skill, 1 energia, +2 Vulnerável ao inimigo)
12. **Fortalecer** (Power, 1 energia, +2 Força)
13. **Ritual da Loucura** (Ritual, 1 energia, 2 turnos, +4 Força ao fim)
14. **Abraçar Corrupção** (Power, 1 energia, +3 Corrupção, +3 Força permanente)
15. **Golpe do Vazio** (Ataque, 2 energia, 16 dano, Exaurir)
16. **Drenar Sanidade** (Skill, 1 energia, -5 sanidade do inimigo)
17. **Invocar Yog-Sothoth** (Ritual, 3 energia, 3 turnos, 50 dano final)

### 5 Artefatos Implementados
1. **Página do Necronomicon** (Rare, Passive, +15% dano)
2. **Sinal do Ancião** (Uncommon, Combat Start, +3 bloqueio)
3. **Trapezedro Reluzente** (Rare, Turn Start, 3 dano ao inimigo)
4. **Ídolo de Cthulhu** (Boss, Passive, +20 HP máx, +1 corrupção/turno)
5. **Adaga Amaldiçoada** (Cursed, Passive, +50% dano, -10 HP máx)

### 5 Inimigos Implementados
1. **Cultista** (30 HP, ataque 5-7, buffos)
2. **Brutamontes** (40 HP, ataque pesado 8-12)
3. **Defensor** (35 HP, bloqueio alto)
4. **Profundo** (45 HP, cresce mais forte com tempo)
5. **Erudito Corrompido** (50 HP, debuffs e rituais)

### 0 Bosses Implementados
⚠️ **CRÍTICO**: Sem bosses, sem fim de jogo!

---

## 🔧 ARQUITETURA TÉCNICA

### Estrutura de Pastas
```
Card Game/
├── scenes/
│   ├── combat/       # Cena principal de combate
│   ├── rewards/      # Escolha de recompensas
│   ├── map/          # Mapa de nós
│   ├── shop/         # Loja de cartas/artifacts
│   └── campfire/     # Descanso
├── scripts/
│   ├── autoload/     # GameState, SaveManager
│   ├── cards/        # card_data.gd, hand.gd
│   ├── data/         # artifact_data.gd, enemy_data.gd
│   └── systems/      # artifact_manager.gd, status_effects.gd
├── resources/
│   ├── cards/        # 17 .tres files
│   ├── artifacts/    # 5 .tres files
│   └── enemies/      # 5 .tres files
└── db_api/           # Node.js API para PostgreSQL
```

### Sistemas Críticos
- **GameState**: Singleton com estado global (HP, gold, deck, artifacts, map)
- **SaveManager**: HTTP requests para API Node.js
- **ArtifactManager**: Aplica efeitos dos artefatos
- **StatusEffects**: Gerencia buffs/debuffs
- **MapGenerator**: Gera mapa procedural

### Sinais Importantes
- `health_changed(current, max)`
- `gold_changed(amount)`
- `deck_changed()`
- `map_state_changed()`
- `artifact_triggered(name, effect)`

---

## 💾 COMO RODAR

### 1. Iniciar API de Save
```bash
cd "db_api"
npm start
```
API estará em `http://localhost:3000`

### 2. Abrir no Godot
```bash
godot --path "C:\Users\Bruno\Documents\JOGOS\Card Game"
```

### 3. Testar Save/Load
- Jogue até vencer um combate
- Autosave automático
- Feche e reabra o jogo
- Save persiste no PostgreSQL

---

## 📝 COMMITS RECENTES
- `4e59105` - feat: implementa sistema de save PostgreSQL completo
- `fa70d1b` - feat: implementa sistema de remoção de cartas na loja
- `f30e6ee` - feat: implementa sistema de fogueira
- `c5db6c9` - fix: corrige persistência do mapa entre cenas
- `f1efe9f` - feat: implementa sistema de loja completo

---

## 🎨 TEMA LOVECRAFTIANO

### Elementos Temáticos
- **Sanidade**: Regenera +3/turno, pode enlouquecer
- **Corrupção**: Trade-off power (+1% por ponto)
- **Rituais**: Cartas multi-turno com efeito final forte
- **Artefatos**: Itens amaldiçoados dos Grandes Anciões
- **Inimigos**: Cultistas, Profundos, Eruditos Corrompidos

### Nomes Temáticos
- "Toque das Sombras" ao invés de "Strike"
- "Véu Protetor" ao invés de "Defend"
- "Ritual de Yog-Sothoth" ao invés de "Big Spell"

---

## 🔮 PRÓXIMA AÇÃO

**IMPLEMENTAR BOSS FIGHTS AGORA** - É a prioridade #1 real, sem isso o jogo não fecha o loop.

---

*Última atualização: 2025-11-17 (Sprint 4.5)*
