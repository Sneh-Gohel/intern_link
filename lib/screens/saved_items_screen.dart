import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intern_link/models/internship_model.dart';
import 'package:intern_link/models/job_model.dart';
import 'package:intern_link/models/user_model.dart';
import 'package:intern_link/screens/internship_detail_screen.dart';
import 'package:intern_link/screens/job_detail_screen.dart';

class SavedItemsScreen extends StatefulWidget {
  final List<dynamic> savedListings;
  final User currentUser;

  const SavedItemsScreen({
    Key? key,
    required this.savedListings,
    required this.currentUser,
  }) : super(key: key);

  @override
  State<SavedItemsScreen> createState() => _SavedItemsScreenState();
}

class _SavedItemsScreenState extends State<SavedItemsScreen> {
  int _activeTab = 0; // 0 = Internships, 1 = Jobs

  @override
  Widget build(BuildContext context) {
    final savedInternships = widget.savedListings.whereType<Internship>().toList();
    final savedJobs = widget.savedListings.whereType<Job>().toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFFF5F9FF),
            elevation: 0,
            pinned: true,
            title: const Text(
              'Saved Items',
              style: TextStyle(
                color: Color.fromARGB(255, 26, 60, 124),
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 229, 239, 255),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildSavedTab('Internships', 0),
                          ),
                          Expanded(
                            child: _buildSavedTab('Jobs', 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
          _activeTab == 0
              ? _buildInternshipsList(savedInternships)
              : _buildJobsList(savedJobs),
        ],
      ),
    );
  }

  Widget _buildSavedTab(String title, int index) {
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

  SliverList _buildInternshipsList(List<Internship> internships) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final internship = internships[index];
          return _buildSavedInternshipCard(internship);
        },
        childCount: internships.length,
      ),
    );
  }

  SliverList _buildJobsList(List<Job> jobs) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final job = jobs[index];
          return _buildSavedJobCard(job);
        },
        childCount: jobs.length,
      ),
    );
  }

  Widget _buildSavedInternshipCard(Internship internship) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFFF5F9FF),
              backgroundImage: AssetImage(internship.companyLogo),
            ),
            title: Text(
              internship.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 26, 60, 124),
              ),
            ),
            subtitle: Text(
              internship.postedBy,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            trailing: IconButton(
              icon: const Icon(
                Iconsax.bookmark_25,
                color: Color.fromARGB(255, 107, 146, 230),
              ),
              onPressed: () => _removeSavedItem(internship.internshipId),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildDetailChip(Iconsax.money, internship.stipend),
                    const SizedBox(width: 10),
                    _buildDetailChip(Iconsax.location, internship.location),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildDetailChip(Iconsax.clock, "3 months"),
                    const SizedBox(width: 10),
                    _buildDetailChip(
                      Iconsax.calendar,
                      'Apply by ${internship.lastDate}',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InternshipDetailScreen(
                            internship: internship,
                            isSaved: true,
                            onApply: () {},
                            onSaveToggle: () => _removeSavedItem(internship.internshipId),
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(
                        color: Color.fromARGB(255, 107, 146, 230),
                      ),
                    ),
                    child: const Text(
                      'View Details',
                      style: TextStyle(
                        color: Color.fromARGB(255, 107, 146, 230),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Apply now action
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 107, 146, 230),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Apply Now',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildSavedJobCard(Job job) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFFF5F9FF),
              backgroundImage: AssetImage(job.companyLogo),
            ),
            title: Text(
              job.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 26, 60, 124),
              ),
            ),
            subtitle: Text(
              job.postedBy,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            trailing: IconButton(
              icon: const Icon(
                Iconsax.bookmark_25,
                color: Color.fromARGB(255, 107, 146, 230),
              ),
              onPressed: () => _removeSavedItem(job.jobId),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildDetailChip(Iconsax.money, job.salary),
                    const SizedBox(width: 10),
                    _buildDetailChip(Iconsax.location, job.location),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildDetailChip(Iconsax.clock, 'Full-time'),
                    const SizedBox(width: 10),
                    _buildDetailChip(
                      Iconsax.calendar,
                      'Apply by ${job.lastDate}',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JobDetailScreen(
                            job: job,
                            isSaved: true,
                            onApply: () {},
                            onSaveToggle: () => _removeSavedItem(job.jobId),
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(
                        color: Color.fromARGB(255, 107, 146, 230),
                      ),
                    ),
                    child: const Text(
                      'View Details',
                      style: TextStyle(
                        color: Color.fromARGB(255, 107, 146, 230),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Apply now action
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 107, 146, 230),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Apply Now',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F9FF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: const Color.fromARGB(255, 107, 146, 230),
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeSavedItem(String id) {
    setState(() {
      widget.currentUser.profile.savedJobs?.remove(id);
      // In a real app, you would update this in your database
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Removed from saved items'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.green.shade600,
        ),
      );
    });
  }
}