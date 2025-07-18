import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../plugins/theme/theme_provider.dart';
import '../plugins/theme/colors.dart';

class AudioLessonsScreen extends ConsumerStatefulWidget {
  const AudioLessonsScreen({super.key});

  @override
  ConsumerState<AudioLessonsScreen> createState() => _AudioLessonsScreenState();
}

class _AudioLessonsScreenState extends ConsumerState<AudioLessonsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  int? _currentlyPlaying;
  
  final List<Map<String, dynamic>> lessons = [
    {
      'title': 'What are ovarian cysts?',
      'duration': '8:45',
      'description': 'Learn the basics about ovarian cysts and their symptoms',
      'category': 'Education',
      'completed': false,
    },
    {
      'title': "How to talk about women's health",
      'duration': '12:30',
      'description': 'Tips for discussing health concerns with healthcare providers',
      'category': 'Communication',
      'completed': true,
    },
    {
      'title': 'When to see a nurse',
      'duration': '6:15',
      'description': 'Know the signs that mean you should seek medical help',
      'category': 'Medical Advice',
      'completed': false,
    },
    {
      'title': 'Healthy lifestyle tips',
      'duration': '15:20',
      'description': 'Practical advice for maintaining good reproductive health',
      'category': 'Wellness',
      'completed': false,
    },
    {
      'title': 'Understanding your cycle',
      'duration': '10:45',
      'description': 'Learn about menstrual cycles and what\'s normal',
      'category': 'Education',
      'completed': true,
    },
    {
      'title': 'Managing stress and anxiety',
      'duration': '9:30',
      'description': 'Techniques for managing stress related to health concerns',
      'category': 'Mental Health',
      'completed': false,
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _playLesson(int index) {
    setState(() {
      _currentlyPlaying = _currentlyPlaying == index ? null : index;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_currentlyPlaying == index 
          ? 'Playing: ${lessons[index]['title']}'
          : 'Paused: ${lessons[index]['title']}'),
        backgroundColor: ref.read(themeProvider) == ThemeMode.dark 
            ? AppColors.dark.primary 
            : AppColors.light.primary,
      ),
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
        title: Text(
          'Audio Lessons',
          style: TextStyle(
            color: colors.text,
            fontWeight: FontWeight.bold,
          ),
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
            icon: Icon(Icons.search, color: colors.primary),
            onPressed: () {
              // Add search functionality
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
                  colors.primary.withOpacity(0.1),
                  colors.scaffoldBackground,
                ],
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: colors.border.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.headphones,
                          size: 48,
                          color: colors.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Audio Health Lessons',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: colors.text,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Listen and learn at your own pace',
                          style: TextStyle(
                            fontSize: 16,
                            color: colors.secondaryText,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Progress section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: colors.border.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.trending_up, color: colors.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Your Progress',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colors.text,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildProgressItem(
                                'Completed',
                                '${lessons.where((l) => l['completed']).length}',
                                Icons.check_circle,
                                Colors.green,
                                colors,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildProgressItem(
                                'Total Time',
                                '1h 23m',
                                Icons.timer,
                                colors.primary,
                                colors,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Lessons list
                  Text(
                    'Available Lessons',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colors.text,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  ...lessons.asMap().entries.map((entry) {
                    final index = entry.key;
                    final lesson = entry.value;
                    return _buildLessonCard(index, lesson, colors);
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressItem(String title, String value, IconData icon, Color color, AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.inputFieldBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colors.text,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: colors.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLessonCard(int index, Map<String, dynamic> lesson, AppColors colors) {
    final isPlaying = _currentlyPlaying == index;
    final isCompleted = lesson['completed'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.border.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isPlaying 
                    ? colors.primary 
                    : (isCompleted ? Colors.green.withOpacity(0.1) : colors.primary.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: isPlaying ? Colors.white : colors.primary,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lesson['title'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colors.text,
                          ),
                        ),
                      ),
                      if (isCompleted)
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lesson['description'],
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.secondaryText,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          lesson['category'],
                          style: TextStyle(
                            fontSize: 10,
                            color: colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time, size: 14, color: colors.secondaryText),
                      const SizedBox(width: 4),
                      Text(
                        lesson['duration'],
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 