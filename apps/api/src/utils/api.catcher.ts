import { Request, Response, NextFunction } from "express";

const error = (req: Request, error: Error) => `
==========================================================
🛑 ERROR CAUGHT IN ASYNC FUNCTION 🛑
----------------------------------------------------------
❌ Message: ${error.message}
📍 Route: ${req.method} ${req.originalUrl}
🕒 Time: ${new Date().toISOString()}
----------------------------------------------------------
🔍 Stack Trace:
${error.stack || "No stack trace available"}
==========================================================
`;

/**
 * A higher-order function that wraps an asynchronous function and catches any errors.
 * If an error occurs, it logs the error with decorations and passes it to the next middleware.
 */
export const catchAsyncError = <T extends Request = Request>(
  fn: (req: T, res: Response, next: NextFunction) => Promise<any>
) => {
  return (req: Request, res: Response, next: NextFunction): void => {
    fn(req as T, res, next).catch((err) => {
      console.error(error(req, err));
      next(err);
    });
  };
};
