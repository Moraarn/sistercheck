/**
 * @file Defines the custom error class `AppError` used for handling application-specific errors.
 */

/**
 * Represents an application-specific error with a status code and optional additional errors.
 *
 * @extends {Error}
 */
export class AppError extends Error {
  statusCode: number;
  errors: any;

  constructor(statusCode: number, message: string, errors: any = null) {
    super(message);
    this.statusCode = statusCode;
    this.errors = errors;

    // Ensures the error is properly identified as operational
    Error.captureStackTrace(this, this.constructor);
  }
}
