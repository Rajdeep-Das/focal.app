class Session {
  final String id;
  final DateTime startTime;
  final int duration;
  final bool completed;

  Session({
    required this.id,
    required this.startTime,
    required this.duration,
    this.completed = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'startTime': startTime.toIso8601String(),
        'duration': duration,
        'completed': completed,
      };

  factory Session.fromJson(Map<String, dynamic> json) => Session(
        id: json['id'],
        startTime: DateTime.parse(json['startTime']),
        duration: json['duration'],
        completed: json['completed'],
      );
}
