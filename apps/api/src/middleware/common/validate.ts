import { Request, Response, NextFunction } from "express";
import Joi from "joi";
import { AppError } from "../../utils/api.errors";

/**
 * Middleware to validate request data against a Joi schema.
 *
 * This middleware checks the validity of the incoming request data (body, params, query)
 * against a provided Joi validation schema. If validation fails, it returns a 400
 * status code with an array of error messages detailing the invalid fields. If validation
 * is successful, it proceeds to the next middleware.
 *
 * @param schema - The Joi schema to validate the request data against.
 * @returns A middleware function that validates the request data and either responds with
 *          errors or proceeds to the next middleware.
 */
export const validate: any = (schema: any) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const errors: { message: string; field: string }[] = [];

    // Validate the request against the schema
    const { error } = schema.validate(
      {
        ...req.body,
        ...req.params,
        ...req.query,
      },
      { abortEarly: false }
    );

    // Check if there is a validation error
    if (error) {
      // Iterate over each validation error and push it to the errors array
      error.details.forEach((ele: Joi.ValidationErrorItem) => {
        errors.push({
          message: ele.message,
          field: ele.path[0] as string,
        });
      });

      // Respond with the list of errors
      return new AppError(400, "Validation error", errors);
    }

    // If no validation errors, proceed to the next middleware
    next();
  };
};
