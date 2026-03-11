import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/repositories/trip_database_repository.dart' as db_repo;

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _isLogin = true; // Toggle between login and register
  bool _isOtpSent = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  void _checkSession() {
    final session = ref.read(supabaseProvider).auth.currentSession;
    if (session != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(AppRouter.tripInput);
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final databaseService = ref.read(db_repo.tripDatabaseRepositoryProvider);
      // Access the underlying service via a temporary provider or direct instantiation if needed, 
      // but here we added methods to DatabaseService which is used by TripDatabaseRepository.
      // Wait, TripDatabaseRepository wraps DatabaseService. I should access DatabaseService directly or update Repo.
      // For now, I'll access the singleton DatabaseService directly as it was modified.
      
      // Actually, better to use the provider if exposed. 
      // In trip_database_repository.dart: final databaseServiceProvider = Provider<DatabaseService>((ref) => DatabaseService());
      // I need to import trip_database_repository.dart to access databaseServiceProvider.
      
      // Let's assume I can get DatabaseService.
      final dbService = ref.read(db_repo.databaseServiceProvider);
      
      final email = _emailController.text.trim();
      await dbService.signInWithEmail(email, shouldCreateUser: !_isLogin);

      setState(() {
        _isOtpSent = true;
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent successfully!')),
        );
      }
    } catch (e) {
      setState(() {
        final errorMsg = e.toString();
        if (errorMsg.contains('Signups not allowed') || errorMsg.contains('User not found')) {
           _errorMessage = 'User not found. Please register first.';
        } else {
           _errorMessage = 'Failed to send OTP: $errorMsg';
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter OTP');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final dbService = ref.read(db_repo.databaseServiceProvider);
      final response = await dbService.verifyEmailOtp(_emailController.text.trim(), _otpController.text.trim());

      if (response.session != null) {
        // If registration, update user metadata
        if (!_isLogin) {
          print('Registration detected. Updating metadata...');
          try {
            final phone = _phoneController.text.trim();
            await dbService.updateUserMetadata(
              name: _nameController.text.trim(),
              phone: phone.isNotEmpty ? phone : null,
            );
            print('Metadata update call completed.');
          } catch (e) {
            print('Failed to update metadata in UI: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Login successful but failed to save profile: $e')),
              );
            }
          }
        } else {
          print('Login detected. Skipping metadata update.');
        }

        if (mounted) {
          context.go(AppRouter.tripInput);
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Invalid OTP or verification failed: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Login' : 'Register'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.travel_explore, size: 80, color: Colors.blue),
                  const SizedBox(height: 16),
                  const Text(
                    'AI Trip Planner',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  
                  if (!_isOtpSent) ...[
                    // Registration Fields
                    if (!_isLogin) ...[
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) => value!.isEmpty ? 'Enter your name' : null,
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Email Field (Always Visible)
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Enter email';
                        if (!value.contains('@')) return 'Invalid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                      // Phone Number Field (Optional for Login, Required for Profile if desired, making optional here as per plan)
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number (Optional)',
                          hintText: '9876543210',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                    const SizedBox(height: 24),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _sendOtp,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : Text(_isLogin ? 'Send OTP to Email' : 'Verify Email'),
                      ),
                    ),
                  ] else ...[
                    // OTP Field
                    Text(
                      'Enter OTP sent to ${_emailController.text}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _otpController,
                      decoration: const InputDecoration(
                        labelText: 'OTP',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock_clock),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 8,
                    ),
                    const SizedBox(height: 24),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _verifyOtp,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Verify & Login'),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _isOtpSent = false),
                      child: const Text('Change Email'),
                    ),
                  ],

                  const SizedBox(height: 24),
                  if (_errorMessage.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_errorMessage, style: TextStyle(color: Colors.red.shade800)),
                    ),
                  
                  if (!_isOtpSent)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                          _errorMessage = '';
                          _isOtpSent = false;
                        });
                      },
                      child: Text(_isLogin
                          ? 'New user? Register here'
                          : 'Already have an account? Login'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}