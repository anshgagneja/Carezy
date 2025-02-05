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

// 🔹 User Login (JWT Valid for 1 Year)
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
            { expiresIn: '365d' } // 🔹 Token now valid for 1 year
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
        if (!authHeader || !authHeader.startsWith("Bearer ")) {
            return res.status(401).json({ error: "Access denied. No token provided." });
        }

        const token = authHeader.split(" ")[1]; // Extract JWT
        const verified = jwt.verify(token, process.env.JWT_SECRET);
        req.user = verified;
        next();
    } catch (err) {
        console.error("❌ JWT Verification Error:", err.message);
        res.status(400).json({ error: "Invalid or expired token" });
    }
};

// 🔹 Add Mood Entry
app.post('/moods', authenticate, async (req, res) => {
    try {
        const { mood_score, note } = req.body;
        const user_id = req.user.userId;

        await pool.query(
            'INSERT INTO mood_logs (user_id, mood_score, note, created_at) VALUES ($1, $2, $3, NOW())',
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
        const moods = await pool.query(
            'SELECT * FROM mood_logs WHERE user_id = $1 ORDER BY created_at DESC', 
            [user_id]
        );

        res.json(moods.rows);
    } catch (err) {
        console.error("❌ Failed to Fetch Moods:", err);
        res.status(500).json({ error: 'Failed to fetch moods' });
    }
});


// 🔹 AI-Powered Mood Analysis (Gemini AI)
app.post('/ai/analyze-mood', authenticate, async (req, res) => {
    try {
        const { mood_score, note } = req.body; // 🔹 Get both mood_score & note
        const model = genAI.getGenerativeModel({ model: "gemini-pro" });

        // 🔹 Stronger AI Prompt (Forces it to analyze the note)
        const prompt = `
        A user is feeling ${mood_score}/10 today.
        They wrote the following note about their mood: "${note}". 

        1️⃣ **Identify the key issue mentioned in the note.**  
        2️⃣ **Based on that issue, suggest 3 activities that can improve their mood.**  
        3️⃣ **Make sure the response directly addresses their concern.**  

        Example:
        - If the note mentions "I got low marks," suggest study strategies or stress relief tips.
        - If the note mentions "I had a fight," suggest conflict resolution or emotional support ideas.
        - If the note mentions "I'm exhausted," suggest rest-related activities.

        Provide clear, actionable, and positive recommendations.
        `;

        const result = await model.generateContent(prompt);
        const text = result.response.candidates[0].content.parts[0].text;

        res.json({ suggestion: text });
    } catch (error) {
        console.error("❌ AI Analysis Error:", error);
        res.status(500).json({ error: 'AI analysis failed' });
    }
});

// 🔹 Add a New Task
app.post('/tasks', authenticate, async (req, res) => {
    try {
        const { title, description, due_date } = req.body;
        const user_id = req.user.userId;

        const result = await pool.query(
            `INSERT INTO tasks (user_id, title, description, due_date) 
             VALUES ($1, $2, $3, $4) RETURNING *`,
            [user_id, title, description, due_date]
        );

        res.json({ message: 'Task added successfully', task: result.rows[0] });
    } catch (err) {
        console.error("❌ Task Creation Error:", err);
        res.status(500).json({ error: 'Failed to create task' });
    }
});

// 🔹 Get All Tasks for Logged-in User
app.get('/tasks', authenticate, async (req, res) => {
    try {
        const user_id = req.user.userId;
        const tasks = await pool.query('SELECT * FROM tasks WHERE user_id = $1 ORDER BY created_at DESC', [user_id]);

        res.json(tasks.rows);
    } catch (err) {
        console.error("❌ Fetch Tasks Error:", err);
        res.status(500).json({ error: 'Failed to fetch tasks' });
    }
});

// 🔹 Update Task Status (Mark as Completed)
app.put('/tasks/:task_id', authenticate, async (req, res) => {
    try {
        const { status } = req.body;
        const { task_id } = req.params;

        const result = await pool.query(
            `UPDATE tasks SET status = $1 WHERE task_id = $2 RETURNING *`,
            [status, task_id]
        );

        res.json({ message: 'Task updated successfully', task: result.rows[0] });
    } catch (err) {
        console.error("❌ Task Update Error:", err);
        res.status(500).json({ error: 'Failed to update task' });
    }
});

// 🔹 Delete a Task
app.delete('/tasks/:task_id', authenticate, async (req, res) => {
    try {
        const { task_id } = req.params;
        await pool.query('DELETE FROM tasks WHERE task_id = $1', [task_id]);

        res.json({ message: 'Task deleted successfully' });
    } catch (err) {
        console.error("❌ Task Deletion Error:", err);
        res.status(500).json({ error: 'Failed to delete task' });
    }
});


// 🔹 Start Server
const PORT = process.env.PORT || 5000;
app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Server running on http://0.0.0.0:${PORT}`);
});
