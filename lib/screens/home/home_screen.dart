import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/admin/admin.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAST Academic Portal'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 6.0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF64B5F6), Color(0xFF2196F3)],
            center: Alignment(0, -0.5),
            radius: 1.5,
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildOptions(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            'Welcome to FAST Academic Portal',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              textStyle: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Choose your role to proceed',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptions(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      children: [
        _buildAnimatedCard(
          context,
          icon: Icons.admin_panel_settings_rounded,
          label: 'Admin',
          onTap: () => _navigateWithTransition(
            context,
            AdminScreen(),
          ),
        ),
        const SizedBox(height: 20),
        _buildAnimatedCard(
          context,
          icon: Icons.school_rounded,
          label: 'Student',
          onTap: () => _navigateWithTransition(
            context,
            LoginScreen(userType: 'Student'),
          ),
        ),
        const SizedBox(height: 20),
        _buildAnimatedCard(
          context,
          icon: Icons.person_rounded,
          label: 'Teacher',
          onTap: () => _navigateWithTransition(
            context,
            LoginScreen(userType: 'Teacher'),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedCard(
      BuildContext context, {
        required IconData icon,
        required String label,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildCardIcon(icon),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  label,
                  style: GoogleFonts.roboto(
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.black38,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardIcon(IconData icon) {
    return Container(
      width: 80,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
      ),
      child: Icon(icon, size: 32, color: Colors.white),
    );
  }

  void _navigateWithTransition(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween =
          Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }
}
