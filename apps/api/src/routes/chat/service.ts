import { Message, ChatRoom } from "./model";
import { IMessage, IChatRoom } from "./type";
import { Types } from "mongoose";
import { AppError } from "../../utils/api.errors";

export class ChatService {
  /**
   * Send a message
   */
  async sendMessage(messageData: Partial<IMessage>) {
    const message = await Message.create(messageData);
    
    // Update or create chat room
    await this.updateChatRoom(messageData.senderId!, messageData.receiverId!, message._id.toString());
    
    return message.toObject();
  }

  /**
   * Get messages between two users
   */
  async getMessages(userId1: string, userId2: string, query: any) {
    const apiFeature = new (
      await import("../../utils/api.features")
    ).ApiFeatures(
      Message.find({
        $or: [
          { senderId: userId1, receiverId: userId2 },
          { senderId: userId2, receiverId: userId1 }
        ]
      }),
      query
    )
      .pagination()
      .sort();

    return await apiFeature.getPaginatedData<[]>();
  }

  /**
   * Get user's chat rooms
   */
  async getUserChatRooms(userId: string) {
    return await ChatRoom.find({ participants: userId })
      .populate('lastMessage')
      .sort({ updatedAt: -1 })
      .lean();
  }

  /**
   * Mark messages as read
   */
  async markMessagesAsRead(senderId: string, receiverId: string) {
    return await Message.updateMany(
      { senderId, receiverId, isRead: false },
      { isRead: true }
    );
  }

  /**
   * Get unread message count
   */
  async getUnreadCount(userId: string) {
    return await Message.countDocuments({
      receiverId: userId,
      isRead: false
    });
  }

  /**
   * Update or create chat room
   */
  private async updateChatRoom(senderId: string, receiverId: string, messageId: string) {
    const participants = [senderId, receiverId].sort();
    
    await ChatRoom.findOneAndUpdate(
      { participants },
      {
        lastMessage: messageId,
        $inc: { [`unreadCount.${receiverId}`]: 1 }
      },
      { upsert: true, new: true }
    );
  }

  /**
   * Delete a message
   */
  async deleteMessage(messageId: string, userId: string) {
    const message = await Message.findById(messageId);
    
    if (!message) {
      throw new AppError(404, "Message not found");
    }
    
    if (message.senderId !== userId) {
      throw new AppError(403, "You can only delete your own messages");
    }
    
    return await Message.findByIdAndDelete(messageId).lean();
  }
} 