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

String formatDateFromIso(String? iso) {
  if (iso == null) return '-';
  try {
    final date = DateTime.parse(iso).toLocal();
    return DateFormat('dd MMMM yyyy').format(date);
  } catch (_) {
    return iso;
  }
}


