import express from "express";
import morgan from "morgan";
import cors from "cors";
import cookieParser from "cookie-parser";
import { dbConnection } from "./config/db";
import { bootstrap } from "./utils/api.bootstrap";
import { PORT } from "./config/env";

// Import Crystal AI routes
import crystalAIRoutes from "./routes/crystal-ai/routes";

// Global type declaration
declare global {
  namespace Express {
    interface Request {
      user?: {
        _id?: string;
        patientId?: string;
        email?: string;
        type?: string;
        role?: string;
        [key: string]: any;
      };
    }
  }
}

/**
 * Initializes an Express application.
 * @see {@link https://expressjs.com/} for more information about Express.
 */
const port = PORT;
const app = express();

// Middleware to parse incoming requests with JSON payloads
app.use(cookieParser());

// Middleware to allow cross-origin requests
app.use(cors());

// Middleware to log incoming requests to the console
app.use(morgan("dev"));

// Middleware to parse incoming requests with JSON payloads
app.use(express.json());

// Middleware to parse incoming requests with URL-encoded payloads
bootstrap(app, __dirname);

// Manually register Crystal AI routes
app.use("/crystal-ai", crystalAIRoutes);
console.log("🔧 Crystal AI routes registered at /crystal-ai");

// Debug: List all registered routes
app._router.stack.forEach((middleware: any) => {
  if (middleware.route) {
    console.log(`📍 Route: ${middleware.route.stack[0].method.toUpperCase()} ${middleware.route.path}`);
  } else if (middleware.name === 'router') {
    middleware.handle.stack.forEach((handler: any) => {
      if (handler.route) {
        console.log(`📍 Route: ${handler.route.stack[0].method.toUpperCase()} ${middleware.regexp.source}${handler.route.path}`);
      }
    });
  }
});

// Connect to the database
dbConnection();

// Start the server
app.listen(port, '0.0.0.0', () => {
  console.log(`Server listening on http://localhost:${port}`);
  console.log(`Server also accessible on http://192.168.1.136:${port}`);
});