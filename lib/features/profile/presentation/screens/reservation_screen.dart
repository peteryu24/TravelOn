import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../reservation/presentation/providers/reservation_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../search/presentation/providers/travel_provider.dart';
import '../../../search/domain/entities/travel_package.dart';

class CustomerReservationsScreen extends StatefulWidget {
  const CustomerReservationsScreen({super.key});

  @override
  State<CustomerReservationsScreen> createState() => _CustomerReservationsScreenState();
}

class _CustomerReservationsScreenState extends State<CustomerReservationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadReservations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReservations() async {
    final userId = context.read<AuthProvider>().currentUser!.id;
    await context.read<ReservationProvider>().loadReservations(userId);
  }

  Future<void> _navigateToPackageDetail(String packageId) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final travelProvider = context.read<TravelProvider>();
      await travelProvider.loadPackages();

      if (!mounted) return;
      Navigator.pop(context);

      final package = travelProvider.packages.firstWhere(
            (p) => p.id == packageId,
        orElse: () => throw Exception('패키지를 찾을 수 없습니다'),
      );

      if (!mounted) return;
      context.push('/package-detail/${package.id}', extra: package);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('패키지 정보를 불러올 수 없습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 예약 내역'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '대기중인 예약'),
            Tab(text: '확정된 예약'),
          ],
        ),
      ),
      body: Consumer<ReservationProvider>(
        builder: (context, provider, child) {
          if (provider.reservations.isEmpty) {
            return const Center(
              child: Text('예약 내역이 없습니다.'),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildReservationList(provider, 'pending'),
              _buildReservationList(provider, 'approved'),
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
      return Center(
        child: Text(status == 'pending' ? '대기중인 예약이 없습니다.' : '확정된 예약이 없습니다.'),
      );
    }

    return Consumer<TravelProvider>(
      builder: (context, travelProvider, child) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reservations.length,
          itemBuilder: (context, index) {
            final reservation = reservations[index];
            // 해당하는 패키지 찾기
            final package = travelProvider.packages.firstWhere(
                  (p) => p.id == reservation.packageId,
              orElse: () => TravelPackage(
                id: reservation.packageId,
                title: reservation.packageTitle,
                description: '',
                price: reservation.price,
                region: '',
                guideName: reservation.guideName,
                guideId: reservation.guideId,
                maxParticipants: 0,
                nights: 1,                          // 기본값 1박
                departureDays: [1, 2, 3, 4, 5, 6, 7],  // 모든 요일 허용
              ),
            );

            return Card(
              clipBehavior: Clip.antiAlias, // 이미지가 카드 모서리를 벗어나지 않도록
              child: InkWell(
                onTap: () => _navigateToPackageDetail(reservation.packageId),
                child: Column(
                  children: [
                    // 썸네일 이미지
                    if (package.mainImage != null && package.mainImage!.isNotEmpty)
                      SizedBox(
                        height: 150,
                        width: double.infinity,
                        child: Image.network(
                          package.mainImage!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(
                                  Icons.error_outline,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    else
                      Container(
                        height: 150,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(
                            Icons.landscape,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    // 예약 정보
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  reservation.packageTitle,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: Colors.grey[600],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('가이드: ${reservation.guideName}'),
                          Text(
                            '예약일: ${DateFormat('yyyy년 MM월 dd일').format(reservation.reservationDate)}',
                          ),
                          Text(
                            '신청일: ${DateFormat('yyyy년 MM월 dd일').format(reservation.requestedAt)}',
                          ),
                          Text(
                            '가격: ₩${NumberFormat('#,###').format(reservation.price.toInt())}',
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: status == 'pending' ? Colors.orange.shade100 : Colors.green.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              status == 'pending' ? '승인 대기중' : '예약 확정',
                              style: TextStyle(
                                color: status == 'pending' ? Colors.orange.shade900 : Colors.green.shade900,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}