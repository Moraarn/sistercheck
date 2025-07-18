import { Response } from "express";
import jwt from "jsonwebtoken";

const generateTokenAndSetCookies = (id: string, res: Response) => {
  console.log(process.env.JWT_SECRET);
  const token = jwt.sign({ id }, process.env.JWT_SECRET || "", {
    expiresIn: "15d",
  });

  res.cookie("token", token, {
    maxAge: 15 * 24 * 60 * 60 * 1000, 
    httpOnly: true,
    sameSite: "strict",
    secure: process.env.NODE_ENV === "production", 
  });

  return token;
};

export default generateTokenAndSetCookies;
