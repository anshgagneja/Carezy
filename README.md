# 🌿 Carezy

**Carezy** is a full-stack mental health companion app that helps users track their well-being, manage tasks, receive AI-driven insights, and interact with a smart assistant — all in a secure and personalized environment.

---

## 🔗 Live Demo

- 🧠 **Frontend App**: [https://carezy-gwim.vercel.app](https://carezy-gwim.vercel.app)
- 🔐 **Backend API**: [https://carezy.xyz](https://carezy.xyz)

---

## ✨ Features

- 🔐 **JWT Authentication**: Secure login and signup using token-based access.
- 📅 **Task Management**: Add, update, complete, and delete your daily goals.
- 😊 **Mood Tracking**: Log your mood and attach daily notes.
- 🤖 **AI Mood Suggestions**: Gemini AI gives personalized suggestions.
- 🎵 **Mood-Based Music**: Get recommended songs from YouTube based on mood.
- 📊 **Mood Trends**: Visual graph showing mood over time.
- 💬 **Carezy Companion**: A friendly AI assistant that begins with an emotional check-in and continues as a supportive chatbot.
- 🖼️ **Profile Management**: Update your name and profile image.
- 📧 **Password Reset via OTP**: Secure reset using email-based OTP.
- 🔒 **NGINX + HTTPS + PM2 on AWS EC2** for secure and scalable hosting.

---

## 🛠️ Tech Stack

| Layer       | Stack                                       |
|-------------|---------------------------------------------|
| **Frontend**| Flutter                                     |
| **Backend** | Node.js + Express.js                        |
| **Database**| PostgreSQL (AWS RDS)                        |
| **AI**      | Gemini AI for mood analysis and chatbot     |
| **DevOps**  | AWS EC2, PM2, NGINX, Let's Encrypt (SSL)    |
| **Hosting** | Vercel (Frontend) + EC2 (Backend)           |
| **Extras**  | YouTube API for music, Gmail for OTPs       |

---

## Installation & Setup
### Prerequisites
- Flutter SDK installed
- Node.js and npm installed
- PostgreSQL installed and configured
- Firebase project set up with Authentication enabled


---

## 🚀 Getting Started

### 🔧 Backend (Node.js + PostgreSQL)

```bash
cd carezy/carezy-backend/
npm install
```
Create a .env file:
```bash
PORT=5000
DB_HOST=your-rds-endpoint
DB_USER=postgres
DB_PASSWORD=your_password
DB_PORT=5432
DB_DATABASE=postgres
JWT_SECRET=your_jwt_secret
EMAIL_USER=your_gmail
EMAIL_PASS=your_app_password
YOUTUBE_API_KEY=your_key
GEMINI_API_KEY=your_key
```

Start server:
```bash
pm2 start server.js
```
Ensure NGINX is configured for HTTPS at https://carezy.xyz.

🎯 Frontend (Flutter Web)
```bash
flutter build web
```

Then push build/web to GitHub and deploy to Vercel:

Framework: Other

Output Directory: build/web

Build Command: (leave blank)

Live: https://carezy-gwim.vercel.app

## Contributing
I welcome contributions! Feel free to fork the repo and submit pull requests.

## License
This project is licensed under the MIT License.

## Contact
For any inquiries, reach out to **me** at [anshgagneja1614@gmail.com](mailto:anshgagneja1614@gmail.com).
```
