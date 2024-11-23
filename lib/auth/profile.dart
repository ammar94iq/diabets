import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

import '../main.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _firestore = FirebaseFirestore.instance;
  String? profileImagePath;

  // TextEditingControllers for form fields
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _contactController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _notesController = TextEditingController();
  String _diabetesType = "Type 1";
  @override
  void initState() {
    super.initState();
    fetchUserData();
    prefs.setString('diabetesType', _diabetesType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Profile & Medical Records'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Profile Image Section
              CircleAvatar(
                radius: 50,
                backgroundImage: profileImagePath == null
                    ? const AssetImage('images/logo.jpg')
                    : FileImage(File(profileImagePath!)) as ImageProvider,
              ),

              const SizedBox(height: 20),

              // Personal Information Section
              Section(
                title: "Personal Information",
                child: Column(
                  children: [
                    CustomTextField(
                        controller: _nameController,
                        label: "Name",
                        hint: "Enter your name"),
                    CustomTextField(
                        controller: _ageController,
                        label: "Age",
                        hint: "Enter your age",
                        isNumber: true),
                    CustomTextField(
                        controller: _contactController,
                        label: "Contact Info",
                        hint: "Enter contact number",
                        isPhone: true),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Medical Records Section
              Section(
                title: "Medical Records",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Diabetes Type',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2.0),
                    DropdownButtonFormField<String>(
                      value: _diabetesType,
                      items: const [
                        DropdownMenuItem(
                            value: "Type 1", child: Text("Type 1")),
                        DropdownMenuItem(
                            value: "Type 2", child: Text("Type 2")),
                        DropdownMenuItem(
                            value: "Gestational", child: Text("Gestational")),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _diabetesType = value!;
                        });
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                    ),
                    CustomTextField(
                        controller: _medicationsController,
                        label: "Medications",
                        hint: "List medications"),
                    CustomTextField(
                        controller: _allergiesController,
                        label: "Allergies",
                        hint: "List known allergies"),
                    CustomTextField(
                      controller: _notesController,
                      label: "Doctor's Notes",
                      hint: "Notes from doctor",
                      isMultiline: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Save and Download Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: saveProfile,
                    child: const Text("Save Profile"),
                  ),
                  ElevatedButton(
                    onPressed: downloadPDF,
                    child: const Text("Download as PDF"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showMessage(String mess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mess)),
    );
  }

  Future<void> fetchUserData() async {
    try {
      String? userId = prefs.getString('uid');
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data();
        setState(() {
          _nameController.text = data?['fullName'] ?? '';
          _ageController.text = data?['age'] ?? '';
          _contactController.text = data?['contact'] ?? '';
          _diabetesType = data?['diabetesType'] ?? 'Type 1';
          _medicationsController.text = data?['medications'] ?? '';
          _allergiesController.text = data?['allergies'] ?? '';
          _notesController.text = data?['notes'] ?? '';
        });
      }
    } catch (e) {
      showMessage("Error fetching user data: $e");
    }
  }

  Future<void> saveProfile() async {
    try {
      // تحديث الوثيقة الخاصة بالمستخدم في مجموعة "users"
      String? userId = prefs.getString('uid');
      await _firestore.collection('users').doc(userId).update({
        'fullName': _nameController.text,
        'age': _ageController.text,
        'contact': _contactController.text,
        'diabetesType': _diabetesType,
        'medications': _medicationsController.text,
        'allergies': _allergiesController.text,
        'notes': _notesController.text,
      });
      prefs.setString('diabetesType', _diabetesType);
      showMessage("Profile updated in user table");
    } catch (e) {
      showMessage("Error updating profile: $e");
    }
  }

  Future<void> downloadPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Personal Profile & Medical Records",
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text("Name: ${_nameController.text}"),
            pw.Text("Age: ${_ageController.text}"),
            pw.Text("Contact: ${_contactController.text}"),
            pw.Text("Diabetes Type: $_diabetesType"),
            pw.Text("Medications: ${_medicationsController.text}"),
            pw.Text("Allergies: ${_allergiesController.text}"),
            pw.Text("Doctor's Notes: ${_notesController.text}"),
          ],
        ),
      ),
    );

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/profile.pdf');
      await file.writeAsBytes(await pdf.save());
      showMessage("PDF downloaded at ${file.path}");
    } catch (e) {
      showMessage("Error generating PDF: $e");
    }
  }
}

class Section extends StatelessWidget {
  final String title;
  final Widget child;

  const Section({Key? key, required this.title, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: [Padding(padding: const EdgeInsets.all(16.0), child: child)],
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isNumber;
  final bool isPhone;
  final bool isMultiline;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    required this.hint,
    this.isNumber = false,
    this.isPhone = false,
    this.isMultiline = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          TextField(
            controller: controller,
            keyboardType: isNumber
                ? TextInputType.number
                : isPhone
                    ? TextInputType.phone
                    : isMultiline
                        ? TextInputType.multiline
                        : TextInputType.text,
            maxLines: isMultiline ? null : 1,
            decoration: InputDecoration(
              hintText: hint,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
