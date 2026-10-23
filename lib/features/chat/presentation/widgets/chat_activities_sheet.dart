import 'package:flutter/material.dart';
import 'package:student_dating_app/core/theme/app_theme.dart';
import 'package:student_dating_app/features/chat/domain/chat_activity_model.dart';

class ChatActivitiesSheet extends StatefulWidget {
  final String currentUserId;
  final Function(ChatActivity activity) onSendActivity;

  const ChatActivitiesSheet({
    super.key,
    required this.currentUserId,
    required this.onSendActivity,
  });

  static Future<void> show(
    BuildContext context, {
    required String currentUserId,
    required Function(ChatActivity activity) onSendActivity,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChatActivitiesSheet(
        currentUserId: currentUserId,
        onSendActivity: onSendActivity,
      ),
    );
  }

  @override
  State<ChatActivitiesSheet> createState() => _ChatActivitiesSheetState();
}

class _ChatActivitiesSheetState extends State<ChatActivitiesSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Two Truths & a Lie state
  final TextEditingController _statement1 = TextEditingController();
  final TextEditingController _statement2 = TextEditingController();
  final TextEditingController _statement3 = TextEditingController();
  int _lieIndex = 0;

  // Would You Rather state
  final TextEditingController _wyrOptionA = TextEditingController();
  final TextEditingController _wyrOptionB = TextEditingController();

  final List<List<String>> _twoTruthsPresets = [
    [
      "I've fallen asleep in an 8 AM lecture",
      "I can play 3 different instruments",
      "I've never watched an episode of Game of Thrones",
    ],
    [
      "I've visited more than 10 countries",
      "I survived entirely on dining hall coffee for 48 hours",
      "I've met a celebrity at the airport",
    ],
    [
      "I lost my campus ID 4 times this semester",
      "I cook dinner from scratch every single night",
      "I have an irrational fear of campus pigeons",
    ],
  ];

  final List<Map<String, String>> _wyrPresets = [
    {
      "prompt": "Campus Survival",
      "a": "8 AM class with the most inspiring professor",
      "b": "2 PM class with a professor whose monotone puts you to sleep",
    },
    {
      "prompt": "Study Grind",
      "a": "All-nighter in the silent library floor",
      "b": "Group cram session in a loud student cafe with unlimited snacks",
    },
    {
      "prompt": "Superpower Choice",
      "a": "Know what everyone thinks of you on first glance",
      "b": "Never feel awkward or anxious in conversations again",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRandomTwoTruths();
    _loadRandomWyr();
  }

  void _loadRandomTwoTruths() {
    final preset = (_twoTruthsPresets..shuffle()).first;
    _statement1.text = preset[0];
    _statement2.text = preset[1];
    _statement3.text = preset[2];
    _lieIndex = 2; // Default to 3rd as lie, customizable
    setState(() {});
  }

  void _loadRandomWyr() {
    final preset = (_wyrPresets..shuffle()).first;
    _wyrOptionA.text = preset['a']!;
    _wyrOptionB.text = preset['b']!;
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    _statement1.dispose();
    _statement2.dispose();
    _statement3.dispose();
    _wyrOptionA.dispose();
    _wyrOptionB.dispose();
    super.dispose();
  }

  void _submitTwoTruths() {
    if (_statement1.text.trim().isEmpty ||
        _statement2.text.trim().isEmpty ||
        _statement3.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all 3 statements')),
      );
      return;
    }

    final activity = ChatActivity(
      type: ActivityType.twoTruthsAndLie,
      title: '🎯 Two Truths & a Lie',
      creatorId: widget.currentUserId,
      options: [
        _statement1.text.trim(),
        _statement2.text.trim(),
        _statement3.text.trim(),
      ],
      correctIndex: _lieIndex,
      blurBoost: 0.25,
    );

    widget.onSendActivity(activity);
    Navigator.of(context).pop();
  }

  void _submitWouldYouRather() {
    if (_wyrOptionA.text.trim().isEmpty || _wyrOptionB.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out both choices')),
      );
      return;
    }

    final activity = ChatActivity(
      type: ActivityType.wouldYouRather,
      title: '⚖️ Campus Would You Rather',
      creatorId: widget.currentUserId,
      prompt: 'Would you rather...',
      options: [
        _wyrOptionA.text.trim(),
        _wyrOptionB.text.trim(),
      ],
      blurBoost: 0.15,
    );

    widget.onSendActivity(activity);
    Navigator.of(context).pop();
  }

  void _submitIcebreaker(String question) {
    final activity = ChatActivity(
      type: ActivityType.icebreaker,
      title: '⚡ Icebreaker Spark',
      creatorId: widget.currentUserId,
      prompt: question,
      blurBoost: 0.10,
    );

    widget.onSendActivity(activity);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
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
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'In-Chat Activities',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt_rounded, size: 16, color: AppTheme.primaryColor),
                      SizedBox(width: 4),
                      Text(
                        'Boosts Unblur',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.primaryColor,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: const [
              Tab(text: '2 Truths & Lie'),
              Tab(text: 'Would You Rather'),
              Tab(text: 'Icebreakers'),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTwoTruthsTab(),
                _buildWouldYouRatherTab(),
                _buildIcebreakersTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTwoTruthsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select which one is your LIE:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
              ),
              TextButton.icon(
                onPressed: _loadRandomTwoTruths,
                icon: const Icon(Icons.shuffle_rounded, size: 16),
                label: const Text('Randomize', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          _buildStatementField(controller: _statement1, index: 0, hint: 'Statement 1 (Truth or Lie)'),
          const SizedBox(height: 10),
          _buildStatementField(controller: _statement2, index: 1, hint: 'Statement 2 (Truth or Lie)'),
          const SizedBox(height: 10),
          _buildStatementField(controller: _statement3, index: 2, hint: 'Statement 3 (Truth or Lie)'),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: _submitTwoTruths,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text(
              'Challenge Match (+25% Unblur)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatementField({
    required TextEditingController controller,
    required int index,
    required String hint,
  }) {
    final bool isLie = _lieIndex == index;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isLie ? const Color(0xFFFEF2F2) : AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isLie ? const Color(0xFFEF4444) : AppTheme.dividerColor,
          width: isLie ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => _lieIndex = index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isLie ? const Color(0xFFEF4444) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isLie ? const Color(0xFFEF4444) : AppTheme.dividerColor),
              ),
              child: Text(
                isLie ? 'LIE ❌' : 'TRUTH',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isLie ? Colors.white : AppTheme.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: 2,
              minLines: 1,
              style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWouldYouRatherTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Craft two college dilemmas:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
              ),
              TextButton.icon(
                onPressed: _loadRandomWyr,
                icon: const Icon(Icons.shuffle_rounded, size: 16),
                label: const Text('Randomize', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _wyrOptionA,
            decoration: InputDecoration(
              labelText: 'Option A',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              filled: true,
              fillColor: AppTheme.backgroundColor,
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              '— OR —',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textMuted, fontSize: 12),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _wyrOptionB,
            decoration: InputDecoration(
              labelText: 'Option B',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              filled: true,
              fillColor: AppTheme.backgroundColor,
            ),
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: _submitWouldYouRather,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text(
              'Send Dilemma (+15% Unblur)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcebreakersTab() {
    final icebreakers = [
      "If you could audit any class on campus purely for fun, what would it be?",
      "Best campus study hideaway: dead silence or buzzing cafe?",
      "What is your ultimate late-night comfort food order after studying?",
      "What is the most niche hyper-fixation or hobby you have right now?",
      "If you had a warning label on first meeting you, what would it say?",
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: icebreakers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final q = icebreakers[index];
        return Material(
          color: const Color(0xFFF5F3FF),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _submitIcebreaker(q),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFDDD6FE)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flash_on_rounded, color: Color(0xFF7C3AED), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      q,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  const Icon(Icons.send_rounded, color: Color(0xFF7C3AED), size: 18),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
