import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:travel_on_final/features/auth/presentation/providers/auth_provider.dart';
import 'package:travel_on_final/features/reservation/presentation/providers/reservation_provider.dart';
import 'package:travel_on_final/features/search/domain/entities/travel_package.dart';

class ReservationCalendarScreen extends StatefulWidget {
  final TravelPackage package;

  const ReservationCalendarScreen({
    Key? key,
    required this.package,
  }) : super(key: key);

  @override
  State<ReservationCalendarScreen> createState() => _ReservationCalendarScreenState();
}

class _ReservationCalendarScreenState extends State<ReservationCalendarScreen> {
  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('예약하기'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: const CalendarStyle(
              // 선택된 날짜 스타일
              selectedDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              // 오늘 날짜 하이라이트 제거
              todayDecoration: BoxDecoration(
                color: Colors.transparent,  // 배경색 투명하게
                shape: BoxShape.circle,
              ),
              // 오늘 날짜 텍스트 스타일
              todayTextStyle: TextStyle(
                color: Colors.black,  // 일반 텍스트와 같은 색상
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (_selectedDay != null) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '선택한 날짜: ${_selectedDay!.year}년 ${_selectedDay!.month}월 ${_selectedDay!.day}일',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '패키지: ${widget.package.title}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    '가격: ₩${NumberFormat('#,###').format(widget.package.price.toInt())}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () => _requestReservation(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  '예약 신청하기',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _requestReservation(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final reservationProvider = context.read<ReservationProvider>();

    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      context.push('/login');
      return;
    }

    try {
      await reservationProvider.createReservation(
        packageId: widget.package.id,
        packageTitle: widget.package.title,
        customerId: authProvider.currentUser!.id,
        customerName: authProvider.currentUser!.name,
        guideName: widget.package.guideName,
        guideId: widget.package.guideId,
        reservationDate: _selectedDay!,
        price: widget.package.price,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('예약이 신청되었습니다.')),
      );
      context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('예약 신청 중 오류가 발생했습니다: $e')),
      );
    }
  }
}