import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../plugins/theme/theme_provider.dart';
import '../plugins/theme/colors.dart';

class SisterChatScreen extends ConsumerStatefulWidget {
  const SisterChatScreen({super.key});

  @override
  ConsumerState<SisterChatScreen> createState() => _SisterChatScreenState();
}

class _SisterChatScreenState extends ConsumerState<SisterChatScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  final List<Map<String, dynamic>> messages = [
    {
      'from': 'Amina',
      'text': 'Hi! I\'m Amina, your peer support Sister. I\'m here to listen and support you.',
      'time': '10:30 AM',
      'isMe': false,
    },
    {
      'from': 'You',
      'text': 'Thank you, I feel anxious about my symptoms.',
      'time': '10:32 AM',
      'isMe': true,
    },
    {
      'from': 'Amina',
      'text': 'You are not alone. Many women experience similar feelings. Would you like to talk more about what\'s worrying you?',
      'time': '10:33 AM',
      'isMe': false,
    },
    {
      'from': 'You',
      'text': 'I\'ve been having irregular periods and some pain.',
      'time': '10:35 AM',
      'isMe': true,
    },
    {
      'from': 'Amina',
      'text': 'I understand this can be concerning. Have you considered speaking with a healthcare provider about these symptoms?',
      'time': '10:36 AM',
      'isMe': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    
    _animationController.forward();
    
    // Scroll to bottom after animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        messages.add({
          'from': 'You',
          'text': _messageController.text.trim(),
          'time': _getCurrentTime(),
          'isMe': true,
        });
      });
      _messageController.clear();
      _scrollToBottom();
    }
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  void _endSession() {
    showDialog(
      context: context,
      builder: (context) => _buildEndSessionDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider) == ThemeMode.dark 
        ? AppColors.dark 
        : AppColors.light;

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.volunteer_activism,
                color: colors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Amina',
                  style: TextStyle(
                    color: colors.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Peer Support Sister',
                  style: TextStyle(
                    color: colors.secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: colors.card,
        elevation: 0,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.text),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: colors.text),
            onPressed: () {
              _showOptionsDialog(context, colors);
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colors.primary.withOpacity(0.05),
                  colors.scaffoldBackground,
                ],
              ),
            ),
            child: Column(
              children: [
                // Chat messages
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      return _buildMessageBubble(msg, colors);
                    },
                  ),
                ),
                
                // Input area
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.card,
                    boxShadow: [
                      BoxShadow(
                        color: colors.border.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: colors.inputFieldBg,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: colors.border,
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: 'Type your message...',
                              hintStyle: TextStyle(color: colors.secondaryText),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            style: TextStyle(color: colors.text),
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.send, color: Colors.white),
                          onPressed: _sendMessage,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, AppColors colors) {
    final isMe = message['isMe'];
    
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? colors.primary : colors.card,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(4),
                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.border.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message['text'],
                style: TextStyle(
                  fontSize: 16,
                  color: isMe ? Colors.white : colors.text,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: EdgeInsets.only(
                left: isMe ? 0 : 16,
                right: isMe ? 16 : 0,
              ),
              child: Text(
                message['time'],
                style: TextStyle(
                  fontSize: 12,
                  color: colors.secondaryText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsDialog(BuildContext context, AppColors colors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Chat Options',
          style: TextStyle(color: colors.text),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.feedback, color: colors.primary),
              title: Text('Give Feedback', style: TextStyle(color: colors.text)),
              onTap: () {
                Navigator.pop(context);
                _showFeedbackDialog(context, colors);
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.red),
              title: Text('End Session', style: TextStyle(color: colors.text)),
              onTap: () {
                Navigator.pop(context);
                _endSession();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: colors.secondaryText)),
          ),
        ],
      ),
    );
  }

  Widget _buildEndSessionDialog() {
    final colors = ref.watch(themeProvider) == ThemeMode.dark 
        ? AppColors.dark 
        : AppColors.light;
        
    return AlertDialog(
      backgroundColor: colors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.exit_to_app, color: Colors.red),
          const SizedBox(width: 8),
          Text(
            'End Session',
            style: TextStyle(color: colors.text),
          ),
        ],
      ),
      content: Text(
        'Thank you for chatting with Amina. Your conversation has been helpful. Would you like to share feedback before ending?',
        style: TextStyle(color: colors.secondaryText),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: colors.secondaryText)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Session ended. Thank you for using SisterCheck!'),
                backgroundColor: colors.primary,
              ),
            );
          },
          child: Text('End Session'),
        ),
      ],
    );
  }

  void _showFeedbackDialog(BuildContext context, AppColors colors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Share Feedback',
          style: TextStyle(color: colors.text),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'How was your experience with Amina?',
              style: TextStyle(color: colors.secondaryText),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.sentiment_very_dissatisfied, color: Colors.red),
                  onPressed: () => _submitFeedback('Poor'),
                ),
                IconButton(
                  icon: Icon(Icons.sentiment_dissatisfied, color: Colors.orange),
                  onPressed: () => _submitFeedback('Fair'),
                ),
                IconButton(
                  icon: Icon(Icons.sentiment_satisfied, color: Colors.yellow),
                  onPressed: () => _submitFeedback('Good'),
                ),
                IconButton(
                  icon: Icon(Icons.sentiment_very_satisfied, color: Colors.green),
                  onPressed: () => _submitFeedback('Excellent'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: colors.secondaryText)),
          ),
        ],
      ),
    );
  }

  void _submitFeedback(String rating) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Thank you for your feedback!'),
        backgroundColor: ref.read(themeProvider) == ThemeMode.dark 
            ? AppColors.dark.primary 
            : AppColors.light.primary,
      ),
    );
  }
} 