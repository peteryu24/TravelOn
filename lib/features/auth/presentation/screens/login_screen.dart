import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_on_final/features/auth/presentation/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.login(_emailController.text, _passwordController.text);
  }

  void _navigateToSignup() {
    context.go('/signup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('로그인')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: '이메일'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: '비밀번호'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('로그인'),
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.bottomLeft,
              child: TextButton(
                onPressed: _navigateToSignup,
                child: Text('회원가입'),
              ),
            ),
            Consumer<AuthProvider>(
              builder: (context, auth, child) {
                return auth.isAuthenticated
                    ? Text('Logged in as ${auth.currentUser?.name}')
                    : Container();
              },
            ),
          ],
        ),
      ),
    );
  }
}
