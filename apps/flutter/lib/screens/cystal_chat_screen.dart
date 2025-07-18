import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:sistercheck/services/crystal_ai_service.dart';
import '../plugins/theme/theme_provider.dart';
import '../plugins/theme/colors.dart';
import '../plugins/app_provider.dart'; // Added for authentication state

class CystalChatScreen extends ConsumerStatefulWidget {
  final String? sessionId;
  
  const CystalChatScreen({super.key, this.sessionId});

  @override
  ConsumerState<CystalChatScreen> createState() => _CystalChatScreenState();
}

class _CystalChatScreenState extends ConsumerState<CystalChatScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Speech recognition
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;
  String _lastWords = '';
  
  // Text to speech
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  
  List<Map<String, dynamic>> messages = [];
  String? currentSessionId;
  bool _isLoading = false;
  bool _isTyping = false;
  bool _isMuted = true; // Default to chat mode (muted)

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
    
    // Initialize speech recognition and TTS
    _initSpeech();
    _initTTS();
    
    // Initialize messages
    _initializeMessages();
  }

  Future<void> _initSpeech() async {
    try {
      print('🎤 Initializing speech recognition...');
      
      // Check available locales first
      final locales = await _speech.locales();
      print('🌍 Available locales: ${locales.length}');
      for (var locale in locales.take(5)) {
        print('   - ${locale.localeId}: ${locale.name}');
      }
      
      // Try to initialize with minimal parameters
      print('🔧 Attempting speech initialization...');
      _speechEnabled = await _speech.initialize(
        onError: (error) {
          print('❌ Speech recognition error: ${error.errorMsg}');
          setState(() {
            _isListening = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Speech recognition error: ${error.errorMsg}'),
              backgroundColor: Colors.red,
            ),
          );
        },
        onStatus: (status) {
          print('📊 Speech status: $status');
          if (status == 'done' || status == 'notListening') {
            setState(() {
              _isListening = false;
            });
            // If we have recognized text, add it to the message controller
            if (_lastWords.isNotEmpty) {
              print('🎯 Recognized: $_lastWords');
              _messageController.text = _lastWords;
              _lastWords = '';
            }
          }
        },
      );
      
      print('🎤 Speech enabled: $_speechEnabled');
      
      if (_speechEnabled) {
        print('✅ Speech recognition initialized successfully!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Speech recognition is ready!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        print('❌ Speech recognition initialization failed');
        print('🔍 Trying to get more error information...');
        
        // Try to get more information about why it failed
        try {
          final hasPermission = await _speech.hasPermission;
          print('🔐 Has permission: $hasPermission');
        } catch (e) {
          print('❌ Could not check permission: $e');
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Speech recognition not available on this device'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('❌ Speech init failed: $e');
      print('❌ Error type: ${e.runtimeType}');
      setState(() {
        _speechEnabled = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to initialize speech recognition: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _initTTS() async {
    try {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      
      _flutterTts.setStartHandler(() {
        setState(() {
          _isSpeaking = true;
        });
      });
      
      _flutterTts.setCompletionHandler(() {
        setState(() {
          _isSpeaking = false;
        });
      });
      
      _flutterTts.setErrorHandler((msg) {
        setState(() {
          _isSpeaking = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Text-to-speech error: $msg'),
            backgroundColor: Colors.red,
          ),
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to initialize text-to-speech: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _startListening() async {
    print('🎤 Start listening called');
    
    if (!_speechEnabled) {
      print('🔄 Initializing speech...');
      await _initSpeech();
      
      if (!_speechEnabled) {
        print('❌ Speech not available, showing voice input options');
        _showVoiceInputOptions();
        return;
      }
    }

    if (_isListening) {
      print('🛑 Stopping...');
      await _stopListening();
      return;
    }

    try {
      print('🎤 Starting...');
      setState(() {
        _isListening = true;
        _lastWords = '';
      });

      await _speech.listen(
        onResult: (result) {
          print('🎯 Result: ${result.recognizedWords}');
          setState(() {
            _lastWords = result.recognizedWords;
          });
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: 'en_US',
        cancelOnError: false,
        listenMode: stt.ListenMode.dictation,
      );
      print('✅ Started successfully');
    } catch (e) {
      print('❌ Start failed: $e');
      setState(() {
        _isListening = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start speech recognition: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _stopListening() async {
    try {
      await _speech.stop();
      setState(() {
        _isListening = false;
      });
    } catch (e) {
      setState(() {
        _isListening = false;
      });
    }
  }

  Future<void> _speakText(String text) async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      setState(() {
        _isSpeaking = false;
      });
      return;
    }

    try {
      await _flutterTts.speak(text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to speak text: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _initializeMessages() async {
    if (widget.sessionId != null) {
      // Load existing session
      currentSessionId = widget.sessionId;
      await _loadSession(widget.sessionId!);
    } else {
      // Start new session with welcome message
      messages = [
        {
          'from': 'CYSTAL',
          'text': 'Hi! I\'m CYSTAL, your AI health assistant. You can type or use voice input. How can I help you today?',
          'time': _getCurrentTime(),
          'isMe': false,
        },
      ];
    }
    
    // Scroll to bottom after animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  Future<void> _loadSession(String sessionId) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final sessionData = await ref.read(CrystalAIService.crystalAIServiceProvider).getSessionWithMessages(sessionId);
      final session = sessionData['session'] as CrystalAISession;
      final sessionMessages = sessionData['messages'] as List<CrystalAIMessage>;

      setState(() {
        messages = sessionMessages.map((msg) {
          return {
            'from': msg.messageType == 'user' ? 'You' : 'CYSTAL',
            'text': msg.messageType == 'user' ? msg.message : msg.response,
            'time': _formatTime(msg.timestamp),
            'isMe': msg.messageType == 'user',
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        messages = [
          {
            'from': 'CYSTAL',
            'text': 'Hi! I\'m CYSTAL, your AI health assistant. You can type or use voice input. How can I help you today?',
            'time': _getCurrentTime(),
            'isMe': false,
          },
        ];
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load chat history: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _speech.cancel();
    _flutterTts.stop();
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

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty && !_isTyping) {
      final userMessage = _messageController.text.trim();
      
      print('🤖 Flutter Chat: Sending message: $userMessage');
      
      setState(() {
        messages.add({
          'from': 'You',
          'text': userMessage,
          'time': _getCurrentTime(),
          'isMe': true,
        });
        _isTyping = true;
      });
      
      _messageController.clear();
      _scrollToBottom();
      
      try {
        // Check authentication state
        final appState = ref.watch(appNotifierProvider);
        print('🤖 Flutter Chat: Auth state - isAuthenticated: ${appState.isAuthenticated}, isPatientAuthenticated: ${appState.isPatientAuthenticated}');
        print('🤖 Flutter Chat: Auth tokens - authToken: ${appState.authToken != null ? 'exists' : 'null'}, patientToken: ${appState.patientToken != null ? 'exists' : 'null'}');
        
        final crystalService = ref.read(CrystalAIService.crystalAIServiceProvider);
        print('🤖 Flutter Chat: Calling Crystal AI service...');
        
        final result = await crystalService.sendMessage(
          message: userMessage,
        );

        print('🤖 Flutter Chat: Crystal AI result: $result');

        if (result['success']) {
          final crystalResponse = result['response'];
          print('🤖 Flutter Chat: Crystal response: $crystalResponse');
          
          setState(() {
            messages.add({
              'from': 'CYSTAL',
              'text': crystalResponse,
              'time': _getCurrentTime(),
              'isMe': false,
            });
            currentSessionId = result['sessionId'];
            _isTyping = false;
          });
          
          // Automatically speak CYSTAL's response
          await _speakText(crystalResponse);
        } else {
          final errorResponse = 'I\'m sorry, I\'m having trouble responding right now. Please try again later.';
          print('🤖 Flutter Chat: Error response: ${result['message']}');
          
          setState(() {
            messages.add({
              'from': 'CYSTAL',
              'text': errorResponse,
              'time': _getCurrentTime(),
              'isMe': false,
            });
            _isTyping = false;
          });
          
          // Speak error response
          await _speakText(errorResponse);
        }
      } catch (e) {
        print('🤖 Flutter Chat: Exception occurred: $e');
        final errorResponse = 'I\'m sorry, I\'m having trouble connecting right now. Please check your internet connection.';
        setState(() {
          messages.add({
            'from': 'CYSTAL',
            'text': errorResponse,
            'time': _getCurrentTime(),
            'isMe': false,
          });
          _isTyping = false;
        });
        
        // Speak error response
        await _speakText(errorResponse);
      }
      
      _scrollToBottom();
    }
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return _formatTime(now);
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
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
                Icons.psychology,
                color: colors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CYSTAL',
                  style: TextStyle(
                    color: colors.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'AI Health Assistant',
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
          // Mute/Unmute button
          IconButton(
            icon: Icon(
              _isMuted ? Icons.mic_off : Icons.mic,
              color: _isMuted ? colors.secondaryText : colors.primary,
            ),
            onPressed: () {
              setState(() {
                _isMuted = !_isMuted;
              });
              if (!_isMuted) {
                // If unmuting, initialize speech
                _initSpeech();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Voice mode enabled. Tap the mic button to speak.'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              } else {
                // If muting, stop any ongoing speech
                _stopListening();
                _flutterTts.stop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Chat mode enabled.'),
                    backgroundColor: Colors.blue,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            tooltip: _isMuted ? 'Enable Voice Mode' : 'Enable Chat Mode',
          ),
          IconButton(
            icon: Icon(Icons.info_outline, color: colors.primary),
            onPressed: () {
              _showInfoDialog(context, colors);
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: colors.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Loading chat...',
                    style: TextStyle(color: colors.secondaryText),
                  ),
                ],
              ),
            )
          : FadeTransition(
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
                      // Speech recognition indicator
                      if (_isListening)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          color: colors.primary.withOpacity(0.1),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _messageController.text,
                                  style: TextStyle(
                                    color: colors.text,
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                              Text(
                                'Tap to stop',
                                style: TextStyle(
                                  color: colors.secondaryText,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      // Chat messages
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: messages.length + (_isTyping ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == messages.length && _isTyping) {
                              return _buildTypingIndicator(colors);
                            }
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
                            // Microphone button
                            Container(
                              decoration: BoxDecoration(
                                color: _isMuted ? colors.border : (_isListening ? Colors.red : colors.primary),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  _isListening ? Icons.stop : (_isMuted ? Icons.mic_off : Icons.mic),
                                  color: _isMuted ? colors.secondaryText : Colors.white,
                                ),
                                onPressed: _isMuted ? null : _startListening,
                                tooltip: _isMuted ? 'Enable voice mode in settings' : 'Tap to speak',
                              ),
                            ),
                            const SizedBox(width: 12),
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
                                  enabled: !_isTyping && !_isListening,
                                  decoration: InputDecoration(
                                    hintText: _isTyping 
                                        ? 'CYSTAL is typing...' 
                                        : (_isListening 
                                            ? 'Listening...' 
                                            : (_isMuted 
                                                ? 'Type your message...' 
                                                : 'Type your message or tap the mic...')),
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
                                color: (_isTyping || _isListening) ? colors.border : colors.primary,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.send, 
                                  color: (_isTyping || _isListening) ? colors.secondaryText : Colors.white
                                ),
                                onPressed: (_isTyping || _isListening) ? null : _sendMessage,
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

  Widget _buildTypingIndicator(AppColors colors) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomLeft: const Radius.circular(4),
            bottomRight: const Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: colors.border.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'CYSTAL is typing...',
              style: TextStyle(
                fontSize: 14,
                color: colors.secondaryText,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      message['text'],
                      style: TextStyle(
                        fontSize: 16,
                        color: isMe ? Colors.white : colors.text,
                      ),
                    ),
                  ),
                  // Add speaker button for CYSTAL's messages
                  if (!isMe && !_isMuted) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _speakText(message['text']),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _isSpeaking ? colors.primary.withOpacity(0.2) : colors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _isSpeaking ? Icons.stop : Icons.volume_up,
                          size: 16,
                          color: _isSpeaking ? colors.primary : colors.primary.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ],
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

  void _showInfoDialog(BuildContext context, AppColors colors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'About CYSTAL',
          style: TextStyle(color: colors.text),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CYSTAL is an AI health assistant designed to provide general health information and support.',
              style: TextStyle(color: colors.secondaryText),
            ),
            const SizedBox(height: 12),
            Text(
              'Features:',
              style: TextStyle(
                color: colors.text,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.keyboard, color: colors.primary, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Type your messages',
                  style: TextStyle(color: colors.secondaryText, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.mic, color: colors.primary, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Use voice input',
                  style: TextStyle(color: colors.secondaryText, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.volume_up, color: colors.primary, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Listen to responses',
                  style: TextStyle(color: colors.secondaryText, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.mic_off, color: colors.primary, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Toggle voice mode',
                  style: TextStyle(color: colors.secondaryText, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Note: CYSTAL is not a substitute for professional medical advice. For serious health concerns, please consult a healthcare provider.',
              style: TextStyle(
                color: colors.secondaryText,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it',
              style: TextStyle(color: colors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showVoiceInputOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.mic, color: Colors.blue),
            SizedBox(width: 8),
            Text('Voice Input Options'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Speech recognition is not available due to device security settings.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            Text(
              'Choose an option:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            ListTile(
              leading: Icon(Icons.keyboard, color: Colors.green),
              title: Text('Type Message'),
              subtitle: Text('Use keyboard input'),
              onTap: () {
                Navigator.pop(context);
                // Focus on text field
                FocusScope.of(context).requestFocus(FocusNode());
              },
            ),
            ListTile(
              leading: Icon(Icons.record_voice_over, color: Colors.orange),
              title: Text('Quick Voice Commands'),
              subtitle: Text('Use preset health questions'),
              onTap: () {
                Navigator.pop(context);
                _showQuickVoiceCommands();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showQuickVoiceCommands() {
    final quickCommands = [
      'I have a headache, what should I do?',
      'What are the symptoms of COVID-19?',
      'How can I improve my sleep?',
      'What foods are good for heart health?',
      'I feel anxious, any advice?',
      'What exercises are good for beginners?',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.record_voice_over, color: Colors.orange),
            SizedBox(width: 8),
            Text('Quick Voice Commands'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: quickCommands.map((command) => 
              ListTile(
                title: Text(command),
                trailing: Icon(Icons.send, color: Colors.blue),
                onTap: () {
                  Navigator.pop(context);
                  _messageController.text = command;
                  _sendMessage();
                },
              )
            ).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }
} 