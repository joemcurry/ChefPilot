import 'package:flutter/services.dart';

class PhoneInputFormatter extends TextInputFormatter {
  // Formats digits into (xxx) xxx-xxxx while typing
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 10) digits = digits.substring(0, 10);

    final buffer = StringBuffer();
    var index = 0;
    if (digits.length >= 1) buffer.write('(');
    while (index < digits.length) {
      if (index == 3) buffer.write(') ');
      if (index == 6) buffer.write('-');
      buffer.write(digits[index]);
      index++;
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
