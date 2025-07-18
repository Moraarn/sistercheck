import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../plugins/theme/theme_provider.dart';
import '../plugins/theme/colors.dart';
import '../services/doctor_dashboard_service.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isLoading = false;
  List<InventoryItem> _availableItems = [];
  List<InventoryItem> _lowStockItems = [];
  List<InventoryItem> _outOfStockItems = [];

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
    _loadInventoryStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadInventoryStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Create sample patient data for inventory check
      final samplePatientData = {
        'Age': 35,
        'Menopause Stage': 'Pre-menopausal',
        'SI Cyst Size cm': 6.5,
        'Cyst Growth': 0.2,
        'fca 125 Level': 45,
        'Ultrasound Fe': 'Complex cyst',
        'Reported Sym': 'Pelvic pain, bloating'
      };

      final result = await ref.read(doctorDashboardServiceProvider).getInventoryStatus(samplePatientData);

      if (result['success']) {
        setState(() {
          _availableItems = result['available'] ?? [];
          _lowStockItems = result['low_stock'] ?? [];
          _outOfStockItems = result['out_of_stock'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to load inventory status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading inventory status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
          'Inventory Status',
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
            icon: Icon(Icons.refresh, color: colors.primary),
            onPressed: _loadInventoryStatus,
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
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: colors.primary,
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadInventoryStatus,
                    color: colors.primary,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
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
                                  Icons.inventory,
                                  size: 48,
                                  color: colors.primary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Real-Time Inventory',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: colors.text,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Monitor stock levels and track inventory status',
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
                          
                          // Summary cards
                          Row(
                            children: [
                              Expanded(
                                child: _buildSummaryCard(
                                  'Available',
                                  _availableItems.length.toString(),
                                  Icons.check_circle,
                                  Colors.green,
                                  colors,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSummaryCard(
                                  'Low Stock',
                                  _lowStockItems.length.toString(),
                                  Icons.warning,
                                  Colors.orange,
                                  colors,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSummaryCard(
                                  'Out of Stock',
                                  _outOfStockItems.length.toString(),
                                  Icons.error,
                                  Colors.red,
                                  colors,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Available items
                          if (_availableItems.isNotEmpty) ...[
                            _buildInventorySection(
                              'Available Items',
                              _availableItems,
                              Icons.check_circle,
                              Colors.green,
                              colors,
                            ),
                            const SizedBox(height: 24),
                          ],
                          
                          // Low stock items
                          if (_lowStockItems.isNotEmpty) ...[
                            _buildInventorySection(
                              'Low Stock Items',
                              _lowStockItems,
                              Icons.warning,
                              Colors.orange,
                              colors,
                            ),
                            const SizedBox(height: 24),
                          ],
                          
                          // Out of stock items
                          if (_outOfStockItems.isNotEmpty) ...[
                            _buildInventorySection(
                              'Out of Stock Items',
                              _outOfStockItems,
                              Icons.error,
                              Colors.red,
                              colors,
                            ),
                            const SizedBox(height: 24),
                          ],
                          
                          // Empty state
                          if (_availableItems.isEmpty && _lowStockItems.isEmpty && _outOfStockItems.isEmpty) ...[
                            Container(
                              padding: const EdgeInsets.all(40),
                              decoration: BoxDecoration(
                                color: colors.card,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: colors.border.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    size: 64,
                                    color: colors.secondaryText,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No Inventory Data',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: colors.text,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Inventory data will appear here once available',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: colors.secondaryText,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String count, IconData icon, Color color, AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.border.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
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

  Widget _buildInventorySection(String title, List<InventoryItem> items, IconData icon, Color color, AppColors colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.border.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.text,
                  ),
                ),
                const Spacer(),
                Text(
                  '${items.length} items',
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildInventoryItem(item, colors);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryItem(InventoryItem item, AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colors.border.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.item,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Stock: ${item.stock} ${item.unit}',
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.secondaryText,
                  ),
                ),
                if (item.note != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.note!,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.secondaryText,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                if (item.estimatedRestock != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Restock: ${item.estimatedRestock!.toString().split(' ')[0]}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(item.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              item.status.replaceAll('_', ' ').toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: _getStatusColor(item.status),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'low_stock':
        return Colors.orange;
      case 'out_of_stock':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
