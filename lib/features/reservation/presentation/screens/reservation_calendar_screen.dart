import 'package:cloud_firestore/cloud_firestore.dart';
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
  Map<String, bool> _availabilityCache = {};  // 날짜 문자열을 키로 사용
  bool _isLoading = false;
  bool _isDepartureDay(DateTime date) {
    // 1: 월요일 ~ 7: 일요일로 변환 (DateTime.weekday는 1: 월요일 ~ 7: 일요일)
    return widget.package.departureDays.contains(date.weekday);
  }
  bool _isValidDepartureDay(DateTime date) {
    return widget.package.departureDays.contains(date.weekday);
  }
  late int _selectedParticipants;  // 선택된 인원 수



  String _getDateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _preloadAvailability() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final start = DateTime(_focusedDay.year, _focusedDay.month, 1);
      final end = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

      // 해당 월의 승인된 예약 모두 가져오기
      final snapshot = await FirebaseFirestore.instance
          .collection('reservations')
          .where('packageId', isEqualTo: widget.package.id)
          .where('status', isEqualTo: 'approved')
          .get();

      final approvedDates = snapshot.docs.map((doc) =>
          (doc.data()['reservationDate'] as Timestamp).toDate()
      ).toList();

      if (mounted) {
        setState(() {
          for (var date = start;
          date.isBefore(end.add(const Duration(days: 1)));
          date = date.add(const Duration(days: 1))) {
            if (!date.isBefore(now)) {
              final dateKey = _getDateKey(date);
              // 해당 날짜에 승인된 예약이 있는지 확인
              final hasApprovedReservation = approvedDates.any((approvedDate) =>
              approvedDate.year == date.year &&
                  approvedDate.month == date.month &&
                  approvedDate.day == date.day
              );
              _availabilityCache[dateKey] = !hasApprovedReservation;
            }
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error preloading availability: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _checkDateAvailability(DateTime date) async {
    if (date.isBefore(DateTime.now())) return false;

    // 출발 가능 요일인지 먼저 확인
    if (!_isValidDepartureDay(date)) return false;

    // 예약 여부 확인 (승인된 예약이 있는지)
    final snapshot = await FirebaseFirestore.instance
        .collection('reservations')
        .where('packageId', isEqualTo: widget.package.id)
        .where('status', isEqualTo: 'approved')
        .where('reservationDate', isEqualTo: Timestamp.fromDate(
      DateTime(date.year, date.month, date.day),
    ))
        .get();

    // 승인된 예약이 있으면 false 반환
    if (snapshot.docs.isNotEmpty) {
      return false;
    }

    final dateKey = _getDateKey(date);
    if (_availabilityCache.containsKey(dateKey)) {
      return _availabilityCache[dateKey]!;
    }

    final provider = context.read<ReservationProvider>();
    final isAvailable = await provider.isDateAvailable(widget.package.id, date);

    if (mounted) {
      setState(() {
        _availabilityCache[dateKey] = isAvailable;
      });
    }

    return isAvailable;
  }


  Future<int> _getDateParticipants(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final snapshot = await FirebaseFirestore.instance
        .collection('reservations')
        .where('packageId', isEqualTo: widget.package.id)
        .where('status', isEqualTo: 'approved')
        .where('reservationDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('reservationDate', isLessThan: Timestamp.fromDate(end))
        .get();

    return snapshot.docs.length;
  }

  Widget _buildCalendarDay(DateTime date) {
    if (date.isBefore(DateTime.now())) {
      return _buildDayContainer(date, isDisabled: true);
    }

    final dateKey = _getDateKey(date);
    final isAvailable = _availabilityCache[dateKey] ?? true;
    final isSelected = _selectedDay != null && isSameDay(_selectedDay!, date);
    final isToday = isSameDay(date, DateTime.now());
    final isDepartureDay = _isValidDepartureDay(date);

    return _buildDayContainer(
      date,
      isSelected: isSelected,
      isAvailable: isAvailable && isDepartureDay,
      isToday: isToday,
      isDepartureDay: isDepartureDay,
    );
  }

  Widget _buildDayContainer(
      DateTime date, {
        bool isSelected = false,
        bool isAvailable = true,
        bool isToday = false,
        bool isDisabled = false,
        bool isDepartureDay = false,
      }) {
    final isEnabled = isAvailable && isDepartureDay && !isDisabled;

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.blue
            : !isEnabled
            ? Colors.grey.shade200
            : isDepartureDay
            ? Colors.blue.shade50  // 출발 가능 요일 강조
            : null,
        shape: BoxShape.circle,
        border: isToday ? Border.all(color: Colors.blue, width: 1) : null,
      ),
      child: Center(
        child: Text(
          '${date.day}',
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : !isEnabled
                ? Colors.grey
                : isToday
                ? Colors.blue
                : isDepartureDay
                ? Colors.blue.shade900  // 출발 가능 요일 텍스트 색상
                : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('예약 날짜 선택'),
      ),
      body: Column(
        children: [
          if (_isLoading)
            const LinearProgressIndicator(),
          TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            enabledDayPredicate: (day) {
              // 과거 날짜 제외
              if (day.isBefore(DateTime.now())) return false;

              // 출발 가능 요일이 아닌 경우 제외
              if (!_isValidDepartureDay(day)) {
                return false;
              }

              // 예약 가능 여부 확인
              final dateKey = _getDateKey(day);
              return _availabilityCache[dateKey] ?? true;
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (selectedDay.isBefore(DateTime.now())) return;

              // 출발 가능 요일인지 확인
              if (!widget.package.departureDays.contains(selectedDay.weekday)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('선택할 수 없는 출발일입니다')),
                );
                return;
              }

              // 예약 가능 여부 확인
              final dateKey = _getDateKey(selectedDay);
              final isAvailable = _availabilityCache[dateKey] ?? true;

              if (isAvailable) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('선택한 날짜는 예약이 마감되었습니다')),
                  );
                }
              }
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
                _availabilityCache.clear(); // 페이지 변경 시 캐시 초기화
              });
              _preloadAvailability();
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, date, _) {
                bool isDepartureDay = widget.package.departureDays.contains(date.weekday);
                return Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDepartureDay ? Colors.blue.shade50 : Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        color: isDepartureDay && !date.isBefore(DateTime.now())
                            ? Colors.black
                            : Colors.grey,
                      ),
                    ),
                  ),
                );
              },
              selectedBuilder: (context, date, _) {
                return Container(
                  margin: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
              disabledBuilder: (context, date, _) {
                return Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              },
              outsideBuilder: (context, date, _) {
                return Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              },
            ),
            calendarStyle: CalendarStyle(
              // 선택된 날짜 스타일
              selectedDecoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: const TextStyle(color: Colors.white),

              // 오늘 날짜 스타일
              todayDecoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                shape: BoxShape.circle,
              ),
              todayTextStyle: const TextStyle(color: Colors.blue),

              // 비활성화된 날짜 스타일
              disabledTextStyle: const TextStyle(color: Colors.grey),

              // 기본 스타일
              defaultDecoration: const BoxDecoration(shape: BoxShape.circle),
              weekendDecoration: const BoxDecoration(shape: BoxShape.circle),
              outsideDecoration: const BoxDecoration(shape: BoxShape.circle),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          if (_selectedDay != null) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '선택한 날짜: ${DateFormat('yyyy년 MM월 dd일').format(_selectedDay!)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '패키지: ${widget.package.title}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.package.nights}박${widget.package.nights + 1}일',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('출발 요일: ', style: TextStyle(fontSize: 16)),
                      Expanded(
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: widget.package.departureDays.map((day) {
                            final weekday = ['월', '화', '수', '목', '금', '토', '일'][day - 1];
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Text(
                                weekday,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue.shade900,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '가격: ₩${NumberFormat('#,###').format(widget.package.price.toInt())}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  // 여기에 인원 선택 위젯 추가
                  _buildParticipantSelector(),

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
        const SnackBar(content: Text('로그인이 필요합니다')),
      );
      context.push('/login');
      return;
    }

    // 인원 수 유효성 검사
    if (_selectedParticipants < widget.package.minParticipants ||
        _selectedParticipants > widget.package.maxParticipants) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('올바른 인원을 선택해주세요')),
      );
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
        participants: _selectedParticipants,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('예약이 신청되었습니다')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('예약 신청 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }
  Widget _buildParticipantSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '인원 선택',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 여기를 수정
              Text('${widget.package.minParticipants}명 ~ ${widget.package.maxParticipants}명'),
              Row(
                children: [
                  IconButton(
                    onPressed: _selectedParticipants > widget.package.minParticipants  // 최소 인원으로 수정
                        ? () {
                      setState(() {
                        _selectedParticipants--;
                      });
                    }
                        : null,
                    icon: Icon(
                      Icons.remove_circle_outline,
                      color: _selectedParticipants > widget.package.minParticipants
                          ? Colors.blue
                          : Colors.grey,
                    ),
                  ),
                  Text(
                    '$_selectedParticipants명',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: _selectedParticipants < widget.package.maxParticipants
                        ? () {
                      setState(() {
                        _selectedParticipants++;
                      });
                    }
                        : null,
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: _selectedParticipants < widget.package.maxParticipants
                          ? Colors.blue
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  @override
  void initState() {
    super.initState();
    _selectedParticipants = widget.package.minParticipants;
    _preloadAvailability();
  }
}