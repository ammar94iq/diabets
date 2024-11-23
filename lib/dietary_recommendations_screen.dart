import 'package:flutter/material.dart';

import 'main.dart';

class DietaryRecommendationsScreen extends StatefulWidget {
  const DietaryRecommendationsScreen({super.key});

  @override
  State<DietaryRecommendationsScreen> createState() =>
      _DietaryRecommendationsScreenState();
}

class _DietaryRecommendationsScreenState
    extends State<DietaryRecommendationsScreen> {
  final TextEditingController _allergiesController = TextEditingController();
  String _mealType = '';
  String? diabetType = prefs.getString('diabetesType');
  bool _showRecommendations = false;

  // List of meals with their ingredients
  final List<Map<String, dynamic>> _meals = [
    {
      'mealImage': 'img2.jpg',
      'mealName': 'Oats with Berries',
      'description': 'Low sugar',
      'ingredients': ['Oats', 'Berries', 'Almond Milk', 'Cinnamon'],
      'calories': 250,
      'suitableForDiabetics': true
    },
    {
      'mealImage': 'img1.jpg',
      'mealName': 'Grilled Chicken Salad',
      'description': 'Diabetic-friendly',
      'ingredients': ['Chicken', 'Lettuce', 'Avocado', 'Olive Oil'],
      'calories': 400,
      'suitableForDiabetics': true
    },
    {
      'mealImage': 'img3.jpg',
      'mealName': 'Avocado Toast',
      'description': 'Low sugar',
      'ingredients': ['Avocado', 'Whole Wheat Bread', 'Lemon'],
      'calories': 350,
      'suitableForDiabetics': true
    },
  ];

  void _getRecommendations() {
    setState(() {
      _showRecommendations = true;
    });
  }

  List<Map<String, dynamic>> _getFilteredMeals() {
    String allergies = _allergiesController.text.toLowerCase();
    // Filter meals based on allergy input
    return _meals.where((meal) {
      for (var ingredient in meal['ingredients']) {
        if (ingredient.toLowerCase().contains(allergies)) {
          return false; // Exclude meals containing the allergy
        }
      }
      return true; // Include meals without the allergy
    }).toList();
  }

  // Get exercise recommendations based on diabetes type
  List<String> _getExerciseRecommendations() {
    List<String> exercises = [];
    if (diabetType == 'Type 1') {
      exercises = [
        'Strength training (3-4 times per week)',
        'Aerobic exercises like swimming or cycling (3-4 times per week)',
        'Yoga for flexibility and stress relief'
      ];
    } else if (diabetType == 'Type 2') {
      exercises = [
        'Brisk walking or jogging (30 minutes daily)',
        'Strength training (2-3 times per week)',
        'Yoga and mindfulness exercises'
      ];
    } else if (diabetType == 'Gestational') {
      exercises = [
        'Gentle walking or swimming (30 minutes daily)',
        'Low-impact strength training',
        'Prenatal yoga for relaxation and flexibility'
      ];
    } else {
      exercises = [
        'Consult a healthcare provider for personalized recommendations'
      ];
    }

    return exercises;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dietary and Exercise Recommendations'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                color: Color(0xFFf5f7fa),
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Personalize Your Dietary Preferences',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _allergiesController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0))),
                      hintText: 'Enter any allergies (e.g., nuts, gluten)',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey, // لون الإطار
                        width: 1.0, // سماكة الإطار
                      ),
                      borderRadius: BorderRadius.circular(10.0), // زوايا دائرية
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 5.0), // إضافة حشوة داخلية
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _mealType.isEmpty ? null : _mealType,
                        hint: const Text('Select Meal Type'),
                        onChanged: (value) {
                          setState(() {
                            _mealType = value!;
                          });
                        },
                        items: [
                          'Breakfast',
                          'Lunch',
                          'Dinner',
                          'Snacks',
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: _getRecommendations,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 15.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6f70a0),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: const Text(
                        'Get Recommendations',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Food Preferences
            const SizedBox(height: 20),

            // Show food recommendations if button is pressed
            _showRecommendations
                ? Column(
                    children: _getFilteredMeals().map((meal) {
                      return MealCard(
                        mealImage: meal['mealImage'],
                        mealName: meal['mealName'],
                        description: meal['description'],
                        details: [
                          'Ingredients: ${meal['ingredients'].join(', ')}',
                          'Calories: ${meal['calories']} kcal',
                          'Suitable for diabetics: ${meal['suitableForDiabetics'] ? 'Yes' : 'No'}',
                        ],
                      );
                    }).toList(),
                  )
                : const SizedBox.shrink(),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: const Color(0xFFf5f7fa),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Exercise Recommendations
                  const Text('Exercise Recommendations:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text(
                    'Based on your diabetes type, we suggest the following exercises:',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _getExerciseRecommendations()
                        .map((exercise) => ListTile(
                              title: Text('- $exercise'),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MealCard extends StatefulWidget {
  final String mealImage;
  final String mealName;
  final String description;
  final List<String> details;
  const MealCard(
      {super.key,
      required this.mealImage,
      required this.mealName,
      required this.description,
      required this.details});

  @override
  State<MealCard> createState() => _MealCardState();
}

class _MealCardState extends State<MealCard> {
  bool _showDetails = false; // حالة لتحديد ما إذا كانت التفاصيل تظهر أم لا

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: const Color(0xFFf5f7fa),
      ),
      margin: const EdgeInsets.only(top: 10.0, bottom: 20.0),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0), // تحديد زوايا الصورة
            child: Image.asset("images/${widget.mealImage}"),
          ),
          const SizedBox(height: 10),
          Text(widget.mealName,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(widget.description),
          const SizedBox(height: 10),
          Center(
            child: InkWell(
              onTap: () {
                setState(() {
                  _showDetails = !_showDetails; // تبديل حالة العرض
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 15.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF6f70a0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  _showDetails ? 'Hide Details' : 'View Details',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          if (_showDetails) // إظهار التفاصيل فقط إذا كانت الحالة مفعّلة
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  widget.details.map((detail) => Text("- $detail")).toList(),
            ),
        ],
      ),
    );
  }
}
