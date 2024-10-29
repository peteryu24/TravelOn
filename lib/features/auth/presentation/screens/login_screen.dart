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

  Future<void> _login() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    await authProvider.login(_emailController.text, _passwordController.text);

    if (authProvider.isAuthenticated) {
      // 로그인 성공 시 환영 메시지 출력
      final userName = authProvider.currentUser?.name ?? '사용자';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$userName님 환영합니다.'),
          duration: Duration(seconds: 4),
        ),
      );

      // 홈 화면으로 이동
      context.go('/');
    } else {
      // 로그인 실패 시 오류 메시지 출력
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('로그인에 실패했습니다. 다시 시도해주세요.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
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
