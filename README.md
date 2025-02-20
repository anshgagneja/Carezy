# Carezy

Carezy is a mental health app designed to provide users with a seamless and engaging experience to enhance their mental well-being. The app integrates Firebase authentication, JWT-based authentication, AI-powered mood analysis, and a robust backend to ensure a smooth and secure user experience.

## Features
- **User Authentication**: Secure login and signup using Firebase Authentication and JWT.
- **Home Screen**: A dashboard providing access to key features.
- **Task Management Screen**: Users can create and manage their daily tasks.
- **Mood Tracking**: Users can log their mood and receive AI-powered suggestions.
- **Mood-Based Music**: Get music recommendations based on the logged mood.
- **Mood Trends Graph**: Visual representation of mood trends using `fl_chart`.
- **Profile Screen**: Allows users to manage their personal details and preferences.
- **Carezy Companion**: A virtual assistant that first asks a set of questions and then generates a response accordingly. After the initial assessment, users can continue chatting with it like a bot for further guidance and support.

## Tech Stack
- **Frontend**: Flutter
- **Backend**: Node.js with Express.js
- **Database**: PostgreSQL
- **Authentication**: Firebase Authentication & JWT
- **AI Integration**: AI-powered mood analysis and chatbot interaction

## Installation & Setup
### Prerequisites
- Flutter SDK installed
- Node.js and npm installed
- PostgreSQL installed and configured
- Firebase project set up with Authentication enabled

### Backend Setup
1. Clone the repository:
   ```sh
   git clone https://github.com/anshgagneja/carezy.git
   cd carezy/carezy_backend
   ```
2. Install dependencies:
   ```sh
   npm install
   ```
3. Configure environment variables:
   Create a `.env` file in the `carezy_backend` directory and add the necessary variables (database credentials, Firebase config, etc.).
4. Start the backend server:
   ```sh
   npm start
   ```

### Frontend Setup
1. Install dependencies:
   ```sh
   flutter pub get
   ```
2. Run the app:
   ```sh
   flutter run
   ```

## Contributing
We welcome contributions! Feel free to fork the repo and submit pull requests.

## License
This project is licensed under the MIT License.

## Contact
For any inquiries, reach out to **me** at [anshgagneja1614@gmail.com](mailto:anshgagneja1614@gmail.com).
```
