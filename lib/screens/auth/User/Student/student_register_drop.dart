import 'package:flutter/material.dart';
import '../../../../utils/database_helper.dart';

class RegisterCourseScreen extends StatefulWidget {
  final String studentId;

  RegisterCourseScreen(this.studentId);

  @override
  _RegisterCourseScreenState createState() => _RegisterCourseScreenState();
}

class _RegisterCourseScreenState extends State<RegisterCourseScreen> {
  late Future<String> _sectionFuture;
  late Future<List<Map<String, dynamic>>> _coursesFuture;
  late Future<List<String>> _registeredCoursesFuture;
  // void _loadRecords() async {
  //   final result = await DatabaseHelper.instance.getAllRecords();
  //   print("Hello $result"); // This will print the result to the console
  // }

  @override
  void initState() {
    super.initState();
    _sectionFuture = _fetchStudentSection();
  //  _loadRecords();
    _sectionFuture.then((section) {
      setState(() {
        _coursesFuture = _fetchCourses(section);
        _registeredCoursesFuture = _fetchRegisteredCourses();
      });
    });
  }

  Future<List<Map<String, dynamic>>> _fetchCourses(String section) async {
    final db = DatabaseHelper.instance;
    return db.getCoursesBySection(section);
  }

  Future<List<String>> _fetchRegisteredCourses() async {
    final db = DatabaseHelper.instance;
    return db.getRegisteredCourses(widget.studentId);
  }

  Future<String> _fetchStudentSection() async {
    final db = DatabaseHelper.instance;
    return db.getStudentSection(widget.studentId);
  }

  Future<void> _registerCourse(String courseCode, String section) async {
    final db = DatabaseHelper.instance;
    await db.registerCourse(widget.studentId, courseCode, section);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Course registered successfully!')),
    );
    _refreshData();
  }

  Future<void> _dropCourse(String courseCode) async {
    final db = DatabaseHelper.instance;
    await db.dropCourse(widget.studentId, courseCode);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Course dropped successfully!')),
    );
    _refreshData();
  }

  void _refreshData() {
    _sectionFuture.then((section) {
      setState(() {
        _coursesFuture = _fetchCourses(section);
        _registeredCoursesFuture = _fetchRegisteredCourses();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _sectionFuture,
      builder: (context, sectionSnapshot) {
        if (sectionSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (sectionSnapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${sectionSnapshot.error}')),
          );
        } else {
          final section = sectionSnapshot.data ?? '1A';
          print(section);
          return Scaffold(
            appBar: AppBar(
              title: const Text('Register Courses'),
              backgroundColor: Colors.blue[900],
            ),
            body: FutureBuilder<List<Map<String, dynamic>>>(
              future: _coursesFuture,
              builder: (context, courseSnapshot) {
                if (courseSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (courseSnapshot.hasError) {
                  return Center(child: Text('Error: ${courseSnapshot.error}'));
                } else if (!courseSnapshot.hasData || courseSnapshot.data!.isEmpty) {
                  return const Center(child: Text('No courses available.'));
                }

                final courses = courseSnapshot.data!;
                print("HELLO $courses");
                return FutureBuilder<List<String>>(
                  future: _registeredCoursesFuture,
                  builder: (context, registeredSnapshot) {
                    if (registeredSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final registeredCourses = registeredSnapshot.data ?? [];
                     print("HELLIO $registeredCourses");
                    return ListView.builder(
                      itemCount: courses.length,
                      itemBuilder: (context, index) {
                        final course = courses[index];
                        final isRegistered = registeredCourses.contains(course['Course_Code']);
                        //print("HELLO $course");
                        return Card(
                          elevation: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundColor: isRegistered ? Colors.green[100] : Colors.blue[100],
                                      child: Icon(
                                        isRegistered ? Icons.check_circle : Icons.book,
                                        color: isRegistered ? Colors.green : Colors.blue[900],
                                        size: 30,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        course['Course_Name'],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildInfoRow('Credit Hours', course['Credit_Hrs'].toString()),
                                _buildInfoRow('Course Type', course['Course_Type']),
                                _buildInfoRow('Section', course['Section']),
                                _buildInfoRow('Teacher', course['Teacher_Name']),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (isRegistered)
                                      ElevatedButton(
                                        onPressed: () => _dropCourse(course['Course_Code']),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text('Drop'),
                                      ),
                                    if (!isRegistered)
                                      ElevatedButton(
                                        onPressed: () => _registerCourse(course['Course_Code'], section),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue[900],
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text('Register'),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          );
        }
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
