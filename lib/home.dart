import 'package:flutter/material.dart';

import 'auth/profile.dart';
import 'auth/signin.dart';
import 'blood_sugar_tracker.dart';
import 'dietary_recommendations_screen.dart';
import 'main.dart';
import 'sugar_measurement_locations_app.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              prefs.clear();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: ((context) {
                    return const SignIn();
                  }),
                ),
                (route) => false,
              );
            },
            icon: const Icon(Icons.login_outlined),
          ),
        ],
        foregroundColor: Colors.white,
        title: const Text('GHND'),
        backgroundColor: const Color(0xFF6f70a0),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome Message
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _getGreetingMessage(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Health Overview and Dashboard Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: FutureBuilder(
                future: updateDashboard(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _dashboardItems.length,
                    itemBuilder: (context, index) {
                      final item = _dashboardItems[index];
                      return DashboardCard(
                        icon: item['icon'] as String,
                        shadowColor: item['shadowColor'] as Color,
                        title: item['title'] as String,
                        data: item['data'] as String,
                        label: item['label'] as String,
                        onPressed: () {
                          openViewPage(context, item['number']);
                        },
                      );
                    },
                  );
                },
              ),
            ),

            // Notifications Section
            Container(
              margin: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 249, 233, 232),
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.red,
                    offset: Offset(-5, 0),
                    blurRadius: 0,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.0),
                  ListTile(
                    leading: Icon(Icons.timer, color: Colors.red),
                    title: Text(
                      "Reminder: Time for your afternoon blood sugar check!",
                      style: TextStyle(fontSize: 16, color: Colors.red),
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

  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    String? fullName = prefs.getString('fullName') ?? '';
    if (hour < 12) {
      return "Good Morning, $fullName!";
    } else if (hour < 18) {
      return "Good Afternoon, $fullName!";
    } else {
      return "Good Evening, $fullName!";
    }
  }

  void openViewPage(BuildContext context, String number) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        if (number == '1') {
          return const BloodSugarTracker();
        } else if (number == '2') {
          return const DietaryRecommendationsScreen();
        } else if (number == '3') {
          return const ProfilePage();
        } else {
          return const NearbyLocationsPage();
        }
      }),
    );
  }
}

class DashboardCard extends StatefulWidget {
  final String icon;
  final Color shadowColor;
  final String title;
  final String data;
  final String label;
  final VoidCallback onPressed;

  const DashboardCard({
    Key? key,
    required this.icon,
    required this.shadowColor,
    required this.title,
    required this.data,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard> {
  @override
  void initState() {
    super.initState();
    updateDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.only(bottom: 15.0),
      decoration: BoxDecoration(
        color: const Color(0xFFf5f7fa),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: widget.shadowColor,
            offset: const Offset(-5, 0),
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.icon,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.055,
              ),
            ),
            const SizedBox(height: 10.0),
            Text(
              widget.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF505184),
                fontSize: screenWidth * 0.055,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10.0),
            Text(
              widget.data,
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                color: const Color(0xFF6f70a0),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10.0),
            InkWell(
              onTap: widget.onPressed,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 5.0,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF6f70a0),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    color: Colors.white,
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

// تحديث البيانات في _dashboardItems
List<Map<String, dynamic>> _dashboardItems = [];
Future<void> updateDashboard() async {
  // تحديث قائمة _dashboardItems
  _dashboardItems = [
    {
      'icon': '💉',
      'shadowColor': Colors.red,
      'title': "Blood Sugar Level",
      'data': '',
      'label': "Track Sugar",
      'number': '1',
    },
    {
      'icon': '🍽️',
      'shadowColor': Colors.green,
      'title': "Dietary Recommendation",
      'data': '',
      'label': "View Recommendations",
      'number': '2',
    },
    {
      'icon': '📂',
      'shadowColor': const Color(0xFF555688),
      'title': "Profile",
      'data': "Update Health Records",
      'label': "Edit Profile",
      'number': "3",
    },
    {
      'icon': '📞',
      'shadowColor': const Color(0xFF555688),
      'title': "Emergency Contacts",
      'data': "Ready for Assistance",
      'label': "View Contacts",
      'number': "4",
    },
  ];
}
