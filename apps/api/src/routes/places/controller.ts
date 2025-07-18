import { Request, Response, NextFunction } from "express";
import { placesService } from "./service";
import { ApiResponse } from "../../utils/api.response";
import { AppError } from "../../utils/api.errors";

export const placesController = {
  /**
   * Search for nearby places using Google Places API
   * @param req - Express request object
   * @param res - Express response object
   * @param next - Express next function
   */
  searchNearbyPlaces: async (
    req: Request,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const { location, radius = "3000", type = "hospital|clinic" } = req.query;

      if (!location) {
        throw new AppError(400, "Location parameter is required", [
          {
            field: "location",
            message: "Location coordinates (lat,lng) are required",
          },
        ]);
      }

      const result = await placesService.searchNearbyPlaces(
        location as string,
        radius as string,
        type as string
      );

      new ApiResponse(200, "Places found successfully", result).send(res);
    } catch (error) {
      next(error);
    }
  },
}; 