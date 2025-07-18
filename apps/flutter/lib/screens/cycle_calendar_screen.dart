import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../plugins/theme/theme_provider.dart';
import '../plugins/theme/colors.dart';

class CycleCalendarScreen extends ConsumerStatefulWidget {
  const CycleCalendarScreen({super.key});

  @override
  ConsumerState<CycleCalendarScreen> createState() => _CycleCalendarScreenState();
}

class _CycleCalendarScreenState extends ConsumerState<CycleCalendarScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  DateTime selectedDate = DateTime.now();
  final List<Map<String, dynamic>> cycleEvents = [
    {
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'type': 'Period Start',
      'notes': 'Light flow',
      'color': Colors.red,
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'type': 'Cramps',
      'notes': 'Mild discomfort',
      'color': Colors.orange,
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'type': 'Period End',
      'notes': 'Flow stopped',
      'color': Colors.pink,
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

  void _addEntry() {
    showDialog(
      context: context,
      builder: (context) => _buildAddEntryDialog(),
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
          'Cycle Calendar',
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
            icon: Icon(Icons.add, color: colors.primary),
            onPressed: _addEntry,
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
                  // Calendar header
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(Icons.chevron_left, color: colors.primary),
                              onPressed: () {
                                setState(() {
                                  selectedDate = DateTime(
                                    selectedDate.year,
                                    selectedDate.month - 1,
                                  );
                                });
                              },
                            ),
                            Text(
                              '${_getMonthName(selectedDate.month)} ${selectedDate.year}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: colors.text,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.chevron_right, color: colors.primary),
                              onPressed: () {
                                setState(() {
                                  selectedDate = DateTime(
                                    selectedDate.year,
                                    selectedDate.month + 1,
                                  );
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildCalendarGrid(colors),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Cycle stats
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
                            Icon(Icons.analytics, color: colors.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Cycle Statistics',
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
                              child: _buildStatItem('Cycle Length', '28 days', Icons.calendar_today, colors),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatItem('Period Length', '5 days', Icons.favorite, colors),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Recent events
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
                            Icon(Icons.history, color: colors.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Recent Events',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colors.text,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...cycleEvents.map((event) => _buildEventItem(event, colors)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEntry,
        backgroundColor: colors.primary,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCalendarGrid(AppColors colors) {
    // Simple calendar grid - in a real app, you'd use a proper calendar package
    return SizedBox(
      height: 300,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1,
        ),
        itemCount: 35, // 5 weeks * 7 days
        itemBuilder: (context, index) {
          final day = index + 1;
          final hasEvent = cycleEvents.any((event) => 
            event['date'].day == day && event['date'].month == selectedDate.month
          );
          
          return Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: hasEvent ? colors.primary.withOpacity(0.2) : colors.inputFieldBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: hasEvent ? colors.primary : colors.border,
                width: hasEvent ? 2 : 1,
              ),
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: TextStyle(
                  color: hasEvent ? colors.primary : colors.text,
                  fontWeight: hasEvent ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.inputFieldBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: colors.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
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
          ),
        ],
      ),
    );
  }

  Widget _buildEventItem(Map<String, dynamic> event, AppColors colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.inputFieldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: event['color'].withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: event['color'],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['type'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.text,
                  ),
                ),
                Text(
                  event['notes'],
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${event['date'].day}/${event['date'].month}',
            style: TextStyle(
              fontSize: 12,
              color: colors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddEntryDialog() {
    final colors = ref.watch(themeProvider) == ThemeMode.dark 
        ? AppColors.dark 
        : AppColors.light;
        
    return AlertDialog(
      backgroundColor: colors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Add Cycle Entry',
        style: TextStyle(color: colors.text),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: colors.inputFieldBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Event Type',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
              items: ['Period Start', 'Period End', 'Cramps', 'Discharge', 'Other']
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) {},
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: colors.inputFieldBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Notes',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
              style: TextStyle(color: colors.text),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: colors.secondaryText)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Entry added successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          },
          child: Text('Save'),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
} 