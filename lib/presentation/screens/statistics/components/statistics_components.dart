import 'package:aegis/data/repositories/statistics_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:aegis/core/utils/color_utils.dart';
import 'package:aegis/core/utils/format_utils.dart';
import 'package:aegis/presentation/viewmodels/statistics_viewmodel.dart';

String formatChartDuration(int totalSeconds) {
  if (totalSeconds == 0) return "0h 0m";
  final int hours = totalSeconds ~/ 3600;
  final int minutes = (totalSeconds % 3600) ~/ 60;
  if (hours > 0) return '${hours}h ${minutes}m';
  return '${minutes}m';
}

class StatisticsHeaderControls extends ConsumerWidget {
  final bool isMobile;
  const StatisticsHeaderControls({super.key, this.isMobile = false});

  void _changePeriod(WidgetRef ref, ChartPeriod newPeriod) {
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

  void _navigateDate(WidgetRef ref, bool forward) {
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

  Future<void> _pickDate(BuildContext context, WidgetRef ref) async {
    final state = ref.read(statisticsViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final picked = await showDatePicker(
      context: context,
      initialDate: state.startDate,
      firstDate: DateTime(2000),
      locale: const Locale('es', 'ES'),
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
      lastDate: DateTime(DateTime.now().year + 50),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: colorScheme,
          ),
          child: Localizations.override(
            context: context,
            locale: const Locale('es', 'ES'),
            child: child!,
          ),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(statisticsViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 1. Sector izquierdo: Botones de periodo
        Container(
          decoration: BoxDecoration(
            color: colorScheme.secondary,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PeriodButton(
                  label: '1S',
                  isSelected: state.currentPeriod == ChartPeriod.week,
                  onTap: () => _changePeriod(ref, ChartPeriod.week)),
              PeriodButton(
                  label: '1M',
                  isSelected: state.currentPeriod == ChartPeriod.month,
                  onTap: () => _changePeriod(ref, ChartPeriod.month)),
              PeriodButton(
                  label: '1A',
                  isSelected: state.currentPeriod == ChartPeriod.year,
                  onTap: () => _changePeriod(ref, ChartPeriod.year)),
            ],
          ),
        ),

        if (!isMobile)
          const SizedBox(width: 32)
        else
          const SizedBox(width: 8), // Margen seguro de separación en móvil

        // 2. Sector derecho: Controles de fecha (Envueltos en Expanded para que absorban la falta de espacio)
        Expanded(
          flex: isMobile ? 1 : 0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment:
                isMobile ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(
                    minWidth: isMobile ? 28 : 40,
                    minHeight: isMobile ? 28 : 40),
                icon: Icon(Icons.arrow_left,
                    color: colorScheme.onSurfaceVariant,
                    size: isMobile ? 24 : 28),
                onPressed: () => _navigateDate(ref, false),
              ),
              // FLEXIBLE: Si la pantalla es pequeña, este contenedor cederá terreno
              Flexible(
                child: InkWell(
                  onTap: () => _pickDate(context, ref),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 8.0 : 12.0,
                        vertical: isMobile ? 6.0 : 8.0),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.2)),
                    ),
                    // FITTEDBOX: Encogerá la fuente del texto mágicamente si no cabe
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        FormatUtils.formatDateRange(state.startDate,
                            state.endDate, state.currentPeriod),
                        textAlign: TextAlign.center,
                        style: (isMobile
                                ? textTheme.bodySmall
                                : textTheme.bodyMedium)
                            ?.copyWith(
                          fontSize: isMobile ? null : 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(
                    minWidth: isMobile ? 28 : 40,
                    minHeight: isMobile ? 28 : 40),
                icon: Icon(Icons.arrow_right,
                    color: colorScheme.onSurfaceVariant,
                    size: isMobile ? 24 : 28),
                onPressed: () => _navigateDate(ref, true),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PeriodButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const PeriodButton(
      {super.key,
      required this.label,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color:
                isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class KpiCard extends StatelessWidget {
  final String title;
  final String value;

  const KpiCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: textTheme.displayMedium?.copyWith(fontSize: 24),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class ChartContainer extends StatelessWidget {
  final String title;
  final String? trailing;
  final bool showLegend;
  final Widget child;
  final double? height;

  const ChartContainer(
      {super.key,
      required this.title,
      this.trailing,
      this.showLegend = false,
      required this.child,
      this.height});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              if (trailing != null)
                Text(trailing!,
                    style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant)),
            ],
          ),
          if (showLegend) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                _LegendItem(color: colorScheme.primary, label: 'Real'),
                const SizedBox(width: 12),
                _LegendItem(
                    color: colorScheme.outline.withValues(alpha: 0.5),
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
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class FocusBarChart extends StatefulWidget {
  final List<ChartDataPoint> data;
  const FocusBarChart({super.key, required this.data});

  @override
  State<FocusBarChart> createState() => _FocusBarChartState();
}

class _FocusBarChartState extends State<FocusBarChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (widget.data.isEmpty || widget.data.every((d) => d.actualSeconds == 0)) {
      return Center(
          child: Text('No hay datos',
              style: TextStyle(color: colorScheme.outline)));
    }

    double maxData = 0;
    for (var d in widget.data) {
      final hours = d.actualSeconds / 3600;
      if (hours > maxData) maxData = hours;
    }
    if (maxData == 0) maxData = 1;

    final double chartMaxY = (maxData * 1.2).ceilToDouble();
    final double interval =
        (chartMaxY / 3).ceilToDouble() > 0 ? (chartMaxY / 3).ceilToDouble() : 1;
    final isDense = widget.data.length > 12;
    final double barWidth = isDense ? 6.0 : 14.0;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: chartMaxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchCallback: (FlTouchEvent event, barTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  barTouchResponse == null ||
                  barTouchResponse.spot == null) {
                _touchedIndex = null;
                return;
              }
              final index = barTouchResponse.spot!.touchedBarGroupIndex;
              _touchedIndex = index == -1 ? null : index;
            });
          },
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => colorScheme.onSurface,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final seconds = widget.data[groupIndex].actualSeconds;
              return BarTooltipItem(
                formatChartDuration(seconds),
                TextStyle(
                    color: colorScheme.surface,
                    fontWeight: FontWeight.bold,
                    fontSize: 11),
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
                if (value.toInt() >= 0 && value.toInt() < widget.data.length) {
                  if (isDense && value.toInt() % 2 != 0) {
                    return const SizedBox();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      widget.data[value.toInt()].label,
                      style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: isDense ? 9 : 11,
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
              reservedSize: 28,
              interval: interval,
              getTitlesWidget: (value, meta) {
                if (value == meta.max && value % interval != 0) {
                  return const SizedBox.shrink();
                }
                return Text('${value.toInt()}h',
                    style: TextStyle(color: colorScheme.outline, fontSize: 10));
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
          horizontalInterval: interval,
          getDrawingHorizontalLine: (value) => FlLine(
              color: colorScheme.outline.withValues(alpha: 0.1),
              strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        barGroups: widget.data.asMap().entries.map((entry) {
          final isTouched = _touchedIndex == entry.key;
          final opacity = _touchedIndex == null || isTouched ? 1.0 : 0.3;
          return BarChartGroupData(
            x: entry.value.index,
            barRods: [
              BarChartRodData(
                toY: entry.value.actualSeconds / 3600,
                color: colorScheme.primary.withValues(alpha: opacity),
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
}

class TasksLineChart extends StatelessWidget {
  final List<ChartDataPoint> data;
  const TasksLineChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (data.isEmpty || data.every((d) => d.tasksCompleted == 0)) {
      return Center(
          child: Text('No hay datos',
              style: TextStyle(color: colorScheme.outline)));
    }

    double maxData = 0;
    for (var d in data) {
      if (d.tasksCompleted > maxData) maxData = d.tasksCompleted.toDouble();
    }
    if (maxData == 0) maxData = 5;

    final double chartMaxY = (maxData * 1.2).ceilToDouble();
    final double interval =
        (chartMaxY / 3).ceilToDouble() > 0 ? (chartMaxY / 3).ceilToDouble() : 1;
    final isDense = data.length > 12;

    List<FlSpot> spots = data
        .map((d) => FlSpot(d.index.toDouble(), d.tasksCompleted.toDouble()))
        .toList();

    return LineChart(
      LineChartData(
        maxY: chartMaxY,
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) => colorScheme.onSurface,
            getTooltipItems: (touchedSpots) {
              return touchedSpots
                  .map((spot) => LineTooltipItem(
                        '${spot.y.toInt()} Tareas',
                        TextStyle(
                            color: colorScheme.surface,
                            fontWeight: FontWeight.bold,
                            fontSize: 11),
                      ))
                  .toList();
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (value) => FlLine(
              color: colorScheme.outline.withValues(alpha: 0.1),
              strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  if (isDense && value.toInt() % 2 != 0) {
                    return const SizedBox();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      data[value.toInt()].label,
                      style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: isDense ? 9 : 11,
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
              reservedSize: 28,
              interval: interval,
              getTitlesWidget: (value, meta) {
                if (value == meta.max && value % interval != 0) {
                  return const SizedBox.shrink();
                }
                return Text(value.toInt().toString(),
                    style: TextStyle(color: colorScheme.outline, fontSize: 10));
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
                  const Color(0xFF10B981).withValues(alpha: 0.0)
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
}

class GroupedBarChart extends StatefulWidget {
  final List<ChartDataPoint> data;
  const GroupedBarChart({super.key, required this.data});

  @override
  State<GroupedBarChart> createState() => _GroupedBarChartState();
}

class _GroupedBarChartState extends State<GroupedBarChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.data.isEmpty ||
        widget.data
            .every((d) => d.actualSeconds == 0 && d.estimatedSeconds == 0)) {
      return Center(
          child: Text('No hay datos',
              style: TextStyle(color: colorScheme.outline)));
    }

    double maxData = 0;
    for (var d in widget.data) {
      final actualH = d.actualSeconds / 3600;
      final estH = d.estimatedSeconds / 3600;
      if (actualH > maxData) maxData = actualH;
      if (estH > maxData) maxData = estH;
    }
    if (maxData == 0) maxData = 1;

    final double chartMaxY = (maxData * 1.2).ceilToDouble();
    final double interval =
        (chartMaxY / 3).ceilToDouble() > 0 ? (chartMaxY / 3).ceilToDouble() : 1;

    final isDense = widget.data.length > 12;
    final double barWidth = isDense ? 4.0 : 10.0;
    final double barsSpace = isDense ? 1.0 : 3.0;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: chartMaxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchCallback: (FlTouchEvent event, barTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  barTouchResponse == null ||
                  barTouchResponse.spot == null) {
                _touchedIndex = null;
                return;
              }
              final index = barTouchResponse.spot!.touchedBarGroupIndex;
              _touchedIndex = index == -1 ? null : index;
            });
          },
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => colorScheme.onSurface,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final d = widget.data[groupIndex];
              final isActual = rodIndex == 1;
              final seconds = isActual ? d.actualSeconds : d.estimatedSeconds;
              return BarTooltipItem(
                '${isActual ? 'R:' : 'E:'} ${formatChartDuration(seconds)}',
                TextStyle(
                    color: colorScheme.surface,
                    fontWeight: FontWeight.bold,
                    fontSize: 11),
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
                if (value.toInt() >= 0 && value.toInt() < widget.data.length) {
                  if (isDense && value.toInt() % 2 != 0) {
                    return const SizedBox();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      widget.data[value.toInt()].label,
                      style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: isDense ? 9 : 11,
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
              reservedSize: 28,
              interval: interval,
              getTitlesWidget: (value, meta) {
                if (value == meta.max && value % interval != 0) {
                  return const SizedBox.shrink();
                }
                return Text('${value.toInt()}h',
                    style: TextStyle(color: colorScheme.outline, fontSize: 10));
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
          horizontalInterval: interval,
          getDrawingHorizontalLine: (value) => FlLine(
              color: colorScheme.outline.withValues(alpha: 0.1),
              strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        barGroups: widget.data.asMap().entries.map((entry) {
          final isTouched = _touchedIndex == entry.key;
          final opacity = _touchedIndex == null || isTouched ? 1.0 : 0.3;
          return BarChartGroupData(
            x: entry.value.index,
            barsSpace: barsSpace,
            barRods: [
              BarChartRodData(
                toY: entry.value.estimatedSeconds / 3600,
                color: colorScheme.outline.withValues(alpha: opacity * 0.5),
                width: barWidth,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
              ),
              BarChartRodData(
                toY: entry.value.actualSeconds / 3600,
                color: colorScheme.primary.withValues(alpha: opacity),
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
}

class ProjectPieChart extends StatefulWidget {
  final List<ProjectDistributionData> data;
  const ProjectPieChart({super.key, required this.data});

  @override
  State<ProjectPieChart> createState() => _ProjectPieChartState();
}

class _ProjectPieChartState extends State<ProjectPieChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.data.isEmpty) {
      return Center(
          child: Text('No hay tareas completadas',
              style: TextStyle(color: colorScheme.outline)));
    }

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 35,
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      _touchedIndex = null;
                      return;
                    }
                    final index =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                    _touchedIndex = index == -1 ? null : index;
                  });
                },
              ),
              sections: widget.data.asMap().entries.map((entry) {
                final isTouched = _touchedIndex == entry.key;
                final opacity = _touchedIndex == null || isTouched ? 1.0 : 0.3;
                return PieChartSectionData(
                  color: ColorUtils.parseColor(entry.value.colorHex)
                      .withValues(alpha: opacity),
                  value: entry.value.taskCount.toDouble(),
                  title: '${entry.value.taskCount}',
                  radius: isTouched ? 40.0 : 35.0,
                  titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.data.asMap().entries.map((entry) {
                final isTouched = _touchedIndex == entry.key;
                final opacity = _touchedIndex == null || isTouched ? 1.0 : 0.3;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                            color: ColorUtils.parseColor(entry.value.colorHex)
                                .withValues(alpha: opacity),
                            shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.value.projectName,
                          style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant
                                  .withValues(alpha: opacity),
                              fontWeight: FontWeight.w500),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
