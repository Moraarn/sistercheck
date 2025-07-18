import jwt from "jsonwebtoken";
import { IUser } from "../../routes/users/type";
import { JWT_SECRET } from "../../config/env";
import User from "../../routes/users/model";
import { catchAsyncError } from "../../utils/api.catcher";
import { ApiResponse } from "../../utils/api.response";

// auth user middleware
export const authUser = catchAsyncError(
  async (req, res, next) => {
    let token = req.cookies?.token;
    if (!token && req.headers.authorization && req.headers.authorization.startsWith('Bearer ')) {
      token = req.headers.authorization.split(' ')[1];
    }

    if (!token) {
      return new ApiResponse(401, "Access denied. No token provided.").send(res);
    }

    const decoded = jwt.verify(token, JWT_SECRET) as { id: string };

    const user = (await User.findById(decoded.id).lean()) as IUser | null;

    if (!user) {
      return new ApiResponse(404, "Unauthorized").send(res);
    }

    (req as any).user = user;

    next();
  }
);
