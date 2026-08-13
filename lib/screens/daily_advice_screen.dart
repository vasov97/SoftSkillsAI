import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softai/extensions/l10n_extension.dart';
import 'package:softai/widgets/app_bottom_bar.dart';

class DailyAdviceScreen extends StatefulWidget {
  final String tip;
  final String explanation;

  const DailyAdviceScreen({
    super.key,
    required this.tip,
    this.explanation = '',
  });

  @override
  State<DailyAdviceScreen> createState() => _DailyAdviceScreenState();
}

class _DailyAdviceScreenState extends State<DailyAdviceScreen> {
  bool _applied = false;
  List<Map<String, String>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final keys =
        prefs.getKeys().where((k) => k.startsWith('dailyTip_')).toList();
    keys.sort((a, b) => b.compareTo(a));

    final now = DateTime.now();
    final List<Map<String, String>> history = [];

    for (final key in keys) {
      final dateStr = key.replaceFirst('dailyTip_', '');
      final tip = prefs.getString(key) ?? '';
      if (tip.isEmpty) continue;

      try {
        final date = DateTime.parse(dateStr);
        final diff = now.difference(date).inDays;
        final daysAgo = diff == 0
            ? (context.isEnglish ? 'today' : 'danas')
            : diff == 1
                ? (context.isEnglish ? '1 day ago' : 'pre 1 dan')
                : (context.isEnglish ? '$diff days ago' : 'pre $diff dana');

        history.add({'tip': tip, 'daysAgo': daysAgo});
      } catch (_) {}
    }

    setState(() => _history = history);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          // MainScreen handles tab switching via its own state
        },
      ),
      backgroundColor: const Color(0xFF006FFF),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Skillena',
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 84, 204, 204),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'AI',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF006FFF),
                  Color(0xFF00AAF2),
                  Color(0xFF00E5E5),
                  Color(0xFF0BFF96),
                ],
                stops: [0.0, 0.24, 0.49, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    l10n.dailyAdvice,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Main advice card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quote marks
                        const Text(
                          '\u201C\u201C',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0066FF),
                            height: 0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Main tip
                        Text(
                          widget.tip,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E),
                            height: 1.4,
                          ),
                        ),
                        if (widget.explanation.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            widget.explanation,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              height: 1.5,
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        // Apply today button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() => _applied = !_applied);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _applied
                                  ? const Color(0xFF00CC88)
                                  : const Color(0xFF0055CC),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _applied ? l10n.applied : l10n.applyToday,
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  _applied
                                      ? Icons.check_circle
                                      : Icons.check_circle_outline,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // History section
                  Text(
                    l10n.adviceHistory,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color.fromARGB(255, 8, 8, 8),
                    ),
                  ),
                  const SizedBox(height: 14),

                  if (_history.isEmpty)
                    Text(
                      l10n.noAdviceHistory,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        color: const Color.fromARGB(255, 8, 8, 8)
                            .withValues(alpha: 0.6),
                      ),
                    )
                  else
                    ...List.generate(_history.length, (index) {
                      final item = _history[index];
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 63, 63, 63)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color.fromARGB(255, 48, 48, 48)
                                .withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item['tip'] ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color.fromARGB(255, 10, 10, 10),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              item['daysAgo'] ?? '',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 12,
                                color: const Color.fromARGB(255, 10, 10, 10)
                                    .withValues(alpha: 0.6),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
