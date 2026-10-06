import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_stats_provider.dart';
import '../../core/theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.value;
    final statsAsync = ref.watch(userStatsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: user == null
            ? const Center(child: CircularProgressIndicator(strokeWidth: 1.5))
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOMORROW',
                            style: TextStyle(
                              fontFamily: 'Michroma',
                              fontSize: 11,
                              letterSpacing: 5,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Profile',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 32),
                          ),
                          const SizedBox(height: 32),

                          // Avatar
                          Row(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: AppTheme.surface2,
                                  border: Border.all(color: AppTheme.hairline, width: 1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Center(
                                  child: Text(
                                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                                    style: const TextStyle(
                                      fontFamily: 'Michroma',
                                      fontSize: 28,
                                      color: AppTheme.text,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.name.toUpperCase(),
                                      style: const TextStyle(
                                        fontFamily: 'Michroma',
                                        fontSize: 16,
                                        color: AppTheme.text,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(user.role.name.toUpperCase(), style: AppTheme.labelStyle),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Info rows
                          _InfoRow(label: 'EMAIL', value: user.email),
                          
                          // Dynamic Stats from Gamification
                          statsAsync.when(
                            data: (stats) => Column(
                              children: [
                                _InfoRow(
                                  label: 'RANK', 
                                  value: stats.rank,
                                  valueColor: AppTheme.accent,
                                ),
                                _InfoRow(
                                  label: 'CITIZEN POINTS', 
                                  value: '${stats.points}',
                                ),
                                _InfoRow(
                                  label: 'RESOLVED', 
                                  value: '${stats.resolvedReports} Reports',
                                ),
                              ],
                            ),
                            loading: () => const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: CircularProgressIndicator(strokeWidth: 1.5),
                            ),
                            error: (_, __) => const SizedBox(),
                          ),
                          
                          if (user.departmentId != null)
                            _InfoRow(label: 'DEPARTMENT', value: user.departmentId!),
                          const SizedBox(height: 40),

                          // Logout
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () async {
                                await ref.read(authProvider.notifier).logout();
                                if (context.mounted) context.go('/login');
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.statusRejected,
                                side: const BorderSide(color: AppTheme.statusRejected, width: 1),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                              child: const Text(
                                'SIGN OUT',
                                style: TextStyle(fontFamily: 'Michroma', letterSpacing: 2, fontSize: 12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.hairline, width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: AppTheme.labelStyle),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: valueColor ?? AppTheme.text, fontFamily: 'Inter', fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

