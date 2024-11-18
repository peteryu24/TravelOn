import 'package:easy_localization/easy_localization.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReservations();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReservations() async {
    try {
      final userId = context.read<AuthProvider>().currentUser!.id;
      await context.read<ReservationProvider>().loadReservations(userId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading reservations: $e')),
      );
    }
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
        orElse: () => throw Exception('reservations.package_not_found'.tr()),
      );

      if (!mounted) return;
      context.push('/package-detail/${package.id}', extra: package);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('reservations.package_load_error'.tr(args: [e.toString()]))),
      );
    }
  }

  Widget _buildReservationList(ReservationProvider provider, String status) {
    final reservations = provider.reservations
        .where((res) => res.status == status)
        .toList();

    if (reservations.isEmpty) {
      return Center(
        child: Text(
            status == 'pending'
                ? 'reservations.no_pending_reservations'.tr()
                : 'reservations.no_confirmed_reservations'.tr()
        ),
      );
    }

    return Consumer<TravelProvider>(
      builder: (context, travelProvider, child) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reservations.length,
          itemBuilder: (context, index) {
            final reservation = reservations[index];

            return Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _navigateToPackageDetail(reservation.packageId),
                child: Column(
                  children: [
                    // Thumbnail image handling
                    _buildPackageImage(reservation, travelProvider),
                    // Reservation information
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPackageTitle(reservation),
                          const SizedBox(height: 8),
                          _buildReservationDetails(reservation, status),
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

  Widget _buildPackageImage(dynamic reservation, TravelProvider travelProvider) {
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
        nights: 1,
        departureDays: [1, 2, 3, 4, 5, 6, 7],
        minParticipants: 1,
        totalDays: 1,
      ),
    );

    if (package.mainImage != null && package.mainImage!.isNotEmpty) {
      return SizedBox(
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
      );
    }

    return Container(
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
    );
  }

  Widget _buildPackageTitle(dynamic reservation) {
    return Row(
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
    );
  }



  Widget _buildReservationDetails(dynamic reservation, String status) {
    final languageCode = context.locale.languageCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${LocalizedStrings.getLocalizedText(languageCode, LocalizedStrings.guide)}'
              '${reservation.guideName}',
        ),
        Text(
          '${LocalizedStrings.getLocalizedText(languageCode, LocalizedStrings.reservationDate)}'
              '${DateFormat('yyyy年 MM月 dd日').format(reservation.reservationDate)}',
        ),
        Text(
          '${LocalizedStrings.getLocalizedText(languageCode, LocalizedStrings.requestDate)}'
              '${DateFormat('yyyy年 MM月 dd日').format(reservation.requestedAt)}',
        ),
        Text(
          '${LocalizedStrings.getLocalizedText(languageCode, LocalizedStrings.price)}'
              '${NumberFormat('#,###').format(reservation.price.toInt())}',
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: status == 'pending' ? Colors.orange.shade100 : Colors.green.shade100,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            status == 'pending'
                ? LocalizedStrings.getLocalizedText(languageCode, LocalizedStrings.pendingApproval)
                : LocalizedStrings.getLocalizedText(languageCode, LocalizedStrings.confirmed),
            style: TextStyle(
              color: status == 'pending' ? Colors.orange.shade900 : Colors.green.shade900,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    final languageCode = context.locale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizedStrings.getLocalizedText(
            languageCode, LocalizedStrings.myReservations)),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: LocalizedStrings.getLocalizedText(
                languageCode, LocalizedStrings.pendingReservations)),
            Tab(text: LocalizedStrings.getLocalizedText(
                languageCode, LocalizedStrings.confirmedReservations)),
          ],
        ),
      ),
      body: Consumer<ReservationProvider>(
        builder: (context, provider, child) {
          if (provider.reservations.isEmpty) {
            return Center(
              child: Text(LocalizedStrings.getLocalizedText(
                  languageCode, LocalizedStrings.noReservations)),
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
}

class LocalizedStrings {
  static String getLocalizedText(String languageCode, Map<String, String> texts) {
    switch (languageCode) {
      case 'ko':
        return texts['ko'] ?? texts['en']!; // 한국어가 없으면 영어 사용
      case 'ja':
        return texts['ja'] ?? texts['en']!;
      case 'zh':
        return texts['zh'] ?? texts['en']!;
      default:
        return texts['en']!;
    }
  }

  static final guide = {
    'ko': '가이드: ',
    'en': 'Guide: ',
    'ja': 'ガイド: ',
    'zh': '导游: ',
  };

  static final reservationDate = {
    'ko': '예약일: ',
    'en': 'Reservation Date: ',
    'ja': '予約日: ',
    'zh': '预约日期: ',
  };

  static final requestDate = {
    'ko': '신청일: ',
    'en': 'Request Date: ',
    'ja': '申込日: ',
    'zh': '申请日期: ',
  };

  static final price = {
    'ko': '가격: ￦',
    'en': 'Price: ￦',
    'ja': '料金: ￥',
    'zh': '价格: ¥',
  };

  static final pendingApproval = {
    'ko': '승인 대기중',
    'en': 'Pending Approval',
    'ja': '承認待ち',
    'zh': '等待确认',
  };

  static final confirmed = {
    'ko': '예약 확정',
    'en': 'Confirmed',
    'ja': '予約確定',
    'zh': '已确认',
  };

  static final myReservations = {
    'ko': '내 예약 내역',
    'en': 'My Reservations',
    'ja': '予約一覧',
    'zh': '我的预约',
  };

  static final pendingReservations = {
    'ko': '대기중인 예약',
    'en': 'Pending Reservations',
    'ja': '承認待ち予約',
    'zh': '待确认预约',
  };

  static final confirmedReservations = {
    'ko': '확정된 예약',
    'en': 'Confirmed Reservations',
    'ja': '確定済み予約',
    'zh': '已确认预约',
  };

  static final noReservations = {
    'ko': '예약 내역이 없습니다.',
    'en': 'No reservations found.',
    'ja': '予約がありません',
    'zh': '暂无预约',
  };
}