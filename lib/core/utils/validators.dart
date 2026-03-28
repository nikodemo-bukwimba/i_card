abstract class Validators {
  static String? required(String? value, {String? field}) {
    if (value == null || value.trim().isEmpty) {
      return field != null ? '$field inahitajika' : 'Sehemu hii inahitajika';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (!RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$').hasMatch(value.trim())) {
      return 'Ingiza barua pepe halali';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final c = value.replaceAll(RegExp(r'[\s\-()]'), '');
    if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(c)) {
      return 'Ingiza namba ya simu halali';
    }
    return null;
  }

  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasScheme) return 'Ingiza URL halali (e.g. https://...)';
    return null;
  }

  static String? hexColor(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final hex = value.trim().replaceAll('#', '');
    if (!RegExp(r'^[0-9A-Fa-f]{6}$').hasMatch(hex)) {
      return 'Ingiza rangi ya hex (e.g. #3C3489)';
    }
    return null;
  }

  static String? compose(
      String? value, List<String? Function(String?)> fns) {
    for (final fn in fns) {
      final r = fn(value);
      if (r != null) return r;
    }
    return null;
  }
}