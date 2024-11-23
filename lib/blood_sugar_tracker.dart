import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

class BloodSugarTracker extends StatefulWidget {
  const BloodSugarTracker({super.key});

  @override
  State<BloodSugarTracker> createState() => _BloodSugarTrackerState();
}

class _BloodSugarTrackerState extends State<BloodSugarTracker> {
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  final TextEditingController bloodSugarController = TextEditingController();
  final TextEditingController commentsController = TextEditingController();
  String? selectedReminderTime;
  String bloodSugarStatus = 'Normal';
  List<Map<String, dynamic>> bloodSugarLevels = [];
  List<Map<String, dynamic>> monthlyBloodSugarLevels = [];
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  final List<String> reminderTimes = [
    '06:00 AM',
    '08:00 AM',
    '10:00 AM',
    '12:00 PM',
    '02:00 PM',
    '04:00 PM',
    '06:00 PM',
    '08:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    loadBloodSugarData();
    loadBloodSugarDataMonthly();
  }

  void setReminder() async {
    if (selectedReminderTime!.isEmpty || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a reminder time or login first')),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('reminders').add({
      'userId': userId, // تخزين معرّف المستخدم
      'reminderTime': selectedReminderTime,
      'createdAt': Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reminder set for $selectedReminderTime')),
    );
  }

  void saveBloodSugar() async {
    final int? bloodSugar = int.tryParse(bloodSugarController.text);
    if (bloodSugar == null || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Enter a valid blood sugar level or login first')),
      );
      return;
    }

    final status = (bloodSugar < 70)
        ? 'Low'
        : (bloodSugar > 180)
            ? 'High'
            : 'Normal';

    final data = {
      'userId': userId, // تخزين معرّف المستخدم
      'bloodSugarLevel': bloodSugar,
      'status': status,
      'comments': commentsController.text,
      'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
    };
// التحقق إذا كان نفس المستخدم ونفس اليوم
    final querySnapshot = await FirebaseFirestore.instance
        .collection('blood_sugar')
        .where('userId', isEqualTo: userId) // تحقق من المستخدم
        .where('date', isEqualTo: data['date']) // تحقق من التاريخ
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // إذا كان هناك سجل موجود، نقوم بتحديثه
      final docId = querySnapshot.docs.first.id;
      await FirebaseFirestore.instance
          .collection('blood_sugar')
          .doc(docId)
          .update({
        'bloodSugarLevel': bloodSugar,
        'status': status,
        'comments': commentsController.text,
      });
      setState(() {
        // تحديث القائمة bloodSugarLevels بناءً على المستند
        final updatedData = data; // البيانات المحدثة
        bloodSugarLevels = bloodSugarLevels.map((entry) {
          if (entry['userId'] == updatedData['userId'] &&
              entry['date'] == updatedData['date']) {
            return updatedData; // تحديث العنصر في القائمة
          }
          return entry; // الحفاظ على باقي العناصر
        }).toList();
        bloodSugarStatus = status;
      });
    } else {
      // إذا لم يكن هناك سجل موجود، نضيف سجل جديد
      await FirebaseFirestore.instance.collection('blood_sugar').add(data);
      setState(() {
        bloodSugarLevels.add(data);
        bloodSugarStatus = status;
      });
    }
    bloodSugarController.clear();
    commentsController.clear();
  }

  List<String> dayNames = []; // قائمة لتخزين أسماء الأيام

  void loadBloodSugarData() async {
    if (userId == null) return;

    final querySnapshot = await FirebaseFirestore.instance
        .collection('blood_sugar')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .get();

    Map<String, Map<String, dynamic>> dailyData = {};

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final date = DateTime.parse(data['date']);
      final dateKey = DateFormat('yyyy-MM-dd').format(date);

      if (!dailyData.containsKey(dateKey) ||
          DateTime.parse(dailyData[dateKey]!['date']).isBefore(date)) {
        dailyData[dateKey] = data;
      }
    }

    final last7DaysData = dailyData.values.toList().take(7).toList();

    // استخراج أسماء الأيام بناءً على التواريخ
    dayNames = last7DaysData.map((data) {
      final date = DateTime.parse(data['date']);
      return DateFormat('EEEE').format(date); // استخراج اسم اليوم
    }).toList();

    setState(() {
      bloodSugarLevels = last7DaysData;
    });
  }

  void loadBloodSugarDataMonthly() async {
    if (userId == null) return;

    final querySnapshot = await FirebaseFirestore.instance
        .collection('blood_sugar')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .get();

    Map<String, List<double>> monthlyData = {};

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final date = DateTime.parse(data['date']);
      final monthKey = DateFormat('yyyy-MM').format(date); // صيغة السنة والشهر

      if (!monthlyData.containsKey(monthKey)) {
        monthlyData[monthKey] = [];
      }

      monthlyData[monthKey]!.add(data['bloodSugarLevel'].toDouble());
    }

    // حساب المتوسط لكل شهر
    List<Map<String, dynamic>> monthlyAverageData =
        monthlyData.entries.map((entry) {
      final month = entry.key;
      final levels = entry.value;
      final average = levels.reduce((a, b) => a + b) / levels.length;

      return {'month': month, 'average': average};
    }).toList();

    // ترتيب البيانات حسب الشهر
    monthlyAverageData.sort((a, b) => b['month'].compareTo(a['month']));

    // عرض آخر 7 أشهر
    final last7MonthsData = monthlyAverageData.take(7).toList();

    setState(() {
      monthlyBloodSugarLevels = last7MonthsData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Sugar Tracker'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        color: const Color(0xFFf8f9fc),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all()),
              child: Column(
                children: [
                  const Text(
                    'Enter Your Blood Sugar Level',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: bloodSugarController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Enter value',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: saveBloodSugar,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 20.0,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6f70a0),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all()),
              child: Column(
                children: [
                  const Text(
                    'Blood Sugar Levels Over Time',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                      height: 300,
                      child: LineChart(
                        LineChartData(
                          titlesData: FlTitlesData(
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              ),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  // تحويل القيمة إلى عدد صحيح للحصول على الفهرس الصحيح
                                  final index = value.toInt();

                                  // التأكد من أن الفهرس ضمن نطاق البيانات
                                  if (index < 0 ||
                                      index >= bloodSugarLevels.length) {
                                    return const SizedBox
                                        .shrink(); // تجاهل أي قيمة غير صحيحة
                                  }

                                  // استخراج التاريخ من البيانات (مخزن كـ String)
                                  final dateString =
                                      bloodSugarLevels[index]['date'];
                                  final date = DateTime.parse(
                                      dateString); // تحويل النص إلى تاريخ

                                  // تنسيق التاريخ ليظهر بالشكل "DD"
                                  final formattedDate =
                                      DateFormat('dd').format(date);

                                  return Text(
                                    formattedDate, // عرض التاريخ بصيغة يوم/شهر/سنة
                                    style: const TextStyle(fontSize: 12),
                                  );
                                },
                              ),
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots:
                                  bloodSugarLevels.asMap().entries.map((entry) {
                                final index = entry.key.toDouble();
                                final level =
                                    entry.value['bloodSugarLevel'].toDouble();
                                return FlSpot(index, level);
                              }).toList(),
                              isCurved: true,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all()),
              child: Column(
                children: [
                  const Text(
                    'Monthly Blood Sugar Overview',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 300,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: monthlyBloodSugarLevels.isNotEmpty
                            ? monthlyBloodSugarLevels
                                    .map((e) => e['average'] as double)
                                    .reduce((a, b) => a > b ? a : b) +
                                50
                            : 100, // القيمة الافتراضية إذا لم تكن هناك بيانات
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 ||
                                    index >= monthlyBloodSugarLevels.length) {
                                  return const SizedBox.shrink();
                                }

                                final monthString =
                                    monthlyBloodSugarLevels[index]['month'];
                                final date =
                                    DateFormat('yyyy-MM').parse(monthString);
                                final formattedDate =
                                    DateFormat('MMM').format(date);

                                return Text(
                                  formattedDate,
                                  style: const TextStyle(fontSize: 12),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 50,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(fontSize: 12),
                                );
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: false,
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: false,
                            ),
                          ),
                        ),
                        barGroups: monthlyBloodSugarLevels
                            .asMap()
                            .entries
                            .map((entry) {
                          final index = entry.key;
                          final average = entry.value['average'];

                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                // تحويل القيمة العشرية إلى عدد صحيح
                                toY: average.toInt().toDouble(),
                                color: Colors.red,
                                width: 15,
                                borderRadius: BorderRadius.circular(4),
                                rodStackItems: [],
                              ),
                            ],
                            showingTooltipIndicators: [1],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(),
              ),
              child: Column(
                children: [
                  const Text(
                    textAlign: TextAlign.center,
                    'Set Reminder for Next Blood Sugar Check',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedReminderTime,
                      hint: const Text('Select a reminder time'),
                      items: reminderTimes.map((time) {
                        return DropdownMenuItem<String>(
                          value: time,
                          child: Text(time),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedReminderTime = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: setReminder,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 10.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: const Color(0xFF6f70a0),
                      ),
                      child: const Text(
                        'Set Reminder',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(),
              ),
              child: Column(
                children: [
                  const Text(
                    'Leave Comments (Optional)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: commentsController,
                    decoration: const InputDecoration(
                      hintText:
                          'Any unusual events affecting your blood sugar?',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10.0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: bloodSugarStatus == 'Low'
                          ? Colors.red
                          : bloodSugarStatus == 'High'
                              ? Colors.orange
                              : Colors.green,
                    ),
                    child: Text(
                      bloodSugarStatus,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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
}
