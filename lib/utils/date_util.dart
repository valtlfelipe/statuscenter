import 'package:intl/intl.dart';

class DateUtil {
  static String format(DateTime date) {
    return new DateFormat('d MMMM yyyy HH:mm').format(date.toLocal());
  }
}