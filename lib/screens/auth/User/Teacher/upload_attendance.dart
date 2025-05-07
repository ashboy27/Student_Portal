import 'package:fast_student_portal_v1/screens/auth/User/Teacher/view_students.dart';
import 'package:flutter/material.dart';
import '../../../../utils/database_helper.dart'; // Replace with your actual database helper file.

class UploadAttendance extends StatefulWidget {
  final String teacherId;

  UploadAttendance(this.teacherId);

  @override
  _UploadAttendanceState createState() => _UploadAttendanceState();
}
class _UploadAttendanceState extends State<UploadAttendance> {
  late Future<List<Map<String, dynamic>>> coursesFuture;
  Map<String, String?> selectedCourse = {'name': null, 'code': null, 'section': null};
  DateTime currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    coursesFuture = DatabaseHelper.instance.fetchTeacherCourses(widget.teacherId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Attendance'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display Current Date
            Text(
              "Date: ${currentDate.day}-${currentDate.month}-${currentDate.year}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            // Dropdown for Courses
            FutureBuilder<List<Map<String, dynamic>>>(
              future: coursesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text("No courses available", style: TextStyle(color: Colors.red));
                }

                List<Map<String, dynamic>> courses = snapshot.data!;
                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Select Course',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: courses.map((course) {
                    // Create a unique value by combining Course_Code and Section_Id
                    String uniqueValue = "${course['Course_Code']}_${course['Section_Id']}";
                    String displayName = "${course['Course_Name']} - Section ${course['Section_Id']}";
                    return DropdownMenuItem<String>(
                      value: uniqueValue,
                      child: Text(displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      // Extract Course_Code and Section_Id from the selected unique value
                      final selected = courses.firstWhere(
                              (course) => "${course['Course_Code']}_${course['Section_Id']}" == value);
                      selectedCourse = {
                        'name': selected['Course_Name'] as String?,
                        'code': selected['Course_Code'] as String?,
                        'section': selected['Section_Id'] as String?,
                      };
                    });

                    if (selectedCourse['code'] != null && selectedCourse['section'] != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewStudents(
                            courseCode: selectedCourse['code']!,
                            sectionId: selectedCourse['section']!,
                          ),
                        ),
                      );
                    }
                  },
                  value: selectedCourse['code'] != null && selectedCourse['section'] != null
                      ? "${selectedCourse['code']}_${selectedCourse['section']}"
                      : null,
                );

              },
            ),
            const SizedBox(height: 30),
            // Empty Content
            Expanded(
              child: Center(
                child: Text(
                  selectedCourse['name'] != null
                      ? "Selected Course: ${selectedCourse['name']} - Section: ${selectedCourse['section']}"
                      : "No Course Selected",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            // Save Attendance Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // For now, nothing happens when saving attendance
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Attendance Saved (Stub Action)")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blueGrey,
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: const Text('Save Attendance'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

