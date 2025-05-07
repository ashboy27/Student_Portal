import 'package:flutter/material.dart';
import '../../../../utils/database_helper.dart';

class AdminViewCourse extends StatelessWidget {
  const AdminViewCourse({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> fetchCourses() async {
    final db = DatabaseHelper.instance;
    return await db.getAllRecords(); // Replace with your actual method to fetch records
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses List'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchCourses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No courses found.'),
            );
          }

          final courses = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return _buildCourseCard(course);
            },
          );
        },
      ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 20.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderRow(course['Course_Code'], course['Course_Name']),
            const SizedBox(height: 10),
            _buildDetailRow(Icons.schedule, 'Credit Hours', course['Credit_Hrs']),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.calendar_month, 'Semester', course['Semester']),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.link, 'Prerequisite ID', course['Prereq_Id'] ?? 'None'),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.category, 'Course Type', course['Course_Type']),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow(String code, String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          code,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            name,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, dynamic value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            value.toString(),
            style: const TextStyle(color: Colors.grey),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
