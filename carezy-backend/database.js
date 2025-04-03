require("dotenv").config();
const { Pool } = require("pg");

const pool = new Pool({
    user: process.env.DB_USER,
    host: process.env.DB_HOST,
    database: process.env.DB_DATABASE,
    password: process.env.DB_PASSWORD,
    port: process.env.DB_PORT,
    ssl: { rejectUnauthorized: false }, // ✅ Required for Render
});

pool.connect()
    .then(() => console.log("✅ Connected to Database"))
    .catch(err => console.error("❌ Database Connection Error:", err));

module.exports = pool;
