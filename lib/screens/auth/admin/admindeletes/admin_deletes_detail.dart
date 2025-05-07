import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../utils/database_helper.dart';



class _StudentIdFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    String text = newValue.text;

    // Restrict input to 2 digits, 1 uppercase letter, a dash, and 4 digits
    if (text.length > 8) {
      return oldValue;
    }

    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i < 2 && RegExp(r'\d').hasMatch(text[i])) {
        buffer.write(text[i]); // First 2 must be digits
      } else if (i == 2 && RegExp(r'[a-zA-Z]').hasMatch(text[i])) {
        buffer.write(text[i].toUpperCase());buffer.write('-');i++; // Third must be uppercase letter
      } else if (i >= 4 && i <= 7 && RegExp(r'\d').hasMatch(text[i])) {
        buffer.write(text[i]); // Last 4 must be digits
      } else {
        return oldValue; // Reject invalid characters
      }
    }

    // Automatically add dash after the third character
    if (buffer.length == 3 && buffer.toString().length < text.length) {
      buffer.write('-');
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
class DeleteUserRecord extends StatefulWidget {
  @override
  _DeleteUserRecordState createState() => _DeleteUserRecordState();
}

class _DeleteUserRecordState extends State<DeleteUserRecord> {
  final _formKey = GlobalKey<FormState>();
  String _selectedUserType = 'Student';
  final TextEditingController _idController = TextEditingController();


  void _deleteUser() async {
    if (_formKey.currentState!.validate()) {
      bool result = false;
      try {
        if (_selectedUserType == 'Student') {
          result = await DatabaseHelper.instance.deleteStudent(_idController.text);
        } else {
          result = await DatabaseHelper.instance.deleteTeacher(_idController.text);
        }

        if (result) {
          _showResultDialog(
              'Success',
              '${_selectedUserType} record deleted successfully!',
              Colors.green
          );
        } else {
          _showResultDialog(
              'Error',
              'Could not delete ${_selectedUserType} record. User may not exist.',
              Colors.red
          );
        }
      } catch (e) {
        _showResultDialog(
            'Error',
            'An error occurred: $e',
            Colors.red
        );
      }
    }
  }

  void _showResultDialog(String title, String message, Color color) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            message,
            style: const TextStyle(color: Colors.black87),
          ),
        ),
        backgroundColor: Colors.blue[50],
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
              _idController.clear();
            },
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Delete User Record',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 5,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Decorative Header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.delete_forever,
                        size: 80,
                        color: Colors.blueAccent,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Remove User Record',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // User Type Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedUserType,
                  decoration: InputDecoration(
                    labelText: 'Select User Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: _selectedUserType == 'Teacher'
                        ? Padding(
                      padding: const EdgeInsets.all(8.0), // Matches Material Design spacing
                      child: Image.asset(
                        'assets/icons/teacher.png',
                        fit: BoxFit.contain,
                      ),
                    )
                        : const Icon(Icons.person_outline),
                  ),
                  items: ['Student', 'Teacher']
                      .map(
                        (type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    ),
                  )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedUserType = value!;
                    });
                  },
                ),

                const SizedBox(height: 20),

                // ID Input Field
                TextFormField(
                  controller: _idController,
                  decoration: InputDecoration(
                    labelText: _selectedUserType == 'Student'
                        ? 'Student ID (e.g., 22K-4581)'
                        : 'Teacher ID',
                    hintText: _selectedUserType == 'Student'
                        ? 'Enter in format: NNL-NNN'
                        : 'Enter Teacher ID',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.badge_outlined),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a valid ID';
                    }



                    return null;
                  },
                  inputFormatters: _selectedUserType == 'Student'
                      ? [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Za-z-]')),
                    _StudentIdFormatter(),
                  ]
                      : [],
                ),
                const SizedBox(height: 30),

                // Delete Button
                ElevatedButton(
                  onPressed: _deleteUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Delete Record',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}