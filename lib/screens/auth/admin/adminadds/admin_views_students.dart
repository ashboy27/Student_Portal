import 'package:flutter/material.dart';
import '../../../../utils/database_helper.dart';

class AdminViewStudent extends StatelessWidget {
  const AdminViewStudent({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> fetchStudents() async {
    final db = DatabaseHelper.instance;
    return await db.getAllStudent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student List'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchStudents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No students found.'),
            );
          }

          final students = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return _buildStudentCard(student);
            },
          );
        },
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
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
            _buildHeaderRow(student['Student_Id'], student['User_Id']),
            const SizedBox(height: 10),
            _buildDetailRow(Icons.apartment, 'Department', student['Department']),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.date_range, 'Batch', student['Batch']),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.group, 'Section', student['Section']),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow(String studentId, int userId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Student ID: $studentId',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'User ID: $userId',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
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
