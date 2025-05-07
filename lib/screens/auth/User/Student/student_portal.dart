import 'package:fast_student_portal_v1/screens/auth/User/Student/view_attendance.dart';

import 'generate_challan.dart';
import 'student_register_drop.dart';
import 'package:fast_student_portal_v1/screens/clasrrom/View/classroom_view.dart';
import 'package:flutter/material.dart';
import '../../../../utils/database_helper.dart';
import '../../../home/home_screen.dart';

class StudentPortal extends StatelessWidget {
  final int userId;
  final String studentId;
  StudentPortal(this.userId,this.studentId);

  Future<Map<String, dynamic>?> _fetchStudentDetails() async {
    final db = DatabaseHelper.instance;
    final result = await db.getUserDetail(userId, 'Student');
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Portal'),
        backgroundColor: Colors.blue[900],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue[900]),
              child: const Text(
                'Student Portal',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Register Courses'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterCourseScreen(studentId)),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.class_outlined),
              title: const Text('View Classrooms'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ClassroomView(userId,false)),

                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('View Attendance'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AttendanceView(studentId: studentId)),

                );
              },
            ),


            ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text('Generate Challan'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GenerateChallanScreen(studentId: studentId),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                      (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchStudentDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data found.'));
          }

          final details = snapshot.data!;
          String sectionInfo = 'B${details['Department']}${details['Section']}';

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildContainer(
                    'University Information',
                    [
                      _buildDetailRow('Roll Number', details['Student_Id']),
                      _buildDetailRow('Department', details['Department']),
                      _buildDetailRow('Batch', details['Batch']),
                      _buildDetailRow('Status', details['User_Type']),
                      _buildDetailRow('Section', sectionInfo),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildContainer(
                    'Contact Information',
                    [
                      _buildDetailRow('Full Name', details['User_Name']),
                      _buildDetailRow('Phone Number', details['Phone_Number']),
                      _buildDetailRow('Email', details['Email_Id']),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContainer(String title, List<Widget> content) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.blue[900],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Center(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: content),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            value != null && value.toString().isNotEmpty
                ? value.toString()
                : 'Not Available',
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
