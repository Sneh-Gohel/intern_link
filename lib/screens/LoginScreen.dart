import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intern_link/models/user_model.dart';
import 'package:intern_link/screens/HomeScreen.dart';
import 'package:intern_link/screens/SignupScreen.dart';
import 'package:intern_link/services/FadeTransitionPageRoute.dart';
import 'package:intern_link/services/json_data_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuad,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
  setState(() {
    _isLoading = true;
    _errorMessage = '';
  });

  try {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter both email and password');
      return;
    }

    // Load users from JSON
    final users = await JsonDataService.loadUsers();
    
    // Debug: Print loaded users to verify data
    debugPrint('Loaded users: ${users.map((u) => u.email).toList()}');

    // Find matching user (case-sensitive comparison)
    User? matchedUser;
    try {
      matchedUser = users.firstWhere(
        (user) => user.email == email && user.password == password,
      );
    } catch (e) {
      debugPrint('User not found: $e');
    }

    if (matchedUser != null) {
      if (matchedUser.status == 'active') {
        debugPrint('Login successful for: ${matchedUser.email}');
        // Successful login
        Navigator.of(context).pushReplacement(
          FadeTransitionPageRoute(
            page: HomeScreen(currentUser: matchedUser),
          ),
        );
      } else {
        setState(() => _errorMessage = 'Your account is not active');
      }
    } else {
      debugPrint('Invalid credentials for: $email');
      setState(() => _errorMessage = 'Invalid email or password');
    }
  } catch (e) {
    debugPrint('Login error: $e');
    setState(() => _errorMessage = 'An error occurred. Please try again.');
  } finally {
    setState(() => _isLoading = false);
  }
}

  Future<void> _signInWithGoogle() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      
      // In a real app, you would verify the Google token with your backend
      // For JSON demo, we'll just check if the email exists in our users.json

      final users = await JsonDataService.loadUsers();
      final matchedUser = users.firstWhere(
        (user) => user.email == googleUser.email,
        orElse: () => User(
          userId: '',
          role: '',
          name: '',
          email: '',
          password: '',
          profile: UserProfile(),
          status: '',
        ),
      );

      if (matchedUser.userId.isEmpty) {
        // Create a new user for demo purposes
        final newUser = User(
          userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
          role: 'job_seeker',
          name: googleUser.displayName ?? 'Google User',
          email: googleUser.email,
          password: 'google_auth',
          profile: UserProfile(
            profilePicture: googleUser.photoUrl,
          ),
          status: 'active',
        );

        // In a real app, you would save this new user to your database
        Navigator.of(context).pushReplacement(
          FadeTransitionPageRoute(
            page: HomeScreen(currentUser: newUser),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          FadeTransitionPageRoute(
            page: HomeScreen(currentUser: matchedUser),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Google Sign-In Error: ${e.toString()}';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 197, 218, 243),
              Color.fromARGB(255, 149, 219, 236),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.05,
                child: Image.asset(
                  'assets/images/texture.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),

            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Welcome to",
                              style: TextStyle(
                                fontSize: 22,
                                color: const Color.fromARGB(255, 107, 146, 230)
                                    .withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "InternLink",
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 26, 60, 124),
                                shadows: [
                                  Shadow(
                                    blurRadius: 10,
                                    color: Colors.black.withOpacity(0.2),
                                    offset: const Offset(2, 2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 60),

                        // Error message
                        if (_errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.red.shade200,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline,
                                      color: Colors.red.shade600),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMessage,
                                      style: TextStyle(
                                        color: Colors.red.shade800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Login card
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Email field
                              TextField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(
                                    Icons.email_outlined,
                                    color: Color.fromARGB(255, 107, 146, 230),
                                  ),
                                  labelText: "Email",
                                  labelStyle: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: Color.fromARGB(255, 26, 60, 124)),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 20),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Password field
                              TextField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(
                                    Icons.lock_outline,
                                    color: Color.fromARGB(255, 107, 146, 230),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey.shade600,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  labelText: "Password",
                                  labelStyle: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: Color.fromARGB(255, 26, 60, 124)),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 20),
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Forgot password
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Password reset feature coming soon!'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 107, 146, 230),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Login button
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(
                                        255, 107, 146, 230),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 3,
                                    shadowColor:
                                        const Color.fromARGB(255, 26, 60, 124),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3,
                                            color: Color.fromARGB(
                                                255, 26, 60, 124),
                                          ),
                                        )
                                      : const Text(
                                          "Login",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Color.fromARGB(
                                                255, 26, 60, 124),
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Divider with OR
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: Colors.grey.shade400,
                                      thickness: 1,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: Text(
                                      "OR",
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: Colors.grey.shade400,
                                      thickness: 1,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              // Google sign-in button
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: OutlinedButton.icon(
                                  onPressed: _isLoading ? null : _signInWithGoogle,
                                  icon: Image.asset(
                                    'assets/images/google.png',
                                    height: 24,
                                  ),
                                  label: const Text(
                                    "Continue with Google",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: Colors.grey.shade300,
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor: Colors.white,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Sign up prompt
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Don't have an account?",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        FadeTransitionPageRoute(
                                          page: const SignupScreen(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "Sign up",
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 26, 60, 124),
                                        fontWeight: FontWeight.w600,
                                      ),
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}