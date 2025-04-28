import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intern_link/models/user_model.dart';
// import 'package:intern_link/screens/edit_profile_screen.dart';
import 'package:intern_link/screens/LoginScreen.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _activeTab = 0; // 0 = Personal, 1 = Professional

  @override
  Widget build(BuildContext context) {
    final isEmployer = widget.user.role == 'employer';
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
                        backgroundImage: widget.user.profile.profilePicture != null
                            ? AssetImage(widget.user.profile.profilePicture!)
                            : const AssetImage('assets/images/default_profile.png'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.user.name,
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
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
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
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => EditProfileScreen(user: widget.user),
                        //   ),
                        // ).then((_) => setState(() {}));
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
                          child: _buildProfileTab(
                            isEmployer ? 'Company' : 'Professional',
                            1,
                          ),
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

                      // Professional/Company Tab
                      isEmployer ? _buildCompanyInfo() : _buildProfessionalInfo(),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Additional Actions
                  if (!isEmployer) ...[
                    _buildActionButton(
                      icon: Iconsax.document_text,
                      text: 'My Resume',
                      onTap: () {
                        // Navigate to resume screen
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                  _buildActionButton(
                    icon: Iconsax.setting,
                    text: 'Settings',
                    onTap: () {
                      // Navigate to settings
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildActionButton(
                    icon: Iconsax.shield_tick,
                    text: 'Privacy Policy',
                    onTap: () {
                      // Navigate to privacy policy
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
          value: widget.user.email,
        ),
        const SizedBox(height: 12),
        if (widget.user.profile.experience != null)
          _buildInfoCard(
            icon: Iconsax.briefcase,
            title: 'Experience',
            value: widget.user.profile.experience!,
          ),
        if (widget.user.profile.experience != null) const SizedBox(height: 12),
        if (widget.user.profile.education != null)
          _buildInfoCard(
            icon: Iconsax.book,
            title: 'Education',
            value: widget.user.profile.education!,
          ),
      ],
    );
  }

  Widget _buildProfessionalInfo() {
    return Column(
      children: [
        if (widget.user.profile.skills != null && widget.user.profile.skills!.isNotEmpty)
          _buildSkillsCard(),
        if (widget.user.profile.resumeLink != null) ...[
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Iconsax.document,
            title: 'Resume',
            value: 'View my resume',
            isLink: true,
          ),
        ],
      ],
    );
  }

  Widget _buildCompanyInfo() {
    return Column(
      children: [
        if (widget.user.profile.companyWebsite != null)
          _buildInfoCard(
            icon: Iconsax.global,
            title: 'Website',
            value: widget.user.profile.companyWebsite!,
            isLink: true,
          ),
        if (widget.user.profile.companyWebsite != null) const SizedBox(height: 12),
        if (widget.user.profile.companyDescription != null)
          _buildInfoCard(
            icon: Iconsax.info_circle,
            title: 'About',
            value: widget.user.profile.companyDescription!,
          ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    bool isLink = false,
  }) {
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
                GestureDetector(
                  onTap: isLink ? () {} : null,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: isLink
                          ? const Color.fromARGB(255, 107, 146, 230)
                          : Colors.grey.shade700,
                      decoration: isLink ? TextDecoration.underline : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsCard() {
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
            children: widget.user.profile.skills!
                .map((skill) => Chip(
                      label: Text(skill),
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