
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../plugins/network_provider.dart';

// Crystal AI Session model
class CrystalAISession {
  final String sessionId;
  final String title;
  final DateTime createdAt;
  final DateTime? lastMessageAt;
  final int messageCount;
  final String lastMessage;
  final DateTime updatedAt;

  CrystalAISession({
    required this.sessionId,
    required this.title,
    required this.createdAt,
    this.lastMessageAt,
    required this.messageCount,
    required this.lastMessage,
    required this.updatedAt,
  });

  factory CrystalAISession.fromJson(Map<String, dynamic> json) {
    return CrystalAISession(
      sessionId: json['sessionId'] ?? '',
      title: json['title'] ?? 'New Conversation',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      lastMessageAt: json['lastMessageAt'] != null 
          ? DateTime.tryParse(json['lastMessageAt']) 
          : null,
      messageCount: json['messageCount'] ?? 0,
      lastMessage: json['lastMessage'] ?? 'No messages yet',
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? json['lastMessageAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'messageCount': messageCount,
      'lastMessage': lastMessage,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

// Crystal AI Message model
class CrystalAIMessage {
  final String messageId;
  final String messageType; // 'user' or 'assistant'
  final String message;
  final String? response;
  final DateTime timestamp;

  CrystalAIMessage({
    required this.messageId,
    required this.messageType,
    required this.message,
    this.response,
    required this.timestamp,
  });

  factory CrystalAIMessage.fromJson(Map<String, dynamic> json) {
    return CrystalAIMessage(
      messageId: json['messageId'] ?? '',
      messageType: json['messageType'] ?? 'user',
      message: json['message'] ?? '',
      response: json['response'],
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'messageType': messageType,
      'message': message,
      'response': response,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class CrystalAIService {
  final NetworkProvider _network;

  CrystalAIService(this._network);

  // Provider for CrystalAIService
  static final provider = Provider<CrystalAIService>((ref) {
    final network = ref.watch(networkProvider);
    return CrystalAIService(network);
  });

  // Provider for chat sessions
  static final chatSessionsProvider = FutureProvider<List<CrystalAISession>>((ref) async {
    final service = ref.watch(provider);
    return await service.getChatSessions();
  });

  // Provider for crystal AI service
  static final crystalAIServiceProvider = Provider<CrystalAIService>((ref) {
    final network = ref.watch(networkProvider);
    return CrystalAIService(network);
  });

  // Send message to Crystal AI - Use Node.js backend
  Future<Map<String, dynamic>> sendMessage({
    required String message,
    String? context,
  }) async {
    try {
      print('🤖 Flutter: Sending message to Crystal AI: $message');
      
      final response = await _network.submitToNodeJS(
        method: HttpMethod.post,
        path: '/crystal-ai/talk',
        body: {
          'message': message,
          if (context != null) 'context': context,
        },
      );

      print('🤖 Flutter: Response success: ${response.success}');
      print('🤖 Flutter: Response data: ${response.data}');
      print('🤖 Flutter: Response message: ${response.message}');

      if (response.success) {
        final result = {
          'success': true,
          'message': response.data?['message'] ?? 'No response from Crystal',
          'response': response.data?['response'] ?? 'No response from Crystal',
          'sessionId': response.data?['sessionId'],
        };
        print('🤖 Flutter: Returning result: $result');
        return result;
      } else {
        final result = {
          'success': false,
          'message': response.message ?? 'Failed to get response from Crystal',
        };
        print('🤖 Flutter: Returning error result: $result');
        return result;
      }
    } catch (e) {
      print('🤖 Flutter: Exception occurred: $e');
      return {
        'success': false,
        'message': 'Error communicating with Crystal: $e',
      };
    }
  }

  // Get chat history - Use Node.js backend
  Future<Map<String, dynamic>> getChatHistory() async {
    try {
      final response = await _network.getFromNodeJS('/crystal-ai/sessions');

      if (response.success) {
        return {
          'success': true,
          'history': response.data?['sessions'] ?? [],
        };
      } else {
        return {
          'success': false,
          'message': response.message ?? 'Failed to get chat history',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error getting chat history: $e',
      };
    }
  }

  // Get chat sessions - Use Node.js backend
  Future<List<CrystalAISession>> getChatSessions() async {
    try {
      final response = await _network.getFromNodeJS('/crystal-ai/sessions');

      if (response.success) {
        final List<dynamic> sessionsData = response.data?['sessions'] ?? [];
        return sessionsData.map((session) => CrystalAISession.fromJson(session)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error getting chat sessions: $e');
      return [];
    }
  }

  // Get session with messages - Use Node.js backend
  Future<Map<String, dynamic>> getSessionWithMessages(String sessionId) async {
    try {
      final response = await _network.getFromNodeJS('/crystal-ai/sessions/$sessionId');

      if (response.success) {
        final sessionData = response.data?['session'];
        final messagesData = response.data?['messages'] ?? [];
        
        final session = CrystalAISession.fromJson(sessionData);
        final messages = messagesData.map((msg) => CrystalAIMessage.fromJson(msg)).toList();
        
        return {
          'session': session,
          'messages': messages,
        };
      } else {
        return {
          'session': null,
          'messages': [],
        };
      }
    } catch (e) {
      print('Error getting session with messages: $e');
      return {
        'session': null,
        'messages': [],
      };
    }
  }

  // Delete session - Use Node.js backend
  Future<bool> deleteSession(String sessionId) async {
    try {
      final response = await _network.submitToNodeJS(
        method: HttpMethod.delete,
        path: '/crystal-ai/sessions/$sessionId',
      );

      return response.success;
    } catch (e) {
      print('Error deleting session: $e');
      return false;
    }
  }
} 