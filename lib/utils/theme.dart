import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:theodolite_transit_case/utils/const.dart';

final appTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: kAccent,
  scaffoldBackgroundColor: kBackground,
  colorScheme: const ColorScheme.light(
    primary: kAccent,
    secondary: kSecondaryText,
    surface: kPanelBg,
    onSurface: kPrimaryText,
    onPrimary: kPanelBg,
    error: kError,
    outline: kOutline,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    titleTextStyle: GoogleFonts.outfit(
      fontSize: 24.sp,
      fontWeight: FontWeight.w700,
      color: kPrimaryText,
    ),
    iconTheme: const IconThemeData(color: kPrimaryText),
  ),
  textTheme: TextTheme(
    displayLarge: GoogleFonts.outfit(
      fontSize: 40.sp,
      fontWeight: FontWeight.w800,
      color: kPrimaryText,
    ),
    displayMedium: GoogleFonts.outfit(
      fontSize: 32.sp,
      fontWeight: FontWeight.w800,
      color: kPrimaryText,
    ),
    displaySmall: GoogleFonts.outfit(
      fontSize: 28.sp,
      fontWeight: FontWeight.w700,
      color: kPrimaryText,
    ),
    headlineLarge: GoogleFonts.outfit(
      fontSize: 24.sp,
      fontWeight: FontWeight.w700,
      color: kPrimaryText,
    ),
    headlineMedium: GoogleFonts.outfit(
      fontSize: 20.sp,
      fontWeight: FontWeight.w600,
      color: kPrimaryText,
    ),
    headlineSmall: GoogleFonts.outfit(
      fontSize: 18.sp,
      fontWeight: FontWeight.w600,
      color: kPrimaryText,
    ),
    titleLarge: GoogleFonts.inter(
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      color: kPrimaryText,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 14.sp,
      fontWeight: FontWeight.w500,
      color: kPrimaryText,
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: 13.sp,
      fontWeight: FontWeight.w500,
      color: kSecondaryText,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 15.sp,
      fontWeight: FontWeight.w400,
      color: kPrimaryText,
      height: 1.5,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: kPrimaryText,
      height: 1.5,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
      color: kSecondaryText,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: 13.sp,
      fontWeight: FontWeight.w600,
      color: kPrimaryText,
      letterSpacing: 0.5,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 12.sp,
      fontWeight: FontWeight.w500,
      color: kSecondaryText,
      letterSpacing: 0.5,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 11.sp,
      fontWeight: FontWeight.w500,
      color: kSecondaryText,
      letterSpacing: 0.5,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white.withAlpha(200),
    contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(kRadiusStandard)),
      borderSide: BorderSide.none,
    ),
    enabledBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(kRadiusStandard)),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(kRadiusStandard)),
      borderSide: BorderSide(color: kAccent.withAlpha(100), width: 2),
    ),
    hintStyle: GoogleFonts.inter(
      color: kSecondaryText,
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
    ),
    labelStyle: GoogleFonts.inter(
      color: kSecondaryText,
      fontSize: 14.sp,
      fontWeight: FontWeight.w500,
    ),
    floatingLabelStyle: GoogleFonts.inter(
      color: kPrimaryText,
      fontSize: 14.sp,
      fontWeight: FontWeight.w600,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kPanelBg,
      foregroundColor: kPrimaryText,
      elevation: 0,
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 32.w),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(kRadiusPill)),
      ),
      textStyle: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 14.sp,
        letterSpacing: 0.5,
      ),
    ),
  ),
  cardTheme: const CardThemeData(
    color: kPanelBg,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(kRadiusStandard)),
    ),
    margin: EdgeInsets.zero,
  ),
  dividerTheme: const DividerThemeData(
    color: kOutline,
    thickness: 1.0,
    space: 0,
  ),
  useMaterial3: true,
);
