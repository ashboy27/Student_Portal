import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../../../utils/database_helper.dart';

class UploadAssignmentScreen extends StatefulWidget {
  final String courseCode;
  final String sectionId;
  final int userId;

  const UploadAssignmentScreen({
    Key? key,
    required this.courseCode,
    required this.sectionId,
    required this.userId,
  }) : super(key: key);

  @override
  State<UploadAssignmentScreen> createState() => _UploadAssignmentScreenState();
}

class _UploadAssignmentScreenState extends State<UploadAssignmentScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _marksController = TextEditingController();
  File? _selectedPdfFile;
  DateTime? _selectedDueDate;
  TimeOfDay? _selectedDueTime;

  Future<void> _selectDueDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != _selectedDueDate) {
      setState(() {
        _selectedDueDate = pickedDate;
      });
    }
  }

  Future<void> _selectDueTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null && pickedTime != _selectedDueTime) {
      setState(() {
        _selectedDueTime = pickedTime;
      });
    }
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedPdfFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _saveAssignment() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title cannot be empty')),
      );
      return;
    }

    if (_marksController.text.isEmpty || int.tryParse(_marksController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid total marks')),
      );
      return;
    }

    if (_selectedDueDate == null || _selectedDueTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a due date and time')),
      );
      return;
    }

    if (_selectedPdfFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a PDF document')),
      );
      return;
    }

    final formattedDueDate = DateFormat('yyyy-MM-dd').format(_selectedDueDate!);
    final formattedDueTime =
        '${_selectedDueTime!.hour.toString().padLeft(2, '0')}:${_selectedDueTime!.minute.toString().padLeft(2, '0')}:00';
    final now = DateTime.now();
    final uploadDate = DateFormat('yyyy-MM-dd').format(now);
    final uploadTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

    try {
      // Save the PDF to the app's documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = _selectedPdfFile!.path.split('/').last;
      final savedPath = '${appDir.path}/$fileName';
      await _selectedPdfFile!.copy(savedPath);

      await DatabaseHelper.instance.addAssignment(
        courseCode: widget.courseCode,
        sectionId: widget.sectionId,
        teacherId: widget.userId.toString(),
        dueDate: formattedDueDate,
        dueTime: formattedDueTime,
        uploadDate: uploadDate,
        uploadTime: uploadTime,
        documentPath: savedPath, // Save file path
        title: _titleController.text,
        totalMarks: int.parse(_marksController.text),
      );

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assignment uploaded successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Assignment')),
      resizeToAvoidBottomInset: true, // Ensures space is adjusted for keyboard
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              maxLines: 1,
              decoration: InputDecoration(
                hintText: 'Assignment Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _marksController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Total Marks',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(
                _selectedDueDate != null
                    ? 'Due Date: ${DateFormat('yyyy-MM-dd').format(_selectedDueDate!)}'
                    : 'Select Due Date',
              ),
              onTap: _selectDueDate,
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: Text(
                _selectedDueTime != null
                    ? 'Due Time: ${_selectedDueTime!.format(context)}'
                    : 'Select Due Time',
              ),
              onTap: _selectDueTime,
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: Text(
                _selectedPdfFile != null
                    ? 'Selected File: ${_selectedPdfFile!.path.split('/').last}'
                    : 'Upload PDF Document',
              ),
              onTap: _pickPdf,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveAssignment,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Upload Assignment',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
