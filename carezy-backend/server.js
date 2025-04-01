require('dotenv').config();
const express = require('express');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const pool = require('./database');
const multer = require('multer');
const fs = require('fs');
const path = require('path');
const axios = require('axios');
const { GoogleGenerativeAI } = require("@google/generative-ai");


const app = express();
app.use(express.json());
app.use(cors());
app.use('/uploads', express.static('uploads')); // ✅ Serve uploaded images

//const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const API_KEY = process.env.GEMINI_API_KEY;
const GEMINI_API_URL = `https://generativelanguage.googleapis.com/v1/models/gemini-1.5-pro:generateContent?key=${API_KEY}`;
async function generateResponse(prompt) {
  try {
      const response = await axios.post(GEMINI_API_URL, {
          contents: [{ role: "user", parts: [{ text: prompt }] }]
      });

      console.log("✅ Gemini Response:", response.data);
      return response.data;
  } catch (error) {
      console.error("❌ Chatbot Error:", error.response ? error.response.data : error.message);
      return { error: "Failed to generate response from Gemini AI" };
  }
}
const DB_HOST = process.env.DB_HOST || 'localhost';

// ✅ Ensure `uploads` folder exists
const UPLOADS_DIR = path.join(__dirname, 'uploads');
if (!fs.existsSync(UPLOADS_DIR)) {
    fs.mkdirSync(UPLOADS_DIR);
}

// 📂 Serve Uploaded Profile Images
app.use('/uploads', express.static(UPLOADS_DIR));

const mime = require('mime');  // ✅ Import MIME Library

app.get('/uploads/:filename', (req, res) => {
    const filePath = path.join(__dirname, 'uploads', req.params.filename);

    if (fs.existsSync(filePath)) {
        const mimeType = mime.getType(filePath);
        res.setHeader('Content-Type', mimeType || 'image/jpeg');  // ✅ Set correct MIME type
        res.setHeader('Cache-Control', 'no-cache, no-store, must-revalidate'); // 🔥 Prevent caching
        res.setHeader('Pragma', 'no-cache');
        res.setHeader('Expires', '0');
        res.sendFile(filePath);
    } else {
        res.status(404).send('Image not found');
    }
});




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
  
      const token = jwt.sign(
        { userId: result.rows[0].id, email: result.rows[0].email },
        process.env.JWT_SECRET,
        { expiresIn: '1y' }
      );
  
      res.json({ token, user: result.rows[0] });
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

// 📂 Configure Multer for Profile Image Uploads
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, UPLOADS_DIR);
    },
    filename: function (req, file, cb) {
        const uniqueName = `${req.user.userId}_${Date.now()}${path.extname(file.originalname)}`;
        cb(null, uniqueName);
    }
});

const upload = multer({ storage });

// 🔹 Fetch User Profile
app.get('/api/user/:id', authenticate, async (req, res) => {
    try {
        const { id } = req.params;
        const user = await pool.query('SELECT id, name, email, profile_image FROM users WHERE id = $1', [id]);

        if (user.rows.length === 0) {
            return res.status(404).json({ error: "User not found" });
        }

        res.json(user.rows[0]);
    } catch (err) {
        console.error("❌ Fetch Profile Error:", err);
        res.status(500).json({ error: "Failed to fetch profile" });
    }
});

// 🔹 Update Profile Name
app.put('/api/user/update-profile', authenticate, async (req, res) => {
    try {
        const { userId, name } = req.body;
        await pool.query('UPDATE users SET name = $1 WHERE id = $2', [name, userId]);

        res.json({ message: "Profile updated successfully" });
    } catch (err) {
        console.error("❌ Update Profile Error:", err);
        res.status(500).json({ error: "Failed to update profile" });
    }
});



// 🔹 Upload Profile Image
app.post('/api/user/upload-image', authenticate, upload.single('profileImage'), async (req, res) => {
    try {
        const imagePath = `http://${DB_HOST}:5000/uploads/${req.file.filename}`;

        await pool.query('UPDATE users SET profile_image = $1 WHERE id = $2', [imagePath, req.user.userId]);

        res.json({ message: "Profile image updated successfully", profile_image: imagePath });
    } catch (err) {
        console.error("❌ Upload Image Error:", err);
        res.status(500).json({ error: "Failed to upload image" });
    }
});



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


async function analyzeMood(mood_score, note) {
  try {
      const prompt = `
      A user is feeling ${mood_score}/10 today.
      They wrote the following note about their mood: "${note}". 

      **Task:**
      1️⃣ Identify the key issue in the note.  
      2️⃣ Suggest **3 activities** to improve the user's mood.  
      3️⃣ Ensure your response is clear, actionable, and positive.  

      **Examples:**
      - If the note says "I got low marks," suggest study tips or stress relief techniques.
      - If the note says "I had a fight," suggest conflict resolution strategies.
      - If the note says "I'm exhausted," suggest rest and relaxation activities.
      `;

      const response = await axios.post(GEMINI_API_URL, {
          contents: [{ role: "user", parts: [{ text: prompt }] }]
      });

      console.log("✅ Gemini Mood Analysis Response:", response.data);

      return response.data;
  } catch (error) {
      console.error("❌ AI Mood Analysis Error:", error.response ? error.response.data : error.message);
      return { error: "Failed to analyze mood" };
  }
}

// 🔹 New AI Mood Analysis Route
app.post('/ai/analyze-mood', authenticate, async (req, res) => {
  try {
      const { mood_score, note } = req.body;

      if (!note || mood_score === undefined) {
          return res.status(400).json({ error: "Both mood_score and note are required" });
      }

      // Call Gemini AI for mood analysis
      const result = await analyzeMood(mood_score, note);

      if (!result || !result.candidates || result.candidates.length === 0) {
          throw new Error("Invalid response from Gemini AI");
      }

      const suggestion = result.candidates[0].content.parts[0].text;

      res.json({ suggestion });
  } catch (error) {
      console.error("❌ AI Mood Analysis Error:", error.message);
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

// const axios = require('axios');

app.post('/music-recommendation', authenticate, async (req, res) => {
    try {
      const { mood } = req.body;
  
      // Your YouTube Data API Key
      const apiKey = process.env.YOUTUBE_API_KEY;
  
      if (!apiKey) {
        return res.status(500).json({ error: "YouTube API key is not configured" });
      }
  
      // Search YouTube for videos matching the mood
      const query = `best songs for ${mood} mood`;
      const url = `https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&q=${encodeURIComponent(
        query
      )}&key=${apiKey}&maxResults=1`;
  
      const response = await axios.get(url);
  
      if (response.data.items && response.data.items.length > 0) {
        const video = response.data.items[0];
        const result = {
          title: video.snippet.title,
          videoId: video.id.videoId,
          thumbnail: video.snippet.thumbnails.medium.url,
          hashtags: video.snippet.description || "",
        };
  
        res.json(result);
      } else {
        res.status(404).json({ error: "No videos found" });
      }
    } catch (err) {
      console.error("Error fetching music suggestion:", err.message);
      res.status(500).json({ error: "Failed to fetch music suggestion" });
    }
  });
  let conversationHistories = {}; // Store conversation history per user

  app.post('/chatbot', authenticate, async (req, res) => {
    try {
        const { query } = req.body;
        const userId = req.user.userId;

        if (!query) {
            return res.status(400).json({ error: "Query is required" });
        }

        if (!conversationHistories[userId]) {
            conversationHistories[userId] = [];
        }

        conversationHistories[userId].push({ role: "user", content: query });

        // Prepare chat history as a prompt
        const prompt = conversationHistories[userId]
            .map((entry) => `${entry.role}: ${entry.content}`)
            .join("\n");

        // Call the Gemini API
        const result = await generateResponse(prompt);

        // Extract response
        if (!result || !result.candidates || result.candidates.length === 0) {
            throw new Error("Invalid response from Gemini API");
        }

        const botResponse = result.candidates[0].content.parts[0].text;

        conversationHistories[userId].push({ role: "bot", content: botResponse });

        res.json({ response: botResponse });
    } catch (error) {
        console.error("❌ Chatbot Error:", error.message);
        res.status(500).json({ error: 'Failed to generate chatbot response' });
    }
});
const nodemailer = require("nodemailer"); // ✅ Add Nodemailer for email

const otpStorage = {}; // Temporary OTP storage (Consider Redis in production)

// ✅ Setup Email Transporter
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

// ✅ 1️⃣ Send OTP for Password Reset
app.post("/send-reset-otp", async (req, res) => {
  const { email } = req.body;

  try {
    const userQuery = await pool.query("SELECT id FROM users WHERE email = $1", [email]);

    if (userQuery.rows.length === 0) {
      return res.status(400).json({ error: "❌ User not found" });
    }

    // Generate 6-digit OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    otpStorage[email] = { otp, expiresAt: Date.now() + 300000 }; // OTP valid for 5 mins

    // Send OTP via Email
    const mailOptions = {
      from: process.env.EMAIL_USER,
      to: email,
      subject: "Carezy Password Reset OTP",
      text: `Your OTP for password reset is: ${otp}. It is valid for 5 minutes.`,
    };

    transporter.sendMail(mailOptions, (error, info) => {
      if (error) {
        console.error("❌ Email Error:", error);
        return res.status(500).json({ error: "Error sending OTP email" });
      }
      res.json({ message: "✅ OTP sent successfully!" });
    });
  } catch (err) {
    console.error("❌ Database Error:", err);
    res.status(500).json({ error: "Database error" });
  }
});

// ✅ 2️⃣ Verify OTP & Reset Password
app.post("/reset-password", async (req, res) => {
  const { email, otp, newPassword } = req.body;

  try {
    if (!otpStorage[email] || otpStorage[email].otp !== otp) {
      return res.status(400).json({ error: "❌ Invalid or expired OTP" });
    }

    delete otpStorage[email]; // Remove OTP after verification

    // Hash new password
    const hashedPassword = await bcrypt.hash(newPassword, 10);

    // Update password in PostgreSQL
    await pool.query("UPDATE users SET password_hash = $1 WHERE email = $2", [hashedPassword, email]);

    res.json({ message: "✅ Password reset successfully!" });
  } catch (err) {
    console.error("❌ Database Error:", err);
    res.status(500).json({ error: "Database error" });
  }
});
