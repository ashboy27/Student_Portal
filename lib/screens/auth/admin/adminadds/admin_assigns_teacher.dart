import 'package:flutter/material.dart';
import '../../../../utils/database_helper.dart';

class AdminAssignsTeacher extends StatelessWidget {
  final TextEditingController _sectionController = TextEditingController();
  final TextEditingController _teacherIdController = TextEditingController();
  final TextEditingController _courseCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Teacher to Course'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Assign a Teacher to a Course',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildTextField('Section ID (e.g., 1A)', _sectionController),
              const SizedBox(height: 20),
              _buildTextField('Teacher ID', _teacherIdController),
              const SizedBox(height: 20),
              _buildTextField('Course Code', _courseCodeController),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () async {
                  final sectionId = _sectionController.text.trim();
                  final teacherId = _teacherIdController.text.trim();
                  final courseCode = _courseCodeController.text.trim();

                  if (!RegExp(r'^\d[A-Za-z]$').hasMatch(sectionId)) {
                    _showSnackBar(context, 'Invalid Section ID format. Example: 1A');
                    return;
                  }

                  // Check if the teacher and course exist using DatabaseHelper methods
                  final teacherExists = await DatabaseHelper.instance.teacherExists(teacherId);
                  final courseExists = await DatabaseHelper.instance.courseExists(courseCode);

                  if (!teacherExists) {
                    _showSnackBar(context, 'Teacher does not exist.');
                    return;
                  }

                  if (!courseExists) {
                    _showSnackBar(context, 'Course does not exist.');
                    return;
                  }

                  // Assign teacher to course
                  final success = await DatabaseHelper.instance.assignTeacherToCourse(
                    sectionId,
                    teacherId,
                    courseCode,
                  );

                  if (success) {
                    _showSnackBar(context, 'Assignment successful!');
                  } else {
                    _showSnackBar(context, 'Error: Could not assign teacher.');
                  }
                },
                icon: const Icon(Icons.check),
                label: const Text('Assign'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: label,
        hintText: label,
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
