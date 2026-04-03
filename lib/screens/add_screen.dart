import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:theodolite_transit_case/common/photo_bottom_sheet.dart';
import 'package:theodolite_transit_case/enum/my_enums.dart';
import 'package:theodolite_transit_case/providers/image_provider.dart';
import 'package:theodolite_transit_case/providers/input_provider.dart';
import 'package:theodolite_transit_case/providers/project_provider.dart';
import 'package:theodolite_transit_case/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

class AddScreen extends ConsumerStatefulWidget {
  final bool isEdit;
  final int currentIndex;
  const AddScreen({super.key, this.isEdit = false, this.currentIndex = 0});

  @override
  ConsumerState<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends ConsumerState<AddScreen> {
  late TextEditingController _idCtrl;
  late TextEditingController _manCtrl;
  late TextEditingController _countryCtrl;
  late TextEditingController _optCtrl;
  late TextEditingController _circCtrl;
  late TextEditingController _leastCtrl;
  late TextEditingController _lvlCtrl;
  late TextEditingController _matCtrl;
  late TextEditingController _dimCtrl;
  late TextEditingController _eraCtrl;
  late TextEditingController _provCtrl;
  late TextEditingController _accCtrl;
  late TextEditingController _calCtrl;
  late TextEditingController _notesCtrl;
  late TextEditingController _tagsCtrl;

  @override
  void initState() {
    super.initState();
    final p = ref.read(inputProvider);
    _idCtrl = TextEditingController(text: p.geodeticIdentifier);
    _manCtrl = TextEditingController(text: p.manufacturer);
    _countryCtrl = TextEditingController(text: p.countryOfManufacture);
    _optCtrl = TextEditingController(text: p.opticalSystem);
    _circCtrl = TextEditingController(text: p.circleGraduation);
    _leastCtrl = TextEditingController(text: p.leastCount);
    _lvlCtrl = TextEditingController(text: p.levelingSystem);
    _matCtrl = TextEditingController(text: p.materialsAndFinish);
    _dimCtrl = TextEditingController(text: p.dimensionsAndWeight);
    _eraCtrl = TextEditingController(text: p.eraOfProduction);
    _provCtrl = TextEditingController(text: p.provenance);
    _accCtrl = TextEditingController(text: p.includedAccessories);
    _calCtrl = TextEditingController(text: p.calibrationLogbook);
    _notesCtrl = TextEditingController(text: p.notes);
    _tagsCtrl = TextEditingController(text: p.tags.join(', '));
  }

  @override
  void dispose() {
    for (final c in [
      _idCtrl, _manCtrl, _countryCtrl, _optCtrl, _circCtrl,
      _leastCtrl, _lvlCtrl, _matCtrl, _dimCtrl, _eraCtrl,
      _provCtrl, _accCtrl, _calCtrl, _notesCtrl, _tagsCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() async {
    final p = ref.read(inputProvider);
    final bool missingId = p.geodeticIdentifier.trim().isEmpty;
    final bool missingMan = p.manufacturer.trim().isEmpty;

    if (missingId || missingMan) {
      String errorMsg = 'Identifier and Manufacturer are required.';
      if (missingId && !missingMan) {
        errorMsg = 'Geodetic Identifier is required.';
      } else if (!missingId && missingMan) {
        errorMsg = 'Manufacturer is required.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMsg,
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          backgroundColor: kError,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusStandard)),
        ),
      );
      return;
    }

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const _SavingDialog());
    await Future.delayed(const Duration(milliseconds: 1200));
    if (widget.isEdit) {
      ref.read(projectProvider).editEntry(ref, widget.currentIndex);
    } else {
      ref.read(projectProvider).addEntry(ref);
    }
    if (mounted) {
      Navigator.pop(context);
      Navigator.pop(context);
      ref.read(inputProvider).clearAll();
      ref.read(imageProvider).clearImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close, color: kPrimaryText, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isEdit ? 'Edit instrument' : 'Record instrument',
          style: GoogleFonts.outfit(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 40.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPhotoSection(),
                    SizedBox(height: 32.h),
                    _buildSectionHeader('Registry Information'),
                    _buildRegistryFields(),
                    SizedBox(height: 32.h),
                    _buildSectionHeader('Optical Specs'),
                    _buildOpticalFields(),
                    SizedBox(height: 32.h),
                    _buildSectionHeader('Physical Properties'),
                    _buildMaterialFields(),
                    SizedBox(height: 32.h),
                    _buildSectionHeader('Archival Details'),
                    _buildLogbookFields(),
                  ],
                ),
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    final imageProv = ref.watch(imageProvider);
    final displayPath = imageProv.getImagePath(imageProv.resultImage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => photoBottomSheet(context, ref.read(imageProvider), 0, ref),
          child: Container(
            width: double.infinity,
            height: 280.h,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(kRadiusStandard),
              boxShadow: const [kShadowSubtle],
            ),
            child: displayPath != null && File(displayPath).existsSync()
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(File(displayPath), fit: BoxFit.cover),
                      Positioned(
                        bottom: 16.h,
                        right: 16.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(220),
                            borderRadius: BorderRadius.circular(kRadiusPill),
                          ),
                          child: Text(
                            'Replace photo',
                            style: GoogleFonts.inter(
                              color: kPrimaryText,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: kBackground,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.add_a_photo_outlined, color: kSecondaryText, size: 36.sp),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Upload photograph',
                        style: GoogleFonts.inter(
                          color: kPrimaryText,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            color: kPrimaryText,
            fontSize: 22.sp,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildRegistryFields() {
    final p = ref.watch(inputProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _field(
          label: 'Geodetic Identifier',
          ctrl: _idCtrl,
          hint: 'e.g. TTC-WILD-T2-1954',
          onChanged: (v) => p.geodeticIdentifier = v,
        ),
        SizedBox(height: 20.h),
        _field(
          label: 'Manufacturer / Brand',
          ctrl: _manCtrl,
          hint: 'e.g. Wild Heerbrugg, Kern & Co',
          onChanged: (v) => p.manufacturer = v,
        ),
        SizedBox(height: 20.h),
        _field(
          label: 'Country of Manufacture',
          ctrl: _countryCtrl,
          hint: 'e.g. Switzerland, Germany',
          onChanged: (v) => p.countryOfManufacture = v,
        ),
        SizedBox(height: 28.h),
        Text(
          'Instrument type',
          style: GoogleFonts.inter(
            color: kSecondaryText,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: InstrumentType.values.map((t) {
            final isSel = p.instrumentType == t;
            return GestureDetector(
              onTap: () => p.instrumentType = t,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSel ? kPrimaryText : Colors.white,
                  borderRadius: BorderRadius.circular(kRadiusPill),
                  boxShadow: isSel ? [kShadowFloat] : [kShadowSubtle],
                ),
                child: Text(
                  t.label,
                  style: GoogleFonts.inter(
                    color: isSel ? Colors.white : kPrimaryText,
                    fontSize: 13.sp,
                    fontWeight: isSel ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOpticalFields() {
    final p = ref.watch(inputProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _field(
          label: 'Optical system',
          ctrl: _optCtrl,
          hint: 'e.g. internal focusing, 32x...',
          maxLines: 2,
          onChanged: (v) => p.opticalSystem = v,
        ),
        SizedBox(height: 20.h),
        _field(
          label: 'Circle graduation',
          ctrl: _circCtrl,
          hint: 'e.g. glass with optical readout',
          maxLines: 2,
          onChanged: (v) => p.circleGraduation = v,
        ),
        SizedBox(height: 20.h),
        _field(
          label: 'Accuracy (least count)',
          ctrl: _leastCtrl,
          hint: 'e.g. 1 arc-second',
          onChanged: (v) => p.leastCount = v,
        ),
        SizedBox(height: 20.h),
        _field(
          label: 'Leveling system',
          ctrl: _lvlCtrl,
          hint: 'e.g. automatic compensator',
          maxLines: 2,
          onChanged: (v) => p.levelingSystem = v,
        ),
      ],
    );
  }

  Widget _buildMaterialFields() {
    final p = ref.watch(inputProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _field(
          label: 'Materials and Finish',
          ctrl: _matCtrl,
          hint: 'e.g. crinkle green enamel',
          maxLines: 2,
          onChanged: (v) => p.materialsAndFinish = v,
        ),
        SizedBox(height: 20.h),
        _field(
          label: 'Dimensions and Weight',
          ctrl: _dimCtrl,
          hint: 'e.g. 8kg total',
          maxLines: 2,
          onChanged: (v) => p.dimensionsAndWeight = v,
        ),
        SizedBox(height: 20.h),
        _field(
          label: 'Era of Production',
          ctrl: _eraCtrl,
          hint: 'e.g. 1954',
          onChanged: (v) => p.eraOfProduction = v,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
        ),
        SizedBox(height: 28.h),
        Text(
          'Condition state',
          style: GoogleFonts.inter(
            color: kSecondaryText,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12.h),
        Column(
          children: ConditionState.values.map((state) {
            final isSel = p.conditionState == state;
            return GestureDetector(
              onTap: () => p.conditionState = state,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                decoration: BoxDecoration(
                  color: isSel ? kAccent.withAlpha(20) : Colors.white,
                  borderRadius: BorderRadius.circular(kRadiusStandard),
                  border: Border.all(color: isSel ? kAccent : Colors.transparent, width: 2),
                  boxShadow: const [kShadowSubtle],
                ),
                child: Row(
                  children: [
                    Icon(
                      isSel ? Icons.check_circle_rounded : Icons.radio_button_off,
                      color: isSel ? kAccent : kSecondaryText.withAlpha(100),
                      size: 22.sp,
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Text(
                        state.label,
                        style: GoogleFonts.inter(
                          color: isSel ? kPrimaryText : kSecondaryText,
                          fontSize: 15.sp,
                          fontWeight: isSel ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLogbookFields() {
    final p = ref.watch(inputProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _field(
          label: 'Provenance',
          ctrl: _provCtrl,
          hint: 'Historical context...',
          maxLines: 3,
          onChanged: (v) => p.provenance = v,
        ),
        SizedBox(height: 20.h),
        _field(
          label: 'Included Accessories',
          ctrl: _accCtrl,
          hint: 'Tripod, filters...',
          maxLines: 2,
          onChanged: (v) => p.includedAccessories = v,
        ),
        SizedBox(height: 20.h),
        _field(
          label: 'Calibration & Logbook',
          ctrl: _calCtrl,
          hint: 'Maintenance records...',
          maxLines: 2,
          onChanged: (v) => p.calibrationLogbook = v,
        ),
        SizedBox(height: 20.h),
        _field(
          label: 'Notes',
          ctrl: _notesCtrl,
          hint: 'Other details...',
          maxLines: 3,
          onChanged: (v) => p.notes = v,
        ),
        SizedBox(height: 20.h),
        _field(
          label: 'Tags (comma separated)',
          ctrl: _tagsCtrl,
          hint: 'brass, manual...',
          onChanged: (v) => p.tags = v.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        ),
      ],
    );
  }

  Widget _field({
    required String label,
    required TextEditingController ctrl,
    required Function(String) onChanged,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: kSecondaryText,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            boxShadow: const [kShadowSubtle],
            borderRadius: BorderRadius.circular(kRadiusStandard),
          ),
          child: TextField(
            controller: ctrl,
            onChanged: onChanged,
            minLines: 1,
            maxLines: maxLines,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: GoogleFonts.inter(
              color: kPrimaryText,
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
      decoration: const BoxDecoration(
        color: kBackground,
      ),
      child: GestureDetector(
        onTap: _save,
        child: Container(
          width: double.infinity,
          height: 64.h,
          decoration: BoxDecoration(
            color: kAccent,
            borderRadius: BorderRadius.circular(kRadiusPill),
            boxShadow: [
              BoxShadow(
                color: kAccent.withAlpha(80),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Center(
            child: Text(
              widget.isEdit ? 'Save edits' : 'Save record',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SavingDialog extends StatelessWidget {
  const _SavingDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: EdgeInsets.all(40.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(kRadiusMedium),
          boxShadow: const [kShadowFloat],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: kAccent, strokeWidth: 3),
            SizedBox(height: 24.h),
            Text(
              'Saving to ledger...',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: kPrimaryText,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
