# Card Game Save API

API REST para salvar e carregar progresso do jogo no PostgreSQL.

## 🚀 Como usar

### 1. Iniciar o servidor

```bash
cd db_api
npm install
npm start
```

O servidor estará rodando em `http://localhost:3000`

### 2. Endpoints disponíveis

#### POST `/api/save`
Salva o progresso do jogador

**Body:**
```json
{
  "save_name": "save_1",
  "player_data": {
    "current_health": 100,
    "max_health": 100,
    "gold": 150,
    "current_floor": 5,
    "nodes_cleared": 10,
    "current_act": 1
  },
  "deck": [
    "res://resources/cards/strike.tres",
    "res://resources/cards/defend.tres"
  ],
  "artifacts": [
    "res://resources/artifacts/necronomicon_page.tres"
  ],
  "map_nodes": [
    {
      "node_id": 1,
      "node_type": 0,
      "position_x": 100.0,
      "position_y": 200.0,
      "is_available": true,
      "is_completed": false,
      "connected_nodes": "[2,3]"
    }
  ]
}
```

**Response:**
```json
{
  "success": true,
  "save_id": 1
}
```

#### GET `/api/load/:save_name`
Carrega um save específico

**Response:**
```json
{
  "success": true,
  "data": {
    "player_data": { ... },
    "deck": [ ... ],
    "artifacts": [ ... ],
    "map_nodes": [ ... ]
  }
}
```

#### GET `/api/saves`
Lista todos os saves disponíveis

**Response:**
```json
{
  "success": true,
  "saves": [
    {
      "save_name": "save_1",
      "current_health": 100,
      "max_health": 100,
      "gold": 150,
      "current_floor": 5,
      "current_act": 1,
      "updated_at": "2025-11-17T02:00:00.000Z"
    }
  ]
}
```

#### DELETE `/api/save/:save_name`
Deleta um save

**Response:**
```json
{
  "success": true
}
```

## 🎮 Uso no Godot

O `SaveManager` (autoload) já está configurado para usar esta API:

```gdscript
# Salvar jogo
SaveManager.save_game("save_1")

# Carregar jogo
SaveManager.load_game("save_1")
```

## 💾 Autosave

O jogo salva automaticamente:
- ✅ Após vencer um combate (rewards.gd)
- ✅ Ao sair da loja (shop.gd)
- ✅ Ao sair da fogueira (campfire.gd)

## 🗄️ Estrutura do Banco

### player_saves
- id (SERIAL PRIMARY KEY)
- save_name (VARCHAR)
- current_health, max_health (INT)
- gold, current_floor, nodes_cleared, current_act (INT)
- created_at, updated_at (TIMESTAMP)

### player_deck
- id (SERIAL PRIMARY KEY)
- save_id (FK)
- card_resource_path (VARCHAR)

### player_artifacts
- id (SERIAL PRIMARY KEY)
- save_id (FK)
- artifact_resource_path (VARCHAR)

### map_nodes
- id (SERIAL PRIMARY KEY)
- save_id (FK)
- node_id, node_type (INT)
- position_x, position_y (FLOAT)
- is_available, is_completed (BOOLEAN)
- connected_nodes (TEXT - JSON array)
