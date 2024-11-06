import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../gallery/presentation/providers/gallery_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('마이페이지')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 사용자 정보 카드
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.grey[200],
                          child: Icon(
                            Icons.person,
                            size: 30,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.name ?? '사용자',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                user?.email ?? '',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 가이드 기능 섹션 (가이드인 경우에만 표시)
                if (user?.isGuide == true) ...[
                  const Text(
                    '가이드 기능',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.add_box),
                          title: const Text('나만의 패키지 만들기'),
                          subtitle: const Text('새로운 여행 패키지를 등록합니다'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            context.push('/add-package');
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.calendar_today),
                          title: const Text('내 패키지 예약 관리'),
                          subtitle: const Text('등록한 패키지의 예약을 관리합니다'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            context.push('/reservations/guide');
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.list_alt),
                          title: const Text('내 패키지 관리'),
                          subtitle: const Text('등록한 패키지를 수정하거나 삭제합니다'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            context.push('/my-packages');
                          },
                        ),
                      ],
                    ),
                  ),
                ],

                // 가이드가 아닌 경우 가이드 인증 메뉴 표시
                if (user?.isGuide != true) ...[
                  const SizedBox(height: 24),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.verified_user),
                      title: const Text('가이드 인증'),
                      subtitle: const Text('가이드 인증을 진행하세요'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/guide-certification'),
                    ),
                  ),
                ],

                // 일반 사용자 기능 섹션
                const SizedBox(height: 24),
                const Text(
                  '예약 관리',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.bookmark),
                    title: const Text('내 예약 내역'),
                    subtitle: const Text('예약한 패키지를 확인합니다'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      context.push('/reservations/customer');
                    },
                  ),
                ),

                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.favorite),
                        title: const Text('찜한 패키지'),
                        subtitle: const Text('관심있는 패키지를 확인합니다'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          context.push('/liked-packages');
                        },
                      ),
                    ],
                  ),
                ),

                // 로그아웃 버튼
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          context.read<GalleryProvider>().reset();
                          await context.read<AuthProvider>().logout();
                          if (context.mounted) {
                            context.go('/login');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('로그아웃 중 오류가 발생했습니다: $e')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('로그아웃'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}