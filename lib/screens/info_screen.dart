import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:theodolite_transit_case/models/project_model.dart';
import 'package:theodolite_transit_case/providers/image_provider.dart';
import 'package:theodolite_transit_case/providers/project_provider.dart';
import 'package:theodolite_transit_case/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

class InfoScreen extends ConsumerWidget {
  final int index;
  const InfoScreen({super.key, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectProv = ref.watch(projectProvider);
    if (index < 0 || index >= projectProv.entries.length) {
      return const Scaffold(body: Center(child: Text('INSTRUMENT NOT FOUND')));
    }
    final entry = projectProv.entries[index];
    final imageProv = ref.watch(imageProvider);
    final imagePath = imageProv.getImagePath(entry.photoPath);

    return Scaffold(
      backgroundColor: kBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: EdgeInsets.only(left: 8.w),
          child: _navBtn(
            context,
            icon: Icons.arrow_back,
            onTap: () => Navigator.pop(context),
          ),
        ),
        actions: [
          _navBtn(
            context,
            icon: Icons.edit,
            onTap: () {
              projectProv.fillInput(ref, index);
              Navigator.pushNamed(
                context,
                '/add_screen',
                arguments: {'isEdit': true, 'currentIndex': index},
              );
            },
          ),
          SizedBox(width: 8.w),
          _navBtn(
            context,
            icon: Icons.delete,
            iconColor: kError,
            onTap: () => _showDeleteDialog(context, projectProv, index),
          ),
          SizedBox(width: 16.w),
        ],
      ),
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(child: _buildHeroImage(imagePath, entry)),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 80.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildIdentityPanel(entry),
                SizedBox(height: 24.h),
                _buildSpecGrid(entry),
                SizedBox(height: 24.h),
                if (entry.provenance.isNotEmpty ||
                    entry.includedAccessories.isNotEmpty ||
                    entry.calibrationLogbook.isNotEmpty ||
                    entry.notes.isNotEmpty)
                  _buildTextPanels(entry),
                if (entry.tags.isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  _buildTagsPanel(entry),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage(String? imagePath, SurveyingInstrumentModel entry) {
    return Container(
      width: double.infinity,
      height: 380.h,
      decoration: BoxDecoration(
        color: kBackground.withAlpha(50),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(kRadiusLarge),
          bottomRight: Radius.circular(kRadiusLarge),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child:
          (entry.photoPath.isNotEmpty &&
              imagePath != null &&
              File(imagePath).existsSync())
          ? Image.file(File(imagePath), fit: BoxFit.cover)
          : Container(
              color: kPanelBg,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.architecture,
                      size: 48.sp,
                      color: kSecondaryText.withAlpha(100),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No photo provided',
                      style: GoogleFonts.inter(
                        color: kSecondaryText,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildIdentityPanel(SurveyingInstrumentModel entry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                entry.geodeticIdentifier.isNotEmpty
                    ? entry.geodeticIdentifier
                    : 'Unassigned ID',
                style: GoogleFonts.inter(
                  color: kAccent,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            if (entry.eraOfProduction.isNotEmpty) ...[
              SizedBox(width: 16.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(kRadiusPill),
                  boxShadow: const [kShadowSubtle],
                ),
                child: Text(
                  entry.eraOfProduction,
                  style: GoogleFonts.inter(
                    color: kSecondaryText,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          entry.manufacturer.isNotEmpty
              ? entry.manufacturer
              : 'Unknown Manufacturer',
          style: GoogleFonts.outfit(
            color: kPrimaryText,
            fontSize: 32.sp,
            fontWeight: FontWeight.w800,
            height: 1.1,
            letterSpacing: -0.5,
          ),
        ),
        if (entry.countryOfManufacture.isNotEmpty) ...[
          SizedBox(height: 6.h),
          Text(
            entry.countryOfManufacture,
            style: GoogleFonts.inter(
              color: kSecondaryText,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        SizedBox(height: 16.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            _pill(kPrimaryText, Colors.white, entry.instrumentType.label),
            _pill(
              Colors.white,
              getConditionColor(entry.conditionState),
              entry.conditionState.label,
            ),
          ],
        ),
      ],
    );
  }

  Widget _pill(Color textColor, Color bgColor, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(kRadiusPill),
        boxShadow: const [kShadowSubtle],
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: textColor,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSpecGrid(SurveyingInstrumentModel entry) {
    final specs = <String, String>{};
    if (entry.opticalSystem.isNotEmpty)
      specs['Optical system'] = entry.opticalSystem;
    if (entry.circleGraduation.isNotEmpty)
      specs['Circle graduation'] = entry.circleGraduation;
    if (entry.leastCount.isNotEmpty)
      specs['Accuracy (least count)'] = entry.leastCount;
    if (entry.levelingSystem.isNotEmpty)
      specs['Leveling system'] = entry.levelingSystem;
    if (entry.materialsAndFinish.isNotEmpty)
      specs['Materials & finish'] = entry.materialsAndFinish;
    if (entry.dimensionsAndWeight.isNotEmpty)
      specs['Dimensions & weight'] = entry.dimensionsAndWeight;

    if (specs.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kRadiusStandard),
        boxShadow: const [kShadowFloat],
      ),
      child: Column(
        children: specs.entries.map((e) => _specTile(e.key, e.value)).toList(),
      ),
    );
  }

  Widget _specTile(String label, String value) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: kOutline.withAlpha(100), width: 1.0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: kSecondaryText,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.inter(
                color: kPrimaryText,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextPanels(SurveyingInstrumentModel entry) {
    return Column(
      children: [
        if (entry.includedAccessories.isNotEmpty)
          _textPanel('Included accessories', entry.includedAccessories),
        if (entry.calibrationLogbook.isNotEmpty)
          _textPanel('Calibration & log', entry.calibrationLogbook),
        if (entry.provenance.isNotEmpty)
          _textPanel('Provenance', entry.provenance),
        if (entry.notes.isNotEmpty) _textPanel('Archival notes', entry.notes),
      ],
    );
  }

  Widget _textPanel(String label, String text) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kRadiusStandard),
        boxShadow: const [kShadowSubtle],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              color: kPrimaryText,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            text,
            style: GoogleFonts.inter(
              color: kSecondaryText,
              fontSize: 15.sp,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsPanel(SurveyingInstrumentModel entry) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: entry.tags
          .map(
            (tag) => Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: kBackground,
                borderRadius: BorderRadius.circular(kRadiusPill),
                boxShadow: const [kShadowSubtle],
              ),
              child: Text(
                '#$tag',
                style: GoogleFonts.inter(
                  color: kSecondaryText,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _navBtn(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = kPrimaryText,
  }) {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(200),
            shape: BoxShape.circle,
            boxShadow: const [kShadowSubtle],
          ),
          child: Icon(icon, color: iconColor, size: 22.sp),
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    ProjectNotifier projectProv,
    int idx,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: _DeleteDialogUI(
          onConfirm: () {
            projectProv.deleteEntry(idx);
            Navigator.pop(ctx);
            Navigator.pop(context);
          },
          onCancel: () => Navigator.pop(ctx),
        ),
      ),
    );
  }
}

class _DeleteDialogUI extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  const _DeleteDialogUI({required this.onConfirm, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kRadiusMedium),
        boxShadow: const [kShadowFloat],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: kError.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.delete_outline, color: kError, size: 32.sp),
          ),
          SizedBox(height: 24.h),
          Text(
            'Delete record?',
            style: GoogleFonts.outfit(
              color: kPrimaryText,
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'This record will be permanently purged from the geodetic archive.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: kSecondaryText,
              fontSize: 14.sp,
              height: 1.5,
            ),
          ),
          SizedBox(height: 32.h),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onCancel,
                  child: Container(
                    height: 52.h,
                    decoration: BoxDecoration(
                      color: kBackground,
                      borderRadius: BorderRadius.circular(kRadiusPill),
                    ),
                    child: Center(
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          color: kSecondaryText,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: GestureDetector(
                  onTap: onConfirm,
                  child: Container(
                    height: 52.h,
                    decoration: BoxDecoration(
                      color: kError,
                      borderRadius: BorderRadius.circular(kRadiusPill),
                      boxShadow: [
                        BoxShadow(
                          color: kError.withAlpha(80),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Delete',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
