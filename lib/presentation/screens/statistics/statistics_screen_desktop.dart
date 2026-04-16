import 'package:aegis/data/repositories/statistics_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:aegis/core/utils/color_utils.dart';
import 'package:aegis/presentation/viewmodels/statistics_viewmodel.dart';

class StatisticsScreenDesktop extends ConsumerStatefulWidget {
  const StatisticsScreenDesktop({super.key});

  @override
  ConsumerState<StatisticsScreenDesktop> createState() =>
      _StatisticsScreenDesktopState();
}

class _StatisticsScreenDesktopState
    extends ConsumerState<StatisticsScreenDesktop> {
  final ValueNotifier<bool> _isHoveringDate = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(statisticsViewModelProvider.notifier).loadStatistics());
  }

  @override
  void dispose() {
    _isHoveringDate.dispose();
    super.dispose();
  }

  void _changePeriod(ChartPeriod newPeriod) {
    final now = DateTime.now();
    DateTime start;
    DateTime end;

    if (newPeriod == ChartPeriod.week) {
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      end = start
          .add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
    } else if (newPeriod == ChartPeriod.month) {
      start = DateTime(now.year, now.month, 1);
      final nextMonth = DateTime(now.year, now.month + 1, 1);
      end = nextMonth.subtract(const Duration(seconds: 1));
    } else {
      start = DateTime(now.year, 1, 1);
      end = DateTime(now.year, 12, 31, 23, 59, 59);
    }

    ref
        .read(statisticsViewModelProvider.notifier)
        .changePeriod(newPeriod, start, end);
  }

  void _navigateDate(bool forward) {
    final state = ref.read(statisticsViewModelProvider);
    final currentStart = state.startDate;
    DateTime start;
    DateTime end;

    if (state.currentPeriod == ChartPeriod.week) {
      start = forward
          ? currentStart.add(const Duration(days: 7))
          : currentStart.subtract(const Duration(days: 7));
      end = start
          .add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
    } else if (state.currentPeriod == ChartPeriod.month) {
      start = forward
          ? DateTime(currentStart.year, currentStart.month + 1, 1)
          : DateTime(currentStart.year, currentStart.month - 1, 1);
      final nextMonth = DateTime(start.year, start.month + 1, 1);
      end = nextMonth.subtract(const Duration(seconds: 1));
    } else {
      start = forward
          ? DateTime(currentStart.year + 1, 1, 1)
          : DateTime(currentStart.year - 1, 1, 1);
      end = DateTime(start.year, 12, 31, 23, 59, 59);
    }

    ref
        .read(statisticsViewModelProvider.notifier)
        .changePeriod(state.currentPeriod, start, end);
  }

  Future<void> _pickDate(BuildContext context) async {
    final state = ref.read(statisticsViewModelProvider);

    final picked = await showDatePicker(
      context: context,
      initialDate: state.startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6366F1),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      DateTime start;
      DateTime end;

      if (state.currentPeriod == ChartPeriod.week) {
        final startOfWeek = picked.subtract(Duration(days: picked.weekday - 1));
        start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        end = start
            .add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
      } else if (state.currentPeriod == ChartPeriod.month) {
        start = DateTime(picked.year, picked.month, 1);
        final nextMonth = DateTime(picked.year, picked.month + 1, 1);
        end = nextMonth.subtract(const Duration(seconds: 1));
      } else {
        start = DateTime(picked.year, 1, 1);
        end = DateTime(picked.year, 12, 31, 23, 59, 59);
      }

      ref
          .read(statisticsViewModelProvider.notifier)
          .changePeriod(state.currentPeriod, start, end);
    }
  }

  String _formatDateRange(DateTime start, DateTime end, ChartPeriod period) {
    final monthFormat = DateFormat('MMM', 'es');
    if (period == ChartPeriod.week) {
      return '${monthFormat.format(start).capitalize()} ${start.day} - ${monthFormat.format(end).capitalize()} ${end.day}';
    } else if (period == ChartPeriod.month) {
      return '${monthFormat.format(start).capitalize()} ${start.year}';
    } else {
      return '${start.year}';
    }
  }

  String _formatDuration(int totalSeconds) {
    if (totalSeconds == 0) return "0h 0m";
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(statisticsViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6366F1)))
          : Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 46,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Análisis',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _PeriodButton(
                                    label: '1S',
                                    isSelected:
                                        state.currentPeriod == ChartPeriod.week,
                                    onTap: () =>
                                        _changePeriod(ChartPeriod.week),
                                  ),
                                  _PeriodButton(
                                    label: '1M',
                                    isSelected: state.currentPeriod ==
                                        ChartPeriod.month,
                                    onTap: () =>
                                        _changePeriod(ChartPeriod.month),
                                  ),
                                  _PeriodButton(
                                    label: '1A',
                                    isSelected:
                                        state.currentPeriod == ChartPeriod.year,
                                    onTap: () =>
                                        _changePeriod(ChartPeriod.year),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            Row(
                              children: [
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.arrow_left,
                                      color: Color(0xFF475569)),
                                  onPressed: () => _navigateDate(false),
                                ),
                                InkWell(
                                  onTap: () => _pickDate(context),
                                  onHover: (hovering) {
                                    _isHoveringDate.value = hovering;
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: ValueListenableBuilder<bool>(
                                    valueListenable: _isHoveringDate,
                                    builder: (context, isHovering, child) {
                                      return Container(
                                        width: 140,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: isHovering
                                              ? const Color(0xFFE0E7FF)
                                              : const Color(0xFFEEF2FF),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: Text(
                                            _formatDateRange(
                                                state.startDate,
                                                state.endDate,
                                                state.currentPeriod),
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF1E293B),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.arrow_right,
                                      color: Color(0xFF475569)),
                                  onPressed: () => _navigateDate(true),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 16, color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _KpiCard(
                          title: 'Tiempo Foco',
                          value: _formatDuration(state.totalFocusSeconds),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _KpiCard(
                          title: 'Tareas',
                          value: state.completedTasks.toString(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _KpiCard(
                          title: 'Estimaciones',
                          value:
                              '${state.estimationAccuracy.toStringAsFixed(0)}%',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _KpiCard(
                          title: 'Racha Hábitos',
                          value: '${state.habitStreak} días',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: _ChartContainer(
                            title: 'Rendimiento Diario (Horas)',
                            child: _buildFocusBarChart(state.chartData),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _ChartContainer(
                            title: 'Rendimiento Diario (Tareas)',
                            trailing: 'Total: ${state.completedTasks}',
                            child: _buildTasksLineChart(state.chartData),
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
                          child: _ChartContainer(
                            title: 'Estimación vs Real (Horas)',
                            showLegend: true,
                            child: _buildGroupedBarChart(state.chartData),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 2,
                          child: _ChartContainer(
                            title: 'Distribución por Proyectos',
                            child: _buildProjectPieChart(
                                state.projectDistribution),
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

  Widget _buildFocusBarChart(List<ChartDataPoint> data) {
    if (data.isEmpty || data.every((d) => d.actualSeconds == 0)) {
      return const Center(
          child:
              Text('No hay datos', style: TextStyle(color: Color(0xFF94A3B8))));
    }

    double maxY = 0;
    for (var d in data) {
      final hours = d.actualSeconds / 3600;
      if (hours > maxY) maxY = hours;
    }
    if (maxY == 0) maxY = 1;

    final isDense = data.length > 12;
    final double barWidth = isDense ? 8.0 : 16.0;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY * 1.2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => const Color(0xFF1E293B),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final seconds = data[groupIndex].actualSeconds;
              return BarTooltipItem(
                _formatDuration(seconds),
                const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value == value.toInt() &&
                    value.toInt() >= 0 &&
                    value.toInt() < data.length) {
                  if (isDense && value.toInt() % 2 != 0) {
                    return const SizedBox();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      data[value.toInt()].label,
                      style: TextStyle(
                          color: const Color(0xFF64748B),
                          fontSize: isDense ? 10 : 12,
                          fontWeight: FontWeight.bold),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}h',
                  style:
                      const TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
                );
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4 > 0 ? maxY / 4 : 1,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: const Color(0xFFF1F5F9), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        barGroups: data.map((d) {
          return BarChartGroupData(
            x: d.index,
            barRods: [
              BarChartRodData(
                toY: d.actualSeconds / 3600,
                color: const Color(0xFF94A3B8),
                width: barWidth,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTasksLineChart(List<ChartDataPoint> data) {
    if (data.isEmpty || data.every((d) => d.tasksCompleted == 0)) {
      return const Center(
          child:
              Text('No hay datos', style: TextStyle(color: Color(0xFF94A3B8))));
    }

    double maxY = 0;
    for (var d in data) {
      if (d.tasksCompleted > maxY) maxY = d.tasksCompleted.toDouble();
    }
    if (maxY == 0) maxY = 5;

    final isDense = data.length > 12;
    List<FlSpot> spots = data
        .map((d) => FlSpot(d.index.toDouble(), d.tasksCompleted.toDouble()))
        .toList();

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) => const Color(0xFF1E293B),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${spot.y.toInt()} Tareas',
                  const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                );
              }).toList();
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4 > 0 ? maxY / 4 : 1,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: const Color(0xFFF1F5F9), strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value == value.toInt() &&
                    value.toInt() >= 0 &&
                    value.toInt() < data.length) {
                  if (isDense && value.toInt() % 2 != 0) {
                    return const SizedBox();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      data[value.toInt()].label,
                      style: TextStyle(
                          color: const Color(0xFF64748B),
                          fontSize: isDense ? 10 : 12,
                          fontWeight: FontWeight.bold),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value % 1 != 0) return const SizedBox();
                return Text(
                  value.toInt().toString(),
                  style:
                      const TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
                );
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: data.length.toDouble() - 1,
        minY: 0,
        maxY: maxY * 1.2,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: const Color(0xFF10B981),
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(show: !isDense),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF10B981).withValues(alpha: 0.3),
                  const Color(0xFF10B981).withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedBarChart(List<ChartDataPoint> data) {
    if (data.isEmpty ||
        data.every((d) => d.actualSeconds == 0 && d.estimatedSeconds == 0)) {
      return const Center(
          child:
              Text('No hay datos', style: TextStyle(color: Color(0xFF94A3B8))));
    }

    double maxY = 0;
    for (var d in data) {
      final actualH = d.actualSeconds / 3600;
      final estH = d.estimatedSeconds / 3600;
      if (actualH > maxY) maxY = actualH;
      if (estH > maxY) maxY = estH;
    }
    if (maxY == 0) maxY = 1;

    final isDense = data.length > 12;
    final double barWidth = isDense ? 5.0 : 12.0;
    final double barsSpace = isDense ? 1.0 : 4.0;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY * 1.2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => const Color(0xFF1E293B),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final d = data[groupIndex];
              final isActual = rodIndex == 1;
              final seconds = isActual ? d.actualSeconds : d.estimatedSeconds;
              final label = isActual ? 'Real: ' : 'Est: ';
              return BarTooltipItem(
                '$label${_formatDuration(seconds)}',
                const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value == value.toInt() &&
                    value.toInt() >= 0 &&
                    value.toInt() < data.length) {
                  if (isDense && value.toInt() % 2 != 0) {
                    return const SizedBox();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      data[value.toInt()].label,
                      style: TextStyle(
                          color: const Color(0xFF64748B),
                          fontSize: isDense ? 10 : 12,
                          fontWeight: FontWeight.bold),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}h',
                  style:
                      const TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
                );
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4 > 0 ? maxY / 4 : 1,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: const Color(0xFFF1F5F9), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        barGroups: data.map((d) {
          return BarChartGroupData(
            x: d.index,
            barsSpace: barsSpace,
            barRods: [
              BarChartRodData(
                toY: d.estimatedSeconds / 3600,
                color: const Color(0xFF94A3B8).withValues(alpha: 0.6),
                width: barWidth,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
              ),
              BarChartRodData(
                toY: d.actualSeconds / 3600,
                color: const Color(0xFF6366F1),
                width: barWidth,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProjectPieChart(List<ProjectDistributionData> data) {
    if (data.isEmpty) {
      return const Center(
          child: Text('No hay tareas completadas',
              style: TextStyle(color: Color(0xFF94A3B8))));
    }

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: data.map((p) {
          return PieChartSectionData(
            color: ColorUtils.parseColor(p.colorHex),
            value: p.taskCount.toDouble(),
            title: '${p.taskCount}',
            radius: 40,
            titleStyle: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          );
        }).toList(),
        pieTouchData: PieTouchData(enabled: false),
      ),
    );
  }
}

class _PeriodButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2))
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color:
                isSelected ? const Color(0xFF6366F1) : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;

  const _KpiCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ChartContainer extends StatelessWidget {
  final String title;
  final String? trailing;
  final bool showLegend;
  final Widget child;

  const _ChartContainer({
    required this.title,
    this.trailing,
    this.showLegend = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              if (trailing != null)
                Text(
                  trailing!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              if (showLegend)
                Row(
                  children: [
                    _LegendItem(color: const Color(0xFF6366F1), label: 'Real'),
                    const SizedBox(width: 12),
                    _LegendItem(
                        color: const Color(0xFF94A3B8).withValues(alpha: 0.6),
                        label: 'Estimación'),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
