import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart'; // Assuming you're using sqflite for the database
import '../../../../utils/database_helper.dart';

class AdminFillCourse extends StatelessWidget {
  final TextEditingController _courseCodeController = TextEditingController();
  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _creditHrsController = TextEditingController();
  final TextEditingController _semesterController = TextEditingController();
  final TextEditingController _prerequisiteIdController = TextEditingController();
  final TextEditingController _courseTypeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Course'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter Course Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildTextField('Course Code', _courseCodeController),
              const SizedBox(height: 20),
              _buildTextField('Course Name', _courseNameController),
              const SizedBox(height: 20),
              _buildTextField('Credit Hours', _creditHrsController, isNumber: true),
              const SizedBox(height: 20),
              _buildTextField('Semester', _semesterController, isNumber: true),
              const SizedBox(height: 20),
              _buildTextField('Prerequisite ID (optional)', _prerequisiteIdController),
              const SizedBox(height: 20),
              _buildTextField('Course Type', _courseTypeController),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    final courseCode = _courseCodeController.text.trim();
                    final courseName = _courseNameController.text.trim();
                    final creditHrs = int.tryParse(_creditHrsController.text.trim());
                    final semester = int.tryParse(_semesterController.text.trim());
                    final prereqId = _prerequisiteIdController.text.trim();
                    final courseType = _courseTypeController.text.trim();

                    if (courseCode.isEmpty ||
                        courseName.isEmpty ||
                        creditHrs == null ||
                        semester == null ||
                        courseType.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill in all required fields')),
                      );
                      return;
                    }

                    try {
                      final db = DatabaseHelper.instance;
                      Future<bool> result = db.courseExists(courseCode);
                      if(await result){

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Course already exists!')),
                        );
                        return;
                      }
                      await db.addCourse(
                        courseCode,
                        courseName,
                        creditHrs,
                        semester,
                        prereqId.isEmpty ? null : prereqId,
                        courseType,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Course added successfully!')),
                      );

                      _clearFields();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Unexpected error: $e')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('Add Course'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isNumber = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: label,
      ),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    );
  }

  void _clearFields() {
    _courseCodeController.clear();
    _courseNameController.clear();
    _creditHrsController.clear();
    _semesterController.clear();
    _prerequisiteIdController.clear();
    _courseTypeController.clear();
  }
}
