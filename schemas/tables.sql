-- Discord Users table remains the same
CREATE TABLE discord_users (
    username VARCHAR(255) PRIMARY KEY,
    display_name VARCHAR(255),
    discord_id BIGINT UNIQUE,
    aliases TEXT[]
);

-- Factions table remains the same
CREATE TABLE factions (
    username VARCHAR(255) PRIMARY KEY,
    tag VARCHAR(50) NOT NULL,
    FOREIGN KEY (username) REFERENCES discord_users(username)
);

-- Players table remains the same
CREATE TABLE players (
    username VARCHAR(255) PRIMARY KEY,
    in_game_name VARCHAR(255) NOT NULL,
    FOREIGN KEY (username) REFERENCES discord_users(username)
);

-- Battles table remains the same
CREATE TABLE battles (
    id SERIAL PRIMARY KEY,
    attacker_username VARCHAR(255) NOT NULL,
    defender_username VARCHAR(255),
    location VARCHAR(255),
    started_at TIMESTAMP NOT NULL,
    ended_at TIMESTAMP,
    outcome VARCHAR(4) CHECK (outcome IN ('win', 'loss', 'draw')),
    status VARCHAR(10) NOT NULL CHECK (status IN ('waiting', 'active', 'completed')),
    FOREIGN KEY (attacker_username) REFERENCES factions(username),
    FOREIGN KEY (defender_username) REFERENCES factions(username)
);

-- Contracts table: changed price and starting_price to INTEGER
CREATE TABLE contracts (
    battle_id INTEGER PRIMARY KEY,
    client_username VARCHAR(255),
    price INTEGER NOT NULL,
    rate INTEGER NOT NULL,
    bidding_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP,
    status VARCHAR(10) NOT NULL CHECK (status IN ('bidding', 'canceled', 'waiting', 'active', 'completed')),
    message TEXT NOT NULL,
    auction_duration INTEGER NOT NULL,
    auction_ext_on_bid INTEGER NOT NULL,
    starting_price INTEGER NOT NULL,
    FOREIGN KEY (battle_id) REFERENCES battles(id),
    FOREIGN KEY (client_username) REFERENCES factions(username)
);

-- Contract Details table: changed to use ROUND for payout
CREATE TABLE contract_details (
    battle_id INTEGER PRIMARY KEY,
    ip_spent INTEGER NOT NULL,
    FOREIGN KEY (battle_id) REFERENCES contracts(battle_id)
);

-- Individual Contract Details table: changed to use ROUND for payout
CREATE TABLE individual_contract_details (
    battle_id INTEGER,
    player_username VARCHAR(255),
    ip_spent INTEGER NOT NULL,
    PRIMARY KEY (battle_id, player_username),
    FOREIGN KEY (battle_id) REFERENCES contracts(battle_id),
    FOREIGN KEY (player_username) REFERENCES players(username)
);

-- Create view for contract_details with payout
CREATE VIEW contract_details_with_payout AS
SELECT 
    cd.battle_id,
    cd.ip_spent,
    ROUND(
        c.price::NUMERIC * 
        cd.ip_spent::NUMERIC / 
        c.rate::NUMERIC
    )::INTEGER as payout
FROM contract_details cd
JOIN contracts c ON c.battle_id = cd.battle_id;

-- Create view for individual_contract_details with payout
CREATE VIEW individual_contract_details_with_payout AS
SELECT 
    icd.battle_id,
    icd.player_username,
    icd.ip_spent,
    ROUND(
        c.price::NUMERIC * 
        icd.ip_spent::NUMERIC / 
        c.rate::NUMERIC
    )::INTEGER as payout
FROM individual_contract_details icd
JOIN contracts c ON c.battle_id = icd.battle_id;
