import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool _saveCredentials = false;
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  // SharedPreferences에서 저장된 ID와 비밀번호를 불러오는 메소드
  Future<void> _loadSavedCredentials() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _emailController.text = _prefs?.getString('savedEmail') ?? '';
      _passwordController.text = _prefs?.getString('savedPassword') ?? '';
      _saveCredentials = _prefs?.getBool('saveCredentials') ?? false;
    });
  }

  // 로그인 시 ID와 비밀번호를 SharedPreferences에 저장
  Future<void> _saveCredentialsToPrefs() async {
    if (_saveCredentials) {
      await _prefs?.setString('savedEmail', _emailController.text);
      await _prefs?.setString('savedPassword', _passwordController.text);
      await _prefs?.setBool('saveCredentials', _saveCredentials);
    } else {
      await _prefs?.remove('savedEmail');
      await _prefs?.remove('savedPassword');
      await _prefs?.remove('saveCredentials');
    }
  }

  // 로그인 메서드
  Future<void> _login() async {
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.login(_emailController.text, _passwordController.text);

    setState(() => _isLoading = false);

    if (authProvider.isAuthenticated) {
      await _saveCredentialsToPrefs();
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/travel-on-login.png',
              height: 230,
              width: 230,
            ),
            TextFieldWidget(controller: _emailController, labelText: '이메일'),
            SizedBox(height: 20),
            PasswordFieldWidget(
              controller: _passwordController,
              labelText: '비밀번호',
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Row(
                    children: [
                      Text('로그인 정보 저장'),
                      Checkbox(
                        value: _saveCredentials,
                        onChanged: (value) {
                          setState(() {
                            _saveCredentials = value ?? false;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: TextButton(
                    onPressed: _navigateToSignup,
                    child: Text(
                      '회원가입',
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[500],
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                ),
                child: Text(
                  '로그인',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
