import 'package:flutter/material.dart';
import '../../../../utils/database_helper.dart'; // Import your database helper file


import 'package:flutter/services.dart';

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

class _StudentSectionFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue,
      TextEditingValue newValue,) {
    String text = newValue.text;

    // Restrict input to 2 characters max
    if (text.length > 2) {
      return oldValue;
    }

    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i == 0 && RegExp(r'\d').hasMatch(text[i])) {
        // First character must be a digit
        buffer.write(text[i]);
      } else if (i == 1 && RegExp(r'[a-zA-Z]').hasMatch(text[i])) {
        // Second character must be a letter (converted to uppercase)
        buffer.write(text[i].toUpperCase());
      } else {
        // Reject invalid characters
        return oldValue;
      }
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class AdminFillsDetail extends StatefulWidget {
  @override
  _AdminFillsDetailState createState() => _AdminFillsDetailState();
}

class _AdminFillsDetailState extends State<AdminFillsDetail> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // Controllers for Student/Teacher-specific fields
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _batchController = TextEditingController();
  final TextEditingController _teacherIdController = TextEditingController();
  final TextEditingController _hireDateController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _sectionController = TextEditingController();

  String _userType = 'Student'; // Default dropdown value

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add User Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Basic Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildTextField('Full Name', _fullNameController),
              _buildTextField('CNIC', _cnicController),
              _buildTextField('Email', _emailController),
              _buildTextField('Password', _passwordController, isPassword: true),
              _buildTextField('Phone Number', _phoneController),
              _buildTextField('Address', _addressController),
              const SizedBox(height: 20),
              const Text(
                'Select User Type',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _userType,
                onChanged: (value) {
                  setState(() {
                    _userType = value!;
                  });
                },
                items: ['Student', 'Teacher']
                    .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                ))
                    .toList(),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'User Type',
                ),
              ),
              const SizedBox(height: 20),
              if (_userType == 'Student') ...[
                const Text(
                  'Student Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _buildStudentIdField('Student ID', _studentIdController),
                _buildTextField('Department', _departmentController),
                _buildTextField('Batch', _batchController),
                _buildStudentSectionField('Section',_sectionController),
              ],
              if (_userType == 'Teacher') ...[
                const Text(
                  'Teacher Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _buildTextField('Teacher ID', _teacherIdController),
                _buildTextField('Hire Date', _hireDateController),
                _buildTextField('Salary', _salaryController),
              ],
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        final db = DatabaseHelper.instance;
                        final result = await db.getTableSchema("Teacher");
                        print(result);
                        await db.insertUser(
                          fullName: _fullNameController.text,
                          cnic: _cnicController.text,
                          email: _emailController.text,
                          password: _passwordController.text,
                          phone: _phoneController.text,
                          address: _addressController.text,
                          userType: _userType,
                          studentId: _userType == 'Student'
                              ? _studentIdController.text
                              : null,
                          department: _userType == 'Student'
                              ? _departmentController.text
                              : null,
                          batch: _userType == 'Student'
                              ? int.parse(_batchController.text)
                              : null,
                          section: _userType=='Student'
                          ?_sectionController.text:null,
                          teacherId: _userType == 'Teacher'
                              ? _teacherIdController.text
                              : null,
                          hireDate: _userType == 'Teacher'
                              ? _hireDateController.text
                              : null,
                          salary: _userType == 'Teacher'
                              ? int.parse(_salaryController.text)
                              : null,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('User added successfully!'),
                          ),
                        );

                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Save Details'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: label,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildStudentIdField(String label, TextEditingController controller) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: label,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Za-z-]')),
          _StudentIdFormatter(),
        ],
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          if (!RegExp(r'^\d{2}[A-Z]-\d{4}$').hasMatch(value)) {
            return 'Student ID must be in the format NN-L-NNNN';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildStudentSectionField(String label, TextEditingController controller) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: label,
        ),
        inputFormatters: [

          _StudentSectionFormatter(),
        ],
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          if (!RegExp(r'[0-9][A-Z]$').hasMatch(value)) {
            return 'Section must be in the format NL';
          }
          return null;
        },
      ),
    );
  }

}
