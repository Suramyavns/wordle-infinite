import 'package:Wordle/data/constants.dart';
import 'package:Wordle/utils/auth_service.dart';
import 'package:Wordle/utils/firestore_service.dart';
import 'package:Wordle/widgets/wordle_animated_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  bool isLoading = false;

  Future<void> handleLogOut() async {
    setState(() => isLoading = true);
    try {
      await AuthService().signOutWithGoogle();
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            children: [
              const WordleAnimatedWidget(title: 'WORDLE'),
              const SizedBox(height: 32),

              if (user != null) ...[
                Text(
                  'STATISTICS',
                  style: WTextStyle.headerTextStyle.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 16),
                _buildStatsStream(user.uid),
              ],

              const Spacer(),
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsStream(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: getStatsFromFirestore(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        final totalGames = docs.length;
        final wins = docs.where((d) => (d.data() as Map)['wasGuessed'] == true);
        final winCount = wins.length;
        final winRate = totalGames == 0
            ? 0
            : (winCount / totalGames * 100).round();

        int bestScore = 0;
        final distribution = List<int>.filled(6, 0);

        for (var doc in wins) {
          final data = doc.data() as Map;
          final tries = data['tries'] as int;
          if (tries >= 1 && tries <= 6) {
            distribution[tries - 1]++;
            if (bestScore == 0 || tries < bestScore) {
              bestScore = tries;
            }
          }
        }

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(label: 'Played', value: '$totalGames'),
                _StatItem(label: 'Win %', value: '$winRate'),
                _StatItem(
                  label: 'Best',
                  value: bestScore == 0 ? '-' : '$bestScore',
                ),
              ],
            ),
            const SizedBox(height: 40),
            Text(
              'GUESS DISTRIBUTION',
              style: WTextStyle.headerTextStyle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 16),
            _GuessDistribution(distribution: distribution),
          ],
        );
      },
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton(
      onPressed: isLoading ? null : handleLogOut,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.red,
        elevation: 0,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.red.shade800),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.red,
              ),
            )
          : const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _GuessDistribution extends StatelessWidget {
  final List<int> distribution;

  const _GuessDistribution({required this.distribution});

  @override
  Widget build(BuildContext context) {
    final maxVal = distribution.reduce((a, b) => a > b ? a : b);

    return Column(
      children: List.generate(6, (index) {
        final count = distribution[index];
        final ratio = maxVal == 0 ? 0.0 : (count / maxVal);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: ratio.clamp(0.08, 1.0),
                      child: Container(
                        height: 20,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade400,
                              Colors.green.shade700,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
