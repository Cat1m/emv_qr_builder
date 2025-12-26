// ignore_for_file: avoid_print

import 'package:emv_qr_builder/emv_qr_builder.dart';

void main() {
  // Sử dụng print cho các script CLI hoặc test nhỏ để đảm bảo luôn thấy output
  print('=== EMV QR Builder Example ===\n');

  final staticData = VietQrFactory.createPersonal(
    bankBin: '970407',
    accountNumber: '19033804311013',
    accountName: 'Lê Minh Chiến',
  );

  final staticQrString = EmvBuilder.build(staticData);
  print('--- Static QR (Any Amount) ---');
  print(staticQrString);
  print('-------------------------------\n');

  final coffeeData = VietQrFactory.createPersonal(
    bankBin: '970407',
    accountNumber: '19033804311013',
    amount: '20000',
    description: 'Buy mé à coffeé',
  );

  final coffeeQrString = EmvBuilder.build(coffeeData);
  print('--- Dynamic QR (20,000 VND - Coffee Support) ---');
  print(coffeeQrString);
  print('-------------------------------\n');

  print('Scan the string above to verify!');
}
