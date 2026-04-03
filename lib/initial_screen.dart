import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:theodolite_transit_case/providers/user_provider.dart';
import 'package:theodolite_transit_case/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

class InitialScreen extends ConsumerWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProv = ref.watch(userProvider);
    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          // Static layered soft shapes
          Positioned(
            top: -50.h,
            right: -50.w,
            child: Container(
              width: 300.w,
              height: 300.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kAccentSurface.withAlpha(150),
                boxShadow: const [BoxShadow(color: kAccentSurface, blurRadius: 100, spreadRadius: 20)],
              ),
            ),
          ),
          Positioned(
            bottom: -100.h,
            left: -100.w,
            child: Container(
              width: 400.w,
              height: 400.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kOutline.withAlpha(150),
                boxShadow: const [BoxShadow(color: kOutline, blurRadius: 100, spreadRadius: 20)],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 48.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sleek header logotype
                  Text('TTC.', style: GoogleFonts.outfit(fontSize: 48.sp, color: kPrimaryText, fontWeight: FontWeight.w800, height: 1.0, letterSpacing: -2.0)),

                  // Hero Typography block (Sentence case)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Theodolite\nTransit\nCase.',
                        style: GoogleFonts.outfit(
                          color: kPrimaryText,
                          fontSize: 56.sp,
                          fontWeight: FontWeight.w800,
                          height: 0.95,
                          letterSpacing: -1.5,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        'A digital archive of geodetic heritage and high-precision optical instruments.',
                        style: GoogleFonts.inter(
                          color: kSecondaryText,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),

                  // Modern Pill CTA
                  GestureDetector(
                    onTap: () {
                      userProv.setFirstTimeUser(false);
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    child: Container(
                      width: double.infinity,
                      height: 64.h,
                      decoration: BoxDecoration(
                        color: kAccent, // Rich Brass Accent
                        borderRadius: BorderRadius.circular(kRadiusPill),
                        boxShadow: [
                          BoxShadow(
                            color: kAccent.withAlpha(80),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                            spreadRadius: -5,
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Open ledger',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
