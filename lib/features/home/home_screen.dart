import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/report_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:intl/intl.dart';
import '../../core/widgets/status_chip.dart';
import '../../core/theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsyncValue = ref.watch(reportListProvider);
    final user = ref.watch(authProvider).value;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: reportsAsyncValue.when(
          loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off_outlined, size: 40, color: AppTheme.textMuted),
                  const SizedBox(height: 16),
                  Text(
                    'FAILED TO LOAD',
                    style: AppTheme.labelStyle,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$err',
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: () => ref.refresh(reportListProvider),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.text,
                      side: const BorderSide(color: AppTheme.hairline),
                    ),
                    child: const Text('RETRY', style: TextStyle(letterSpacing: 2, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),
          data: (response) {
            final reports = response.reports;
            final total = response.total;

            return RefreshIndicator(
              onRefresh: () async => ref.refresh(reportListProvider.future),
              color: AppTheme.accent,
              backgroundColor: AppTheme.surface2,
              child: CustomScrollView(
                slivers: [
                  // Header
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
                            'My Reports',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 32),
                          ),
                          if (user != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              user.name.toUpperCase(),
                              style: AppTheme.labelStyle,
                            ),
                          ],
                          const SizedBox(height: 32),

                          // Stats row
                          Row(
                            children: [
                              _StatCard(label: 'TOTAL', value: total.toString()),
                              const SizedBox(width: 12),
                              _StatCard(
                                label: 'SUBMITTED',
                                value: reports.where((r) => r.status.value == 'submitted').length.toString(),
                              ),
                              const SizedBox(width: 12),
                              _StatCard(
                                label: 'RESOLVED',
                                value: reports.where((r) => r.status.value == 'resolved').length.toString(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Section label
                          Container(
                            padding: const EdgeInsets.only(bottom: 12),
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: AppTheme.hairline, width: 1)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('RECENT', style: AppTheme.labelStyle),
                                Text('${reports.length} ITEM${reports.length != 1 ? 'S' : ''}', style: AppTheme.labelStyle),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // List
                  if (reports.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.inbox_outlined, size: 48, color: AppTheme.textMuted),
                            const SizedBox(height: 16),
                            Text('NO REPORTS YET', style: AppTheme.labelStyle),
                            const SizedBox(height: 8),
                            const Text(
                              'Tap NEW in the bottom bar to submit your first report.',
                              style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final report = reports[index];
                          final dateFormatted = DateFormat('MMM d, yyyy').format(report.createdAt);

                          return GestureDetector(
                            onTap: () => context.push('/report/${report.reportId}'),
                            child: Container(
                              margin: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                              decoration: const BoxDecoration(
                                border: Border(bottom: BorderSide(color: AppTheme.hairline, width: 1)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Row(
                                  children: [
                                    // Image thumbnail
                                    Container(
                                      width: 72,
                                      height: 72,
                                      decoration: BoxDecoration(
                                        color: AppTheme.surface2,
                                        borderRadius: BorderRadius.circular(4),
                                        image: DecorationImage(
                                          image: NetworkImage(report.imageUrl),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            report.category.label.toUpperCase(),
                                            style: const TextStyle(
                                              fontFamily: 'Michroma',
                                              fontSize: 13,
                                              color: AppTheme.text,
                                              letterSpacing: 0.5,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(dateFormatted, style: AppTheme.labelStyle),
                                          const SizedBox(height: 8),
                                          StatusChip(status: report.status.value),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right, color: AppTheme.textMuted, size: 20),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: reports.length,
                      ),
                    ),
                  const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border.all(color: AppTheme.hairline, width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Michroma',
                fontSize: 28,
                color: AppTheme.text,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: AppTheme.labelStyle),
          ],
        ),
      ),
    );
  }
}
