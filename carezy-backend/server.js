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
const logger = require('./logger');
const mime = require('mime');  
require("@google/generative-ai");


const app = express();
app.use(express.json());
app.use(cors());

// ✅ Ensure `uploads` folder exists
const UPLOADS_DIR = path.join(__dirname, 'uploads');
if (!fs.existsSync(UPLOADS_DIR)) {
    fs.mkdirSync(UPLOADS_DIR);
}
app.use('/uploads', express.static(UPLOADS_DIR)); // ✅ Serve uploaded images

const API_KEY = process.env.GEMINI_API_KEY;
const DB_HOST = process.env.DB_HOST || 'localhost';
const JWT_SECRET = process.env.JWT_SECRET;
const PORT = process.env.PORT || 5000;
if (!JWT_SECRET) {
  logger.error("❌ JWT_SECRET is missing. Please check environment variables.");
  process.exit(1);
}

if (!API_KEY) {
  logger.warn("⚠️ GEMINI_API_KEY is missing. AI responses will not work.");
}
const GEMINI_API_URL = `https://generativelanguage.googleapis.com/v1/models/gemini-1.5-pro:generateContent?key=${API_KEY}`;
async function generateResponse(prompt) {
  try {
      const response = await axios.post(GEMINI_API_URL, {
          contents: [{ role: "user", parts: [{ text: prompt }] }]
      });

      logger.info("✅ Gemini response received");
      return response.data;
  } catch (error) {
      logger.error("❌ Chatbot Error:", error.response ? error.response.data : error.message);
      return { error: "Failed to generate response from Gemini AI" };
  }
}
// 🔹 Default Route
app.get('/', (req, res) => {
  res.send('Welcome to Carezy API!');
  logger.info("🏠 Root route accessed");
});

// 🔹 Serve Profile Images
app.get('/uploads/:filename', (req, res) => {
  const filePath = path.join(UPLOADS_DIR, req.params.filename);

  if (fs.existsSync(filePath)) {
      const mimeType = mime.getType(filePath);
      res.setHeader('Content-Type', mimeType || 'image/jpeg');
      res.setHeader('Cache-Control', 'no-cache, no-store, must-revalidate');
      res.setHeader('Pragma', 'no-cache');
      res.setHeader('Expires', '0');
      res.sendFile(filePath);
  } else {
      logger.warn(`⚠️ Image not found: ${req.params.filename}`);
      res.status(404).json({ error: 'Image not found' });
  }
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

      const token = jwt.sign({ userId: result.rows[0].id, email }, JWT_SECRET, { expiresIn: '1y' });

      res.json({ token, user: result.rows[0] });
      logger.info(`🆕 User registered: ${email}`);
  } catch (err) {
      logger.error("❌ User Registration Error:", err);
      res.status(500).json({ error: 'User registration failed' });
  }
});
  

// 🔹 User Login
app.post('/login', async (req, res) => {
  try {
      const { email, password } = req.body;
      const user = await pool.query('SELECT * FROM users WHERE email = $1', [email]);

      if (user.rows.length === 0) {
          logger.warn(`⚠️ Login attempt failed (User not found): ${email}`);
          return res.status(400).json({ error: 'User not found' });
      }

      const isMatch = await bcrypt.compare(password, user.rows[0].password_hash);
      if (!isMatch) {
          logger.warn(`⚠️ Login attempt failed (Invalid password): ${email}`);
          return res.status(400).json({ error: 'Invalid credentials' });
      }

      const token = jwt.sign({ userId: user.rows[0].id, email }, JWT_SECRET, { expiresIn: '1y' });

      res.json({ token, user: { id: user.rows[0].id, name: user.rows[0].name, email } });
      logger.info(`🔑 User logged in: ${email}`);
  } catch (err) {
      logger.error("❌ Login Error:", err);
      res.status(500).json({ error: 'Login failed' });
  }
});

// 🔹 Authentication Middleware
const authenticate = (req, res, next) => {
  try {
      const authHeader = req.header('Authorization');
      if (!authHeader || !authHeader.startsWith("Bearer ")) {
          return res.status(401).json({ error: "Access denied. No token provided." });
      }

      const token = authHeader.split(" ")[1];
      const verified = jwt.verify(token, JWT_SECRET);
      req.user = verified;
      next();
  } catch (err) {
      logger.warn("⚠️ JWT Verification Failed:", err.message);
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
      logger.error("❌ Fetch Profile Error:", err);
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
      logger.error("❌ Update Profile Error:", err);
      res.status(500).json({ error: "Failed to update profile" });
  }
});
// 🔹 Upload Profile Image
app.post('/api/user/upload-image', authenticate, upload.single('profileImage'), async (req, res) => {
  try {
      const imagePath = `http://${DB_HOST}:5000/uploads/${req.file.filename}`;

      await pool.query('UPDATE users SET profile_image = $1 WHERE id = $2', [imagePath, req.user.userId]);

      res.json({ message: "Profile image updated successfully", profile_image: imagePath });
      logger.info(`📸 Profile image updated for User ID: ${req.user.userId}`);
  } catch (err) {
      logger.error("❌ Upload Image Error:", err);
      res.status(500).json({ error: "Failed to upload image" });
  }
});

app.post('/moods', authenticate, async (req, res) => {
  try {
      const { mood_score, note } = req.body;
      const user_id = req.user.userId;

      if (typeof mood_score !== 'number' || !note) {
          logger.warn("⚠️ Invalid mood data provided");
          return res.status(400).json({ error: "Invalid mood data provided" });
      }

      await pool.query(
          'INSERT INTO mood_logs (user_id, mood_score, note, created_at) VALUES ($1, $2, $3, NOW())',
          [user_id, mood_score, note]
      );

      logger.info(`✅ Mood logged successfully for user ${user_id}`);
      res.json({ message: 'Mood logged successfully' });
  } catch (err) {
      logger.error(`❌ Mood Logging Error: ${err.message}`);
      res.status(500).json({ error: 'Failed to log mood' });
  }
});

// ✅ Get Mood History
app.get('/moods', authenticate, async (req, res) => {
  try {
      const user_id = req.user.userId;
      const moods = await pool.query(
          'SELECT * FROM mood_logs WHERE user_id = $1 ORDER BY created_at DESC',
          [user_id]
      );

      logger.info(`✅ Mood history retrieved for user ${user_id}`);
      res.json(moods.rows);
  } catch (err) {
      logger.error(`❌ Mood Fetch Error: ${err.message}`);
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

        logger.info("✅ Gemini Mood Analysis Response received successfully");
        return response.data;
    } catch (error) {
        logger.error(`❌ AI Mood Analysis Error: ${error.response ? JSON.stringify(error.response.data) : error.message}`);
        return { error: "Failed to analyze mood" };
    }
}

// ✅ AI Mood Analysis Route
app.post('/ai/analyze-mood', authenticate, async (req, res) => {
  try {
      const { mood_score, note } = req.body;

      if (!note || typeof mood_score !== 'number') {
          logger.warn("⚠️ Both mood_score and note are required for AI analysis");
          return res.status(400).json({ error: "Both mood_score and note are required" });
      }

      const result = await analyzeMood(mood_score, note);

      if (!result || !result.candidates?.length) {
          throw new Error("Invalid response from Gemini AI");
      }

      logger.info(`✅ AI Mood Analysis successful for user ${req.user.userId}`);
      res.json({ suggestion: result.candidates[0].content.parts[0].text });
  } catch (error) {
      logger.error(`❌ AI Mood Analysis Error: ${error.message}`);
      res.status(500).json({ error: 'AI analysis failed' });
  }
});
// ✅ Add New Task
app.post('/tasks', authenticate, async (req, res) => {
  try {
      const { title, description, due_date } = req.body;
      const user_id = req.user.userId;

      if (!title || !description || !due_date) {
          logger.warn("⚠️ Missing task data: title, description, or due_date");
          return res.status(400).json({ error: "All fields (title, description, due_date) are required" });
      }

      const result = await pool.query(
          `INSERT INTO tasks (user_id, title, description, due_date) 
           VALUES ($1, $2, $3, $4) RETURNING *`,
          [user_id, title, description, due_date]
      );

      logger.info(`✅ Task added successfully for user ${user_id}`);
      res.json({ message: 'Task added successfully', task: result.rows[0] });
  } catch (err) {
      logger.error(`❌ Task Creation Error: ${err.message}`);
      res.status(500).json({ error: 'Failed to create task' });
  }
});

// 🔹 Get All Tasks for Logged-in User
app.get('/tasks', authenticate, async (req, res) => {
  try {
      const user_id = req.user.userId;
      logger.info(`Fetching tasks for user_id: ${user_id}`);  // Log the request

      const tasks = await pool.query('SELECT * FROM tasks WHERE user_id = $1 ORDER BY created_at DESC', [user_id]);

      logger.info(`Fetched ${tasks.rows.length} tasks for user_id: ${user_id}`); // Log success

      res.json(tasks.rows);
  } catch (err) {
      logger.error(`Failed to fetch tasks for user_id: ${req.user.userId}, Error: ${err.message}`); // Log error
      console.error("❌ Fetch Tasks Error:", err);
      res.status(500).json({ error: 'Failed to fetch tasks' });
  }
});

// ✅ Update Task Status
app.put('/tasks/:task_id', authenticate, async (req, res) => {
  try {
      const { status } = req.body;
      const { task_id } = req.params;

      if (!['pending', 'completed'].includes(status)) {
          logger.warn("⚠️ Invalid task status update request");
          return res.status(400).json({ error: "Invalid status. Allowed values: 'pending', 'completed'" });
      }

      const result = await pool.query(
          `UPDATE tasks SET status = $1 WHERE task_id = $2 RETURNING *`,
          [status, task_id]
      );

      if (result.rowCount === 0) {
          logger.warn(`⚠️ Task not found: ${task_id}`);
          return res.status(404).json({ error: "Task not found" });
      }

      logger.info(`✅ Task ${task_id} updated successfully`);
      res.json({ message: 'Task updated successfully', task: result.rows[0] });
  } catch (err) {
      logger.error(`❌ Task Update Error: ${err.message}`);
      res.status(500).json({ error: 'Failed to update task' });
  }
});

// ✅ Delete a Task
app.delete('/tasks/:task_id', authenticate, async (req, res) => {
  try {
      const { task_id } = req.params;
      const result = await pool.query('DELETE FROM tasks WHERE task_id = $1 RETURNING *', [task_id]);

      if (result.rowCount === 0) {
          logger.warn(`⚠️ Task not found: ${task_id}`);
          return res.status(404).json({ error: "Task not found" });
      }

      logger.info(`✅ Task ${task_id} deleted successfully`);
      res.json({ message: 'Task deleted successfully' });
  } catch (err) {
      logger.error(`❌ Task Deletion Error: ${err.message}`);
      res.status(500).json({ error: 'Failed to delete task' });
  }
});
// 🔹 Start Server
app.listen(PORT, '0.0.0.0', () => {
  logger.info(`🚀 Server running on http://0.0.0.0:${PORT}`);
});

// ✅ Music Recommendation Route
app.post('/music-recommendation', authenticate, async (req, res) => {
  try {
      const { mood } = req.body;
      const apiKey = process.env.YOUTUBE_API_KEY;

      if (!apiKey) {
          logger.error("❌ YouTube API key is not configured");
          return res.status(500).json({ error: "YouTube API key is not configured" });
      }

      const query = `best songs for ${mood} mood`;
      const url = `https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&q=${encodeURIComponent(query)}&key=${apiKey}&maxResults=1`;

      const response = await axios.get(url);

      if (response.data.items && response.data.items.length > 0) {
          const video = response.data.items[0];
          const result = {
              title: video.snippet.title,
              videoId: video.id.videoId,
              thumbnail: video.snippet.thumbnails.medium.url,
              hashtags: video.snippet.description || "",
          };

          logger.info(`✅ Music recommendation for mood "${mood}" fetched successfully`);
          res.json(result);
      } else {
          logger.warn("⚠️ No videos found for the given mood");
          res.status(404).json({ error: "No videos found" });
      }
  } catch (err) {
      logger.error(`❌ Music Recommendation Error: ${err.message}`);
      res.status(500).json({ error: "Failed to fetch music suggestion" });
  }
});

// ✅ Chatbot Route
let conversationHistories = {}; 

app.post('/chatbot', authenticate, async (req, res) => {
  try {
      const { query } = req.body;
      const userId = req.user.userId;

      if (!query) {
          logger.warn("⚠️ Query is required for chatbot");
          return res.status(400).json({ error: "Query is required" });
      }

      if (!conversationHistories[userId]) {
          conversationHistories[userId] = [];
      }

      conversationHistories[userId].push({ role: "user", content: query });

      const prompt = conversationHistories[userId]
          .map((entry) => `${entry.role}: ${entry.content}`)
          .join("\n");

      const result = await generateResponse(prompt);

      if (!result || !result.candidates || result.candidates.length === 0) {
          throw new Error("Invalid response from Gemini API");
      }

      const botResponse = result.candidates[0].content.parts[0].text;

      conversationHistories[userId].push({ role: "bot", content: botResponse });

      logger.info(`✅ Chatbot response generated for user ${userId}`);
      res.json({ response: botResponse });
  } catch (error) {
      logger.error(`❌ Chatbot Error: ${error.message}`);
      res.status(500).json({ error: 'Failed to generate chatbot response' });
  }
});

// ✅ Email Transporter
const nodemailer = require("nodemailer");

const otpStorage = {}; 

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASS,
  },
});

// ✅ Send OTP for Password Reset
app.post("/send-reset-otp", async (req, res) => {
  const { email } = req.body;

  try {
      const userQuery = await pool.query("SELECT id FROM users WHERE email = $1", [email]);

      if (userQuery.rows.length === 0) {
          logger.warn(`⚠️ User not found for email: ${email}`);
          return res.status(400).json({ error: "❌ User not found" });
      }

      const otp = Math.floor(100000 + Math.random() * 900000).toString();
      otpStorage[email] = { otp, expiresAt: Date.now() + 300000 };

      const mailOptions = {
          from: process.env.EMAIL_USER,
          to: email,
          subject: "Carezy Password Reset OTP",
          text: `Your OTP for password reset is: ${otp}. It is valid for 5 minutes.`,
      };

      transporter.sendMail(mailOptions, (error, info) => {
          if (error) {
              logger.error(`❌ Email Sending Error: ${error.message}`);
              return res.status(500).json({ error: "Error sending OTP email" });
          }
          logger.info(`✅ OTP sent successfully to ${email}`);
          res.json({ message: "✅ OTP sent successfully!" });
      });
  } catch (err) {
      logger.error(`❌ Database Error: ${err.message}`);
      res.status(500).json({ error: "Database error" });
  }
});

// ✅ Verify OTP & Reset Password
app.post("/reset-password", async (req, res) => {
  const { email, otp, newPassword } = req.body;

  try {
      if (!otpStorage[email] || otpStorage[email].otp !== otp) {
          logger.warn(`⚠️ Invalid or expired OTP attempt for ${email}`);
          return res.status(400).json({ error: "❌ Invalid or expired OTP" });
      }

      delete otpStorage[email]; 

      const hashedPassword = await bcrypt.hash(newPassword, 10);

      await pool.query("UPDATE users SET password_hash = $1 WHERE email = $2", [hashedPassword, email]);

      logger.info(`✅ Password reset successfully for ${email}`);
      res.json({ message: "✅ Password reset successfully!" });
  } catch (err) {
      logger.error(`❌ Password Reset Error: ${err.message}`);
      res.status(500).json({ error: "Database error" });
  }
});