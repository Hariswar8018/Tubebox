require('dotenv').config();
const { Pool } = require('pg');

let pool = null;

if (process.env.DATABASE_URL) {
    pool = new Pool({
        connectionString: process.env.DATABASE_URL,
        ssl: {
            rejectUnauthorized: false // Often required for cloud databases like Supabase/Neon
        }
    });

    pool.on('error', (err, client) => {
        console.error('Unexpected error on idle client', err);
        process.exit(-1);
    });
} else {
    console.warn("WARNING: DATABASE_URL is not set in .env. Database features will be disabled.");
}

module.exports = {
    query: (text, params) => {
        if (!pool) {
            console.log("Mock query executed (No DB connected):", text);
            return Promise.resolve({ rows: [] });
        }
        return pool.query(text, params);
    },
    hasDb: () => pool !== null
};
