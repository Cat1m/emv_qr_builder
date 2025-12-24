import 'dart:developer';

import 'package:emv_qr_builder/emv_qr_builder.dart';

void main() {
  log('=== EMV QR Builder Example ===\n');

  // ---------------------------------------------------------
  // 1. Static QR Code (General Donation)
  // This generates a generic QR. The donor can enter any amount they want.
  // Useful for loging on stickers or GitHub READMEs.
  // ---------------------------------------------------------
  final staticData = VietQrFactory.createPersonal(
    bankBin: '970407', // Techcombank
    accountNumber: '19033804311013',
    accountName: 'KHACH HANG', // Optional: Account holder name
  );

  final staticQrString = EmvBuilder.build(staticData);
  log('--- Static QR (Any Amount) ---');
  log(staticQrString);
  log('-------------------------------\n');

  // ---------------------------------------------------------
  // 2. Dynamic QR Code (Buy Me a Coffee)
  // This generates a QR with a fixed amount of 20,000 VND.
  // Perfect for the "Iced Black Coffee No Sugar" use case! ☕️
  // ---------------------------------------------------------
  final coffeeData = VietQrFactory.createPersonal(
    bankBin: '970407', // Techcombank
    accountNumber: '19033804311013',
    amount: '20000', // 20,000 VND
    description: 'Buy me a coffee', // Transaction content
  );

  final coffeeQrString = EmvBuilder.build(coffeeData);
  log('--- Dynamic QR (20,000 VND - Coffee Support) ---');
  log(coffeeQrString);
  log('-------------------------------\n');

  log('Scan the string above to verify!');
}
