import jwt from "jsonwebtoken";
import Admin from "../../routes/admins/model";
import { catchAsyncError } from "../../utils/api.catcher";
import { ApiResponse } from "../../utils/api.response";
import { JWT_SECRET } from "../../config/env";
import { AdminRequest } from "../../types/auth";
import { IAdmin } from "../../routes/admins/type";

// middleware to authenticate admin
export const authAdmin = catchAsyncError<AdminRequest>(
  async (req, res, next) => {
    let token = req.cookies?.token;
    if (!token && req.headers.authorization && req.headers.authorization.startsWith('Bearer ')) {
      token = req.headers.authorization.split(' ')[1];
    }

    if (!token) {
      return new ApiResponse(401, "Access denied. No token provided.").send(res);
    }
    const decoded = jwt.verify(token, JWT_SECRET) as { id: string };
    const admin = await Admin.findById(decoded.id).lean() as IAdmin | null;

    if (!admin) {
      return new ApiResponse(401, "Unauthorized").send(res);
    }

    req.admin = admin;
    next();
  }
);
