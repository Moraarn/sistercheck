import express, { Request, Response, NextFunction } from "express";
import { globalErrorHandler } from "../middleware/error";
import fs from "fs";
import path from "path";
import { ApiResponse } from "./api.response";
import {
  APP_AUTHOR,
  APP_DESCRIPTION,
  APP_NAME,
  APP_VERSION,
} from "../config/env";
import { AppError } from "./api.errors";

/**
 * Gets the appropriate route file path based on environment
 * @param routesPath Base routes directory path
 * @param folder Folder name containing the route
 * @returns Full path to the route file
 */
function getRouteFilePath(routesPath: string, folder: string): string {
  // Check for TypeScript file first (development)
  const tsFile = path.join(routesPath, folder, "routes.ts");
  if (fs.existsSync(tsFile)) {
    return tsFile;
  }

  // Check for JavaScript file (production)
  const jsFile = path.join(routesPath, folder, "routes.js");
  if (fs.existsSync(jsFile)) {
    return jsFile;
  }

  return ""; // Return empty string if no file found
}

/**
 * Dynamically imports a route module
 * @param filePath Path to the route file
 * @returns Imported route module
 */
async function importRouteModule(filePath: string) {
  try {
    // Convert file path to URL format for import
    const fileUrl = `file://${filePath}`;
    const module = await import(fileUrl);
    return module;
  } catch (error) {
    // If direct import fails, try relative path import
    try {
      const relativePath = path.relative(__dirname, filePath);
      const module = await import(relativePath);
      return module;
    } catch (err) {
      console.error(`Failed to import route module: ${filePath}`, err);
      return null;
    }
  }
}

/**
 * Bootstraps the Express application by setting up routes and middleware.
 *
 * @param {express.Application} app - The Express application instance.
 * @param {string} directory - The base directory containing route folders.
 *
 * This function performs the following tasks:
 * 1. Dynamically loads all route modules from `directory/src/routes/<folder-name>/route`.
 * 2. Registers each route path to the Express application using `app.use` with `folder-name` as the route prefix.
 * 3. Handles all undefined routes by responding with a 404 error and the message "Endpoint was not found".
 * 4. Uses the global error handler middleware to manage errors.
 */
export async function bootstrap(app: express.Application, directory: string) {
  // Define a default route to handle requests to the root URL
  app.route("/").get((_req: Request, res: Response) => {
    new ApiResponse(200, "API is running", {
      name: APP_NAME,
      version: APP_VERSION,
      description: APP_DESCRIPTION,
      author: APP_AUTHOR,
      timestamp: new Date().toISOString(),
      endpoints: [],  // Will be populated after routes are loaded
      totalEndpoints: 0,
    }).send(res);
  });

  // Path to the directory containing all route folders
  const routesPath = path.join(directory, "routes");
  console.log(`Routes directory: ${routesPath}`);

  // Check if the routes directory exists
  if (!fs.existsSync(routesPath)) {
    throw new Error(`Routes directory not found: ${routesPath}`);
  }

  // Track registered routes
  const registeredRoutes: string[] = [];

  // Dynamically load route files from the specified routes directory
  const folders = fs.readdirSync(routesPath);

  for (const folder of folders) {
    const routeFile = getRouteFilePath(routesPath, folder);

    if (routeFile) {
      try {
        const module = await importRouteModule(routeFile);
        
        if (module?.default) {
          // Register the route to the Express application
          app.use(`/${folder}`, module.default);
          registeredRoutes.push(`/${folder}`);
          console.log(`Route registered: /${folder}`);
        } else {
          console.warn(`No default export found in: ${routeFile}`);
        }
      } catch (err) {
        console.error(`Failed to load route from: ${routeFile}`, err);
      }
    } else {
      console.warn(`No route file found for folder: ${folder}`);
    }
  }

  // Update root route handler with registered routes
  app.route("/").get((_req: Request, res: Response) => {
    new ApiResponse(200, "API is running", {
      name: APP_NAME,
      version: APP_VERSION,
      description: APP_DESCRIPTION,
      author: APP_AUTHOR,
      timestamp: new Date().toISOString(),
      endpoints: registeredRoutes,
      totalEndpoints: registeredRoutes.length,
    }).send(res);
  });

  // Handle undefined routes by returning a 404 error
  app.all("*", (req: Request, _res: Response, next: NextFunction) => {
    next(
      new AppError(404, "Endpoint was not found", [
        {
          field: req.originalUrl,
          message: "The requested endpoint was not found on this server.",
        },
      ])
    );
  });

  // Use the global error handler middleware to manage errors
  app.use(globalErrorHandler);
}