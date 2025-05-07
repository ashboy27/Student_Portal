import 'package:flutter/material.dart';
import '../../../../../utils/database_helper.dart';
import 'classroom_detail_view.dart';

class ClassroomView extends StatelessWidget {
  final int userId; // User ID of the student or teacher
  final bool isTeacher; // Determines if the user is a teacher

  ClassroomView(this.userId, this.isTeacher);

  Future<List<Map<String, dynamic>>> _fetchClassrooms() async {
    final db = DatabaseHelper.instance;

    if (isTeacher) {
      // Fetch classrooms where the teacher is assigned
      final String teacherId = await db.getUserId(userId, 'Teacher');
      return await db.getClassroomsByTeacher(teacherId);
    } else {
      // Fetch classrooms where the student is enrolled
      final String studentId = await db.getUserId(userId, 'Student');
     // print(studentId);
      final result = await db.getClassroomsByStudent(studentId);
      //print(result);
      return result;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Classrooms')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchClassrooms(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No classrooms found.'));
          }

          final classrooms = snapshot.data!;

         // print(classrooms);
          return ListView.builder(
            itemCount: classrooms.length,
            itemBuilder: (context, index) {
              final classroom = classrooms[index];

              return Card(
                elevation: 4,
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(
                    classroom['Course_Name'],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Section: ${classroom['Section_Id']}\nTeacher: ${classroom['User_Name'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  trailing: Text(
                    classroom['Course_Code'],
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    // Navigate to ClassroomDetailsView
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClassroomDetailsView(
                          classroom['Course_Code'],
                          classroom['Section_Id'],
                          userId, // Pass the user ID
                          isTeacher, // Pass the user role
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
