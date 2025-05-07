import 'package:flutter/material.dart';
import '../../../utils/database_helper.dart';

class EditAnnouncement extends StatefulWidget {
  final int announcementId;
  final String initialContent;
  final int userId;
  final String sectionId;
  final String courseCode;
  final String uploadTime;
  final String uploadDate;

  const EditAnnouncement({
    Key? key,
    required this.announcementId,
    required this.initialContent,
    required this.userId,
    required this.sectionId,
    required this.courseCode,
    required this.uploadTime,
    required this.uploadDate,
  }) : super(key: key);

  @override
  _EditAnnouncementState createState() => _EditAnnouncementState();
}

class _EditAnnouncementState extends State<EditAnnouncement> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.initialContent);
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveAnnouncement() async {
    if (_formKey.currentState!.validate()) {
      await DatabaseHelper.instance.updateAnnouncement(
        announcementId: widget.announcementId,
        content: _contentController.text,
        uploadDate: widget.uploadDate,
        uploadTime: widget.uploadTime,
      );
      Navigator.pop(context, _contentController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Announcement'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveAnnouncement,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _contentController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the content';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}