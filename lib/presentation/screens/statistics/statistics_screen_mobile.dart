import 'package:aegis/data/repositories/statistics_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:aegis/core/utils/color_utils.dart';
import 'package:aegis/presentation/viewmodels/statistics_viewmodel.dart';
import 'package:aegis/presentation/screens/settings/settings_screen_mobile.dart';
import 'package:aegis/core/providers/database_provider.dart';

class StatisticsScreenMobile extends ConsumerStatefulWidget {
  const StatisticsScreenMobile({super.key});

  @override
  ConsumerState<StatisticsScreenMobile> createState() =>
      _StatisticsScreenMobileState();
}

class _StatisticsScreenMobileState
    extends ConsumerState<StatisticsScreenMobile> {
  final PageController _kpiPageController = PageController(
    viewportFraction: 0.5,
    initialPage: 1000,
  );
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
      return '${start.day} ${monthFormat.format(start).capitalize()} - ${end.day} ${monthFormat.format(end).capitalize()}';
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

  Widget _buildKpiCardByIndex(int index, StatisticsState state) {
    switch (index) {
      case 0:
        return _KpiCard(
            title: 'Tiempo Foco',
            value: _formatDuration(state.totalFocusSeconds));
      case 1:
        return _KpiCard(
            title: 'Tareas', value: state.completedTasks.toString());
      case 2:
        return _KpiCard(
            title: 'Distracciones', value: state.distractionsCount.toString());
      case 3:
        return _KpiCard(
            title: 'Estimaciones',
            value: '${state.estimationAccuracy.toStringAsFixed(0)}%');
      case 4:
        return _KpiCard(title: 'Hábitos', value: '${state.habitStreak} d');
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(statisticsViewModelProvider);

    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF6366F1)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        titleSpacing: 0,
        title: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Análisis',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        backgroundColor: const Color(0xFFF8FAFC),
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.settings, color: Color(0xFF1E293B)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreenMobile(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final db = ref.read(databaseProvider);
          await db.seedTestStatistics();
          ref.read(statisticsViewModelProvider.notifier).loadStatistics();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('¡Datos de prueba generados! 🚀')),
            );
          }
        },
        icon: const Icon(Icons.science),
        label: const Text('Generar Datos'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyHeaderDelegate(
              height: 76,
              child: Column(
                children: [
                  const Divider(color: Color(0xFFE2E8F0), height: 1),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
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
                                  onTap: () => _changePeriod(ChartPeriod.week),
                                ),
                                _PeriodButton(
                                  label: '1M',
                                  isSelected:
                                      state.currentPeriod == ChartPeriod.month,
                                  onTap: () => _changePeriod(ChartPeriod.month),
                                ),
                                _PeriodButton(
                                  label: '1A',
                                  isSelected:
                                      state.currentPeriod == ChartPeriod.year,
                                  onTap: () => _changePeriod(ChartPeriod.year),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                    minWidth: 32, minHeight: 32),
                                icon: const Icon(Icons.arrow_left,
                                    color: Color(0xFF475569)),
                                onPressed: () => _navigateDate(false),
                              ),
                              InkWell(
                                onTap: () => _pickDate(context),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0, vertical: 8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: const Color(0xFFE2E8F0)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.02),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    _formatDateRange(state.startDate,
                                        state.endDate, state.currentPeriod),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                    minWidth: 32, minHeight: 32),
                                icon: const Icon(Icons.arrow_right,
                                    color: Color(0xFF475569)),
                                onPressed: () => _navigateDate(true),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(color: Color(0xFFE2E8F0), height: 1),
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
                            ? const Color(0xFF6366F1)
                            : const Color(0xFFCBD5E1),
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
                      _ChartContainer(
                        title: 'Rendimiento Diario (Horas)',
                        child: _buildFocusBarChart(state.chartData),
                      ),
                      const SizedBox(height: 24),
                      _ChartContainer(
                        title: 'Rendimiento Diario (Tareas)',
                        trailing: 'Total: ${state.completedTasks}',
                        child: _buildTasksLineChart(state.chartData),
                      ),
                      const SizedBox(height: 24),
                      _ChartContainer(
                        title: 'Estimación vs Real (Horas)',
                        showLegend: true,
                        child: _buildGroupedBarChart(state.chartData),
                      ),
                      const SizedBox(height: 24),
                      _ChartContainer(
                        title: 'Distribución por Proyectos',
                        child: _buildProjectPieChart(state.projectDistribution),
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
    final double barWidth = isDense ? 4.0 : 12.0;

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
                    fontSize: 10),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  if (isDense && value.toInt() % 3 != 0) {
                    return const SizedBox();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      data[value.toInt()].label,
                      style: TextStyle(
                        color: const Color(0xFF64748B),
                        fontSize: isDense ? 9 : 10,
                        fontWeight: FontWeight.bold,
                      ),
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
              reservedSize: 24,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}h',
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9),
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
          horizontalInterval: maxY / 3 > 0 ? maxY / 3 : 1,
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
                  '${spot.y.toInt()}',
                  const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10),
                );
              }).toList();
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 3 > 0 ? maxY / 3 : 1,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: const Color(0xFFF1F5F9), strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  if (isDense && value.toInt() % 3 != 0) {
                    return const SizedBox();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      data[value.toInt()].label,
                      style: TextStyle(
                        color: const Color(0xFF64748B),
                        fontSize: isDense ? 9 : 10,
                        fontWeight: FontWeight.bold,
                      ),
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
              reservedSize: 24,
              getTitlesWidget: (value, meta) {
                if (value % 1 != 0) return const SizedBox();
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9),
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
    final double barWidth = isDense ? 3.0 : 8.0;
    final double barsSpace = isDense ? 1.0 : 2.0;

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
              final label = isActual ? 'R: ' : 'E: ';
              return BarTooltipItem(
                '$label${_formatDuration(seconds)}',
                const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  if (isDense && value.toInt() % 3 != 0) {
                    return const SizedBox();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      data[value.toInt()].label,
                      style: TextStyle(
                        color: const Color(0xFF64748B),
                        fontSize: isDense ? 9 : 10,
                        fontWeight: FontWeight.bold,
                      ),
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
              reservedSize: 24,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}h',
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9),
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
          horizontalInterval: maxY / 3 > 0 ? maxY / 3 : 1,
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
        centerSpaceRadius: 30,
        sections: data.map((p) {
          return PieChartSectionData(
            color: ColorUtils.parseColor(p.colorHex),
            value: p.taskCount.toDouble(),
            title: '${p.taskCount}',
            radius: 35,
            titleStyle: const TextStyle(
                fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
          );
        }).toList(),
        pieTouchData: PieTouchData(
          enabled: true,
          touchCallback: (FlTouchEvent event, pieTouchResponse) {},
        ),
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _StickyHeaderDelegate({required this.child, required this.height});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFFF8FAFC),
      height: height,
      alignment: Alignment.center,
      child: child,
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            fontSize: 13,
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

  const _KpiCard({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
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
              fontSize: 24,
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
      height: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              if (trailing != null)
                Text(
                  trailing!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
            ],
          ),
          if (showLegend) ...[
            const SizedBox(height: 8),
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
          const SizedBox(height: 16),
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
              fontSize: 10,
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
