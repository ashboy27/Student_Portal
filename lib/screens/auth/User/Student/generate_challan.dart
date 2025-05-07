import 'package:flutter/material.dart';
import '../../../../utils/database_helper.dart';

class GenerateChallanScreen extends StatelessWidget {
  final String studentId;
  final int currentCreditHourFees;

  const GenerateChallanScreen({
    required this.studentId,
    this.currentCreditHourFees = 1000, // Default fee per credit hour
  });

  Future<int> _calculateFees() async {
    final db = DatabaseHelper.instance;
    return db.calculateTotalFees(studentId, currentCreditHourFees);
  }

  Future<List<Map<String, dynamic>>> _fetchRegisteredCourses() async {
    final db = DatabaseHelper.instance;
    return db.getRegisteredCoursesWithDetails(studentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Challan'),
        backgroundColor: Colors.blue[900],
      ),
      body: FutureBuilder<int>(
        future: _calculateFees(),
        builder: (context, feeSnapshot) {
          if (feeSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (feeSnapshot.hasError) {
            return Center(child: Text('Error: ${feeSnapshot.error}'));
          }

          final totalFees = feeSnapshot.data ?? 0;

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchRegisteredCourses(),
            builder: (context, courseSnapshot) {
              if (courseSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (courseSnapshot.hasError) {
                return Center(child: Text('Error: ${courseSnapshot.error}'));
              } else if (!courseSnapshot.hasData || courseSnapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'No registered courses.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                );
              }

              final courses = courseSnapshot.data!;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Colors.blue[50],
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Fees:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'PKR $totalFees',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Text(
                      'Registered Courses',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      separatorBuilder: (context, index) => const Divider(),
                      itemCount: courses.length,
                      itemBuilder: (context, index) {
                        final course = courses[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue[100],
                            child: Text(
                              course['Course_Code'].substring(0, 2).toUpperCase(),
                              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            course['Course_Name'],
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'Credit Hours: ${course['Credit_Hrs']}',
                            style: const TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                          trailing: Text(
                            'PKR ${course['Credit_Hrs'] * currentCreditHourFees}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Challan generated successfully!'),
                            action: SnackBarAction(
                              label: 'View',
                              onPressed: () {
                                // Future functionality to download/view PDF
                              },
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[900],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.download),
                          SizedBox(width: 8),
                          Text(
                            'Generate Challan',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
