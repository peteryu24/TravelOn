import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:travel_on_final/features/auth/presentation/providers/auth_provider.dart';
import 'package:travel_on_final/features/auth/presentation/widgets/text_field_widget.dart';
import 'package:travel_on_final/features/auth/presentation/widgets/password_field_widget.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

// 로그인
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

  Future<void> _loadSavedCredentials() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _emailController.text = _prefs?.getString('savedEmail') ?? '';
      _passwordController.text = _prefs?.getString('savedPassword') ?? '';
      _saveCredentials = _prefs?.getBool('saveCredentials') ?? false;
    });
  }

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
        const SnackBar(content: Text('로그인에 실패했습니다. 다시 시도해주세요.')),
      );
    }
  }

  void _resetPassword() {
    context.push('/reset_password');
  }

  void _navigateToSignup() {
    context.push('/signup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('로그인', style: TextStyle(fontSize: 20.sp))),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/travel-on-login.png',
              height: 200.h,
              width: 200.w,
            ),
            TextFieldWidget(controller: _emailController, labelText: '이메일'),
            SizedBox(height: 20.h),
            PasswordFieldWidget(
              controller: _passwordController,
              labelText: '비밀번호',
            ),
            SizedBox(height: 5.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 8.0.w),
                  child: Row(
                    children: [
                      Text(
                        '로그인 정보 저장',
                        style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black),
                      ),
                      SizedBox(width: 5.w),
                      CupertinoSwitch(
                        activeColor: Colors.blue,
                        value: _saveCredentials,
                        onChanged: (value) {
                          setState(() {
                            _saveCredentials = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: _navigateToSignup,
                  child: Text(
                    '회원가입',
                    style: TextStyle(color: Colors.blue, fontSize: 14.sp),
                  ),
                ),
                Text(
                  '·',
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
                TextButton(
                  onPressed: _resetPassword,
                  child: Text(
                    '비밀번호 재설정',
                    style: TextStyle(color: Colors.blue, fontSize: 14.sp),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[500],
                padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 14.h),
              ),
              child: Text(
                '로그인',
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey[400])),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    'OR',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey[400])),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              'SNS 계정으로 로그인',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialButton(
                  iconWidget: ClipOval(
                    child: Image.asset(
                      'assets/images/google_light.png',
                      width: 58.sp,
                      height: 58.sp,
                      fit: BoxFit.cover,
                    ),
                  ),
                  color: Colors.white,
                  onPressed: () async {
                    try {
                      final authProvider =
                          Provider.of<AuthProvider>(context, listen: false);
                      await authProvider.signInWithGoogle();

                      if (authProvider.isAuthenticated) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  '${authProvider.currentUser!.name}님 환영합니다.')),
                        );
                        context.go('/');
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Google 로그인에 실패했습니다.')),
                      );
                    }
                  },
                ),
                SizedBox(width: 20.w),
                _buildSocialButton(
                  iconWidget: ClipOval(
                    child: Image.asset(
                      'assets/images/apple_light.png',
                      width: 120.sp,
                      height: 120.sp,
                      fit: BoxFit.cover,
                    ),
                  ),
                  color: Colors.black,
                  onPressed: () {
                    // Apple 로그인 구현
                  },
                ),
                SizedBox(width: 20.w),
                _buildSocialButton(
                  iconWidget: ClipOval(
                    child: Image.asset(
                      'assets/images/naver_light.png',
                      width: 40.sp,
                      height: 40.sp,
                      fit: BoxFit.cover,
                    ),
                  ),
                  color: const Color(0xFF03C75A),
                  onPressed: () {
                    // Naver 로그인 구현
                  },
                ),
                SizedBox(width: 20.w),
                _buildSocialButton(
                  iconWidget: ClipOval(
                    child: Image.asset(
                      'assets/images/kakao_light.png',
                      width: 100.sp,
                      height: 100.sp,
                      fit: BoxFit.cover,
                    ),
                  ),
                  color: const Color(0xFFFEE500),
                  onPressed: () {
                    // Kakao 로그인 구현
                  },
                ),
              ],
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required Widget iconWidget,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 45.w,
        height: 45.w,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: iconWidget),
      ),
    );
  }
}
