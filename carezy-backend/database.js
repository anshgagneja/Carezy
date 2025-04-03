require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
    user: process.env.DB_USER,
    host: process.env.DB_HOST,
    database: process.env.DB_DATABASE,
    password: process.env.DB_PASSWORD,
    port: process.env.DB_PORT,
    ssl: { rejectUnauthorized: false },  // ✅ Required for Supabase
    idleTimeoutMillis: 30000,  // Keep connections open for 30s
    connectionTimeoutMillis: 5000,  // 5s timeout
});

module.exports = pool;
