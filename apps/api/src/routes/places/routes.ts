import express from "express";
import { placesController } from "./controller";

const router = express.Router();

// GET /places - Search for nearby places
router.get("/", placesController.searchNearbyPlaces);

export default router; 