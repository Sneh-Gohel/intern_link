import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intern_link/models/internship_model.dart';
import 'package:intern_link/models/job_model.dart';
import 'package:intern_link/models/user_model.dart';
import 'package:intern_link/screens/application_status_screen.dart';
import 'package:intern_link/screens/internship_detail_screen.dart';
import 'package:intern_link/screens/job_detail_screen.dart';
import 'package:intern_link/screens/profile_screen.dart';
import 'package:intern_link/screens/saved_items_screen.dart';
import 'package:intern_link/services/json_data_service.dart';

class HomeScreen extends StatefulWidget {
  final User currentUser;

  const HomeScreen({Key? key, required this.currentUser}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  List<Internship> _internships = [];
  List<Job> _jobs = [];
  List<dynamic> _allListings = [];
  bool _isLoading = true;
  bool _showInternships = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final internships = await JsonDataService.loadInternships();
      final jobs = await JsonDataService.loadJobs();
      
      setState(() {
        _internships = internships;
        _jobs = jobs;
        _allListings = [...internships, ...jobs];
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  void _toggleSaved(String id) {
    setState(() {
      if (widget.currentUser.profile.savedJobs?.contains(id) ?? false) {
        widget.currentUser.profile.savedJobs?.remove(id);
      } else {
        widget.currentUser.profile.savedJobs ??= [];
        widget.currentUser.profile.savedJobs?.add(id);
      }
    });
    // In a real app, you would update this in your database
  }

  void _applyForListing(dynamic listing) {
    setState(() {
      // In a real app, you would create a new application in your database
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Applied for ${listing.title}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  List<dynamic> get _displayedListings {
    return _showInternships 
        ? _internships.where((i) => i.status == 'approved').toList()
        : _jobs.where((j) => j.status == 'approved').toList();
  }

  List<dynamic> get _savedListings {
    return _allListings.where((item) {
      return widget.currentUser.profile.savedJobs?.contains(
        item is Internship ? item.internshipId : item.jobId
      ) ?? false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      body: CustomScrollView(
        slivers: [
          // App bar with search
          SliverAppBar(
            backgroundColor: const Color(0xFFF5F9FF),
            elevation: 0,
            pinned: true,
            floating: true,
            expandedHeight: 150,
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
                padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello,',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            Text(
                              widget.currentUser.name.split(' ').first,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfileScreen(user: widget.currentUser),
                              ),
                            );
                          },
                          child: CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 20,
                              backgroundImage: widget.currentUser.profile.profilePicture != null
                                  ? AssetImage(widget.currentUser.profile.profilePicture!)
                                  : const AssetImage('assets/images/default_profile.png'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(75),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {}); // Trigger rebuild for search
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Search internships, jobs...',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    prefixIcon: Icon(Iconsax.search_normal,
                        color: Colors.grey.shade600),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categories
                  const Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 26, 60, 124),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildCategoryCard(
                          Iconsax.code,
                          'Development',
                          const Color(0xFFE1F0FF),
                          const Color(0xFF1A3C7C),
                        ),
                        _buildCategoryCard(
                          Iconsax.designtools,
                          'Design',
                          const Color(0xFFFFE7F5),
                          const Color(0xFFD23369),
                        ),
                        _buildCategoryCard(
                          Iconsax.chart_2,
                          'Marketing',
                          const Color(0xFFE4F9E4),
                          const Color(0xFF2E7D32),
                        ),
                        _buildCategoryCard(
                          Iconsax.cpu,
                          'Data Science',
                          const Color(0xFFF0E7FF),
                          const Color(0xFF5E35B1),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Toggle between Internships and Jobs
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Internships'),
                          selected: _showInternships,
                          onSelected: (selected) {
                            setState(() {
                              _showInternships = true;
                            });
                          },
                          selectedColor: const Color.fromARGB(255, 107, 146, 230),
                          labelStyle: TextStyle(
                            color: _showInternships ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Jobs'),
                          selected: !_showInternships,
                          onSelected: (selected) {
                            setState(() {
                              _showInternships = false;
                            });
                          },
                          selectedColor: const Color.fromARGB(255, 107, 146, 230),
                          labelStyle: TextStyle(
                            color: !_showInternships ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // Featured Listings
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _showInternships ? 'Featured Internships' : 'Featured Jobs',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 26, 60, 124),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SavedItemsScreen(
                                savedListings: _savedListings,
                                currentUser: widget.currentUser,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'See all',
                          style: TextStyle(
                            color: Color.fromARGB(255, 107, 146, 230),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Listings
          _isLoading
              ? SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(
                        color: const Color.fromARGB(255, 107, 146, 230),
                      ),
                    ),
                  ),
                )
              : _displayedListings.isEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Center(
                          child: Text(
                            'No ${_showInternships ? 'internships' : 'jobs'} available',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final listing = _displayedListings[index];
                          return _buildListingCard(listing, context);
                        },
                        childCount: _displayedListings.length,
                      ),
                    ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildListingCard(dynamic listing, BuildContext context) {
    final isSaved = widget.currentUser.profile.savedJobs?.contains(
      listing is Internship ? listing.internshipId : listing.jobId
    ) ?? false;

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
              backgroundImage: AssetImage(listing.companyLogo),
            ),
            title: Text(
              listing.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 26, 60, 124),
              ),
            ),
            subtitle: Text(
              listing.postedBy, // In a real app, you'd look up the company name
              style: TextStyle(color: Colors.grey.shade600),
            ),
            trailing: IconButton(
              icon: Icon(
                isSaved ? Iconsax.bookmark_25 : Iconsax.bookmark,
                color: isSaved
                    ? const Color.fromARGB(255, 107, 146, 230)
                    : Colors.grey.shade400,
              ),
              onPressed: () {
                _toggleSaved(listing is Internship 
                    ? listing.internshipId 
                    : listing.jobId);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildDetailChip(
                      Iconsax.money,
                      listing is Internship ? listing.stipend : listing.salary,
                    ),
                    const SizedBox(width: 10),
                    _buildDetailChip(Iconsax.location, listing.location),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildDetailChip(Iconsax.clock, "3 months"), // Hardcoded for demo
                    const SizedBox(width: 10),
                    _buildDetailChip(
                      Iconsax.calendar,
                      'Apply by ${listing.lastDate}',
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
                          builder: (context) => listing is Internship
                              ? InternshipDetailScreen(
                                  internship: listing,
                                  onApply: () => _applyForListing(listing),
                                  isSaved: isSaved,
                                  onSaveToggle: () => _toggleSaved(listing.internshipId),)
                              : JobDetailScreen(
                                  job: listing,
                                  onApply: () => _applyForListing(listing),
                                  isSaved: isSaved,
                                  onSaveToggle: () => _toggleSaved(listing.jobId),
                        ),
                      ));
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(
                          color: Color.fromARGB(255, 107, 146, 230)),
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
                      _applyForListing(listing);
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

  Widget _buildCategoryCard(IconData icon, String title, Color bgColor, Color iconColor) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
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
            Icon(icon, size: 16, color: const Color.fromARGB(255, 107, 146, 230)),
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

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SavedItemsScreen(
                    savedListings: _savedListings,
                    currentUser: widget.currentUser,
                  ),
                ),
              );
            } else if (index == 2) {
              Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ApplicationStatusScreen(
      listings: _allListings,  // Use the class property
      currentUser: widget.currentUser,  // Use the widget property
    ),
  ),
);
            } else if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(user: widget.currentUser),
                ),
              );
            } else {
              setState(() => _currentIndex = index);
            }
          },
          backgroundColor: Colors.white,
          selectedItemColor: const Color.fromARGB(255, 107, 146, 230),
          unselectedItemColor: Colors.grey.shade500,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Icon(_currentIndex == 0 ? Iconsax.home_25 : Iconsax.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(_currentIndex == 1 ? Iconsax.save_25 : Iconsax.save_2),
              label: 'Saved',
            ),
            BottomNavigationBarItem(
              icon: Icon(_currentIndex == 2
                  ? Iconsax.document_text_15
                  : Iconsax.document_text),
              label: 'Applications',
            ),
            BottomNavigationBarItem(
              icon: Icon(_currentIndex == 3 ? Iconsax.profile_2user5 : Iconsax.profile_2user),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}