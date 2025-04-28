import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intern_link/models/internship_model.dart';
import 'package:intern_link/models/user_model.dart';
import 'package:url_launcher/url_launcher.dart';

class InternshipDetailScreen extends StatefulWidget {
  final Internship internship;
  final bool isSaved;
  final VoidCallback onApply;
  final VoidCallback onSaveToggle;

  const InternshipDetailScreen({
    Key? key,
    required this.internship,
    required this.isSaved,
    required this.onApply,
    required this.onSaveToggle,
  }) : super(key: key);

  @override
  State<InternshipDetailScreen> createState() => _InternshipDetailScreenState();
}

class _InternshipDetailScreenState extends State<InternshipDetailScreen> {
  bool _isExpanded = false;
  bool _isApplying = false;

  @override
  Widget build(BuildContext context) {
    final internship = widget.internship;
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
                    internship.companyLogo,
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
                          internship.title,
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
                          internship.status.toUpperCase(),
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
                    'Posted by ${internship.postedBy}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildDetailChip(
                        Iconsax.money,
                        internship.stipend,
                        const Color.fromARGB(255, 229, 239, 255),
                      ),
                      const SizedBox(width: 10),
                      _buildDetailChip(
                        Iconsax.location,
                        internship.location,
                        const Color.fromARGB(255, 229, 239, 255),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildDetailChip(
                        Iconsax.clock,
                        '3 months', // Adjust duration as needed
                        const Color.fromARGB(255, 229, 239, 255),
                      ),
                      const SizedBox(width: 10),
                      _buildDetailChip(
                        Iconsax.calendar,
                        'Apply by ${internship.lastDate}',
                        const Color.fromARGB(255, 229, 239, 255),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'About the Internship',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: const Color.fromARGB(255, 26, 60, 124),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    internship.description,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Eligibility Criteria',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: const Color.fromARGB(255, 26, 60, 124),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    internship.eligibility,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ExpansionPanelList(
                    elevation: 0,
                    expandedHeaderPadding: EdgeInsets.zero,
                    expansionCallback: (index, isExpanded) {
                      setState(() => _isExpanded = !isExpanded);
                    },
                    children: [
                      ExpansionPanel(
                        headerBuilder: (context, isExpanded) {
                          return const ListTile(
                            title: Text(
                              'Additional Information',
                              style: TextStyle(
                                color: Color.fromARGB(255, 26, 60, 124),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                        body: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoItem('Start Date', 'Immediate'),
                            _buildInfoItem('Duration', '3 months'),
                            _buildInfoItem('Work Mode', internship.location == 'Remote' 
                                ? 'Remote' 
                                : 'On-site'),
                            _buildInfoItem('Skills Required', 'Flutter, Dart, Firebase'),
                          ],
                        ),
                        isExpanded: _isExpanded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
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
                  final uri = Uri.parse('https://${internship.postedBy}.com');
                  if (false) {
                    // await launchUrl(uri);
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
                  'Visit Website',
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

  Widget _buildDetailChip(IconData icon, String text, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: const Color.fromARGB(255, 107, 146, 230),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                text,
                style: const TextStyle(
                  color: Color.fromARGB(255, 26, 60, 124),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6, right: 10),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 107, 146, 230),
              shape: BoxShape.circle,
            ),
          ),
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
}