require('dotenv').config();
const express = require('express');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const pool = require('./database');
const { GoogleGenerativeAI } = require("@google/generative-ai");

const app = express();
app.use(express.json());
app.use(cors());

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

// 🔹 Default Route
app.get('/', (req, res) => {
    res.send('Welcome to Carezy API!');
});

// 🔹 User Registration
app.post('/register', async (req, res) => {
    try {
        const { name, email, password } = req.body;
        const hashedPassword = await bcrypt.hash(password, 10);
        const result = await pool.query(
            'INSERT INTO users (name, email, password_hash) VALUES ($1, $2, $3) RETURNING id, name, email',
            [name, email, hashedPassword]
        );
        res.json(result.rows[0]);
    } catch (err) {
        console.error("❌ User Registration Error:", err);
        res.status(500).json({ error: 'User registration failed' });
    }
});

// 🔹 User Login
app.post('/login', async (req, res) => {
    try {
        const { email, password } = req.body;
        const user = await pool.query('SELECT * FROM users WHERE email = $1', [email]);

        if (user.rows.length === 0) {
            return res.status(400).json({ error: 'User not found' });
        }

        const isMatch = await bcrypt.compare(password, user.rows[0].password_hash);
        if (!isMatch) {
            return res.status(400).json({ error: 'Invalid credentials' });
        }

        const token = jwt.sign(
            { userId: user.rows[0].id, email: user.rows[0].email },
            process.env.JWT_SECRET,
            { expiresIn: '1h' }
        );

        res.json({ token, user: { id: user.rows[0].id, name: user.rows[0].name, email: user.rows[0].email } });
    } catch (err) {
        console.error("❌ Login Error:", err);
        res.status(500).json({ error: 'Login failed' });
    }
});

// 🔹 Middleware for Authentication
const authenticate = (req, res, next) => {
    try {
        const authHeader = req.header('Authorization');
        console.log("🔹 Received Authorization Header:", authHeader); // Debug log

        if (!authHeader || !authHeader.startsWith("Bearer ")) {
            console.error("❌ Access denied. No token provided.");
            return res.status(401).json({ error: "Access denied. No token provided." });
        }

        const token = authHeader.split(" ")[1]; // Extract JWT
        console.log("🔍 Extracted Token:", token); // Debug log

        const verified = jwt.verify(token, process.env.JWT_SECRET);
        console.log("✅ Token Verified Successfully:", verified); // Debug log

        req.user = verified; // Attach user data to request
        next();
    } catch (err) {
        console.error("❌ JWT Verification Error:", err.message);
        res.status(400).json({ error: "Invalid token" });
    }
};

// 🔹 Add Mood Entry
app.post('/moods', authenticate, async (req, res) => {
    try {
        const { mood_score, note } = req.body;
        const user_id = req.user.userId;

        await pool.query(
            'INSERT INTO mood_logs (user_id, mood_score, note) VALUES ($1, $2, $3)',
            [user_id, mood_score, note]
        );
        
        res.json({ message: 'Mood logged successfully' });
    } catch (err) {
        console.error("❌ Failed to Log Mood:", err);
        res.status(500).json({ error: 'Failed to log mood' });
    }
});

// 🔹 Get Mood History
app.get('/moods', authenticate, async (req, res) => {
    try {
        const user_id = req.user.userId;
        const moods = await pool.query('SELECT * FROM mood_logs WHERE user_id = $1', [user_id]);

        res.json(moods.rows);
    } catch (err) {
        console.error("❌ Failed to Fetch Moods:", err);
        res.status(500).json({ error: 'Failed to fetch moods' });
    }
});

// 🔹 AI-Powered Mood Analysis (Gemini AI)
app.post('/ai/analyze-mood', authenticate, async (req, res) => {
    try {
        const { mood } = req.body;
        const model = genAI.getGenerativeModel({ model: "gemini-pro" });

        const result = await model.generateContent(`Suggest activities for someone feeling ${mood}`);
        const text = result.response.candidates[0].content.parts[0].text;

        res.json({ suggestion: text });
    } catch (error) {
        console.error("❌ AI Analysis Error:", error);
        res.status(500).json({ error: 'AI analysis failed' });
    }
});

// 🔹 Start Server
const PORT = process.env.PORT || 5000;
app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Server running on http://0.0.0.0:${PORT}`);
});
