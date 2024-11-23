import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../home.dart';
import 'signin.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Controllers for text fields
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  void showMessage(String mess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mess)),
    );
  }

  void redirectIntoHomePage() {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
      builder: ((context) {
        return const HomePage();
      }),
    ), (route) => false);
  }

  Future<void> registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Check if the email is already registered
        QuerySnapshot emailCheck = await _firestore
            .collection('users')
            .where('email', isEqualTo: _emailController.text)
            .get();

        if (emailCheck.docs.isNotEmpty) {
          showMessage('Email is already registered');
          return;
        }

        // Create user with Firebase Authentication
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Store additional user details in Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'fullName': _fullNameController.text,
          'email': _emailController.text,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Save user data in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('uid', userCredential.user!.uid);
        await prefs.setString('fullName', _fullNameController.text);
        await prefs.setString('email', _emailController.text);

        showMessage('Registration successful!');
        redirectIntoHomePage();

        // Navigate to another screen or clear the form
        _formKey.currentState!.reset();
      } on FirebaseAuthException catch (e) {
        showMessage(e.message ?? 'Registration failed');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        color: const Color(0xFFf7f8fb),
        height: MediaQuery.sizeOf(context).height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            'Create Your Account',
                            style: TextStyle(
                              color: Color(0xFF505184),
                              fontSize: 25.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        // Full Name Field
                        const Text('Full Name',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5.0),
                        TextFormField(
                          controller: _fullNameController,
                          decoration: const InputDecoration(
                            hintText: 'Enter your full name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your full name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),

                        // Email Field
                        const Text('Email Address',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5.0),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            hintText: 'Enter your email',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),

                        // Password Field
                        const Text('Password',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5.0),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            hintText: 'Enter your password',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),

                        // Confirm Password Field
                        const Text('Confirm Password',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5.0),
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: const InputDecoration(
                            hintText: 'Confirm your password',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),

                        // Register Button
                        Center(
                          child: InkWell(
                            onTap: registerUser,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                                vertical: 10.0,
                              ),
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                color: Color(0xFF6f70a0),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                              ),
                              child: const Text(
                                textAlign: TextAlign.center,
                                'Register',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Footer
                        const SizedBox(height: 16.0),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(context,
                                  MaterialPageRoute(
                                builder: ((context) {
                                  return const SignIn();
                                }),
                              ), (route) => false);
                            },
                            child: const Text(
                                'Already have an account? Login here'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Loading Indicator
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
