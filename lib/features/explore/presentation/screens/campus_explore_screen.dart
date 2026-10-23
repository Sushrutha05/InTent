import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:student_dating_app/core/theme/app_theme.dart';
import 'package:student_dating_app/features/explore/domain/campus_spot_models.dart';
import 'package:student_dating_app/features/explore/presentation/providers/campus_explore_provider.dart';

class CampusExploreScreen extends ConsumerStatefulWidget {
  const CampusExploreScreen({super.key});

  @override
  ConsumerState<CampusExploreScreen> createState() =>
      _CampusExploreScreenState();
}

class _CampusExploreScreenState extends ConsumerState<CampusExploreScreen> {
  SpotCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final spotsAsync = ref.watch(campusSpotsProvider);
    final myCheckInAsync = ref.watch(currentUserCheckInProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Campus Radar',
              style: GoogleFonts.outfit(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppTheme.textSecondary,
            ),
            onPressed:
                () =>
                    ref
                        .read(campusExploreControllerProvider.notifier)
                        .refresh(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppTheme.dividerColor, height: 1.0),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(campusExploreControllerProvider.notifier).refresh();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Active Check-in Banner
              myCheckInAsync.when(
                data: (myCheckIn) => _buildMyCheckInBanner(myCheckIn),
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),

              const SizedBox(height: 16),

              // Category filters
              _buildCategoryFilters(),

              const SizedBox(height: 20),

              // Hotspots Grid Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Campus Hotspots',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    'Live Check-Ins',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Spots List
              spotsAsync.when(
                loading:
                    () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                error: (e, _) => Center(child: Text('Error loading spots: $e')),
                data: (spots) {
                  final filteredSpots =
                      _selectedCategory == null
                          ? spots
                          : spots
                              .where((s) => s.category == _selectedCategory)
                              .toList();

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredSpots.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final spot = filteredSpots[index];
                      return _buildSpotCard(spot);
                    },
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyCheckInBanner(SpotCheckIn? checkIn) {
    if (checkIn == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor.withValues(alpha: 0.12),
              const Color(0xFF6366F1).withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_location_alt_rounded,
                color: AppTheme.primaryColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Not checked in anywhere',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Check in at a campus spot to be discovered nearby!',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final minutesLeft = checkIn.expiresAt.difference(DateTime.now()).inMinutes;
    final hoursLeft = (minutesLeft / 60).floor();
    final remainingMinutes = minutesLeft % 60;
    final timeLeftStr =
        hoursLeft > 0
            ? '${hoursLeft}h ${remainingMinutes}m'
            : '${minutesLeft}m';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'You are checked in!',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF065F46),
                      ),
                    ),
                    Text(
                      'Expires in $timeLeftStr',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF047857),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  ref.read(campusExploreControllerProvider.notifier).checkOut();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                ),
                child: const Text(
                  'Check Out',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.bubble_chart_rounded,
                  size: 16,
                  color: Color(0xFF10B981),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '"${checkIn.vibeStatus}"',
                    style: const TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    final categories = [
      null,
      SpotCategory.study,
      SpotCategory.social,
      SpotCategory.outdoor,
      SpotCategory.lounge,
      SpotCategory.fitness,
    ];

    final labels = [
      'All Spots',
      'Study 📚',
      'Social 💬',
      'Outdoors 🌳',
      'Cafe ☕',
      'Fitness 🏋️',
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory == cat;

          return FilterChip(
            label: Text(labels[index]),
            selected: isSelected,
            onSelected: (_) => setState(() => _selectedCategory = cat),
            selectedColor: AppTheme.primaryColor,
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppTheme.textPrimary,
            ),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color:
                    isSelected ? AppTheme.primaryColor : AppTheme.dividerColor,
              ),
            ),
            showCheckmark: false,
          );
        },
      ),
    );
  }

  Widget _buildSpotCard(CampusSpot spot) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showSpotDetailsModal(spot),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: spot.themeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(spot.icon, color: spot.themeColor, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            spot.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            spot.building,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary.withValues(
                                alpha: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Live Student Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            spot.activeCheckIns > 0
                                ? const Color(
                                  0xFF10B981,
                                ).withValues(alpha: 0.12)
                                : AppTheme.surfaceSolid,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (spot.activeCheckIns > 0) ...[
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            spot.activeCheckIns > 0
                                ? '${spot.activeCheckIns} Here'
                                : 'Quiet',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color:
                                  spot.activeCheckIns > 0
                                      ? const Color(0xFF047857)
                                      : AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  spot.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showSpotDetailsModal(spot),
                      icon: const Icon(Icons.people_outline_rounded, size: 16),
                      label: Text(
                        spot.activeCheckIns > 0
                            ? 'See Who\'s Here'
                            : 'Be First Here',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _showCheckInDialog(spot),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: spot.themeColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Check In',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSpotDetailsModal(CampusSpot spot) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SpotDetailsSheet(spot: spot),
    );
  }

  void _showCheckInDialog(CampusSpot spot) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CheckInDialogSheet(spot: spot),
    );
  }
}

class _SpotDetailsSheet extends ConsumerWidget {
  final CampusSpot spot;

  const _SpotDetailsSheet({required this.spot});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkInsAsync = ref.watch(spotCheckInsProvider(spot.id));

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: spot.themeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(spot.icon, color: spot.themeColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        spot.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        spot.building,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.dividerColor),
          Expanded(
            child: checkInsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (checkIns) {
                if (checkIns.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_off_rounded,
                          size: 48,
                          color: AppTheme.textMuted,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No students checked in here yet',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Be the first to check in and start the vibe!',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: checkIns.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final checkIn = checkIns[index];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.dividerColor),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppTheme.surfaceSolid,
                            backgroundImage:
                                checkIn.userPhotoUrl != null
                                    ? CachedNetworkImageProvider(
                                      checkIn.userPhotoUrl!,
                                      maxHeight: 100,
                                      maxWidth: 100,
                                    )
                                    : null,
                            child:
                                checkIn.userPhotoUrl == null
                                    ? const Icon(
                                      Icons.person,
                                      color: AppTheme.textSecondary,
                                    )
                                    : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      checkIn.userName,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        checkIn.userIntent.toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (checkIn.userMajor.isNotEmpty)
                                  Text(
                                    checkIn.userMajor,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                const SizedBox(height: 4),
                                Text(
                                  '"${checkIn.vibeStatus}"',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckInDialogSheet extends ConsumerStatefulWidget {
  final CampusSpot spot;

  const _CheckInDialogSheet({required this.spot});

  @override
  ConsumerState<_CheckInDialogSheet> createState() =>
      _CheckInDialogSheetState();
}

class _CheckInDialogSheetState extends ConsumerState<_CheckInDialogSheet> {
  final TextEditingController _vibeController = TextEditingController();
  int _durationHours = 2;

  final List<String> _quickVibes = [
    'Studying for midterms 📚',
    'Grabbing iced coffee & relaxing ☕',
    'Free until my next class 👋',
    'Looking for study partner 💡',
    'Workout session / gym grind 💪',
  ];

  @override
  void initState() {
    super.initState();
    _vibeController.text = _quickVibes.first;
  }

  @override
  void dispose() {
    _vibeController.dispose();
    super.dispose();
  }

  void _confirmCheckIn() async {
    final vibe = _vibeController.text.trim();
    if (vibe.isEmpty) return;

    await ref
        .read(campusExploreControllerProvider.notifier)
        .checkIn(
          spotId: widget.spot.id,
          vibeStatus: vibe,
          durationHours: _durationHours,
        );

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Checked in at ${widget.spot.name}! 🎉'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Check In at ${widget.spot.name}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Share your campus vibe so nearby students know what you\'re up to.',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),

          // Quick vibe chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _quickVibes.map((v) {
                  final isSelected = _vibeController.text == v;
                  return ChoiceChip(
                    label: Text(v),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _vibeController.text = v),
                    selectedColor: widget.spot.themeColor.withValues(
                      alpha: 0.15,
                    ),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color:
                          isSelected
                              ? widget.spot.themeColor
                              : AppTheme.textPrimary,
                    ),
                  );
                }).toList(),
          ),

          const SizedBox(height: 14),
          TextField(
            controller: _vibeController,
            maxLength: 60,
            decoration: InputDecoration(
              labelText: 'Or type custom vibe status',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              filled: true,
              fillColor: AppTheme.backgroundColor,
            ),
          ),

          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Duration:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 1, label: Text('1h')),
                  ButtonSegment(value: 2, label: Text('2h')),
                  ButtonSegment(value: 4, label: Text('4h')),
                ],
                selected: {_durationHours},
                onSelectionChanged:
                    (set) => setState(() => _durationHours = set.first),
              ),
            ],
          ),

          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _confirmCheckIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.spot.themeColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Broadcast Check-In',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
