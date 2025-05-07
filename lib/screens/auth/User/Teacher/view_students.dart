import 'package:flutter/material.dart';
import '../../../../utils/database_helper.dart';

class ViewStudents extends StatefulWidget {
  final String courseCode;
  final String sectionId;

  const ViewStudents({
    Key? key,
    required this.courseCode,
    required this.sectionId,
  }) : super(key: key);

  @override
  State<ViewStudents> createState() => _ViewStudentsState();
}

class _ViewStudentsState extends State<ViewStudents> {
  late Future<List<Map<String, dynamic>>> _students;
  final Map<String, String> _attendanceStatus = {};
  late String _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now().toIso8601String().split('T')[0]; // Default to today's date
    _loadStudents();
    _loadAttendanceForDate();
  }

  void _loadStudents() {
    _students = DatabaseHelper.instance.fetchStudentsForSection(
      widget.sectionId,
      widget.courseCode,
    );
  }

  // Date Picker for selecting the date
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(_selectedDate),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.parse(_selectedDate)) {
      setState(() {
        _selectedDate = picked.toIso8601String().split('T')[0]; // Format the date as YYYY-MM-DD
        _loadAttendanceForDate(); // Reload attendance records for the selected date
      });
    }
  }

  // Load attendance records for the selected date
  void _loadAttendanceForDate() async {
    final students = await _students;

    // Load attendance records for each student
    for (var student in students) {
      final studentId = student['Student_Id'];

      final attendanceRecords = await DatabaseHelper.instance.fetchAttendanceForDate(
        widget.courseCode,
        studentId,  // Use studentId here
        _selectedDate,
      );

      if (attendanceRecords.isNotEmpty) {
        setState(() {
          _attendanceStatus[studentId] = attendanceRecords[0]['Status'] == 1 ? 'Present' : 'Absent';
        });
      } else {
        // If no record exists for this student, set to 'Absent' by default
        setState(() {
          _attendanceStatus[studentId] = 'Absent';
        });
      }
    }
  }

  void _saveAttendance() async {
    for (var entry in _attendanceStatus.entries) {
      final studentId = entry.key;
      final status = entry.value == 'Present' ? 1 : 0;

      await DatabaseHelper.instance.saveAttendance(
        widget.courseCode,
        studentId,
        _selectedDate,
        status,
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attendance saved successfully!')),
    );
  }

  Widget _buildStudentTile(String studentId, String name) {
    return ListTile(
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text('ID: $studentId'),
      trailing: DropdownButton<String>(
        value: _attendanceStatus[studentId] ?? 'Absent',
        items: const [
          DropdownMenuItem(value: 'Present', child: Text('Present')),
          DropdownMenuItem(value: 'Absent', child: Text('Absent')),
        ],
        onChanged: (value) {
          setState(() {
            _attendanceStatus[studentId] = value ?? 'Absent';
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.courseCode} - ${widget.sectionId} Students'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Picker Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Date: $_selectedDate',
                  style: const TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _selectDate,
                ),
              ],
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _students,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No students found.'));
                }

                final students = snapshot.data!;
                return Expanded(
                  child: ListView.separated(
                    itemCount: students.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return _buildStudentTile(
                        student['Student_Id'],
                        student['User_Name'],
                      );
                    },
                  ),
                );
              },
            ),
            // Save Attendance Button
            ElevatedButton(
              onPressed: _saveAttendance,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Save Attendance', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
