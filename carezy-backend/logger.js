const { createLogger, format, transports } = require('winston');

const logger = createLogger({
    level: process.env.NODE_ENV === 'production' ? 'info' : 'debug',  // 🔹 Log only "info" and above in production
    format: format.combine(
        format.timestamp(),
        format.printf(({ timestamp, level, message }) => {
            return `${timestamp} [${level.toUpperCase()}]: ${message}`;
        })
    ),
    transports: [
        new transports.Console(),  // ✅ Log to console
        new transports.File({ filename: 'logs/app.log' })  // ✅ Log to file
    ]
});

module.exports = logger;
