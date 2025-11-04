class TimeHelper {
  static Map<String, String> utcRangeForLocalToday() {
    final now = DateTime.now();
    final startLocal = DateTime(now.year, now.month, now.day);
    final endLocal = startLocal.add(const Duration(days: 1));
    return {
      'startUtc': startLocal.toUtc().toIso8601String(),
      'endUtc': endLocal.toUtc().toIso8601String(),
    };
  }
}
