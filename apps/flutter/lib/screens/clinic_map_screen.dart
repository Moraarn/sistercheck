import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../plugins/theme/theme_provider.dart';
import '../plugins/theme/colors.dart';

class ClinicMapScreen extends ConsumerStatefulWidget {
  const ClinicMapScreen({super.key});

  @override
  ConsumerState<ClinicMapScreen> createState() => _ClinicMapScreenState();
}

class _ClinicMapScreenState extends ConsumerState<ClinicMapScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  LatLng? _userLocation;
  bool _loading = true;
  int _selectedTab = 0;
  final List<String> _filters = ['All', 'Hospitals', 'Clinics', 'Specialized'];
  String _searchQuery = '';

  List<Map<String, dynamic>> _places = [];
  bool _placesLoading = false;
  String? _placesError;

  final TextEditingController _searchController = TextEditingController();

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
    _getUserLocation();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getUserLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        setState(() => _loading = false);
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        setState(() => _loading = false);
        return;
      }
    }

    locationData = await location.getLocation();
    setState(() {
      _userLocation = LatLng(locationData.latitude ?? -1.2921, locationData.longitude ?? 36.8219);
      _loading = false;
    });
    _fetchNearbyPlaces();
  }

  Future<void> _fetchNearbyPlaces() async {
    if (_userLocation == null) return;
    setState(() {
      _placesLoading = true;
      _placesError = null;
    });
    try {
      String type = '';
      switch (_selectedTab) {
        case 1:
          type = 'hospital';
          break;
        case 2:
          type = 'clinic';
          break;
        case 3:
          type = 'hospital|clinic'; // We'll filter for specialized below
          break;
        default:
          type = 'hospital|clinic';
      }
      // Call the backend proxy instead of Google directly
      final url = Uri.parse(
        'http://localhost:5000/api/places?location=${_userLocation!.latitude},${_userLocation!.longitude}&radius=3000&type=$type',
      );
      final response = await http.get(url);
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final results = data['results'] as List;
        setState(() {
          _places = results.map<Map<String, dynamic>>((place) {
            return {
              'name': place['name'],
              'vicinity': place['vicinity'] ?? '',
              'location': LatLng(
                place['geometry']['location']['lat'],
                place['geometry']['location']['lng'],
              ),
              'rating': place['rating']?.toDouble() ?? 0.0,
              'types': place['types'] ?? [],
              'place_id': place['place_id'],
              'open_now': place['opening_hours']?['open_now'],
            };
          }).toList();
          _placesLoading = false;
        });
      } else {
        setState(() {
          _placesError = data['error_message'] ?? 'Failed to fetch places.';
          _placesLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _placesError = 'Error fetching places: $e';
        _placesLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get filteredPlaces {
    List<Map<String, dynamic>> filtered = _places;
    if (_selectedTab == 1) {
      filtered = filtered.where((place) => place['types'].contains('hospital')).toList();
    } else if (_selectedTab == 2) {
      filtered = filtered.where((place) => place['types'].contains('clinic')).toList();
    } else if (_selectedTab == 3) {
      // Specialized: filter by specialty keywords
      final keywords = [
        'gynecology', 'obstetric', 'oncology', 'cardiology', 'specialist', 'fertility', 'cancer', 'neurology', 'orthopedic', 'pediatric', 'reproductive', 'maternity', 'transplant', 'emergency', 'surgery', 'radiology', 'laboratory', 'icu', 'family planning', 'screening', 'treatment', 'diagnostic', 'therapy', 'clinic', 'hospital'
      ];
      filtered = filtered.where((place) {
        final name = place['name'].toString().toLowerCase();
        final types = (place['types'] as List).join(' ').toLowerCase();
        return keywords.any((kw) => name.contains(kw) || types.contains(kw));
      }).toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((place) =>
        place['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
        place['vicinity'].toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider) == ThemeMode.dark 
        ? AppColors.dark 
        : AppColors.light;
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Find Hospitals & Clinics',
          style: TextStyle(
            color: colors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.text),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.my_location, color: colors.primary),
            onPressed: _getUserLocation,
            tooltip: 'My Location',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
                  // Modern pill tab bar
                  Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: colors.card.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: colors.border.withOpacity(0.08),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(_filters.length, (i) {
                          final selected = _selectedTab == i;
                          return AnimatedContainer(
                            duration: Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(24),
                              onTap: () {
                                setState(() {
                                  _selectedTab = i;
                                });
                                _fetchNearbyPlaces();
                              },
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 250),
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                decoration: BoxDecoration(
                                  color: selected ? colors.primary.withOpacity(0.15) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: selected
                                      ? [
                                          BoxShadow(
                                            color: colors.primary.withOpacity(0.12),
                                            blurRadius: 8,
                                            offset: Offset(0, 2),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Text(
                                  _filters[i],
                                  style: TextStyle(
                                    color: selected ? colors.primary : colors.text,
                                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Material(
                      elevation: 2,
                      borderRadius: BorderRadius.circular(24),
                      color: colors.card.withOpacity(0.8),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search by name or specialty...',
                          prefixIcon: Icon(Icons.search, color: colors.primary),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        style: TextStyle(color: colors.text, fontSize: 16),
                      ),
                    ),
                  ),
                  // Map and list
                  Expanded(
                    child: isWide
                        ? Row(
                            children: [
                              Expanded(child: _buildMap(colors)),
                              SizedBox(width: 16),
                              Expanded(child: _buildPlacesList(colors)),
                            ],
                          )
                        : Column(
                            children: [
                              Expanded(flex: 2, child: _buildMap(colors)),
                              Expanded(flex: 1, child: _buildPlacesList(colors)),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMap(AppColors colors) {
    return Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
            color: colors.border.withOpacity(0.12),
            blurRadius: 16,
            offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
                    child: _loading
                        ? Container(
                            color: colors.card,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Loading map...',
                                    style: TextStyle(
                                      color: colors.text,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: _userLocation ?? const LatLng(-1.2921, 36.8219),
                              zoom: 14,
                            ),
                            markers: {
                  if (_userLocation != null)
                              Marker(
                                markerId: const MarkerId('user'),
                      position: _userLocation!,
                                infoWindow: const InfoWindow(title: 'You are here'),
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                              ),
                  ...filteredPlaces.asMap().entries.map((entry) {
                    final place = entry.value;
                                return Marker(
                      markerId: MarkerId('place${entry.key}'),
                      position: place['location'],
                                  infoWindow: InfoWindow(
                        title: place['name'],
                        snippet: place['vicinity'],
                      ),
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                      onTap: () {
                        _showPlaceDetails(place);
                      },
                                );
                              }).toSet(),
                            },
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                            mapType: MapType.normal,
                          ),
                  ),
    );
  }

  Widget _buildPlacesList(AppColors colors) {
    return Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  decoration: BoxDecoration(
        color: colors.card.withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
            color: colors.border.withOpacity(0.10),
            blurRadius: 12,
            offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Icon(Icons.local_hospital, color: colors.primary),
                            const SizedBox(width: 8),
                            Text(
                  'Nearby Hospitals & Clinics (${filteredPlaces.length})',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colors.text,
                              ),
                            ),
                          ],
                        ),
                      ),
          if (_placesLoading)
            const Center(child: CircularProgressIndicator()),
          if (_placesError != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(_placesError!, style: TextStyle(color: Colors.red)),
            ),
          if (!_placesLoading && _placesError == null)
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: filteredPlaces.length,
                          itemBuilder: (context, index) {
                  final place = filteredPlaces[index];
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                      color: colors.inputFieldBg.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: colors.border,
                                  width: 1,
                                ),
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withOpacity(0.04),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                              ),
                              child: InkWell(
                      onTap: () => _showPlaceDetails(place),
                      borderRadius: BorderRadius.circular(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                              color: colors.primary.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: Icon(
                              Icons.local_hospital,
                                        color: colors.primary,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                  place['name'],
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: colors.text,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                  place['vicinity'],
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: colors.secondaryText,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.star,
                                                size: 16,
                                                color: Colors.amber,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                      place['rating'].toString(),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: colors.secondaryText,
                                                ),
                                              ),
                                    if (place['open_now'] != null) ...[
                                                const SizedBox(width: 16),
                                                Icon(
                                                  Icons.access_time,
                                                  size: 16,
                                        color: place['open_now'] ? Colors.green : Colors.red,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                        place['open_now'] ? 'Open' : 'Closed',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                          color: place['open_now'] ? Colors.green : Colors.red,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: colors.secondaryText,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
        ],
      ),
    );
  }

  void _showPlaceDetails(Map<String, dynamic> place) {
    final colors = ref.read(themeProvider) == ThemeMode.dark 
        ? AppColors.dark 
        : AppColors.light;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(
          color: colors.card.withOpacity(0.98),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withOpacity(0.08),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.local_hospital, color: colors.primary, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            place['name'],
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: colors.text,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: colors.primary, size: 20),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            place['vicinity'],
                            style: TextStyle(
                              fontSize: 16,
                              color: colors.secondaryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          place['rating'].toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colors.text,
                          ),
                        ),
                        if (place['open_now'] != null) ...[
                          const SizedBox(width: 20),
                          Icon(
                            Icons.access_time,
                            color: place['open_now'] ? Colors.green : Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            place['open_now'] ? 'Open' : 'Closed',
                            style: TextStyle(
                              fontSize: 14,
                              color: place['open_now'] ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
        ),
      ),
    );
  }
} 