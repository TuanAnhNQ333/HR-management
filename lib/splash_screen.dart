// splash_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    // Khởi tạo AnimationController và Animation
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..forward();

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _checkLoginStatus();
  }

  // Kiểm tra trạng thái đăng nhập
  void _checkLoginStatus() async {
    await Future.delayed(Duration(seconds: 3)); // Hiệu ứng chờ (3 giây)
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Nếu đã đăng nhập
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Nếu chưa đăng nhập
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // Giải phóng controller khi không sử dụng nữa
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _animation, // Áp dụng animation
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo ứng dụng với hiệu ứng fade-in
              Icon(
                Icons.group,
                size: 100,
                color: Colors.blueAccent,
              ),
              SizedBox(height: 20),
              // Tên ứng dụng với hiệu ứng fade-in
              Text(
                "Ứng dụng nhóm",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 20),
              // Vòng tròn tải (loading indicator)
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
