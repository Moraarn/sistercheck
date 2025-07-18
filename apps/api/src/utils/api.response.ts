import { Response } from "express";
import { IAppResponse, EResponseStatus } from "../types/global";

/**
 * ApiResponse class is used to structure API responses in a consistent format.
 * It helps in sending success or error responses with relevant status code, message, data, and errors.
 */
export class ApiResponse {
  private statusCode: number;
  private message: string;
  private data: any | null;
  private errors: any[] | null;

  constructor(
    statusCode: number = 200,
    message: string,
    data: any = null,
    errors: any[] | null = null
  ) {
    this.statusCode = statusCode;
    this.message = message;
    this.data = data;
    this.errors = errors;
  }

  private deriveStatusFromCode(statusCode: number): EResponseStatus {
    if (statusCode >= 200 && statusCode < 300) {
      return EResponseStatus.SUCCESS;
    }
    return EResponseStatus.ERROR;
  }

  /**
   * Sends the structured API response.
   *
   * @param res - The Express response object.
   */
  public send(res: Response): void {
    const status = this.deriveStatusFromCode(this.statusCode);
    const response: IAppResponse = {
      status,
      message: this.message,
      success: status === EResponseStatus.SUCCESS,
      ...this.data,
      ...(this.errors !== null && { errors: this.errors }),
    };

    res.status(this.statusCode).json(response);
  }
}
