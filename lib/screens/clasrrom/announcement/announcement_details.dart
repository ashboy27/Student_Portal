import 'package:flutter/material.dart';

class AnnouncementDetails extends StatelessWidget {
  final Map<String, dynamic> announcement;

  const AnnouncementDetails({Key? key, required this.announcement})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Announcement Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              announcement['Content'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              '${announcement['Upload_date']} at ${announcement['Upload_time']}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const Spacer(),
            const Text('Comments Section Placeholder'),
            // Implement comments.dart later
          ],
        ),
      ),
    );
  }
}
