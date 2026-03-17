import 'package:intl/intl.dart';

abstract final class Formatters {
  static final _currency = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );
  static final _date = DateFormat('dd/MM/yyyy');
  static final _decimal3 = NumberFormat.decimalPattern('pt_BR')
    ..minimumFractionDigits = 3
    ..maximumFractionDigits = 3;

  static String currency(num value) => _currency.format(value);
  static String date(DateTime value) => _date.format(value);
  static String decimal(num value, {int fractionDigits = 2}) {
    final decimal = NumberFormat.decimalPattern('pt_BR')
      ..minimumFractionDigits = fractionDigits
      ..maximumFractionDigits = fractionDigits;
    return decimal.format(value);
  }

  static String hectares(num value) => _decimal3.format(value);
}
