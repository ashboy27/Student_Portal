import 'package:flutter/material.dart';
import 'adminadds/admin_fills_course.dart';
import 'adminadds/admin_fills_detail.dart';
import 'adminadds/admin_assigns_teacher.dart';
import 'admindeletes/admin_deletes_detail.dart';
import './adminadds/admin_views_courses.dart';
import './adminadds/admin_views_students.dart';
import './adminadds/admin_views_teacher.dart';
import '../../home/home_screen.dart'; // Assuming you have this screen already defined

class AdminScreen extends StatelessWidget {
  final TextEditingController _codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Login'),
        backgroundColor: Colors.blueAccent,
        elevation: 5,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter Secret Code',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Secret Code',
                hintText: 'Enter secret code here',
                labelStyle: TextStyle(color: Colors.blueAccent),
                hintStyle: TextStyle(color: Colors.grey),
              ),
              obscureText: true,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                if (_codeController.text == 'fast') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminActionsPage()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Incorrect Code'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 30.0),
                backgroundColor: Colors.blueAccent,
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminActionsPage extends StatefulWidget {
  @override
  _AdminActionsPageState createState() => _AdminActionsPageState();
}

class _AdminActionsPageState extends State<AdminActionsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Portal'),
        backgroundColor: Colors.blueAccent,
        elevation: 5,
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueAccent,
              ),
              child: Text(
                'Admin Portal',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('University Info'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UniversityInfoPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Add Course'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminFillCourse()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Add User Record'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminFillsDetail()),
                );
              },
            ),
            // New ListTile for Deleting User Record
            ListTile(
              leading: const Icon(Icons.person_remove),
              title: const Text('Delete User Record'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DeleteUserRecord()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment_ind),
              title: const Text('Assign Course'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminAssignsTeacher()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('View Student Record'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminViewStudent()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outlined),
              title: const Text('View Teacher Records'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminViewTeacher()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.view_agenda),
              title: const Text('View Courses Records'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminViewCourse()),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Logout'),
              onTap: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text(
          'Welcome to Admin Portal!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
        ),
      ),
    );
  }
}

class UniversityInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('University Info'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // University Info Container
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'University Information',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                  ),
                  const SizedBox(height: 10),
                  _buildInfoRow('Name:', 'FAST NUCES'),
                  _buildInfoRow('City:', 'Karachi'),
                  _buildInfoRow('Address:', 'Bhens Colony'),
                  _buildInfoRow('Departments:', '4'),
                  const SizedBox(height: 20),
                  const Text(
                    'Contact Info:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                  ),
                  const SizedBox(height: 10),
                  const Text('Phone: +92 123 4567890'),
                  const Text('Email: info@fast.edu.pk'),
                  const SizedBox(height: 10),
                  const Text('Website: www.fast.edu.pk'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for building information rows
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
