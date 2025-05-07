import 'package:flutter/material.dart';
import '../../../../utils/database_helper.dart';

class AdminViewTeacher extends StatelessWidget {
  const AdminViewTeacher({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> fetchTeachers() async {
    final db = DatabaseHelper.instance;
    return await db.getAllTeacher(); // Replace with your actual method to fetch teacher data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher List'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchTeachers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No teachers found.'),
            );
          }

          final teachers = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: teachers.length,
            itemBuilder: (context, index) {
              final teacher = teachers[index];
              return _buildTeacherCard(teacher);
            },
          );
        },
      ),
    );
  }

  Widget _buildTeacherCard(Map<String, dynamic> teacher) {
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
            _buildHeaderRow(teacher['Teacher_Id'], teacher['User_Id']),
            const SizedBox(height: 10),
            _buildDetailRow(Icons.calendar_today, 'Hire Date', teacher['Hire_Date']),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.attach_money, 'Salary', teacher['Salary']),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow(String teacherId, int userId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Teacher ID: $teacherId',
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
