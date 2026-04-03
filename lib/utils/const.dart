import 'package:flutter/material.dart';
import 'package:theodolite_transit_case/enum/my_enums.dart';

// ─── COLOR PALETTE — "Brass, Glass & Filed Steel" ───────────────────────────────
const Color kBackground  = Color(0xFFF4F1EB); // Warm off-white
const Color kPrimaryText = Color(0xFF1C1A14); // Carbon ink, near-black
const Color kPanelBg     = Color(0xFFFDFBF6); // Clean white-cream
const Color kSecondaryText = Color(0xFF7A7264); // Worn label ink, warm grey
const Color kAccent      = Color(0xFFB07D3A); // Polished brass
const Color kOutline     = Color(0xFFE4DFD5); // Ivory rule line
const Color kError       = Color(0xFF8C3B2A); // Signal red lacquer

// ─── DERIVED COLORS ───────────────────────────────────────────────────────────
const Color kAccentLight = Color(0xFFC49A5A);
const Color kAccentSurface = Color(0xFFF2EADC);
const Color kGlassBackground = Color(0xB3FFFFFF); // 70% White for frosted glass
const Color kSuccess    = Color(0xFF4A6B5B);
const Color kWarning    = Color(0xFFB07D3A);

// ─── SPACING ─────────────────────────────────────────────────────────────────
const double kSpacingXXS  = 4.0;
const double kSpacingXS   = 8.0;
const double kSpacingS    = 12.0;
const double kSpacingM    = 16.0;
const double kSpacingL    = 20.0;
const double kSpacingXL   = 24.0;
const double kSpacingXXL  = 32.0;
const double kSpacingXXXL = 48.0;

// ─── BORDER RADIUS (2025 Standard) ──────────────────────────────────────────────
const double kRadiusZero     = 0.0;
const double kRadiusSubtle   = 16.0;
const double kRadiusStandard = 24.0;
const double kRadiusMedium   = 32.0;
const double kRadiusLarge    = 40.0;
const double kRadiusXLarge   = 48.0;
const double kRadiusPill     = 999.0;

// ─── SHADOWS ─────────────────────────────────────────────────────────────────
const BoxShadow kShadowSubtle = BoxShadow(
  offset: Offset(0, 10),
  blurRadius: 30,
  spreadRadius: -5,
  color: Color(0x15B07D3A), // Warm, diffuse brass-tinted shadow
);

const BoxShadow kShadowFloat = BoxShadow(
  offset: Offset(0, 20),
  blurRadius: 40,
  spreadRadius: -10,
  color: Color(0x20000000), // Deep, soft float shadow
);

const double kStrokeWeight        = 0.0; // Disabled globally for 2025 modern theme
const double kStrokeWeightMedium  = 0.0;

// ─── IDENTIFIER COLORS ─────────────────────────────────────────────────────────
Color getInstrumentTypeColor(InstrumentType type) {
  switch (type) {
    case InstrumentType.theodolite:
      return kAccent;
    case InstrumentType.transit:
      return const Color(0xFF4A6B5B);
    case InstrumentType.dumpyLevel:
      return const Color(0xFF7A5B4A);
    case InstrumentType.tiltingLevel:
      return const Color(0xFF3D6B6B);
    case InstrumentType.alidade:
      return const Color(0xFF6B4F7A);
    case InstrumentType.sextant:
      return const Color(0xFF4A5B7A);
    case InstrumentType.tachymeter:
      return const Color(0xFF7A6B4A);
    case InstrumentType.other:
      return kSecondaryText;
  }
}

// ─── CONDITION COLORS ─────────────────────────────────────────────────────────
Color getConditionColor(ConditionState state) {
  switch (state) {
    case ConditionState.museumDisplay:
      return kAccent;
    case ConditionState.functional:
      return kSuccess;
    case ConditionState.smooth:
      return kPrimaryText;
    case ConditionState.frozen:
      return kError;
    case ConditionState.unknown:
      return kSecondaryText;
  }
}
