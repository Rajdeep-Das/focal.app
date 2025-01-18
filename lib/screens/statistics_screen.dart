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
          appBar: AppBar(title: Text('Statistics')),
          body: RefreshIndicator(
            onRefresh: timer.refreshStatistics,
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                _buildDailyStats(stats),
                SizedBox(height: 24),
                _buildWeeklyChart(weeklyStats, context),
                SizedBox(height: 24),
                _buildSessionHistory(timer.sessions),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDailyStats(DailyStatistics? stats) {
    if (stats == null) return SizedBox.shrink();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Today\'s Progress',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            _buildStatRow('Total Sessions', '${stats.totalSessions}'),
            _buildStatRow('Completed', '${stats.completedSessions}'),
            _buildStatRow('Minutes Focused', '${stats.totalMinutesFocused}'),
            _buildStatRow('Completion Rate',
                '${stats.completionRate.toStringAsFixed(1)}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildSessionHistory(List<Session> sessions) {
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
