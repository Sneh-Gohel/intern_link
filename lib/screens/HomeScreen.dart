import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  // Sample internship data
  final List<Map<String, dynamic>> _internships = [
    {
      'title': 'Flutter Developer Intern',
      'company': 'Tech Innovations Inc.',
      'logo': 'assets/images/tech_innovations.jpg',
      'stipend': '\$1,500/month',
      'location': 'Remote',
      'duration': '3 months',
      'deadline': 'May 15, 2023',
      'isSaved': false,
    },
    {
      'title': 'UX/UI Design Intern',
      'company': 'Creative Minds Agency',
      'logo': 'assets/images/creative_minds.png',
      'stipend': '\$1,200/month',
      'location': 'New York, NY',
      'duration': '6 months',
      'deadline': 'May 30, 2023',
      'isSaved': true,
    },
    {
      'title': 'Data Science Intern',
      'company': 'Analytics Pro',
      'logo': 'assets/images/analytics_pro.jpg',
      'stipend': '\$2,000/month',
      'location': 'San Francisco, CA',
      'duration': '4 months',
      'deadline': 'June 10, 2023',
      'isSaved': false,
    },
  ];

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
                            const Text(
                              'Alex Johnson',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(
                                'https://randomuser.me/api/portraits/men/1.jpg'),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextField(
                  controller: _searchController,
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

                  // Featured Internships
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Featured Internships',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 26, 60, 124),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
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

          // Internship listings
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final internship = _internships[index];
                return _buildInternshipCard(internship, context);
              },
              childCount: _internships.length,
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildCategoryCard(
      IconData icon, String title, Color bgColor, Color iconColor) {
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

  Widget _buildInternshipCard(
      Map<String, dynamic> internship, BuildContext context) {
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
              child: Image.asset(
                internship['logo'],
                width: 30,
                height: 30,
              ),
            ),
            title: Text(
              internship['title'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 26, 60, 124),
              ),
            ),
            subtitle: Text(
              internship['company'],
              style: TextStyle(color: Colors.grey.shade600),
            ),
            trailing: IconButton(
              icon: Icon(
                internship['isSaved'] ? Iconsax.bookmark_25 : Iconsax.bookmark,
                color: internship['isSaved']
                    ? const Color.fromARGB(255, 107, 146, 230)
                    : Colors.grey.shade400,
              ),
              onPressed: () {
                setState(() {
                  internship['isSaved'] = !internship['isSaved'];
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildDetailChip(Iconsax.money, internship['stipend']),
                    const SizedBox(width: 10),
                    _buildDetailChip(Iconsax.location, internship['location']),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildDetailChip(Iconsax.clock, internship['duration']),
                    const SizedBox(width: 10),
                    _buildDetailChip(
                        Iconsax.calendar, 'Apply by ${internship['deadline']}'),
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
                      // View details action
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
            Icon(icon,
                size: 16, color: const Color.fromARGB(255, 107, 146, 230)),
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
          onTap: (index) => setState(() => _currentIndex = index),
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
              icon: Icon(_currentIndex == 3
                  ? Iconsax.profile_2user5
                  : Iconsax.profile_2user),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
