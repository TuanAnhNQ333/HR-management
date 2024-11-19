// login_screen.dart


import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false; // Biến để hiển thị loading indicator

  // Hàm đăng nhập
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Hiển thị loading khi bắt đầu đăng nhập
      });
      try {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đăng nhập thành công!')),
        );
        Navigator.pushReplacementNamed(context, '/home'); // Chuyển đến trang chính
      } catch (e) {
        String errorMessage = 'Đã xảy ra lỗi!';
        if (e is FirebaseAuthException) {
          // Xử lý lỗi Firebase cụ thể
          switch (e.code) {
            case 'user-not-found':
              errorMessage = 'Không tìm thấy người dùng với email này';
              break;
            case 'wrong-password':
              errorMessage = 'Mật khẩu không đúng';
              break;
            case 'invalid-email':
              errorMessage = 'Email không hợp lệ';
              break;
            default:
              errorMessage = 'Đã xảy ra lỗi, vui lòng thử lại';
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } finally {
        setState(() {
          _isLoading = false; // Ẩn loading khi hoàn thành
        });
      }
    }
  }

  // Hàm xử lý quên mật khẩu
  Future<void> _resetPassword() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập email của bạn')),
      );
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã gửi yêu cầu đặt lại mật khẩu!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi, vui lòng thử lại')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Đăng Nhập')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Hãy nhập email hợp lệ';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Mật khẩu'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Hãy nhập mật khẩu';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator() // Hiển thị loading khi đăng nhập
                  : ElevatedButton(
                      onPressed: _login,
                      child: Text('Đăng Nhập'),
                    ),
              SizedBox(height: 10),
              TextButton(
                onPressed: _resetPassword, // Chức năng quên mật khẩu
                child: Text('Quên mật khẩu?'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register'); // Chuyển đến màn hình đăng ký
                },
                child: Text('Chưa có tài khoản? Đăng ký ngay!'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
