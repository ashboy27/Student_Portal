import 'package:flutter/material.dart';
import '../../../utils/database_helper.dart';

class AddAnnouncement extends StatefulWidget {
  final String courseCode;
  final String sectionId;
  final int userId;

  const AddAnnouncement({
    Key? key,
    required this.courseCode,
    required this.sectionId,
    required this.userId,
  }) : super(key: key);

  @override
  State<AddAnnouncement> createState() => _AddAnnouncementState();
}

class _AddAnnouncementState extends State<AddAnnouncement> {
  final TextEditingController _contentController = TextEditingController();

  Future<void> _saveAnnouncement() async {
    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Content cannot be empty')),
      );
      return;
    }

    final now = DateTime.now();

    final formattedDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final formattedTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

    try {
      // Check if user can add an announcement
      final canAdd = await DatabaseHelper.instance.canAddAnnouncement(widget.userId);
      if (!canAdd) {
        throw Exception('You can only add an announcement once every minute.');
      }

      // Add announcement
      await DatabaseHelper.instance.addAnnouncement(
        widget.userId,
        widget.sectionId,
        widget.courseCode,
        _contentController.text,
        formattedDate, // Ensuring YYYY-MM-DD
        formattedTime,
      );

      // Navigate back on successful post
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Announcement added successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Announcement')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Write your announcement...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveAnnouncement,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Post Announcement',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
