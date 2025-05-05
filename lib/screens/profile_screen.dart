import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  final String userId; // Now only takes user ID

  const ProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _activeTab = 0;
  late Future<Map<String, dynamic>> _userData;
  bool _isLoading = true;
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _userData = _fetchUserData();
  }

  Future<Map<String, dynamic>> _fetchUserData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (!doc.exists) {
        throw Exception('User not found');
      }

      final data = doc.data()!;
      setState(() {
        _user = data;
        _isLoading = false;
      });
      return data;
    } catch (e) {
      setState(() => _isLoading = false);
      throw Exception('Failed to load user data: $e');
    }
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F9FF),
        body: Center(
          child: CircularProgressIndicator(
            color: const Color.fromARGB(255, 107, 146, 230),
          ),
        ),
      );
    }

    if (_user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F9FF),
        body: Center(
          child: Text(
            'Failed to load profile',
            style: TextStyle(
              color: const Color.fromARGB(255, 26, 60, 124),
            ),
          ),
        ),
      );
    }

    final isEmployer = _user!['jobSeeker'] == false;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFFF5F9FF),
            expandedHeight: 220,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 46,
                        backgroundImage: _user!['profilePicture'] != null
                            ? CachedNetworkImageProvider(
                                _user!['profilePicture'])
                            : const AssetImage(
                                    'assets/images/default_profile.png')
                                as ImageProvider,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _user!['name'] ?? 'No Name',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      isEmployer ? 'Employer' : 'Job Seeker',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.logout,
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  // Handle logout
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Edit Profile Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        print("Edit Profile Button Pressed");
                      },
                      icon: const Icon(Iconsax.edit, size: 18),
                      label: const Text('Edit Profile'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(
                          color: Color.fromARGB(255, 107, 146, 230),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Profile Tabs
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 229, 239, 255),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildProfileTab('Personal', 0),
                        ),
                        Expanded(
                          child: _buildProfileTab('Professional', 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tab Content
                  IndexedStack(
                    index: _activeTab,
                    children: [
                      // Personal Tab
                      _buildPersonalInfo(),

                      // Professional Tab
                      _buildProfessionalInfo(),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Additional Actions
                  _buildActionButton(
                    icon: Iconsax.document_text,
                    text: 'My Resume',
                    onTap: () {
                      if (_user!['resumeUrl'] != null) {
                        _launchURL(_user!['resumeUrl']);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No resume uploaded')),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildActionButton(
                    icon: Iconsax.shield_tick,
                    text: 'Privacy Policy',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Privacy Policy'),
                          content: SingleChildScrollView(
                            child: Text(
                              _privacyPolicyText,
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Privacy Policy Text
  final String _privacyPolicyText = '''
1. Information We Collect:
We collect personal information you provide when creating an account, including name, email, education, skills, and work experience.

2. How We Use Your Information:
- To provide and improve our services
- To connect job seekers with employers
- To communicate with you about opportunities
- For analytics and service improvements

3. Data Sharing:
We only share your profile information with potential employers when you apply for positions. We do not sell your data to third parties.

4. Data Security:
We implement industry-standard security measures to protect your information.

5. Your Rights:
You can access, update, or delete your personal information through your account settings.

6. Changes to This Policy:
We may update this policy and will notify you of significant changes.

7. Contact Us:
For any privacy-related questions, please contact support@internlink.com
''';

  Widget _buildProfileTab(String title, int index) {
    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: _activeTab == index
              ? const Color.fromARGB(255, 107, 146, 230)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _activeTab == index
                ? Colors.white
                : const Color.fromARGB(255, 26, 60, 124),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfo() {
    return Column(
      children: [
        _buildInfoCard(
          icon: Iconsax.sms,
          title: 'Email',
          value: _user!['email'] ?? 'Not provided',
        ),
        const SizedBox(height: 12),
        if (_user!['Experience'] != null)
          _buildInfoCard(
            icon: Iconsax.briefcase,
            title: 'Experience',
            value: _user!['Experience'],
          ),
        if (_user!['Experience'] != null) const SizedBox(height: 12),
        if (_user!['Education'] != null)
          _buildInfoCard(
            icon: Iconsax.book,
            title: 'Education',
            value: _user!['Education'],
          ),
      ],
    );
  }

  Widget _buildProfessionalInfo() {
    return Column(
      children: [
        if (_user!['Skills'] != null && _user!['Skills'].isNotEmpty)
          _buildSkillsCard(),
        if (_user!['resumeUrl'] != null) ...[
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Iconsax.document,
            title: 'Resume',
            value: 'View my resume',
            isLink: true,
            onTap: () => _launchURL(_user!['resumeUrl']),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    bool isLink = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 20,
              color: const Color.fromARGB(255, 107, 146, 230),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 26, 60, 124),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      color: isLink
                          ? const Color.fromARGB(255, 107, 146, 230)
                          : Colors.grey.shade700,
                      decoration: isLink ? TextDecoration.underline : null,
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

  Widget _buildSkillsCard() {
    final skills = _user!['Skills']?.split(', ') ?? [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Iconsax.cpu,
                size: 20,
                color: Color.fromARGB(255, 107, 146, 230),
              ),
              SizedBox(width: 12),
              Text(
                'Skills',
                style: TextStyle(
                  color: Color.fromARGB(255, 26, 60, 124),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skills
                .map((skill) => Chip(
                      label: Text(skill.trim()),
                      backgroundColor: const Color.fromARGB(255, 229, 239, 255),
                      labelStyle: const TextStyle(
                        color: Color.fromARGB(255, 26, 60, 124),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color.fromARGB(255, 107, 146, 230),
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                color: Color.fromARGB(255, 26, 60, 124),
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color.fromARGB(255, 107, 146, 230),
            ),
          ],
        ),
      ),
    );
  }
}
