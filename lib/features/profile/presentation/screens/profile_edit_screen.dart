import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_on_final/features/auth/presentation/providers/auth_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileEditScreen extends StatefulWidget {
  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _introductionController = TextEditingController();
  String? _gender;
  DateTime? _birthDate;
  String? _profileImageUrl;
  File? _selectedImageFile;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        setState(() {
          _nameController.text = user.name;
          _gender = user.gender;
          _birthDate = user.birthDate;
          _profileImageUrl = user.profileImageUrl;
          _introductionController.text = user.introduction ?? '';
        });
      }
    });
  }

  Future<void> _selectBirthDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _birthDate = pickedDate;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImageFile = File(pickedFile.path);
        _profileImageUrl = null;
      });
    }
  }

  void _saveProfile() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이름은 비어 있을 수 없습니다')),
      );
      return;
    }

    try {
      await context.read<AuthProvider>().updateUserProfile(
        name: _nameController.text,
        gender: _gender,
        birthDate: _birthDate,
        profileImageUrl: _selectedImageFile != null ? _selectedImageFile!.path : _profileImageUrl,
        introduction: _introductionController.text,
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('프로필 업데이트에 실패했습니다')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: Text('회원 정보 수정')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            InkWell(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 40,
                backgroundImage: _selectedImageFile != null
                    ? FileImage(_selectedImageFile!)
                    : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty)
                        ? NetworkImage(_profileImageUrl!)
                        : AssetImage('assets/images/default_profile.png') as ImageProvider,
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '이름',
                  labelStyle: TextStyle(color: Colors.blue),
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                enabled: false,
                decoration: InputDecoration(
                  labelText: '이메일',
                  labelStyle: TextStyle(color: Colors.blue),
                  border: InputBorder.none,
                ),
                controller: TextEditingController(text: user?.email ?? ''),
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _introductionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: '내 소개',
                  labelStyle: TextStyle(color: Colors.blue),
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '성별',
                    style: TextStyle(color: Colors.blue),
                  ),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _gender = '남성';
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: _gender == '남성' ? Colors.blue.shade100 : null,
                          side: BorderSide(color: Colors.blue),
                        ),
                        child: Text('남성'),
                      ),
                      SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _gender = '여성';
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: _gender == '여성' ? Colors.blue.shade100 : null,
                          side: BorderSide(color: Colors.blue),
                        ),
                        child: Text('여성'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '생일',
                    style: TextStyle(color: Colors.blue),
                  ),
                  Text(
                    _birthDate != null
                        ? "${_birthDate!.year}-${_birthDate!.month}-${_birthDate!.day}"
                        : '생일을 선택하세요 →',
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_today, color: Colors.blue),
                    onPressed: _selectBirthDate,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveProfile,
              child: Text('저장'),
            ),
          ],
        ),
      ),
    );
  }
}
