import 'package:hive_flutter/hive_flutter.dart';
import '../models/session_model.dart';

class SessionRepository {
  late Box<Session> _sessionBox;

  Future<void> initialize() async {
    _sessionBox = await Hive.openBox<Session>('sessions');
  }

  Future<void> saveSession(Session session) async {
    await _sessionBox.add(session);
  }

  Future<List<Session>> getSessionsByDate(DateTime date) async {
    return _sessionBox.values
        .where((session) =>
            session.startTime.year == date.year &&
            session.startTime.month == date.month &&
            session.startTime.day == date.day)
        .toList();
  }

  Future<List<Session>> getSessionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    return _sessionBox.values
        .where((session) =>
            session.startTime.isAfter(start) && session.startTime.isBefore(end))
        .toList();
  }
}
