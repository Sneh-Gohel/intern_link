import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intern_link/screens/HomeScreen.dart';
import 'package:intern_link/service/FadeTransitionPageRoute.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
    _usernameController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1)); // Simulate loading

    if (_usernameController.text == "admin" &&
        _passwordController.text == "123") {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: const Text('Logged in Successfully as Admin'),
      //     behavior: SnackBarBehavior.floating,
      //     shape: RoundedRectangleBorder(
      //       borderRadius: BorderRadius.circular(10),
      //     ),
      //     backgroundColor: Colors.green.shade600,
      //   ),
      // );
      Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        FadeTransitionPageRoute(page: const HomeScreen()),
      );
    });
      // Navigate to home/dashboard here
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Invalid Credentials'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }

    setState(() => _isLoading = false);
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        print("Name: ${user.displayName}");
        print("Email: ${user.email}");
        print("Profile Photo: ${user.photoURL}");
        print("UID: ${user.uid}");
      }
    } catch (e) {
      print('Google Sign-In Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade600,
        ),
      );
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
            // Background texture effect
            Positioned.fill(
              child: Opacity(
                opacity: 0.05,
                child: Image.asset(
                  'assets/images/texture.png', // Add a subtle texture image
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
                        // App logo/name section
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
                              // Username field
                              TextField(
                                controller: _usernameController,
                                style: const TextStyle(fontSize: 16),
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(
                                    Icons.person_outline,
                                    color: Color.fromARGB(255, 107, 146, 230),
                                  ),
                                  labelText: "Username",
                                  labelStyle: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color:
                                            Color.fromARGB(255, 26, 60, 124)),
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
                                style: const TextStyle(fontSize: 16),
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
                                        color:
                                            Color.fromARGB(255, 26, 60, 124)),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 20),
                                ),
                              ),

                              const SizedBox(height: 30),

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
                                  onPressed: _signInWithGoogle,
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
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                              'Signup screen coming soon!'),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
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
