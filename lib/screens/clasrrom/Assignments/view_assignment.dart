import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import '../../../utils/database_helper.dart';
import 'add_assignment.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ViewAssignments extends StatefulWidget {
  final String courseCode;
  final String sectionId;
  final int userId;
  final bool isTeacher;

  const ViewAssignments({
    Key? key,
    required this.courseCode,
    required this.sectionId,
    required this.userId,
    required this.isTeacher,
  }) : super(key: key);

  @override
  State<ViewAssignments> createState() => _ViewAssignmentsState();
}

class _ViewAssignmentsState extends State<ViewAssignments> {
  late Future<List<Map<String, dynamic>>> _assignments;

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  void _loadAssignments() {
    _assignments = DatabaseHelper.instance.getAssignments(
      widget.courseCode,
      widget.sectionId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.courseCode} Assignments'),
        actions: [
          if (widget.isTeacher)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UploadAssignmentScreen(
                      courseCode: widget.courseCode,
                      sectionId: widget.sectionId,
                      userId: widget.userId,
                    ),
                  ),
                );
                setState(() {
                  _loadAssignments();
                });
              },
            ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _assignments,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No Assignments Found',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // Sorting the assignments by upload date (latest first)
          final assignments = snapshot.data!;
          final sortedAssignments = List<Map<String, dynamic>>.from(assignments);
          sortedAssignments.sort((a, b) {
            final uploadDateA = DateTime.parse(a['Upload_Date']);
            final uploadDateB = DateTime.parse(b['Upload_Date']);
            return uploadDateB.compareTo(uploadDateA);  // Sort by latest first
          });

          return ListView.builder(
            itemCount: sortedAssignments.length,
            itemBuilder: (context, index) {
              final assignment = sortedAssignments[index];
              final dueDateTime = DateTime.parse(
                  '${assignment['Due_Date']} ${assignment['Due_Time']}');
              final isOverdue = DateTime.now().isAfter(dueDateTime);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    assignment['Upload_Text'] ?? 'No Title',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: widget.isTeacher || !isOverdue
                          ? Colors.black
                          : Colors.red,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Due: ${assignment['Due_Date']} at ${assignment['Due_Time']}',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                  onTap: () async {
                    final filePath = assignment['Document'];
                    if (filePath != null) {
                      // Handle overdue case for students
                      if (widget.isTeacher || !isOverdue) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ViewAssignmentDocumentScreen(filePath: filePath),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Due date has passed. You cannot view this assignment.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    }
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

// Screen to view the PDF document
class ViewAssignmentDocumentScreen extends StatelessWidget {
  final String filePath;

  const ViewAssignmentDocumentScreen({Key? key, required this.filePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('View Assignment Document')),
      body: FutureBuilder<String>(
        future: _getLocalFile(filePath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.hasData) {
            final localPath = snapshot.data!;
            return PDFView(filePath: localPath);
          }

          return const Center(child: Text('File not found'));
        },
      ),
    );
  }

  Future<String> _getLocalFile(String filePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final localFile = File('${appDir.path}/$filePath');
    if (await localFile.exists()) {
      return localFile.path;
    } else {
      throw Exception('File not found');
    }
  }
}
