import 'package:flutter/material.dart';
import '../announcement/announcements.dart';
import '../people/view_people.dart';
import '../Assignments/view_assignment.dart';
import '../Assignments/add_assignment.dart';
class ClassroomDetailsView extends StatelessWidget {
  final String courseCode;
  final String sectionId;
  final int userId;
  final bool isTeacher;

  const ClassroomDetailsView(
      this.courseCode, this.sectionId, this.userId, this.isTeacher,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$courseCode - Section $sectionId'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 20),
            _buildActionButton(
              context,
              icon: Icons.assignment_outlined,
              label: isTeacher ? 'Upload Assignment' : 'View Assignments',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                         ViewAssignments(courseCode: courseCode,
                      sectionId: sectionId,
                      userId: userId,
                      isTeacher: isTeacher,
                         ),
                  ),
                );
              },
            ),
            _buildActionButton(
              context,
              icon: Icons.people_outline,
              label: 'View People',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ViewPeople(courseCode: courseCode,sectionId: sectionId),
                  ),
                );
              },
            ),
            _buildActionButton(
              context,
              icon: Icons.announcement_outlined,
              label: 'View Announcements',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ViewAnnouncements(
                      courseCode: courseCode,
                      sectionId: sectionId,
                      userId: userId,
                      isTeacher: isTeacher,
                    ),
                  ),
                );
              },
            ),
            const Spacer(),
            if (!isTeacher)
              Text(
                'Note: Assignments are visible after submission deadlines.',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      color: Colors.indigo[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to $courseCode - Section $sectionId',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
            const SizedBox(height: 8),
            Text(
              isTeacher
                  ? 'You can manage assignments, announcements, and student performance here.'
                  : 'Access assignments, announcements, and class details easily.',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required VoidCallback onTap,
      }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: Icon(icon, size: 24),
      label: Text(
        label,
        style: const TextStyle(fontSize: 16),
      ),
      onPressed: onTap,
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title Screen Coming Soon!',
          style: const TextStyle(fontSize: 18, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
