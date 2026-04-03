import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:theodolite_transit_case/enum/my_enums.dart';
import 'package:theodolite_transit_case/models/project_model.dart';
import 'package:theodolite_transit_case/providers/image_provider.dart';
import 'package:theodolite_transit_case/providers/project_provider.dart';
import 'package:theodolite_transit_case/providers/search_provider.dart';
import 'package:theodolite_transit_case/providers/input_provider.dart';
import 'package:theodolite_transit_case/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  InstrumentType? _selectedFilter;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchProv = ref.watch(searchProvider);
    final projectProv = ref.watch(projectProvider);
    final allEntries = projectProv.entries;

    final filteredByType = _selectedFilter == null
        ? allEntries
        : allEntries.where((e) => e.instrumentType == _selectedFilter).toList();
    final entries = searchProv.filteredList(filteredByType);

    return Scaffold(
      backgroundColor: kBackground,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        slivers: [
          SliverAppBar(
            expandedHeight: 160.h,
            stretch: true,
            pinned: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.fadeTitle
              ],
              background: _buildHeader(allEntries.length),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  _buildSearchBar(),
                  SizedBox(height: 16.h),
                  _buildFilterChips(),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
          entries.isEmpty
              ? SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(),
                )
              : SliverPadding(
                  padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 140.h),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final entry = entries[index];
                        final mainIndex =
                            ref.read(projectProvider).entries.indexOf(entry);
                        return _buildToolCard(context, entry, mainIndex);
                      },
                      childCount: entries.length,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.w,
                      mainAxisSpacing: 16.h,
                      childAspectRatio: 0.70,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24.w, 56.h, 24.w, 16.h),
      color: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instrument log',
                    style: GoogleFonts.inter(
                      color: kSecondaryText,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'The Archive',
                    style: GoogleFonts.outfit(
                      color: kPrimaryText,
                      fontSize: 34.sp,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  ref.read(inputProvider).clearAll();
                  ref.read(imageProvider).clearImage();
                  Navigator.pushNamed(context, '/add_screen');
                },
                child: Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(kRadiusPill),
                    boxShadow: const [kShadowSubtle],
                  ),
                  child: Center(
                    child: Icon(Icons.add, color: kPrimaryText, size: 28.sp),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Text(
                'Count:',
                style: GoogleFonts.inter(
                  color: kSecondaryText,
                  fontSize: 13.sp,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                count.toString().padLeft(3, '0'),
                style: GoogleFonts.inter(
                  color: kPrimaryText,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: kOutline,
                    borderRadius: BorderRadius.circular(kRadiusPill),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final isFocused = _searchFocusNode.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 56.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kRadiusPill),
        boxShadow: const [kShadowSubtle],
        border: Border.all(
          color: isFocused ? kAccent.withAlpha(100) : Colors.transparent,
          width: 2.0,
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 16.w),
          Icon(
            Icons.search,
            color: isFocused ? kAccent : kSecondaryText,
            size: 20.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: (v) =>
                  ref.read(searchProvider.notifier).setSearchQuery(v),
              style: GoogleFonts.inter(
                color: kPrimaryText,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Search by manufacturer or ID...',
                hintStyle: GoogleFonts.inter(
                  color: kSecondaryText,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                ref.read(searchProvider.notifier).clearSearchQuery();
                setState(() {});
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Icon(Icons.close, color: kSecondaryText, size: 20.sp),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 36.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildChip('All Logs', null),
          ...InstrumentType.values.map((t) => _buildChip(t.label, t)),
        ],
      ),
    );
  }

  Widget _buildChip(String label, InstrumentType? type) {
    final isSelected = _selectedFilter == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(right: 12.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryText : Colors.white,
          borderRadius: BorderRadius.circular(kRadiusPill),
          boxShadow: isSelected ? [kShadowFloat] : [kShadowSubtle],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? Colors.white : kSecondaryText,
            fontSize: 12.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildToolCard(
      BuildContext context, SurveyingInstrumentModel entry, int index) {
    final imageProv = ref.watch(imageProvider);
    final imagePath = imageProv.getImagePath(entry.photoPath);

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/info_screen',
          arguments: {'index': index}),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(kRadiusStandard),
          boxShadow: const [kShadowSubtle],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Box
            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                color: kBackground.withAlpha(100),
                child: (entry.photoPath.isNotEmpty &&
                        imagePath != null &&
                        File(imagePath).existsSync())
                    ? Image.file(
                        File(imagePath),
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Center(
                        child: Icon(Icons.architecture,
                            color: kOutline, size: 40.sp),
                      ),
              ),
            ),
            // Info Area
            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.geodeticIdentifier.isNotEmpty
                              ? entry.geodeticIdentifier
                              : 'NO ID',
                          style: GoogleFonts.inter(
                            color: kAccent,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          entry.manufacturer.isNotEmpty ? entry.manufacturer : 'Unknown Maker',
                          style: GoogleFonts.outfit(
                            color: kPrimaryText,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            height: 1.1,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: kBackground,
                        borderRadius: BorderRadius.circular(kRadiusSubtle),
                      ),
                      child: Text(
                        entry.instrumentType.label,
                        style: GoogleFonts.inter(
                          color: kSecondaryText,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kRadiusMedium),
        boxShadow: const [kShadowFloat],
      ),
      margin: EdgeInsets.all(24.w),
      padding: EdgeInsets.all(32.w),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: kBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.edit_document, size: 48.sp, color: kSecondaryText.withAlpha(100)),
          ),
          SizedBox(height: 24.h),
          Text(
            'Blank page',
            style: GoogleFonts.outfit(
              color: kPrimaryText,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'The ledger is empty. Tap the + button to record a new surveying instrument.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: kSecondaryText,
              fontSize: 14.sp,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
