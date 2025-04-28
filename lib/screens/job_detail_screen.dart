// TODO Implement this library.
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intern_link/models/job_model.dart';
import 'package:url_launcher/url_launcher.dart';

class JobDetailScreen extends StatefulWidget {
  final Job job;
  final bool isSaved;
  final VoidCallback onApply;
  final VoidCallback onSaveToggle;

  const JobDetailScreen({
    Key? key,
    required this.job,
    required this.isSaved,
    required this.onApply,
    required this.onSaveToggle,
  }) : super(key: key);

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  bool _isExpanded = false;
  bool _isApplying = false;
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFFF5F9FF),
            expandedHeight: 250,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    job.companyLogo,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color.fromARGB(255, 197, 218, 243),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.isSaved ? Iconsax.bookmark_25 : Iconsax.bookmark,
                    color: Colors.white,
                  ),
                ),
                onPressed: widget.onSaveToggle,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          job.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: const Color.fromARGB(255, 26, 60, 124),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 229, 239, 255),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          job.status.toUpperCase(),
                          style: const TextStyle(
                            color: Color.fromARGB(255, 107, 146, 230),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Posted by ${job.postedBy}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Job Details Tabs
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 229, 239, 255),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildDetailTab('Overview', 0),
                        ),
                        Expanded(
                          child: _buildDetailTab('Requirements', 1),
                        ),
                        Expanded(
                          child: _buildDetailTab('Benefits', 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tab Content
                  IndexedStack(
                    index: _currentTab,
                    children: [
                      // Overview Tab
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailItem(Iconsax.money, 'Salary', job.salary),
                          _buildDetailItem(
                              Iconsax.location, 'Location', job.location),
                          _buildDetailItem(Iconsax.calendar, 'Last Date',
                              'Apply by ${job.lastDate}'),
                          const SizedBox(height: 20),
                          Text(
                            'Job Description',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: const Color.fromARGB(255, 26, 60, 124),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            job.description,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),

                      // Requirements Tab
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailItem(
                              Iconsax.book, 'Education', job.eligibility),
                          _buildDetailItem(Iconsax.cpu, 'Skills Required',
                              'Flutter, Dart, Firebase, REST APIs'),
                          _buildDetailItem(Iconsax.briefcase, 'Experience',
                              '2+ years in mobile development'),
                          const SizedBox(height: 20),
                          Text(
                            'Additional Requirements',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: const Color.fromARGB(255, 26, 60, 124),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '• Strong understanding of state management\n'
                            '• Experience with CI/CD pipelines\n'
                            '• Familiarity with Agile methodologies\n'
                            '• Portfolio of published apps',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),

                      // Benefits Tab
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBulletPoint(
                              'Competitive salary and bonus structure'),
                          _buildBulletPoint('Health insurance coverage'),
                          _buildBulletPoint('Flexible work hours'),
                          _buildBulletPoint('Remote work options'),
                          _buildBulletPoint('Professional development budget'),
                          _buildBulletPoint('Generous vacation policy'),
                          const SizedBox(height: 20),
                          Text(
                            'Company Culture',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: const Color.fromARGB(255, 26, 60, 124),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'We foster a collaborative environment where creativity and innovation thrive. Our team values work-life balance and continuous learning.',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  final uri = Uri.parse('https://${job.postedBy}.com');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not launch website')),
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(
                    color: Color.fromARGB(255, 107, 146, 230),
                  ),
                ),
                child: const Text(
                  'Company Website',
                  style: TextStyle(
                    color: Color.fromARGB(255, 107, 146, 230),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  setState(() => _isApplying = true);
                  await Future.delayed(const Duration(seconds: 1)); // Simulate apply
                  widget.onApply();
                  setState(() => _isApplying = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Application submitted successfully!'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.green.shade600,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 107, 146, 230),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isApplying
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Apply Now',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTab(String title, int index) {
    return GestureDetector(
      onTap: () => setState(() => _currentTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: _currentTab == index
              ? const Color.fromARGB(255, 107, 146, 230)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _currentTab == index ? Colors.white : const Color.fromARGB(255, 26, 60, 124),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 8, right: 10),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 107, 146, 230),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}