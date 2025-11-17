-- Schema para sistema de save do Card Game

CREATE TABLE IF NOT EXISTS player_saves (
    id SERIAL PRIMARY KEY,
    save_name VARCHAR(100) NOT NULL DEFAULT 'save_1',
    current_health INT NOT NULL,
    max_health INT NOT NULL,
    gold INT NOT NULL,
    current_floor INT NOT NULL,
    nodes_cleared INT NOT NULL,
    current_act INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS player_deck (
    id SERIAL PRIMARY KEY,
    save_id INT REFERENCES player_saves(id) ON DELETE CASCADE,
    card_resource_path VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS player_artifacts (
    id SERIAL PRIMARY KEY,
    save_id INT REFERENCES player_saves(id) ON DELETE CASCADE,
    artifact_resource_path VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS map_nodes (
    id SERIAL PRIMARY KEY,
    save_id INT REFERENCES player_saves(id) ON DELETE CASCADE,
    node_id INT NOT NULL,
    node_type INT NOT NULL,
    position_x FLOAT NOT NULL,
    position_y FLOAT NOT NULL,
    is_available BOOLEAN NOT NULL,
    is_completed BOOLEAN NOT NULL,
    connected_nodes TEXT
);

-- Índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_player_deck_save_id ON player_deck(save_id);
CREATE INDEX IF NOT EXISTS idx_player_artifacts_save_id ON player_artifacts(save_id);
CREATE INDEX IF NOT EXISTS idx_map_nodes_save_id ON map_nodes(save_id);
