import 'package:aegis/core/providers/database_provider.dart';
import 'package:aegis/core/providers/general_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aegis/presentation/viewmodels/statistics_viewmodel.dart';
import 'package:aegis/presentation/screens/statistics/components/statistics_components.dart';

class StatisticsScreenDesktop extends ConsumerStatefulWidget {
  const StatisticsScreenDesktop({super.key});

  @override
  ConsumerState<StatisticsScreenDesktop> createState() =>
      _StatisticsScreenDesktopState();
}

class _StatisticsScreenDesktopState
    extends ConsumerState<StatisticsScreenDesktop> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(statisticsViewModelProvider.notifier).loadStatistics());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(statisticsViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final devMode = ref.watch(devModeProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
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
      body: state.isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 48,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Análisis',
                            style: textTheme.displayLarge?.copyWith(
                                fontWeight: FontWeight.bold, fontSize: 32)),
                        const StatisticsHeaderControls(isMobile: false),
                      ],
                    ),
                  ),
                  Divider(
                      height: 32,
                      color: colorScheme.outline.withValues(alpha: 0.1)),
                  Row(
                    children: [
                      Expanded(
                          child: KpiCard(
                              title: 'Tiempo Foco',
                              value: formatChartDuration(
                                  state.totalFocusSeconds))),
                      const SizedBox(width: 16),
                      Expanded(
                          child: KpiCard(
                              title: 'Tareas',
                              value: state.completedTasks.toString())),
                      const SizedBox(width: 16),
                      Expanded(
                          child: KpiCard(
                              title: 'Estimaciones',
                              value:
                                  '${state.estimationAccuracy.toStringAsFixed(0)}%')),
                      const SizedBox(width: 16),
                      Expanded(
                          child: KpiCard(
                              title: 'Racha Hábitos',
                              value: '${state.habitStreak} días')),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: ChartContainer(
                            title: 'Rendimiento Diario (Horas)',
                            child: FocusBarChart(data: state.chartData),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: ChartContainer(
                            title: 'Rendimiento Diario (Tareas)',
                            trailing: 'Total: ${state.completedTasks}',
                            child: TasksLineChart(data: state.chartData),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: ChartContainer(
                            title: 'Estimación vs Real (Horas)',
                            showLegend: true,
                            child: GroupedBarChart(data: state.chartData),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 2,
                          child: ChartContainer(
                            title: 'Distribución por Proyectos',
                            child: ProjectPieChart(
                                data: state.projectDistribution),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
