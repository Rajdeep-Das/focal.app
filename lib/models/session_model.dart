import 'package:hive/hive.dart';

part 'session_model.g.dart';

@HiveType(typeId: 0)
enum SessionStatus {
  @HiveField(0)
  completed,
  @HiveField(1)
  interrupted
}

@HiveType(typeId: 2)
class Session {
  @HiveField(0)
  final DateTime startTime;
  @HiveField(1)
  final DateTime endTime;
  @HiveField(2)
  final SessionStatus status;

  Session({
    required this.startTime,
    required this.endTime,
    required this.status,
  });
}
