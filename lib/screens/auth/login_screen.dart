import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/database_helper.dart';
import 'User/Student/student_portal.dart';
import 'User/Teacher/teacher_portal.dart';

class RollNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.toUpperCase(); // Automatically convert to uppercase
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i < 2) {
        // First 2 characters must be digits
        if (RegExp(r'\d').hasMatch(text[i])) {
          buffer.write(text[i]);
        }
      } else if (i == 2) {
        // Third character must be a letter
        if (RegExp(r'[A-Za-z]').hasMatch(text[i])) {
          buffer.write(text[i].toUpperCase());
          buffer.write("-");
          i++;
        }
      } else {
        // Remaining characters must be digits
        if (RegExp(r'\d').hasMatch(text[i])) {
          buffer.write(text[i]);
        }
      }
    }

    String formattedText = buffer.toString();
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class LoginScreen extends StatefulWidget {
  final String userType;

  const LoginScreen({Key? key, required this.userType}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  void setErrorMessage() {
    setState(() {
      _errorMessage = 'Invalid password or ID';
    });
  }

  Future<void> _login() async {
    final db = DatabaseHelper.instance;
    final userType = widget.userType;
    final id = _idController.text.trim();
    final password = _passwordController.text.trim();
    try {
      // Get user from the 'users' table based on ID and password
      final user = await db.getUserByIdAndPassword(id, password, userType);
      final user1 = await db.getAllRecords();
      print("HELLO $user1");
      if (user != null) {
        final int userId = user['User_Id'];
        final String studentId = await db.getUserId(userId,'Student');
        final String teacherId = await db.getUserId(userId, 'Teacher');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => userType == 'Student'
                ? StudentPortal(userId,studentId)
                : TeacherPortal(userId,teacherId),
          ),
        );
      } else {
        // Handle invalid credentials
        setErrorMessage();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Handle errors (e.g., database issues)
      print("Error during login: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final idLabel = widget.userType == 'Student' ? 'Roll Number' : 'Teacher ID';

    return Scaffold(
      appBar: AppBar(title: Text('${widget.userType} Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ID Input Field
              TextFormField(
                controller: _idController,
                decoration: InputDecoration(
                  labelText: idLabel,
                  border: const OutlineInputBorder(),
                ),
                inputFormatters: widget.userType == 'Student'
                    ? [
                  LengthLimitingTextInputFormatter(8),
                  RollNumberFormatter(),
                ]
                    : [],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your $idLabel';
                  }
                  if (widget.userType == 'Student' &&
                      !RegExp(r'^\d{2}[A-Z]-\d{4}$').hasMatch(value)) {
                    return 'Roll Number must be in the format XXA-YYYY';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password Input Field
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Login Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _login();
                  }
                },
                child: const Text('Login'),
              ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
