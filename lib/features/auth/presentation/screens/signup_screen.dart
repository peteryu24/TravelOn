import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_on_final/features/auth/domain/usecases/signup_usecase.dart';
import 'package:travel_on_final/features/auth/presentation/providers/auth_provider.dart';
import 'package:travel_on_final/features/auth/presentation/widgets/email_field_widget.dart';
import 'package:travel_on_final/features/auth/presentation/widgets/password_field_widget.dart';
import 'package:travel_on_final/features/auth/presentation/widgets/text_field_widget.dart';
import 'package:travel_on_final/features/auth/presentation/helpers/dialog_helper.dart';
import 'package:travel_on_final/features/auth/presentation/utils/validation.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailIdController = TextEditingController();
  final TextEditingController _emailDomainController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordMatched = true;
  bool _isPasswordLengthValid = true;
  String _selectedDomain = 'naver.com';

  Future<void> _signup() async {
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final signupUseCase = SignupUseCase(authProvider);
    final email = '${_emailIdController.text}@${_selectedDomain == '직접 입력' ? _emailDomainController.text : _selectedDomain}';

    await signupUseCase.execute(email, _passwordController.text, _nameController.text);
    setState(() => _isLoading = false);
    DialogHelper.showEmailVerificationDialog(context);
  }

  void _checkPasswordRequirements() {
    setState(() {
      _isPasswordMatched = validatePasswordMatch(_passwordController.text, _confirmPasswordController.text);
      _isPasswordLengthValid = validatePasswordLength(_passwordController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('회원가입')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFieldWidget(controller: _nameController, labelText: '닉네임'),
                  SizedBox(height: 16),
                  EmailFieldWidget(
                    emailIdController: _emailIdController,
                    emailDomainController: _emailDomainController,
                    onDomainSelected: (value) => setState(() => _selectedDomain = value),
                    selectedDomain: _selectedDomain,
                  ),
                  SizedBox(height: 16),
                  PasswordFieldWidget(
                    controller: _passwordController,
                    labelText: '비밀번호',
                    onChanged: (_) => _checkPasswordRequirements(),
                  ),
                  if (!_isPasswordLengthValid)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                      child: Text(
                        '비밀번호는 6자리 이상이어야 합니다.',
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  SizedBox(height: 16),
                  PasswordFieldWidget(
                    controller: _confirmPasswordController,
                    labelText: '비밀번호 확인',
                    onChanged: (_) => _checkPasswordRequirements(),
                  ),
                  if (!_isPasswordMatched)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                      child: Text(
                        '비밀번호가 다릅니다.',
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: _isFormValid ? _signup : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[300],
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                      ),
                      child: Text('회원가입', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  bool get _isFormValid {
    return _nameController.text.isNotEmpty &&
        _emailIdController.text.isNotEmpty &&
        (_selectedDomain == '직접 입력' ? _emailDomainController.text.isNotEmpty : true) &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _isPasswordMatched &&
        _isPasswordLengthValid;
  }
}
