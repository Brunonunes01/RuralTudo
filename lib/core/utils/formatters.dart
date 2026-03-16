import 'package:intl/intl.dart';

abstract final class Formatters {
  static final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  static final _date = DateFormat('dd/MM/yyyy');

  static String currency(num value) => _currency.format(value);
  static String date(DateTime value) => _date.format(value);
}
