import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intern_link/models/user_model.dart';
import 'package:intern_link/screens/LoginScreen.dart';
import 'package:intern_link/services/FadeTransitionPageRoute.dart';
import 'package:intern_link/services/auth_service.dart';
import 'package:intern_link/services/json_data_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  File? _profileImage;
  File? _resumeFile;
  File? _companyLogo;
  String? _userType = 'job_seeker';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  List<String> _skills = [];

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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _skillsController.dispose();
    _experienceController.dispose();
    _educationController.dispose();
    _websiteController.dispose();
    _descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (_userType == 'job_seeker') {
          _profileImage = File(pickedFile.path);
        } else {
          _companyLogo = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _pickResume() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _resumeFile = File(pickedFile.path);
      });
    }
  }

  void _addSkill() {
    if (_skillsController.text.isNotEmpty) {
      setState(() {
        _skills.add(_skillsController.text);
        _skillsController.clear();
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_userType == 'job_seeker' && _resumeFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please upload your resume'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.red.shade600,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final newUser = User(
        userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
        role: _userType!,
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text, // In real app, hash this
        profile: UserProfile(
          resumeLink: _resumeFile?.path,
          profilePicture: _profileImage?.path,
          companyLogo: _companyLogo?.path,
          skills: _userType == 'job_seeker' ? _skills : null,
          experience: _userType == 'job_seeker' ? _experienceController.text : null,
          education: _userType == 'job_seeker' ? _educationController.text : null,
          companyWebsite: _userType == 'employer' ? _websiteController.text : null,
          companyDescription: _userType == 'employer' ? _descriptionController.text : null,
          savedJobs: [],
          postedJobs: [],
          postedInternships: [],
        ),
        status: 'active',
      );

      final success = await AuthService.register(newUser);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Account created successfully!'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: Colors.green.shade600,
          ),
        );

        Navigator.of(context).pushReplacement(
          FadeTransitionPageRoute(page: const LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Email already exists'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade600,
        ),
      );
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Join",
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
                        const SizedBox(height: 40),
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
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // User Type Selection
                                const Text(
                                  'I am signing up as:',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 26, 60, 124),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ChoiceChip(
                                        label: const Text('Job Seeker'),
                                        selected: _userType == 'job_seeker',
                                        onSelected: (selected) {
                                          setState(() => _userType = 'job_seeker');
                                        },
                                        selectedColor: const Color.fromARGB(255, 107, 146, 230),
                                        labelStyle: TextStyle(
                                          color: _userType == 'job_seeker' 
                                              ? Colors.white 
                                              : const Color.fromARGB(255, 26, 60, 124),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ChoiceChip(
                                        label: const Text('Employer'),
                                        selected: _userType == 'employer',
                                        onSelected: (selected) {
                                          setState(() => _userType = 'employer');
                                        },
                                        selectedColor: const Color.fromARGB(255, 107, 146, 230),
                                        labelStyle: TextStyle(
                                          color: _userType == 'employer' 
                                              ? Colors.white 
                                              : const Color.fromARGB(255, 26, 60, 124),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Name Field
                                TextFormField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    labelText: _userType == 'job_seeker' 
                                        ? 'Full Name' 
                                        : 'Company Name',
                                    labelStyle: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Color.fromARGB(255, 26, 60, 124),
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 16, 
                                      horizontal: 20,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return _userType == 'job_seeker' 
                                          ? 'Please enter your name' 
                                          : 'Please enter company name';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),

                                // Email Field
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    labelStyle: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Color.fromARGB(255, 26, 60, 124),
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 16, 
                                      horizontal: 20,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    if (!value.contains('@')) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),

                                // Password Field
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    labelStyle: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Color.fromARGB(255, 26, 60, 124),
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 16, 
                                      horizontal: 20,
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
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a password';
                                    }
                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),

                                // Confirm Password Field
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirmPassword,
                                  decoration: InputDecoration(
                                    labelText: 'Confirm Password',
                                    labelStyle: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Color.fromARGB(255, 26, 60, 124),
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 16, 
                                      horizontal: 20,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirmPassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.grey.shade600,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureConfirmPassword = !_obscureConfirmPassword;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value != _passwordController.text) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),

                                // Profile Picture/Company Logo
                                Text(
                                  _userType == 'job_seeker' 
                                      ? 'Profile Picture' 
                                      : 'Company Logo',
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 26, 60, 124),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      border: Border.all(
                                        color: const Color.fromARGB(255, 107, 146, 230),
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: _userType == 'job_seeker'
                                        ? _profileImage != null
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.circular(12),
                                                child: Image.file(
                                                  _profileImage!,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : const Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.add_a_photo,
                                                    color: Color.fromARGB(255, 107, 146, 230),
                                                  ),
                                                  SizedBox(height: 5),
                                                  Text(
                                                    'Add Photo',
                                                    style: TextStyle(
                                                      color: Color.fromARGB(255, 107, 146, 230),
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              )
                                        : _companyLogo != null
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.circular(12),
                                                child: Image.file(
                                                  _companyLogo!,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : const Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.add_a_photo,
                                                    color: Color.fromARGB(255, 107, 146, 230),
                                                  ),
                                                  SizedBox(height: 5),
                                                  Text(
                                                    'Add Logo',
                                                    style: TextStyle(
                                                      color: Color.fromARGB(255, 107, 146, 230),
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Job Seeker Specific Fields
                                if (_userType == 'job_seeker') ...[
                                  // Resume Upload
                                  const Text(
                                    'Resume',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 26, 60, 124),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  OutlinedButton(
                                    onPressed: _pickResume,
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      side: const BorderSide(
                                        color: Color.fromARGB(255, 107, 146, 230),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.upload,
                                          color: Color.fromARGB(255, 107, 146, 230),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _resumeFile != null 
                                              ? 'Resume Selected' 
                                              : 'Upload Resume',
                                          style: const TextStyle(
                                            color: Color.fromARGB(255, 107, 146, 230),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Skills
                                  const Text(
                                    'Skills',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 26, 60, 124),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _skillsController,
                                          decoration: InputDecoration(
                                            hintText: 'Add a skill',
                                            filled: true,
                                            fillColor: Colors.grey.shade50,
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                color: Color.fromARGB(255, 26, 60, 124),
                                              ),
                                            ),
                                            contentPadding: const EdgeInsets.symmetric(
                                              vertical: 16, 
                                              horizontal: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(255, 107, 146, 230),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: IconButton(
                                          icon: const Icon(Icons.add, color: Colors.white),
                                          onPressed: _addSkill,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    children: _skills.map((skill) => Chip(
                                      label: Text(skill),
                                      deleteIcon: const Icon(Icons.close, size: 18),
                                      onDeleted: () {
                                        setState(() => _skills.remove(skill));
                                      },
                                      backgroundColor: const Color.fromARGB(255, 229, 239, 255),
                                      labelStyle: const TextStyle(
                                        color: Color.fromARGB(255, 26, 60, 124),
                                      ),
                                    )).toList(),
                                  ),
                                  const SizedBox(height: 20),

                                  // Experience
                                  TextFormField(
                                    controller: _experienceController,
                                    decoration: InputDecoration(
                                      labelText: 'Experience',
                                      labelStyle: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color.fromARGB(255, 26, 60, 124),
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        vertical: 16, 
                                        horizontal: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Education
                                  TextFormField(
                                    controller: _educationController,
                                    decoration: InputDecoration(
                                      labelText: 'Education',
                                      labelStyle: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color.fromARGB(255, 26, 60, 124),
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        vertical: 16, 
                                        horizontal: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],

                                // Employer Specific Fields
                                if (_userType == 'employer') ...[
                                  TextFormField(
                                    controller: _websiteController,
                                    decoration: InputDecoration(
                                      labelText: 'Company Website',
                                      labelStyle: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color.fromARGB(255, 26, 60, 124),
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        vertical: 16, 
                                        horizontal: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  TextFormField(
                                    controller: _descriptionController,
                                    maxLines: 3,
                                    decoration: InputDecoration(
                                      labelText: 'Company Description',
                                      labelStyle: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color.fromARGB(255, 26, 60, 124),
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        vertical: 16, 
                                        horizontal: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],

                                // Submit Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _submitForm,
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
                                            "Sign Up",
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

                                // Already have account
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Already have an account?",
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pushReplacement(
                                          FadeTransitionPageRoute(
                                              page: const LoginScreen()),
                                        );
                                      },
                                      child: const Text(
                                        "Login",
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