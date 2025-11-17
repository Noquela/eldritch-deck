const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

const pool = new Pool({
    user: 'postgres',
    host: 'localhost',
    database: 'cardgame',
    password: '#7u9XXfxn',
    port: 5432,
});

// Inicializar schema
pool.query(`
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
`).then(() => console.log('✅ Schema criado/verificado')).catch(console.error);

// SAVE - Salvar progresso
app.post('/api/save', async (req, res) => {
    const client = await pool.connect();
    try {
        await client.query('BEGIN');

        const { save_name, player_data, deck, artifacts, map_nodes } = req.body;

        // Deletar save anterior com mesmo nome
        await client.query('DELETE FROM player_saves WHERE save_name = $1', [save_name]);

        // Inserir novo save
        const saveResult = await client.query(
            `INSERT INTO player_saves (save_name, current_health, max_health, gold, current_floor, nodes_cleared, current_act, updated_at)
             VALUES ($1, $2, $3, $4, $5, $6, $7, NOW())
             RETURNING id`,
            [save_name, player_data.current_health, player_data.max_health, player_data.gold,
             player_data.current_floor, player_data.nodes_cleared, player_data.current_act]
        );

        const saveId = saveResult.rows[0].id;

        // Inserir deck
        for (const card_path of deck) {
            await client.query(
                'INSERT INTO player_deck (save_id, card_resource_path) VALUES ($1, $2)',
                [saveId, card_path]
            );
        }

        // Inserir artifacts
        for (const artifact_path of artifacts) {
            await client.query(
                'INSERT INTO player_artifacts (save_id, artifact_resource_path) VALUES ($1, $2)',
                [saveId, artifact_path]
            );
        }

        // Inserir map nodes
        for (const node of map_nodes) {
            await client.query(
                `INSERT INTO map_nodes (save_id, node_id, node_type, position_x, position_y, is_available, is_completed, connected_nodes)
                 VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
                [saveId, node.node_id, node.node_type, node.position_x, node.position_y,
                 node.is_available, node.is_completed, node.connected_nodes]
            );
        }

        await client.query('COMMIT');
        res.json({ success: true, save_id: saveId });
    } catch (e) {
        await client.query('ROLLBACK');
        console.error('Erro ao salvar:', e);
        res.status(500).json({ success: false, error: e.message });
    } finally {
        client.release();
    }
});

// LOAD - Carregar progresso
app.get('/api/load/:save_name', async (req, res) => {
    try {
        const { save_name } = req.params;

        // Buscar save
        const saveResult = await pool.query(
            'SELECT * FROM player_saves WHERE save_name = $1 ORDER BY updated_at DESC LIMIT 1',
            [save_name]
        );

        if (saveResult.rows.length === 0) {
            return res.json({ success: false, error: 'Save não encontrado' });
        }

        const save = saveResult.rows[0];
        const saveId = save.id;

        // Buscar deck
        const deckResult = await pool.query(
            'SELECT card_resource_path FROM player_deck WHERE save_id = $1',
            [saveId]
        );
        const deck = deckResult.rows.map(row => row.card_resource_path);

        // Buscar artifacts
        const artifactsResult = await pool.query(
            'SELECT artifact_resource_path FROM player_artifacts WHERE save_id = $1',
            [saveId]
        );
        const artifacts = artifactsResult.rows.map(row => row.artifact_resource_path);

        // Buscar map nodes
        const nodesResult = await pool.query(
            'SELECT * FROM map_nodes WHERE save_id = $1',
            [saveId]
        );
        const map_nodes = nodesResult.rows;

        res.json({
            success: true,
            data: {
                player_data: {
                    current_health: save.current_health,
                    max_health: save.max_health,
                    gold: save.gold,
                    current_floor: save.current_floor,
                    nodes_cleared: save.nodes_cleared,
                    current_act: save.current_act
                },
                deck,
                artifacts,
                map_nodes
            }
        });
    } catch (e) {
        console.error('Erro ao carregar:', e);
        res.status(500).json({ success: false, error: e.message });
    }
});

// LIST - Listar saves disponíveis
app.get('/api/saves', async (req, res) => {
    try {
        const result = await pool.query(
            'SELECT save_name, current_health, max_health, gold, current_floor, current_act, updated_at FROM player_saves ORDER BY updated_at DESC'
        );
        res.json({ success: true, saves: result.rows });
    } catch (e) {
        console.error('Erro ao listar saves:', e);
        res.status(500).json({ success: false, error: e.message });
    }
});

// DELETE - Deletar save
app.delete('/api/save/:save_name', async (req, res) => {
    try {
        const { save_name } = req.params;
        await pool.query('DELETE FROM player_saves WHERE save_name = $1', [save_name]);
        res.json({ success: true });
    } catch (e) {
        console.error('Erro ao deletar save:', e);
        res.status(500).json({ success: false, error: e.message });
    }
});

const PORT = 3000;
app.listen(PORT, () => {
    console.log(`🎮 Card Game Save API rodando na porta ${PORT}`);
});
