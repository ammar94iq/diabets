import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class NearbyLocationsPage extends StatelessWidget {
  const NearbyLocationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF505184),
      ),
      body: Container(
        color: const Color(0xFFf7f8fb),
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            const SizedBox(height: 20.0),
            const Text(
              "Nearby Sugar Measurement Locations",
              style: TextStyle(
                color: Color(0xFF505184),
                fontSize: 20.0,
              ),
            ),
            const SizedBox(height: 20.0),
            // OpenStreetMap widget
            Container(
              height: 300,
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: FlutterMap(
                options: const MapOptions(
                  initialCenter:
                      LatLng(24.7136, 46.6753), // Riyadh, Saudi Arabia
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  const MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(24.7136, 46.6753), // Marker for Riyadh
                        width: 80,
                        height: 80,
                        child: Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Location List with Contact Information
            Column(
              children: [
                const Text(
                  "City Clinic",
                  style: TextStyle(
                    color: Color(0xFF505184),
                    fontSize: 20.0,
                  ),
                ),
                const SizedBox(height: 10.0),
                const SizedBox(height: 5),
                const Row(
                  children: [
                    Icon(Icons.phone, color: Colors.green, size: 18),
                    SizedBox(width: 8),
                    Text("+966 123 456 789"),
                  ],
                ),
                const SizedBox(height: 5),
                const Row(
                  children: [
                    Icon(Icons.email, color: Colors.blue, size: 18),
                    SizedBox(width: 8),
                    Text("info@cityclinic.sa"),
                  ],
                ),
                const SizedBox(height: 5),
                const Row(
                  children: [
                    Icon(Icons.web, color: Colors.orange, size: 18),
                    SizedBox(width: 8),
                    Text("www.cityclinic.sa"),
                  ],
                ),
                const SizedBox(height: 10.0),
                InkWell(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10.0,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF505184),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: const Text(
                      "Get Directions",
                      style: TextStyle(fontSize: 18.0, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                const Divider(),
                const Text(
                  "Health Center",
                  style: TextStyle(
                    color: Color(0xFF505184),
                    fontSize: 20.0,
                  ),
                ),
                const SizedBox(height: 10.0),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.phone, color: Colors.green, size: 18),
                        SizedBox(width: 8),
                        Text("+966 987 654 321"),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.email, color: Colors.blue, size: 18),
                        SizedBox(width: 8),
                        Text("contact@healthcenter.sa"),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.web, color: Colors.orange, size: 18),
                        SizedBox(width: 8),
                        Text("www.healthcenter.sa"),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
                InkWell(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10.0,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF505184),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: const Text(
                      "Get Directions",
                      style: TextStyle(fontSize: 18.0, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
