import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intern_link/models/application_model.dart';
import 'package:intern_link/models/internship_model.dart';
import 'package:intern_link/models/job_model.dart';
import 'package:intern_link/models/user_model.dart';

class ApplicationStatusScreen extends StatefulWidget {
  final List<dynamic> listings;
  final User currentUser;

  const ApplicationStatusScreen({
    Key? key,
    required this.listings,
    required this.currentUser,
  }) : super(key: key);

  @override
  State<ApplicationStatusScreen> createState() => _ApplicationStatusScreenState();
}

class _ApplicationStatusScreenState extends State<ApplicationStatusScreen> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final isEmployer = widget.currentUser.role == 'employer';
    final filteredListings = _filterListings(widget.listings);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFFF5F9FF),
            elevation: 0,
            pinned: true,
            title: Text(
              isEmployer ? 'Received Applications' : 'My Applications',
              style: const TextStyle(
                color: Color.fromARGB(255, 26, 60, 124),
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildFilterChip('All', 'all'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Pending', 'pending'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Shortlisted', 'shortlisted'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Rejected', 'rejected'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          filteredListings.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.note_remove,
                          size: 60,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          isEmployer ? 'No applications received' : 'No applications found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _selectedFilter == 'all'
                              ? isEmployer 
                                  ? 'You haven\'t received any applications yet'
                                  : 'You haven\'t applied to anything yet'
                              : 'No $_selectedFilter applications',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final listing = filteredListings[index];
                      return isEmployer
                          ? _buildEmployerApplicationCard(listing)
                          : _buildApplicantApplicationCard(listing);
                    },
                    childCount: filteredListings.length,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedFilter == value,
      onSelected: (selected) {
        setState(() => _selectedFilter = value);
      },
      selectedColor: const Color.fromARGB(255, 107, 146, 230),
      labelStyle: TextStyle(
        color: _selectedFilter == value ? Colors.white : const Color.fromARGB(255, 26, 60, 124),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      side: BorderSide(
        color: _selectedFilter == value 
            ? const Color.fromARGB(255, 107, 146, 230)
            : Colors.grey.shade300,
      ),
    );
  }

  List<dynamic> _filterListings(List<dynamic> listings) {
    return listings.where((listing) {
      if (widget.currentUser.role == 'employer') {
        // For employer, show listings that have applications
        if (listing.applicationsReceived.isEmpty) return false;
        
        if (_selectedFilter == 'all') return true;
        
        // Check if any application matches the filter
        return listing.applicationsReceived.any(
          (app) => app.status == _selectedFilter
        );
      } else {
        // For job seeker, show their own applications
        final userApplication = listing.applicationsReceived.firstWhere(
          (app) => app.applicantId == widget.currentUser.userId,
          orElse: () => Application(
            applicationId: '',
            type: '',
            jobOrInternshipId: '',
            applicantId: '',
            appliedOn: '',
            status: '',
            remarks: '',
          ),
        );
        
        if (_selectedFilter == 'all') return userApplication.applicantId.isNotEmpty;
        return userApplication.status == _selectedFilter;
      }
    }).toList();
  }

  Widget _buildApplicantApplicationCard(dynamic listing) {
    final userApplication = listing.applicationsReceived.firstWhere(
      (app) => app.applicantId == widget.currentUser.userId,
      orElse: () => Application(
        applicationId: '',
        type: '',
        jobOrInternshipId: '',
        applicantId: '',
        appliedOn: '',
        status: '',
        remarks: '',
      ),
    );

    final isJob = listing is Job;
    final statusColor = _getStatusColor(userApplication.status);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: const Color(0xFFF5F9FF),
                  backgroundImage: AssetImage(listing.companyLogo),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color.fromARGB(255, 26, 60, 124),
                        ),
                      ),
                      Text(
                        isJob ? 'Job Application' : 'Internship Application',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    userApplication.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildDetailItem(Iconsax.calendar, userApplication.appliedOn),
                const SizedBox(width: 16),
                _buildDetailItem(Iconsax.location, listing.location),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildDetailItem(
                  Iconsax.money,
                  isJob ? listing.salary : listing.stipend,
                ),
                const SizedBox(width: 16),
                _buildDetailItem(
                  Iconsax.clock,
                  '${isJob ? 'Full-time' : '3 months'}',
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (userApplication.remarks.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Remarks:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 26, 60, 124),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userApplication.remarks,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            if (userApplication.status == 'shortlisted')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle interview scheduling
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 107, 146, 230),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Schedule Interview',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployerApplicationCard(dynamic listing) {
    final isJob = listing is Job;
    final applications = listing.applicationsReceived
        .where((app) => _selectedFilter == 'all' || app.status == _selectedFilter)
        .toList();

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: const Color(0xFFF5F9FF),
                  backgroundImage: AssetImage(listing.companyLogo),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color.fromARGB(255, 26, 60, 124),
                        ),
                      ),
                      Text(
                        isJob ? 'Job Posting' : 'Internship Posting',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 229, 239, 255),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${applications.length} ${applications.length == 1 ? 'Application' : 'Applications'}',
                    style: const TextStyle(
                      color: Color.fromARGB(255, 26, 60, 124),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildDetailItem(Iconsax.calendar, 'Last Date: ${listing.lastDate}'),
                const SizedBox(width: 16),
                _buildDetailItem(Iconsax.location, listing.location),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildDetailItem(
                  Iconsax.money,
                  isJob ? listing.salary : listing.stipend,
                ),
                const SizedBox(width: 16),
                _buildDetailItem(
                  Iconsax.clock,
                  '${isJob ? 'Full-time' : '3 months'}',
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Applications:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Color.fromARGB(255, 26, 60, 124),
              ),
            ),
            const SizedBox(height: 8),
            ...applications.map((application) => _buildApplicationListItem(application)),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationListItem(Application application) {
    final statusColor = _getStatusColor(application.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F9FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child: Icon(Iconsax.profile_circle, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Applicant ID: ${application.applicantId.substring(0, 8)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color.fromARGB(255, 26, 60, 124),
                      ),
                    ),
                    Text(
                      'Applied on: ${application.appliedOn}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  application.status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (application.remarks.isNotEmpty)
            Text(
              'Remarks: ${application.remarks}',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 12,
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _updateApplicationStatus(application, 'shortlisted');
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: const BorderSide(
                      color: Colors.green,
                    ),
                  ),
                  child: const Text(
                    'Shortlist',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _updateApplicationStatus(application, 'rejected');
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: const BorderSide(
                      color: Colors.red,
                    ),
                  ),
                  child: const Text(
                    'Reject',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: const Color.fromARGB(255, 107, 146, 230),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _updateApplicationStatus(Application application, String newStatus) {
    setState(() {
      application.status = newStatus;
      // In a real app, you would update this in your database
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Application ${newStatus.toLowerCase()}'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: newStatus == 'shortlisted' ? Colors.green : Colors.red,
        ),
      );
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'shortlisted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}