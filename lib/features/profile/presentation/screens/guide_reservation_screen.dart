import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../reservation/presentation/providers/reservation_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class GuideReservationsScreen extends StatefulWidget {
  const GuideReservationsScreen({super.key});

  @override
  State<GuideReservationsScreen> createState() => _GuideReservationsScreenState();
}

class _GuideReservationsScreenState extends State<GuideReservationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;  // TabController 추가

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);  // TabController 초기화
    _loadReservations();
  }

  @override
  void dispose() {
    _tabController.dispose();  // TabController 해제
    super.dispose();
  }

  Future<void> _loadReservations() async {
    final userId = context.read<AuthProvider>().currentUser!.id;
    await context.read<ReservationProvider>().loadReservations(userId, isGuide: true);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('예약 관리'),
        bottom: TabBar(
          controller: _tabController,  // TabController 연결
          tabs: const [
            Tab(text: '대기중'),
            Tab(text: '승인됨'),
            Tab(text: '거절됨'),
          ],
        ),
      ),
      body: Consumer<ReservationProvider>(
        builder: (context, provider, child) {
          return TabBarView(
            controller: _tabController,  // TabController 연결
            children: [
              _buildReservationList(provider, 'pending'),
              _buildReservationList(provider, 'approved'),
              _buildReservationList(provider, 'rejected'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReservationList(ReservationProvider provider, String status) {
    final reservations = provider.reservations
        .where((res) => res.status == status)
        .toList();

    if (reservations.isEmpty) {
      return const Center(
        child: Text('예약 내역이 없습니다.'),
      );
    }

    return ListView.builder(
      itemCount: reservations.length,
      itemBuilder: (context, index) {
        final reservation = reservations[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reservation.packageTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('예약자: ${reservation.customerName}'),
                Text(
                  '예약일: ${DateFormat('yyyy년 MM월 dd일').format(reservation.reservationDate)}',
                ),
                Text(
                  '가격: ₩${NumberFormat('#,###').format(reservation.price.toInt())}',
                ),
                const SizedBox(height: 12),
                if (status == 'pending')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => _updateReservationStatus(
                          reservation.id,
                          'rejected',
                        ),
                        child: const Text('거절'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _updateReservationStatus(
                          reservation.id,
                          'approved',
                        ),
                        child: const Text('승인'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateReservationStatus(String reservationId, String status) async {
    try {
      await context.read<ReservationProvider>().updateReservationStatus(
        reservationId,
        status,
      );

      // 상태 업데이트 후 즉시 예약 목록 다시 로드
      if (mounted) {
        final userId = context.read<AuthProvider>().currentUser!.id;
        await context.read<ReservationProvider>().loadReservations(userId, isGuide: true);

        // 상태에 따라 탭 변경
        if (mounted) {
          if (status == 'approved') {
            _tabController.animateTo(1);  // 승인됨 탭으로 이동
          } else if (status == 'rejected') {
            _tabController.animateTo(2);  // 거절됨 탭으로 이동
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(status == 'approved' ? '예약이 승인되었습니다.' : '예약이 거절되었습니다.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: $e'),
          ),
        );
      }
    }
  }
}