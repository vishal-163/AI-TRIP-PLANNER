import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/models/trip_input_model.dart';
import '../../../../core/providers/trip_provider.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/gradient_scaffold.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/modern_button.dart';

class TripInputScreen extends ConsumerWidget {
  const TripInputScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    
    return authState.when(
      data: (state) {
        if (state.session != null) {
          return const _TripInputScreenContent();
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(AppRouter.login);
          });
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go(AppRouter.login);
        });
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

class _TripInputScreenContent extends ConsumerStatefulWidget {
  const _TripInputScreenContent();

  @override
  ConsumerState<_TripInputScreenContent> createState() => _TripInputScreenState();
}

class _TripInputScreenState extends ConsumerState<_TripInputScreenContent> {
  final _formKey = GlobalKey<FormState>();
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  final List<String> _destinations = [];
  final _budgetLevelController = TextEditingController();
  final _numberOfTravelersController = TextEditingController();
  final _specialConstraintsController = TextEditingController();
  
  List<String> _originSuggestions = [];
  List<String> _destinationSuggestions = [];
  bool _isOriginLoading = false;
  bool _isDestinationLoading = false;
  
  DateTime? _startDate;
  DateTime? _endDate;
  
  final List<String> _availableInterests = [
    'Adventure', 'Luxury', 'Culture', 'Nightlife',
    'Food', 'Nature', 'Photography', 'Family-friendly'
  ];
  final List<String> _selectedInterests = [];

  // PageView Controller
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 4;

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    _budgetLevelController.dispose();
    _numberOfTravelersController.dispose();
    _specialConstraintsController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<List<String>> _fetchCitySuggestions(String query) async {
    if (query.isEmpty) return [];
    await Future.delayed(const Duration(milliseconds: 300));
    final allCities = [
      'Mumbai, Maharashtra', 'Delhi, Delhi', 'Bangalore, Karnataka',
      'Goa', 'Jaipur, Rajasthan', 'Kerala', 'Manali, Himachal Pradesh',
      'Udaipur, Rajasthan', 'Agra, Uttar Pradesh', 'Varanasi, Uttar Pradesh',
      'Kolkata, West Bengal', 'Chennai, Tamil Nadu', 'Hyderabad, Telangana',
      'Pune, Maharashtra', 'Ahmedabad, Gujarat', 'Amritsar, Punjab',
      'Shimla, Himachal Pradesh', 'Darjeeling, West Bengal', 'Rishikesh, Uttarakhand',
      'Ooty, Tamil Nadu', 'Coorg, Karnataka', 'Mysore, Karnataka',
      'Pondicherry', 'Andaman & Nicobar Islands', 'Ladakh'
    ];
    return allCities
        .where((city) => city.toLowerCase().contains(query.toLowerCase()))
        .take(5)
        .toList();
  }

  void _onOriginChanged(String value) {
    if (value.length > 2) {
      setState(() => _isOriginLoading = true);
      _fetchCitySuggestions(value).then((suggestions) {
        setState(() {
          _originSuggestions = suggestions;
          _isOriginLoading = false;
        });
      });
    } else {
      setState(() {
        _originSuggestions = [];
        _isOriginLoading = false;
      });
    }
  }

  void _onDestinationChanged(String value) {
    if (value.length > 2) {
      setState(() => _isDestinationLoading = true);
      _fetchCitySuggestions(value).then((suggestions) {
        setState(() {
          _destinationSuggestions = suggestions;
          _isDestinationLoading = false;
        });
      });
    } else {
      setState(() {
        _destinationSuggestions = [];
        _isDestinationLoading = false;
      });
    }
  }

  void _addDestination() {
    final destination = _destinationController.text.trim();
    if (destination.isNotEmpty && !_destinations.contains(destination)) {
      setState(() {
        _destinations.add(destination);
        _destinationController.clear();
        _destinationSuggestions = [];
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
          if (_startDate != null && _endDate!.isBefore(_startDate!)) {
            _startDate = _endDate;
          }
        }
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select dates')),
        );
        return;
      }
      
      if (_destinations.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one destination')),
        );
        return;
      }
      
      final tripInput = TripInputModel(
        origin: _originController.text.trim(),
        destinations: List.from(_destinations),
        startDate: _startDate!,
        endDate: _endDate!,
        numberOfTravelers: int.tryParse(_numberOfTravelersController.text) ?? 1,
        budgetLevel: _budgetLevelController.text.trim(),
        interests: _selectedInterests,
        specialConstraints: _specialConstraintsController.text.trim(),
      );
      
      ref.read(tripInputProvider.notifier).state = tripInput;
      context.push('/itinerary');
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
      setState(() => _currentPage++);
    } else {
      _submitForm();
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
      setState(() => _currentPage--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: Text('Plan Your Trip', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.save_outlined), onPressed: () => context.push('/saved-trips')),
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () => context.push('/settings')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Progress Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: List.generate(_totalPages, (index) {
                  return Expanded(
                    child: Container(
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                }),
              ),
            ),
            
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                  _buildStep4(),
                ],
              ),
            ),
            
            // Navigation Buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: ModernButton(
                        onPressed: _prevPage,
                        text: 'Back',
                        backgroundColor: Colors.grey[200],
                        textColor: Colors.black87,
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ModernButton(
                      onPressed: _nextPage,
                      text: _currentPage == _totalPages - 1 ? 'Generate Trip' : 'Next',
                      icon: _currentPage == _totalPages - 1 ? Icons.auto_awesome : Icons.arrow_forward,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Where are you going?',
              style: Theme.of(context).textTheme.displayMedium,
              textAlign: TextAlign.center,
            ).animate().fadeIn().slideY(begin: 0.3, end: 0),
            const SizedBox(height: 32),
            GlassContainer(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  TextFormField(
                    controller: _originController,
                    decoration: const InputDecoration(
                      labelText: 'Origin City',
                      prefixIcon: Icon(Icons.flight_takeoff),
                    ),
                    onChanged: _onOriginChanged,
                  ),
                  if (_isOriginLoading) const LinearProgressIndicator(),
                  if (_originSuggestions.isNotEmpty)
                    _buildSuggestionsList(_originSuggestions, (val) {
                      _originController.text = val;
                      setState(() => _originSuggestions = []);
                    }),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _destinationController,
                          decoration: const InputDecoration(
                            labelText: 'Destination City',
                            prefixIcon: Icon(Icons.location_on),
                          ),
                          onChanged: _onDestinationChanged,
                          onFieldSubmitted: (_) => _addDestination(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
                          onPressed: _addDestination,
                        ),
                      ),
                    ],
                  ),
                  if (_isDestinationLoading) const LinearProgressIndicator(),
                  if (_destinationSuggestions.isNotEmpty)
                    _buildSuggestionsList(_destinationSuggestions, (val) {
                      _destinationController.text = val;
                      setState(() => _destinationSuggestions = []);
                      _addDestination();
                    }),
                  if (_destinations.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _destinations.map((dest) => Chip(
                          label: Text(dest),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () => setState(() => _destinations.remove(dest)),
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                          side: BorderSide.none,
                        )).toList(),
                      ),
                    ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms).scale(),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'When are you traveling?',
              style: Theme.of(context).textTheme.displayMedium,
              textAlign: TextAlign.center,
            ).animate().fadeIn().slideY(begin: 0.3, end: 0),
            const SizedBox(height: 32),
            GlassContainer(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  InkWell(
                    onTap: () => _selectDate(context, true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Start Date',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _startDate == null ? 'Select Date' : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  InkWell(
                    onTap: () => _selectDate(context, false),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'End Date',
                        prefixIcon: Icon(Icons.event),
                      ),
                      child: Text(
                        _endDate == null ? 'Select Date' : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms).scale(),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Trip Details',
              style: Theme.of(context).textTheme.displayMedium,
              textAlign: TextAlign.center,
            ).animate().fadeIn().slideY(begin: 0.3, end: 0),
            const SizedBox(height: 32),
            GlassContainer(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  TextFormField(
                    controller: _budgetLevelController,
                    decoration: const InputDecoration(
                      labelText: 'Budget (e.g. ₹50000)',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _numberOfTravelersController,
                    decoration: const InputDecoration(
                      labelText: 'Number of Travelers',
                      prefixIcon: Icon(Icons.people),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _specialConstraintsController,
                    decoration: const InputDecoration(
                      labelText: 'Special Constraints (Optional)',
                      prefixIcon: Icon(Icons.info_outline),
                      hintText: 'e.g., Wheelchair access, dietary restrictions',
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms).scale(),
          ],
        ),
      ),
    );
  }

  Widget _buildStep4() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'What are your interests?',
              style: Theme.of(context).textTheme.displayMedium,
              textAlign: TextAlign.center,
            ).animate().fadeIn().slideY(begin: 0.3, end: 0),
            const SizedBox(height: 32),
            GlassContainer(
              padding: const EdgeInsets.all(24),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: _availableInterests.map((interest) {
                  final isSelected = _selectedInterests.contains(interest);
                  return FilterChip(
                    label: Text(interest),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedInterests.add(interest);
                        } else {
                          _selectedInterests.remove(interest);
                        }
                      });
                    },
                    checkmarkColor: Colors.white,
                    selectedColor: Theme.of(context).primaryColor,
                    backgroundColor: Colors.white.withOpacity(0.5),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  );
                }).toList(),
              ),
            ).animate().fadeIn(delay: 200.ms).scale(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionsList(List<String> suggestions, Function(String) onSelected) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(suggestions[index]),
            onTap: () => onSelected(suggestions[index]),
          );
        },
      ),
    );
  }
}
