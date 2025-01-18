import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/timer_provider.dart';
import '../models/analytics_model.dart';
import '../models/session_model.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, timer, _) {
        final stats = timer.todayStats;
        final weeklyStats = timer.weeklyStats;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Statistics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
          ),
          body: RefreshIndicator(
            onRefresh: timer.refreshStatistics,
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              children: [
                _buildDailyStats(stats, context),
                SizedBox(height: 24),
                _buildWeeklyChart(weeklyStats, context),
                SizedBox(height: 24),
                _buildSessionHistory(timer.sessions, context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDailyStats(DailyStatistics? stats, BuildContext context) {
    if (stats == null) return SizedBox.shrink();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.today,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Today\'s Progress',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildStatRow(
              context,
              'Total Sessions',
              '${stats.totalSessions}',
              Icons.repeat,
            ),
            _buildStatRow(
              context,
              'Completed',
              '${stats.completedSessions}',
              Icons.check_circle_outline,
            ),
            _buildStatRow(
              context,
              'Minutes Focused',
              '${stats.totalMinutesFocused}',
              Icons.timer_outlined,
            ),
            _buildStatRow(
              context,
              'Completion Rate',
              '${stats.completionRate.toStringAsFixed(1)}%',
              Icons.trending_up,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
      BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(WeeklyAnalytics? weeklyStats, BuildContext context) {
    if (weeklyStats == null) return SizedBox.shrink();

    final weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    // Calculate optimal interval based on max minutes
    double calculateInterval(double maxY) {
      if (maxY <= 60) return 15.0; // 15min intervals if under 1h
      if (maxY <= 120) return 30.0; // 30min intervals if under 2h
      if (maxY <= 240) return 60.0; // 1h intervals if under 4h
      return 120.0; // 2h intervals otherwise
    }

    String formatMinutes(double value) {
      if (value == 0) return '0';
      if (value >= 60) {
        final hours = (value / 60).floor();
        return '${hours}h';
      }
      return '${value.floor()}m';
    }

    final maxY = weeklyStats.maxDailyMinutes.toDouble();
    final interval = calculateInterval(maxY);

    return Card(
      child: Padding(
        padding: EdgeInsets.fromLTRB(8, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Weekly Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY + interval, // Add padding to top
                  gridData: FlGridData(
                    drawHorizontalLine: true,
                    horizontalInterval: interval,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300],
                        strokeWidth: 0.5,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: interval,
                        reservedSize: 40, // More space for labels
                        getTitlesWidget: (value, meta) {
                          if (value == maxY + interval)
                            return SizedBox.shrink();
                          return Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Text(
                              formatMinutes(value),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              weekDays[value.toInt()],
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  barGroups: weeklyStats.dailyMinutes
                      .asMap()
                      .entries
                      .map((e) => BarChartGroupData(
                            x: e.key,
                            barRods: [
                              BarChartRodData(
                                toY: e.value.toDouble(),
                                width: 20,
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                              ),
                            ],
                          ))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionHistory(List<Session> sessions, BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Sessions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            ...sessions.map((session) => ListTile(
                  title: Text('${session.startTime.toString().split('.')[0]}'),
                  trailing: Text(session.status == SessionStatus.completed
                      ? 'Completed'
                      : 'Interrupted'),
                )),
          ],
        ),
      ),
    );
  }
}
