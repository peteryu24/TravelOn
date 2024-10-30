import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_on_final/features/auth/presentation/providers/auth_provider.dart';
import 'package:travel_on_final/features/auth/presentation/widgets/text_field_widget.dart';
import 'package:travel_on_final/features/auth/presentation/widgets/password_field_widget.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.login(_emailController.text, _passwordController.text);

    setState(() => _isLoading = false);

    if (authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${authProvider.currentUser!.name}님 환영합니다.')),
      );
      context.go('/');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('로그인에 실패했습니다. 다시 시도해주세요.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _navigateToSignup() {
    context.push('/signup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('로그인')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFieldWidget(controller: _emailController, labelText: '이메일'),
                  SizedBox(height: 16),
                  PasswordFieldWidget(
                    controller: _passwordController,
                    labelText: '비밀번호',
                  ),
                  SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[300],
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                      ),
                      child: Text(
                        '로그인',
                        style: TextStyle(
                          color: Colors.white
                        ),
                      ),
                    ),
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
