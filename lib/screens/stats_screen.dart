import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:theodolite_transit_case/enum/my_enums.dart';
import 'package:theodolite_transit_case/models/project_model.dart';
import 'package:theodolite_transit_case/providers/project_provider.dart';
import 'package:theodolite_transit_case/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  int? _selectedDecade;

  bool _isInDecade(SurveyingInstrumentModel e, int decade) {
    if (e.eraOfProduction.length >= 4) {
      final year = int.tryParse(e.eraOfProduction.substring(0, 4));
      if (year != null) {
        return (year ~/ 10) * 10 == decade;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final projectProv = ref.watch(projectProvider);
    final allEntries = projectProv.entries;
    final displayEntries = _selectedDecade == null
        ? allEntries
        : allEntries.where((e) => _isInDecade(e, _selectedDecade!)).toList();

    if (projectProv.isLoading) {
      return Scaffold(
        backgroundColor: kBackground,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final hasGlobalOrigins = displayEntries.any(
      (e) => e.countryOfManufacture.trim().isNotEmpty,
    );
    final hasChronology = allEntries.any((e) {
      if (e.eraOfProduction.length >= 4) {
        return int.tryParse(e.eraOfProduction.substring(0, 4)) != null;
      }
      return false;
    });

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: Text(
          'Statistics',
          style: GoogleFonts.outfit(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 100.h),
          child: allEntries.isEmpty
              ? _buildEmptyState()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildArchiveStatusBanner(displayEntries),
                    SizedBox(height: 16.h),

                    if (hasGlobalOrigins) ...[
                      _sectionHeader('Global origins'),
                      _buildGlobalOrigins(displayEntries),
                      SizedBox(height: 16.h),
                    ],

                    if (hasChronology) ...[
                      _sectionHeader(
                        'Chronology multiplexer',
                        trailing: _selectedDecade != null
                            ? Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: kAccent,
                                  borderRadius: BorderRadius.circular(
                                    kRadiusPill,
                                  ),
                                ),
                                child: Text(
                                  'Focus: ${_selectedDecade}s',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      _buildHistogram(allEntries),
                      SizedBox(height: 16.h),
                    ],

                    if (displayEntries.isNotEmpty) ...[
                      _sectionHeader('Condition analysis'),
                      _buildConditionRadar(displayEntries),
                    ],
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 100.h),
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: const [kShadowSubtle],
            ),
            child: Icon(
              Icons.show_chart,
              color: kSecondaryText.withAlpha(150),
              size: 64.sp,
            ),
          ),
          SizedBox(height: 32.h),
          Text(
            'No analytics available',
            style: GoogleFonts.outfit(
              color: kPrimaryText,
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Inscribe instruments to generate technical readouts.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: kSecondaryText, fontSize: 14.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildArchiveStatusBanner(List<SurveyingInstrumentModel> entries) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final topMaker = () {
      final counts = <String, int>{};
      for (var e in entries) {
        if (e.manufacturer.trim().isNotEmpty) {
          counts[e.manufacturer] = (counts[e.manufacturer] ?? 0) + 1;
        }
      }
      if (counts.isEmpty) return 'Unknown Manufacturer';
      return counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    }();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: kAccent,
        borderRadius: BorderRadius.circular(kRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: kAccent.withAlpha(80),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                Icons.inventory_2_rounded,
                color: Colors.white.withAlpha(150),
                size: 32.sp,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(40),
                  borderRadius: BorderRadius.circular(kRadiusPill),
                ),
                child: Text(
                  'Archive Status',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entries.length}',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 56.sp,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                ),
              ),
              SizedBox(width: 8.w),
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Text(
                  entries.length == 1 ? 'Instrument' : 'Instruments',
                  style: GoogleFonts.inter(
                    color: Colors.white.withAlpha(200),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(20),
              borderRadius: BorderRadius.circular(kRadiusStandard),
            ),
            child: Row(
              children: [
                Icon(Icons.military_tech, color: Colors.white, size: 28.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dominant Manufacturer',
                        style: GoogleFonts.inter(
                          color: Colors.white.withAlpha(150),
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        topMaker,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, {Widget? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.outfit(
              color: kPrimaryText,
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (trailing != null) ...[SizedBox(width: 8.w), trailing],
      ],
    );
  }

  Widget _buildGlobalOrigins(List<SurveyingInstrumentModel> entries) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final Map<String, int> counts = {};
    for (var e in entries) {
      if (e.countryOfManufacture.trim().isNotEmpty) {
        counts[e.countryOfManufacture] =
            (counts[e.countryOfManufacture] ?? 0) + 1;
      }
    }
    if (counts.isEmpty) return const SizedBox.shrink();

    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxCount = counts.values.reduce(math.max);

    return Container(
      margin: EdgeInsets.only(top: 12.h),
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kRadiusStandard),
        boxShadow: const [kShadowFloat],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: sorted.take(5).map((e) {
          final factor = e.value / maxCount;

          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    e.key,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: kPrimaryText,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  flex: 5,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Container(
                            height: 12.h,
                            width: constraints.maxWidth,
                            decoration: BoxDecoration(
                              color: kBackground,
                              borderRadius: BorderRadius.circular(kRadiusPill),
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOutQuart,
                            height: 12.h,
                            width: constraints.maxWidth * factor,
                            decoration: BoxDecoration(
                              color: e.value == maxCount
                                  ? kAccent
                                  : kSecondaryText.withAlpha(100),
                              borderRadius: BorderRadius.circular(kRadiusPill),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(width: 16.w),
                SizedBox(
                  width: 32.w,
                  child: Text(
                    e.value.toString(),
                    style: GoogleFonts.outfit(
                      fontSize: 14.sp,
                      color: kSecondaryText,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHistogram(List<SurveyingInstrumentModel> entries) {
    final Map<int, int> decades = {};
    for (final e in entries) {
      if (e.eraOfProduction.length >= 4) {
        final year = int.tryParse(e.eraOfProduction.substring(0, 4));
        if (year != null) {
          final dec = (year ~/ 10) * 10;
          decades[dec] = (decades[dec] ?? 0) + 1;
        }
      }
    }
    if (decades.isEmpty) return const SizedBox.shrink();

    final maxCount = decades.values.reduce(math.max);
    final sortedDecades = decades.keys.toList()..sort();

    return Container(
      height: 200.h,
      margin: EdgeInsets.only(top: 12.h),
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kRadiusStandard),
        boxShadow: const [kShadowFloat],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: sortedDecades.map((dec) {
          final count = decades[dec]!;
          final heightFactor = count / maxCount;
          final isSelected = _selectedDecade == dec;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _selectedDecade = (_selectedDecade == dec) ? null : dec;
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  count.toString(),
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: isSelected ? kAccent : kPrimaryText,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutQuart,
                  width: 36.w,
                  height: 100.h * heightFactor,
                  decoration: BoxDecoration(
                    color: isSelected ? kAccent : kBackground,
                    borderRadius: BorderRadius.circular(kRadiusPill),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: kAccent.withAlpha(100),
                              blurRadius: 20,
                              offset: const Offset(0, 5),
                            ),
                          ]
                        : null,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  '${dec}s',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: isSelected ? kAccent : kSecondaryText,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildConditionRadar(List<SurveyingInstrumentModel> entries) {
    if (entries.isEmpty) return const SizedBox.shrink();
    final Map<ConditionState, int> counts = {};
    for (final e in entries)
      counts[e.conditionState] = (counts[e.conditionState] ?? 0) + 1;

    return Container(
      margin: EdgeInsets.only(top: 12.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kRadiusStandard),
        boxShadow: const [kShadowFloat],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 140.w,
            height: 140.w,
            child: CustomPaint(
              painter: SoftActivityRingsPainter(
                counts: counts,
                total: entries.length,
              ),
            ),
          ),
          SizedBox(width: 32.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: ConditionState.values
                  .where((s) => (counts[s] ?? 0) > 0)
                  .map((state) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: Row(
                        children: [
                          Container(
                            width: 12.w,
                            height: 12.w,
                            decoration: BoxDecoration(
                              color: getConditionColor(state),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              state.label,
                              style: GoogleFonts.inter(
                                color: kPrimaryText,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${((counts[state]! / entries.length) * 100).toInt()}%',
                            style: GoogleFonts.outfit(
                              color: kSecondaryText,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  })
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class SoftActivityRingsPainter extends CustomPainter {
  final Map<ConditionState, int> counts;
  final int total;

  SoftActivityRingsPainter({required this.counts, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    double currentRadius = size.width / 2;

    for (var state in ConditionState.values) {
      final count = counts[state] ?? 0;
      if (count == 0) continue;

      final ratio = count / total;
      final color = getConditionColor(state);

      // Background track
      final trackPaint = Paint()
        ..color = kBackground
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 14.0;
      canvas.drawCircle(center, currentRadius, trackPaint);

      // Foreground arc
      if (ratio > 0) {
        final arcPaint = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 14.0;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: currentRadius),
          -math.pi / 2,
          ratio * 2 * math.pi,
          false,
          arcPaint,
        );
      }
      currentRadius -= 20.0;
    }
  }

  @override
  bool shouldRepaint(covariant SoftActivityRingsPainter oldDelegate) => true;
}
