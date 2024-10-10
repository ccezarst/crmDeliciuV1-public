const winston = require("winston");
module.exports = {
    announce: async function (message, req) {
        if (req != null) {
            logger.info("-" + req.ip + "- " + message);
        } else {
            logger.info(message);
        }
    },
    announceError: async function (message, req) {
        if (req != null) {
            // Use Error object to capture the call stack
            const callerStack = new Error().stack;
            // Split the stack trace into lines
            const stackLines = callerStack.split('\n');
            // The second line usually contains the caller information
            const callerLine = stackLines[2].trim();
            logger.error("-" + req.ip + "- " + message);
            logger.error(callerLine)
        } else {
            logger.error(message);
        }
    },
}
const logFormat = winston.format.printf(({ level, message, timestamp }) => {
    return `${timestamp} [${level.toUpperCase()}]: ${message}`;
});
let date_ob = new Date();
const logger = winston.createLogger({
    level: 'info',
    format: winston.format.combine(winston.format.timestamp(), logFormat,),
    exitOnError: false,
    timestamp: true,
    transports: [
        new winston.transports.Console(),
        new winston.transports.File({ filename: 'logs/' + date_ob.getFullYear() + "/" + "Luna " + (date_ob.getMonth() + 1) + "/" + "Ziua " + date_ob.getDate() + "/" + 'error.log', level: 'error' }),
        new winston.transports.File({ filename: 'logs/' + date_ob.getFullYear() + "/" + "Luna " + (date_ob.getMonth() + 1) + "/" + "Ziua " + date_ob.getDate() + "/" + 'combined.log' }),
    ],
});