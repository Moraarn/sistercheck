import axios from "axios";
import { GOOGLE_MAPS_API_KEY } from "../../config/env";

export const placesService = {
  /**
   * Search for nearby places using Google Places API
   * @param location - Location coordinates in "lat,lng" format
   * @param radius - Search radius in meters
   * @param type - Place types to search for
   * @returns Promise with places data
   */
  searchNearbyPlaces: async (
    location: string,
    radius: string,
    type: string
  ) => {
    try {
      if (!GOOGLE_MAPS_API_KEY) {
        throw new Error("Google Maps API key is not configured");
      }

      // Parse location coordinates
      const [lat, lng] = location.split(",").map(coord => parseFloat(coord.trim()));
      
      if (isNaN(lat) || isNaN(lng)) {
        throw new Error("Invalid location coordinates format. Expected 'lat,lng'");
      }

      // Build the Google Places API URL
      const baseUrl = "https://maps.googleapis.com/maps/api/place/nearbysearch/json";
      const params = new URLSearchParams({
        location: `${lat},${lng}`,
        radius: radius,
        type: type,
        key: GOOGLE_MAPS_API_KEY,
      });

      const url = `${baseUrl}?${params.toString()}`;

      // Make the request to Google Places API
      const response = await axios.get(url);
      const data = response.data;

      if (data.status === "OK") {
        return {
          status: "OK",
          results: data.results,
        };
      } else {
        throw new Error(`Google Places API error: ${data.status} - ${data.error_message || "Unknown error"}`);
      }
    } catch (error) {
      console.error("Error fetching places from Google API:", error);
      throw error;
    }
  },
}; 