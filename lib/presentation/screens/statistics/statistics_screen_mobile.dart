import 'package:aegis/core/providers/general_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aegis/presentation/viewmodels/statistics_viewmodel.dart';
import 'package:aegis/presentation/screens/settings/settings_screen_mobile.dart';
import 'package:aegis/core/providers/database_provider.dart';
import 'package:aegis/presentation/screens/statistics/components/statistics_components.dart';

class StatisticsScreenMobile extends ConsumerStatefulWidget {
  const StatisticsScreenMobile({super.key});

  @override
  ConsumerState<StatisticsScreenMobile> createState() =>
      _StatisticsScreenMobileState();
}

class _StatisticsScreenMobileState
    extends ConsumerState<StatisticsScreenMobile> {
  final PageController _kpiPageController =
      PageController(viewportFraction: 0.5, initialPage: 1000);
  int _currentKpiPage = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(statisticsViewModelProvider.notifier).loadStatistics());
  }

  @override
  void dispose() {
    _kpiPageController.dispose();
    super.dispose();
  }

  Widget _buildKpiCardByIndex(int index, StatisticsState state) {
    switch (index) {
      case 0:
        return KpiCard(
            title: 'Tiempo Foco',
            value: formatChartDuration(state.totalFocusSeconds));
      case 1:
        return KpiCard(title: 'Tareas', value: state.completedTasks.toString());
      case 2:
        return KpiCard(
            title: 'Distracciones', value: state.distractionsCount.toString());
      case 3:
        return KpiCard(
            title: 'Estimaciones',
            value: '${state.estimationAccuracy.toStringAsFixed(0)}%');
      case 4:
        return KpiCard(title: 'Hábitos', value: '${state.habitStreak} d');
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(statisticsViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final devMode = ref.watch(devModeProvider);

    if (state.isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
            child: CircularProgressIndicator(color: colorScheme.primary)),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('Análisis', style: textTheme.displayLarge),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(Icons.settings, color: colorScheme.onSurface),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsScreenMobile()));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: devMode == true
          ? FloatingActionButton.extended(
              onPressed: () async {
                final db = ref.read(databaseProvider);
                await db.seedTestStatistics();
                ref.read(statisticsViewModelProvider.notifier).loadStatistics();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('¡Datos de prueba generados! 🚀')));
                }
              },
              icon: const Icon(Icons.science),
              label: const Text('Generar Datos'),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            )
          : null,
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyHeaderDelegate(
              height: 76,
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                children: [
                  Divider(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                      height: 1),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: StatisticsHeaderControls(isMobile: true),
                    ),
                  ),
                  Divider(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                      height: 1),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: SizedBox(
                    height: 100,
                    child: PageView.builder(
                      controller: _kpiPageController,
                      padEnds: false,
                      onPageChanged: (index) {
                        setState(() {
                          _currentKpiPage = index % 5;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: _buildKpiCardByIndex(index % 5, state),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: _currentKpiPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentKpiPage == index
                            ? colorScheme.primary
                            : colorScheme.outline.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      ChartContainer(
                        height: 320,
                        title: 'Rendimiento diario (Horas)',
                        child: FocusBarChart(data: state.chartData),
                      ),
                      const SizedBox(height: 24),
                      ChartContainer(
                        height: 320,
                        title: 'Rendimiento diario (Tareas)',
                        trailing: 'Total: ${state.completedTasks}',
                        child: TasksLineChart(data: state.chartData),
                      ),
                      const SizedBox(height: 24),
                      ChartContainer(
                        height: 320,
                        title: 'Estimación vs Real (Horas)',
                        showLegend: true,
                        child: GroupedBarChart(data: state.chartData),
                      ),
                      const SizedBox(height: 24),
                      ChartContainer(
                        height: 320,
                        title: 'Distribución por areas',
                        child: AreaPieChart(data: state.areaDistribution),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;
  final Color color;

  _StickyHeaderDelegate(
      {required this.child, required this.height, required this.color});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
        color: color,
        height: height,
        alignment: Alignment.center,
        child: child);
  }

  @override
  double get maxExtent => height;
  @override
  double get minExtent => height;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
