import Joi from "joi";

export enum ENodeEnv {
  DEVELOPMENT = "development",
  PRODUCTION = "production",
}

export enum EResponseStatus {
  SUCCESS = "success",
  ERROR = "error",
}

export interface IAppResponse {
  status: EResponseStatus;
  message: string;
  // data will be spread into the response
  [key: string]: any;
  errors?: any[] | null;
}

// validate mongoose id schema using joi
export const idSchema = Joi.object({
  id: Joi.string().regex(/^[0-9a-fA-F]{24}$/),
}).unknown(true);
