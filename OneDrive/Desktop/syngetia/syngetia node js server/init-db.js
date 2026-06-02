require('dotenv').config();
const { Pool } = require('pg');

async function initDb() {
    if (!process.env.DATABASE_URL) {
        console.error("ERROR: DATABASE_URL not found in .env");
        process.exit(1);
    }

    const pool = new Pool({
        connectionString: process.env.DATABASE_URL,
        ssl: { rejectUnauthorized: false }
    });

    try {
        console.log("Connecting to the database...");
        await pool.query(`
            CREATE TABLE IF NOT EXISTS campaigns (
                id SERIAL PRIMARY KEY,
                campaign_name VARCHAR(255) NOT NULL,
                crop VARCHAR(100) NOT NULL,
                region VARCHAR(255) NOT NULL,
                language VARCHAR(50) NOT NULL,
                engagement_prediction INTEGER,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        `);
        console.log("Success! Table 'campaigns' is ready.");
    } catch (err) {
        console.error("Database initialization failed:", err);
    } finally {
        await pool.end();
    }
}

initDb();
