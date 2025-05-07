import 'package:flutter/material.dart';
import '../../../utils/database_helper.dart';

class ViewPeople extends StatefulWidget {
  final String courseCode;
  final String sectionId;

  const ViewPeople({
    Key? key,
    required this.courseCode,
    required this.sectionId,
  }) : super(key: key);

  @override
  State<ViewPeople> createState() => _ViewPeopleState();
}

class _ViewPeopleState extends State<ViewPeople> {
  late Future<List<Map<String, dynamic>>> _teachers;
  late Future<List<Map<String, dynamic>>> _students;

  @override
  void initState() {
    super.initState();
    _loadPeople();
  }

  void _loadPeople() {
    _teachers = DatabaseHelper.instance.fetchTeachersForSection(
      widget.sectionId,
      widget.courseCode,
    );
    _students = DatabaseHelper.instance.fetchStudentsForSection(
      widget.sectionId,
      widget.courseCode,
    );
  }

  Widget _buildProfileTile(String name) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blueAccent,
        child: Text(
          name[0].toUpperCase(),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),

    );
  }

  Widget _buildSection(String title, Future<List<Map<String, dynamic>>> future) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.data == null || snapshot.data!.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'No $title found.',
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }

        final people = snapshot.data!;
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: people.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final person = people[index];
            return _buildProfileTile(
              person['User_Name']
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.courseCode} - ${widget.sectionId} People'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Teachers',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildSection('teachers', _teachers),
            const SizedBox(height: 24),
            const Text(
              'Students',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildSection('students', _students),
          ],
        ),
      ),
    );
  }
}
