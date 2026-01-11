import 'package:intl/intl.dart';

String formatMonth(String ym) {
  try {
    final date = DateFormat("yyyy-MM").parse(ym);
    return DateFormat("MMMM yyyy", "id_ID").format(date);
  } catch (e) {
    return ym;
  }
}

String formatDate(DateTime? date) {
  if (date == null) return '-';
  final local = date.toLocal();
  return DateFormat('dd/MM/yyyy').format(local);
}

String formatDate2(DateTime? date) {
  if (date == null) return '-';
  final local = date.toLocal();
  return DateFormat('d MMM yyyy').format(local);
}

String formatDateFromIso(String? iso) {
  if (iso == null) return '-';
  try {
    final date = DateTime.parse(iso).toLocal();
    return DateFormat('dd MMMM yyyy').format(date);
  } catch (_) {
    return iso;
  }
}

String formatDateToIso(String? value) {
  if (value == null || value.isEmpty) return '';
  try {
    final date = DateFormat('dd/MM/yyyy').parseStrict(value);
    return DateFormat('yyyy-MM-dd').format(date);
  } catch (_) {
    return value;
  }
}

String safeDateForApi(String? value) {
  if (value == null || value.trim().isEmpty) return '';

  final v = value.trim();

  // yyyy-MM-dd
  if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(v)) {
    return v;
  }

  // dd/MM/yyyy
  try {
    final date = DateFormat('dd/MM/yyyy').parseStrict(v);
    return DateFormat('yyyy-MM-dd').format(date);
  } catch (_) {}

  // d MMM yyyy (EN)
  try {
    final date = DateFormat('d MMM yyyy', 'en_US').parseStrict(v);
    return DateFormat('yyyy-MM-dd').format(date);
  } catch (_) {}

  // 🔴 FIX: d MMM yyyy (ID singkatan)
  try {
    final normalized = _normalizeIndonesianMonth(v);
    final date = DateFormat('d MMM yyyy', 'en_US').parseStrict(normalized);
    return DateFormat('yyyy-MM-dd').format(date);
  } catch (_) {}

  // d MMMM yyyy (ID lengkap)
  try {
    final date = DateFormat('d MMMM yyyy', 'id_ID').parseStrict(v);
    return DateFormat('yyyy-MM-dd').format(date);
  } catch (_) {}

  throw FormatException('Format tanggal tidak dikenali: $value');
}

String _normalizeIndonesianMonth(String value) {
  const months = {
    'Jan': 'Jan',
    'Feb': 'Feb',
    'Mar': 'Mar',
    'Apr': 'Apr',
    'Mei': 'May',
    'Jun': 'Jun',
    'Jul': 'Jul',
    'Agu': 'Aug',
    'Sep': 'Sep',
    'Okt': 'Oct',
    'Nov': 'Nov',
    'Des': 'Dec',
  };

  var result = value;
  months.forEach((id, en) {
    result = result.replaceAllMapped(
      RegExp('\\b$id\\b', caseSensitive: false),
          (_) => en,
    );
  });

  return result;
}





