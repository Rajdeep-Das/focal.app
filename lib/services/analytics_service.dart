import '../models/analytics_model.dart';
import '../repositories/session_repository.dart';
import '../models/session_model.dart';

class AnalyticsService {
  final SessionRepository _repository;

  AnalyticsService(this._repository);

  Future<DailyStatistics> getDailyStatistics(DateTime date) async {
    final sessions = await _repository.getSessionsByDate(date);

    return DailyStatistics(
      totalSessions: sessions.length,
      completedSessions:
          sessions.where((s) => s.status == SessionStatus.completed).length,
      totalMinutesFocused: sessions.fold(
          0,
          (sum, session) =>
              sum + session.endTime.difference(session.startTime).inMinutes),
    );
  }

  Future<WeeklyAnalytics> getWeeklyAnalytics(DateTime weekStart) async {
    List<int> dailyMinutes = [];
    int totalSessions = 0;
    int completedSessions = 0;

    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final stats = await getDailyStatistics(date);
      dailyMinutes.add(stats.totalMinutesFocused);
      totalSessions += stats.totalSessions;
      completedSessions += stats.completedSessions;
    }

    return WeeklyAnalytics(
      dailyMinutes: dailyMinutes,
      totalSessions: totalSessions,
      completedSessions: completedSessions,
    );
  }
}
