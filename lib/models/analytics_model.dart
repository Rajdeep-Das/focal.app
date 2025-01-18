import 'dart:math' show max;

class DailyStatistics {
  final int totalSessions;
  final int completedSessions;
  final int totalMinutesFocused;

  DailyStatistics({
    required this.totalSessions,
    required this.completedSessions,
    required this.totalMinutesFocused,
  });

  double get completionRate =>
      totalSessions == 0 ? 0 : (completedSessions / totalSessions) * 100;
}

class WeeklyAnalytics {
  final List<int> dailyMinutes;
  final int totalSessions;
  final int completedSessions;

  WeeklyAnalytics({
    required this.dailyMinutes,
    required this.totalSessions,
    required this.completedSessions,
  });

  int get maxDailyMinutes =>
      dailyMinutes.isEmpty ? 0 : dailyMinutes.reduce(max);
}
