import 'package:emv_qr_builder/src/constants/emv_ids.dart';
import 'package:emv_qr_builder/src/generator/crc16.dart';
import 'package:test/test.dart';
import 'package:emv_qr_builder/emv_qr_builder.dart';

void main() {
  group('CRC16 Calculator', () {
    test('Should calculate correctly for standard test vectors', () {
      expect(Crc16.calculate('123456789'), equals('29B1'));
      // Note: NapAS/EMV uses CRC-16-CCITT (0xFFFF, 0x1021).
      // '123456789' -> '29B1' is correct for this specific variant.
    });

    test('Should match VietQR known sample', () {
      // Example string part without CRC
      const data =
          '00020101021138580010A0000007270128000697041501141133666688880208QRIBFTTA53037045802VN5910KHACH HANG6007Vietnam6304';
      // Expected CRC for above
      const expectedCrc = '026B';
      expect(Crc16.calculate(data), equals(expectedCrc));
    });
  });

  group('VietQrFactory', () {
    test('createPersonal should build correct nested structure', () {
      final data = VietQrFactory.createPersonal(
        bankBin: '970415',
        accountNumber: '123456',
        amount: '50000',
        description: 'Test',
      );

      expect(data.currency, equals('704'));
      expect(data.country, equals('VN'));
      expect(data.merchantAccountInfo.containsKey('38'), isTrue);

      // Check content of Field 38 (The core VietQR logic)
      final id38 = data.merchantAccountInfo['38']!;
      expect(id38, contains('0010A000000727')); // GUID Napas
      expect(id38, contains('0208QRIBFTTA')); // Service Code
    });

    test('Should set Dynamic QR if amount is present', () {
      final data = VietQrFactory.createPersonal(
        bankBin: '970415',
        accountNumber: '123',
        amount: '10000',
      );
      expect(data.isDynamic, isTrue);
    });

    test('Should set Static QR if amount is missing', () {
      final data = VietQrFactory.createPersonal(
        bankBin: '970415',
        accountNumber: '123',
      );
      expect(data.isDynamic, isFalse);
    });
  });

  group('EmvBuilder', () {
    test('Build function should return valid string format', () {
      final data = VietQrFactory.createPersonal(
        bankBin: '970415',
        accountNumber: '112233',
        accountName: 'NGUYEN VAN A',
      );

      final result = EmvBuilder.build(data);

      // 1. Check Header
      expect(result.startsWith('000201'), isTrue);

      // 2. Check Mandatory Fields existence
      expect(
        result.contains('${EmvIds.currency}03704'),
        isTrue,
      ); // Currency VND
      expect(result.contains('${EmvIds.merchantName}12NGUYEN VAN A'), isTrue);

      // 3. Check CRC exists at end
      expect(result.length, greaterThan(4));
      final crcId = result.substring(result.length - 8, result.length - 4);
      expect(crcId, equals('6304'));
    });
  });
}
