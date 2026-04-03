import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:theodolite_transit_case/enum/my_enums.dart';
import 'package:theodolite_transit_case/models/project_model.dart';
import 'package:theodolite_transit_case/providers/image_provider.dart';
import 'package:theodolite_transit_case/providers/project_provider.dart';
import 'package:theodolite_transit_case/utils/const.dart';

class PhysicsOrb {
  final InstrumentType type;
  final int count;
  final List<SurveyingInstrumentModel> items;

  double x, y;
  double dx, dy;
  double radius;
  bool isGrabbed = false;

  PhysicsOrb({
    required this.type,
    required this.count,
    required this.items,
    required this.x,
    required this.y,
    required double baseRadius,
  }) : dx = (math.Random().nextDouble() - 0.5) * 4,
       dy = (math.Random().nextDouble() - 0.5) * 4,
       radius = baseRadius;
}

class ShowcaseScreen extends ConsumerStatefulWidget {
  const ShowcaseScreen({super.key});

  @override
  ConsumerState<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends ConsumerState<ShowcaseScreen>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  List<PhysicsOrb> _orbs = [];
  bool _isInitialized = false;
  int _lastEntriesHash = -1;

  PhysicsOrb? _focusedOrb;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  int _computeHash(List<SurveyingInstrumentModel> entries) {
    int hash = entries.length;
    for (var e in entries) {
      // Extensive hash to reliably detect deep field changes in the database
      hash ^=
          e.instrumentType.hashCode ^
          e.geodeticIdentifier.hashCode ^
          e.eraOfProduction.hashCode ^
          e.manufacturer.hashCode ^
          e.photoPath.hashCode ^
          e.conditionState.hashCode;
    }
    return hash;
  }

  void _initializeOrbs(
    List<SurveyingInstrumentModel> entries,
    Size screenSize,
  ) {
    if (screenSize.width == 0 || entries.isEmpty) return;

    final currentHash = _computeHash(entries);
    if (_isInitialized && _lastEntriesHash == currentHash) return;

    _isInitialized = true;
    _lastEntriesHash = currentHash;

    final counts = <InstrumentType, int>{};
    for (var e in entries) {
      counts[e.instrumentType] = (counts[e.instrumentType] ?? 0) + 1;
    }

    if (counts.isEmpty) return;

    final maxCount = counts.values.reduce(math.max);
    final random = math.Random();

    // Preserve previously grabbed orb if we are just reloading data
    final prevFocus = _focusedOrb?.type;

    _orbs = counts.keys.map((type) {
      final count = counts[type]!;
      final factor = (count / maxCount).clamp(0.4, 1.0);
      final radius = 60.w * factor;

      return PhysicsOrb(
        type: type,
        count: count,
        items: entries.where((e) => e.instrumentType == type).toList(),
        x: (screenSize.width / 2) + (random.nextDouble() - 0.5) * 100,
        y: (screenSize.height / 3) + (random.nextDouble() - 0.5) * 100,
        baseRadius: radius,
      );
    }).toList();

    if (prevFocus != null) {
      try {
        _focusedOrb = _orbs.firstWhere((o) => o.type == prevFocus);
      } catch (e) {
        _focusedOrb = null;
      }
    } else {
      _focusedOrb = null;
    }
  }

  void _onTick(Duration elapsed) {
    if (_orbs.isEmpty || !mounted) return;

    final Size size = MediaQuery.of(context).size;
    final double centerX = size.width / 2;
    // Push the center of gravity drastically up if we are focused to make room for bottom sheet
    final double centerY = _focusedOrb == null
        ? size.height / 2
        : size.height * 0.25;

    const double friction = 0.94;
    const double gravityStrength = 0.02; // Pull to center
    const double bounce = 0.6; // Elasticity

    for (int i = 0; i < _orbs.length; i++) {
      final o = _orbs[i];

      if (o.isGrabbed) {
        o.dx = 0;
        o.dy = 0;
      } else {
        o.dx += (centerX - o.x) * gravityStrength;
        o.dy += (centerY - o.y) * gravityStrength;

        o.dx *= friction;
        o.dy *= friction;

        o.x += o.dx;
        o.y += o.dy;

        // Screen boundary collision
        if (o.x - o.radius < 0) {
          o.x = o.radius;
          o.dx = -o.dx * bounce;
        } else if (o.x + o.radius > size.width) {
          o.x = size.width - o.radius;
          o.dx = -o.dx * bounce;
        }

        // Top ceiling collision (don't go beyond app bar 120.h)
        if (o.y - o.radius < 120.h) {
          o.y = o.radius + 120.h;
          o.dy = -o.dy * bounce;
        } else if (o.y + o.radius > size.height) {
          o.y = size.height - o.radius;
          o.dy = -o.dy * bounce;
        }
      }

      // Pairwise repulsion
      for (int j = i + 1; j < _orbs.length; j++) {
        final o2 = _orbs[j];
        final double distX = o.x - o2.x;
        final double distY = o.y - o2.y;
        final double distSq = distX * distX + distY * distY;
        final double minRadius = o.radius + o2.radius + 10.w;

        if (distSq < minRadius * minRadius && distSq > 0) {
          final double distance = math.sqrt(distSq);
          final double overlap = minRadius - distance;

          final double nx = distX / distance;
          final double ny = distY / distance;

          final totalR = o.radius + o2.radius;
          final r1Ratio = o2.radius / totalR;
          final r2Ratio = o.radius / totalR;

          if (!o.isGrabbed) {
            o.x += nx * overlap * r1Ratio * 0.5;
            o.y += ny * overlap * r1Ratio * 0.5;
            o.dx += nx * overlap * 0.1;
            o.dy += ny * overlap * 0.1;
          }
          if (!o2.isGrabbed) {
            o2.x -= nx * overlap * r2Ratio * 0.5;
            o2.y -= ny * overlap * r2Ratio * 0.5;
            o2.dx -= nx * overlap * 0.1;
            o2.dy -= ny * overlap * 0.1;
          }
        }
      }
    }

    setState(() {});
  }

  void _focusOrb(PhysicsOrb orb) {
    if (_focusedOrb == orb) {
      _focusedOrb = null;
      HapticFeedback.lightImpact();
      return;
    }
    HapticFeedback.selectionClick();
    _focusedOrb = orb;
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(projectProvider).entries;
    final Size size = MediaQuery.of(context).size;

    _initializeOrbs(entries, size);

    return Scaffold(
      backgroundColor: kBackground,
      body: entries.isEmpty
          ? _buildEmptyState()
          : Stack(
              fit: StackFit.expand,
              children: [
                // 1. Mesh Background
                Positioned(
                  top: 140.h,
                  bottom: 140.h,
                  left: 20.w,
                  right: 20.w,
                  child: CustomPaint(
                    painter: MeshBackgroundPainter(),
                    child: const SizedBox.expand(),
                  ),
                ),

                // 2. Physics Bubble Cluster
                ..._orbs.map((orb) {
                  return Positioned(
                    left: orb.x - orb.radius,
                    top: orb.y - orb.radius,
                    width: orb.radius * 2,
                    height: orb.radius * 2,
                    child: GestureDetector(
                      onPanDown: (_) => orb.isGrabbed = true,
                      onPanUpdate: (d) {
                        orb.x += d.delta.dx;
                        orb.y += d.delta.dy;
                      },
                      onPanEnd: (d) {
                        orb.isGrabbed = false;
                        orb.dx = d.velocity.pixelsPerSecond.dx / 60;
                        orb.dy = d.velocity.pixelsPerSecond.dy / 60;
                      },
                      onPanCancel: () => orb.isGrabbed = false,
                      onTap: () => _focusOrb(orb),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _focusedOrb == orb ? kAccent : Colors.white,
                          border: Border.all(
                            color: _focusedOrb == orb
                                ? Colors.white
                                : kBackground,
                            width: 3.w,
                          ),
                          boxShadow: [
                            _focusedOrb == orb ? kShadowFloat : kShadowSubtle,
                            if (_focusedOrb == orb)
                              BoxShadow(
                                color: kAccent.withAlpha(50),
                                blurRadius: 40,
                              ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                orb.count.toString(),
                                style: GoogleFonts.outfit(
                                  color: _focusedOrb == orb
                                      ? Colors.white
                                      : kPrimaryText,
                                  fontSize: orb.radius * 0.6,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (orb.radius > 40.w)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4.w,
                                  ),
                                  child: Text(
                                    orb.type.label,
                                    style: GoogleFonts.inter(
                                      color: _focusedOrb == orb
                                          ? Colors.white.withAlpha(200)
                                          : kSecondaryText,
                                      fontSize: orb.radius * 0.2,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                // 3. Darken background when focused
                if (_focusedOrb != null)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _focusedOrb = null;
                        });
                      },
                      child: Container(color: Colors.black.withAlpha(60)),
                    ),
                  ),

                // 4. Focused Orb Gallery (Bottom Sheet Carousel)
                if (_focusedOrb != null) _buildFocusSlider(),

                // 5. Header overlay
                Positioned(
                  top: 54.h,
                  left: 20.w,
                  right: 20.w,
                  child: IgnorePointer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Ecosystem Physics',
                          style: GoogleFonts.outfit(
                            color: kPrimaryText,
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'Drag orbs to simulate. Tap to explore inventory.',
                          style: GoogleFonts.inter(
                            color: kSecondaryText,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildFocusSlider() {
    final imageProv = ref.watch(imageProvider);
    final items = _focusedOrb!.items;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: MediaQuery.of(context).size.height * 0.42 + 90.h,
      child: Container(
        padding: EdgeInsets.only(top: 24.h),
        decoration: BoxDecoration(
          color: kPanelBg.withAlpha(220),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(kRadiusLarge),
            topRight: Radius.circular(kRadiusLarge),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 40,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(kRadiusLarge),
            topRight: Radius.circular(kRadiusLarge),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _focusedOrb!.type.label,
                        style: GoogleFonts.outfit(
                          color: kPrimaryText,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _focusedOrb = null;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: const [kShadowSubtle],
                          ),
                          child: Icon(
                            Icons.close,
                            size: 20.sp,
                            color: kPrimaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final globalIndex = ref
                          .read(projectProvider)
                          .entries
                          .indexOf(item);
                      final imagePath = imageProv.getImagePath(item.photoPath);

                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          Navigator.pushNamed(
                            context,
                            '/info_screen',
                            arguments: {'index': globalIndex},
                          );
                        },
                        child: Container(
                          width: 200.w,
                          margin: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              kRadiusStandard,
                            ),
                            border: Border.all(color: kOutline, width: 1.5),
                            boxShadow: const [kShadowSubtle],
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 3,
                                child:
                                    (imagePath != null &&
                                        item.photoPath.isNotEmpty &&
                                        File(imagePath).existsSync())
                                    ? Image.file(
                                        File(imagePath),
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        color: kBackground,
                                        child: Icon(
                                          Icons.architecture,
                                          color: kSecondaryText.withAlpha(50),
                                          size: 48.sp,
                                        ),
                                      ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: EdgeInsets.all(12.w),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        item.geodeticIdentifier.isNotEmpty
                                            ? item.geodeticIdentifier
                                            : 'Unassigned',
                                        style: GoogleFonts.inter(
                                          color: kAccent,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        item.manufacturer.isNotEmpty
                                            ? item.manufacturer
                                            : 'Unknown Maker',
                                        style: GoogleFonts.outfit(
                                          color: kPrimaryText,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 110.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: const [kShadowSubtle],
            ),
            child: Icon(
              Icons.architecture,
              color: kSecondaryText.withAlpha(150),
              size: 64.sp,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Physics suspended',
            style: GoogleFonts.outfit(
              color: kPrimaryText,
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'No instruments logged in database to simulate.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: kSecondaryText, fontSize: 14.sp),
          ),
        ],
      ),
    );
  }
}

class MeshBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kSecondaryText.withAlpha(40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final double step = 40.w;

    final int countX = (size.width / step).floor();
    final double offsetX = (size.width - (countX * step)) / 2;

    final int countY = (size.height / step).floor();
    final double offsetY = (size.height - (countY * step)) / 2;

    // Draw a perfectly centered grid of crosses
    for (double x = offsetX; x <= size.width - offsetX; x += step) {
      for (double y = offsetY; y <= size.height - offsetY; y += step) {
        canvas.drawLine(Offset(x - 4.w, y), Offset(x + 4.w, y), paint);
        canvas.drawLine(Offset(x, y - 4.w), Offset(x, y + 4.w), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
