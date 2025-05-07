import 'package:flutter/material.dart';
import '../../../../utils/database_helper.dart';

class AttendanceView extends StatefulWidget {
  final String studentId;

  const AttendanceView({Key? key, required this.studentId}) : super(key: key);

  @override
  _AttendanceViewState createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<AttendanceView> {
  late Future<List<Map<String, dynamic>>> _courses;
  late Future<List<Map<String, dynamic>>> _attendance;
  String? _selectedCourseCode;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  void _loadCourses() {
    _courses = DatabaseHelper.instance.getStudentCourses(widget.studentId);
  }

  void _loadAttendance(String courseCode) {
    setState(() {
      _selectedCourseCode = courseCode;
      _attendance = DatabaseHelper.instance.getAttendanceForCourse(courseCode, widget.studentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
      ),
      body: Column(
        children: [
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _courses,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                return const Center(child: Text('No Courses Found.'));
              }

              final courses = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: courses.map<Widget>((course) {
                    final courseCode = course['Course_Code'];
                    return ChoiceChip(
                      label: Text(courseCode),
                      selected: _selectedCourseCode == courseCode,
                      onSelected: (_) => _loadAttendance(courseCode),
                    );
                  }).toList(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          if (_selectedCourseCode != null)
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _attendance,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No Attendance Found.'));
                  }

                  final attendance = snapshot.data!;
                  return SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Status')),
                      ],
                      rows: attendance.map<DataRow>((att) {
                        final date = att['Attend_Date'];
                        final status = att['Status'] == 1 ? 'Present' : 'Absent';
                        return DataRow(cells: [
                          DataCell(Text(date)),
                          DataCell(Text(status)),
                        ]);
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
