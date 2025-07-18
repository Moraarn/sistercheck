import mongoose from "mongoose";
import { MONGODB_URI } from "./env";

export function dbConnection() {
  mongoose
    .connect(MONGODB_URI)
    .then(() => {
      console.log("DB Connected Succesfully");
    })
    .catch((error) => {
      console.log("DB Failed to connect", error);
    });
}
