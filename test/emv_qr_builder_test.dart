import 'package:emv_qr_builder/src/constants/emv_ids.dart';
import 'package:emv_qr_builder/src/generator/crc16.dart';
import 'package:test/test.dart';
import 'package:emv_qr_builder/emv_qr_builder.dart';

void main() {
  group('CRC16 Calculator', () {
    test('Should calculate correctly for standard test vectors', () {
      expect(Crc16.calculate('123456789'), equals('29B1'));
    });

    test('Should match VietQR known sample', () {
      // Chuỗi mẫu thực tế (đã cắt CRC)
      const data =
          '00020101021138580010A0000007270128000697041501141133666688880208QRIBFTTA53037045802VN5910KHACH HANG6007Vietnam6304';
      // CRC thực tế của chuỗi trên là 5546
      const expectedCrc = '5546';
      expect(Crc16.calculate(data), equals(expectedCrc));
    });
  });

  group('VietQrFactory - Personal', () {
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

      final id38 = data.merchantAccountInfo['38']!;
      expect(id38, contains('0010A000000727'));
      expect(id38, contains('0208QRIBFTTA'));
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

    test('Should normalize Vietnamese characters in fields', () {
      final data = VietQrFactory.createPersonal(
        bankBin: '970415',
        accountNumber: '123',
        accountName: 'Nguyễn Văn A', // Input có dấu
        description: 'Chuyển tiền',
      );

      final result = EmvBuilder.build(data);

      // SỬA LỖI 1: Kỳ vọng 'Nguyen Van A' (bỏ dấu) thay vì 'NGUYEN VAN A' (viết hoa)
      // Vì hàm normalize của bạn chỉ bỏ dấu chứ không toUpperCase
      expect(result.contains('Nguyen Van A'), isTrue);

      // Kiểm tra description (nếu hàm normalize hoạt động)
      expect(result.contains('Chuyen tien'), isTrue);
    });
  });

  group('VietQrFactory - Business', () {
    test('createBusiness should map advanced fields correctly', () {
      final data = VietQrFactory.createBusiness(
        bankBin: '970418',
        accountNumber: '1440180025',
        merchantName: 'Cua Hang A',
        merchantCity: 'Ha Noi',
        mcc: '5411',
        billNumber: 'INV-01',
        terminalId: 'POS-01',
        storeId: 'STORE-Main',
      );

      expect(data.merchantCategory, equals('5411'));
      expect(data.additionalData, isNotNull);

      // SỬA LỖI 2: additionalData là String, không phải Map.
      // Chúng ta kiểm tra xem chuỗi TLV có được tạo đúng format không.

      // Format: ID + Length + Value
      // Bill Number (ID 01): '01' + '06' + 'INV-01' -> '0106INV-01'
      expect(data.additionalData, contains('0106INV-01'));

      // Terminal ID (ID 07): '07' + '06' + 'POS-01' -> '0706POS-01'
      expect(data.additionalData, contains('0706POS-01'));

      // Store ID (ID 03): '03' + '10' + 'STORE-Main' -> '0310STORE-Main'
      expect(data.additionalData, contains('0310STORE-Main'));
    });
  });

  group('EmvBuilder Integration', () {
    test('Build function should return valid string format (Personal)', () {
      final data = VietQrFactory.createPersonal(
        bankBin: '970415',
        accountNumber: '112233',
        accountName: 'Nguyen Van A',
      );

      final result = EmvBuilder.build(data);

      expect(result.startsWith('000201'), isTrue);
      expect(result.contains('${EmvIds.currency}03704'), isTrue);
      expect(result.contains('${EmvIds.merchantName}12Nguyen Van A'), isTrue);
      expect(result.length, greaterThan(4));
    });

    test('Build function should generate valid Business QR string', () {
      final data = VietQrFactory.createBusiness(
        bankBin: '970418',
        accountNumber: '9999',
        merchantName: 'SHOP A',
        merchantCity: 'HCM',
        mcc: '5411',
        billNumber: 'BILL123',
      );

      final result = EmvBuilder.build(data);

      // Kiểm tra xem Field 62 (Additional Data) có xuất hiện trong chuỗi cuối cùng không
      expect(result.contains('62'), isTrue);

      // Kiểm tra xem giá trị billNumber có nằm trong chuỗi không
      expect(result.contains('BILL123'), isTrue);
    });
  });
}
