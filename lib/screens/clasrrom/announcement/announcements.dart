import 'package:flutter/material.dart';
import '../../../utils/database_helper.dart';
import 'add_announcement.dart';
import 'edit_announcement.dart'; // Import the EditAnnouncement page

class ViewAnnouncements extends StatefulWidget {
  final String courseCode;
  final String sectionId;
  final bool isTeacher;
  final int userId;

  const ViewAnnouncements({
    Key? key,
    required this.courseCode,
    required this.sectionId,
    required this.userId,
    required this.isTeacher,
  }) : super(key: key);

  @override
  State<ViewAnnouncements> createState() => _ViewAnnouncementsState();
}

class _ViewAnnouncementsState extends State<ViewAnnouncements> {
  late Future<List<Map<String, dynamic>>> _announcements;

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  void _loadAnnouncements() {
    print("Loading announcements...");
    _announcements = DatabaseHelper.instance
        .fetchAnnouncements(widget.courseCode, widget.sectionId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.courseCode} Announcements'),
        actions: [
          if (widget.isTeacher)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddAnnouncement(
                      courseCode: widget.courseCode,
                      sectionId: widget.sectionId,
                      userId: widget.userId,
                    ),
                  ),
                );
                setState(() {
                  _loadAnnouncements();
                });
              },
            ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _announcements,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No Announcements Found',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final announcements = snapshot.data!;
          return ListView.builder(
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final announcement = announcements[index];
              final announcementId = announcement['Announcement_Id'];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    announcement['Content'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'On ${announcement['Upload_date']} at ${announcement['Upload_time']}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  trailing: widget.isTeacher
                      ? PopupMenuButton<int>(
                    onSelected: (value) async {
                      if (value == 0) {
                        // Edit
                        final updatedContent = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditAnnouncement(
                              announcementId: announcementId,
                              initialContent: announcement['Content'],
                              userId: widget.userId,
                              sectionId: widget.sectionId,
                              courseCode: widget.courseCode,
                              uploadDate: announcement['Upload_date'],
                              uploadTime: announcement['Upload_time'],
                            ),
                          ),
                        );
                        if (updatedContent != null) {
                          setState(() {
                            _loadAnnouncements();
                          });
                        }
                      } else if (value == 1) {
                        // Delete
                        await DatabaseHelper.instance
                            .deleteAnnouncement(announcementId);
                        setState(() {
                          _loadAnnouncements();
                        });
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem<int>(
                        value: 0,
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem<int>(
                        value: 1,
                        child: Text('Delete'),
                      ),
                    ],
                  )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
