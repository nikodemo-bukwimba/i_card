abstract class DateTimeUtils {
  static const _months = [
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec',
  ];

  static String formatDate(DateTime dt) =>
      '${_months[dt.month - 1]} ${dt.day}, ${dt.year}';

  static String formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m ${dt.hour < 12 ? 'AM' : 'PM'}';
  }

  static String formatDateTime(DateTime dt) =>
      '${formatDate(dt)} · ${formatTime(dt)}';

  static String timeAgo(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inSeconds < 60)  return 'sasa hivi';
    if (d.inMinutes < 60)  return 'dakika ${d.inMinutes} zilizopita';
    if (d.inHours < 24)    return 'saa ${d.inHours} zilizopita';
    if (d.inDays == 1)     return 'jana';
    if (d.inDays < 7)      return 'siku ${d.inDays} zilizopita';
    return formatDate(dt);
  }
}