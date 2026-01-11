class FormatString {
  static String format(dynamic value) {
    if (value == null) return '-';

    final raw = value.toString().trim();
    if (raw.isEmpty) return '-';

    return raw
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    })
        .join(' ');
  }
}