import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:travel_on_final/features/auth/data/models/user_model.dart';
import 'package:travel_on_final/features/auth/presentation/providers/auth_provider.dart';
import 'package:travel_on_final/features/review/domain/entities/review.dart';
import 'package:travel_on_final/features/review/presentation/provider/review_provider.dart';
import 'package:travel_on_final/features/search/presentation/providers/travel_provider.dart';
import 'package:travel_on_final/features/chat/domain/usecases/create_chat_id.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({required this.userId, Key? key}) : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Future<UserModel?>? userFuture;
  bool showName = true;
  bool showEditOptions = false;

  @override
  void initState() {
    super.initState();
    userFuture = context.read<AuthProvider>().getUserById(widget.userId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewProvider>().loadReviewsForUser(widget.userId);
    });
  }

  Future<void> _pickBackgroundImage(UserModel user, AuthProvider authProvider) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      await authProvider.updateUserProfile(
        name: user.name,
        profileImageUrl: user.profileImageUrl,
        introduction: user.introduction,
        backgroundImageUrl: pickedFile.path,
      );

      setState(() {
        userFuture = authProvider.getUserById(widget.userId);
      });
    }
  }

  Future<void> _removeBackgroundImage(UserModel user, AuthProvider authProvider) async {
    try {
      await authProvider.updateUserProfile(
        name: user.name,
        gender: user.gender,
        birthDate: user.birthDate,
        profileImageUrl: user.profileImageUrl,
        backgroundImageUrl: null,
        introduction: user.introduction,
      );

      setState(() {
        userFuture = authProvider.getUserById(widget.userId);
      });
    } catch (e) {
      print('배경 이미지 제거 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('배경 이미지 제거에 실패했습니다. 다시 시도해주세요.')),
      );
    }
  }

  void _showRemoveBackgroundDialog(UserModel user, AuthProvider authProvider) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("배경 이미지 제거"),
          content: Text("배경 이미지를 제거하시겠습니까?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("아니오"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text("예"),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _removeBackgroundImage(user, authProvider);
    }
  }

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("배경 이미지 변경"),
          content: Text("배경 이미지를 바꾸시겠습니까?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("취소"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text("확인"),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final reviewProvider = context.watch<ReviewProvider>();
    final travelProvider = context.watch<TravelProvider>();

    final isCurrentUser = authProvider.currentUser?.id == widget.userId;

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<UserModel?>(
          future: userFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              return RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "${snapshot.data!.name} ",
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    TextSpan(
                      text: "님의 프로필",
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              );
            }
            else {
              return Text("프로필");
            }
          },
        ),
      ),
      body: FutureBuilder<UserModel?>(
        future: userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("오류가 발생했습니다."));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text("사용자 정보를 찾을 수 없습니다."));
          }

          final user = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 330.h,
                      decoration: BoxDecoration(
                        color: user.backgroundImageUrl == null || user.backgroundImageUrl!.isEmpty
                            ? Colors.lightBlue.shade100
                            : null,
                        image: user.backgroundImageUrl != null && user.backgroundImageUrl!.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(user.backgroundImageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: user.backgroundImageUrl != null && user.backgroundImageUrl!.isNotEmpty
                          ? Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                              ),
                            )
                          : null,
                    ),
                    if (user.isGuide)
                      Positioned(
                        top: 20.h,
                        left: 20.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            '가이드',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 30.h,
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 70.r,
                            backgroundImage: user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty
                                ? NetworkImage(user.profileImageUrl!)
                                : AssetImage('assets/images/default_profile.png') as ImageProvider,
                          ),
                          SizedBox(height: 10.h),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                showName = !showName;
                              });
                            },
                            child: Row(
                              children: [
                                AnimatedSwitcher(
                                  duration: Duration(milliseconds: 300),
                                  child: Container(
                                    key: ValueKey<bool>(showName),
                                    padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: SizedBox(
                                      height: 30.h,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          showName ? user.name : user.email,
                                          style: TextStyle(
                                            fontSize: showName ? 20.sp : 12.sp,
                                            fontWeight: showName ? FontWeight.bold : FontWeight.normal,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 5.h),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              user.introduction ?? '반갑습니다.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.white,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: 10.h),
                        ],
                      ),
                    ),
                    if (isCurrentUser)
                      Positioned(
                        top: 20.h,
                        right: 20.w,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              width: 35.w,
                              height: 35.h,
                              margin: EdgeInsets.only(bottom: 5.h),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Icon(showEditOptions ? Icons.close : Icons.list, color: Colors.white),
                                onPressed: () {
                                  setState(() {
                                    showEditOptions = !showEditOptions;
                                  });
                                },
                              ),
                            ),
                            if (showEditOptions) ...[
                              Container(
                                width: 35.w,
                                height: 35.h,
                                margin: EdgeInsets.only(bottom: 5.h),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.edit_note, color: Colors.white),
                                  onPressed: () {
                                    context.push('/profile/edit');
                                  },
                                ),
                              ),
                              Container(
                                width: 35.w,
                                height: 35.h,
                                margin: EdgeInsets.only(bottom: 5.h),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.edit, color: Colors.white),
                                  onPressed: () async {
                                    final shouldChange = await _showConfirmationDialog(context);
                                    if (shouldChange) {
                                      _pickBackgroundImage(user, authProvider);
                                    }
                                  },
                                ),
                              ),
                              Container(
                                width: 35.w,
                                height: 35.h,
                                margin: EdgeInsets.only(bottom: 5.h),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.white),
                                  onPressed: () => _showRemoveBackgroundDialog(user, authProvider),
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    else
                      Positioned(
                        top: 20.h,
                        right: 20.w,
                        child: Container(
                          width: 35.w,
                          height: 35.h,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(Icons.chat_bubble, color: Colors.white),
                            onPressed: () {
                              final currentUserId = authProvider.currentUser?.id;
                              if (currentUserId != null) {
                                final chatId = CreateChatId().call(currentUserId, user.id);
                                context.push('/chat/$chatId');
                              }
                            },
                          ),
                        ),
                      ),
                  ],
                ),
                Divider(),
                if (user.isGuide) ...[
                  FutureBuilder<Map<String, dynamic>>(
                    future: context.read<TravelProvider>().getGuideReviewStats(user.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text("리뷰 정보를 불러오는 중 오류 발생");
                      } else if (!snapshot.hasData) {
                        return Text("리뷰 데이터가 없습니다.");
                      } else {
                        final reviewStats = snapshot.data!;
                        final totalReviews = reviewStats['totalReviews'] as int;
                        final averageRating = reviewStats['averageRating'] as double;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "평균 별점 ${averageRating.toStringAsFixed(1)}점",
                              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              "리뷰 $totalReviews개",
                              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                if (index < averageRating.floor()) {
                                  return Icon(Icons.star, color: Colors.amber, size: 24.w);
                                } else if (index < averageRating) {
                                  return Icon(Icons.star_half, color: Colors.amber, size: 24.w);
                                } else {
                                  return Icon(Icons.star_border, color: Colors.grey, size: 24.w);
                                }
                              }),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "가이드 패키지",
                        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          context.push('/user-packages/${user.id}');
                        },
                        child: Text("더보기"),
                      ),
                    ],
                  ),
                  GridView.builder(
                    itemCount: travelProvider.packages
                        .where((package) => package.guideId == user.id)
                        .take(6)
                        .length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    itemBuilder: (context, index) {
                      final guidePackages = travelProvider.packages
                          .where((package) => package.guideId == user.id)
                          .toList();
                      final package = guidePackages[index];
                      final formattedPrice = NumberFormat('#,###').format(package.price.toInt());
                      return Card(
                        child: Column(
                          children: [
                            package.mainImage != null
                              ? Image.network(
                                  package.mainImage!,
                                  width: 130.w,
                                  height: 130.h,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  'assets/images/default_image.png',
                                  width: 130.w,
                                  height: 130.h,
                                  fit: BoxFit.cover,
                                ),
                            Text(
                              package.title,
                              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '₩${formattedPrice}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ]
                else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "최근에 작성한 리뷰",
                        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          context.push('/user-reviews/${user.id}');
                        },
                        child: Text("더보기"),
                      ),
                    ],
                  ),
                  Selector<ReviewProvider, List<Review>>(
                    selector: (_, provider) => provider.userReviews.take(5).toList(),
                    builder: (context, userReviews, child) {
                      if (userReviews.isEmpty) {
                        return Center(child: Text("작성한 리뷰가 없습니다."));
                      }

                      return ListView.builder(
                        itemCount: userReviews.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final review = userReviews[index];
                          final package = context.read<TravelProvider>().packages.firstWhere(
                                (pkg) => pkg.id == review.packageId,
                                orElse: () => null as dynamic,
                              );

                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
                            elevation: 3,
                            child: Padding(
                              padding: EdgeInsets.all(12.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (package != null) ...[
                                    Text(
                                      "패키지: ${package.title}",
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                    SizedBox(height: 6.h),
                                  ],
                                  Text(
                                    review.content,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 8.h),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "평점: ${review.rating} / 5",
                                        style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                                      ),
                                      Text(
                                        "작성일: ${DateFormat('yyyy.MM.dd').format(review.createdAt)}",
                                        style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
