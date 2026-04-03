import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:theodolite_transit_case/screens/home_screen.dart';
import 'package:theodolite_transit_case/screens/stats_screen.dart';
import 'package:theodolite_transit_case/screens/showcase_screen.dart';
import 'package:theodolite_transit_case/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animController;

  final List<Widget> _screens = const [
    HomeScreen(),
    StatsScreen(),
    ShowcaseScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _setIndex(int i) {
    if (i == _currentIndex) return;
    setState(() => _currentIndex = i);
    _animController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      extendBody: true,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildTallyNav(),
          ),
        ],
      ),
    );
  }

  Widget _buildTallyNav() {
    return Container(
      height: 64.h,
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 16.h, left: 32.w, right: 32.w),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusPill),
        boxShadow: const [kShadowFloat],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildTallyItem(0, Icons.menu_book, 'Ledger'),
          _buildTallyItem(1, Icons.bar_chart, 'Statistics'),
          _buildTallyItem(2, Icons.bubble_chart, 'Ecosystem'),
        ],
      ),
    );
  }

  Widget _buildTallyItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _setIndex(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: isSelected ? 32.w : 0,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 4.h),
              decoration: BoxDecoration(
                color: kAccent,
                borderRadius: BorderRadius.circular(kRadiusPill),
              ),
            ),
            Icon(
              icon,
              color: isSelected ? kPrimaryText : kSecondaryText.withAlpha(150),
              size: 22.sp,
            ),
            SizedBox(height: 2.h),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: GoogleFonts.inter(
                color: isSelected ? kPrimaryText : kSecondaryText,
                fontSize: 10.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: 0.2,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
