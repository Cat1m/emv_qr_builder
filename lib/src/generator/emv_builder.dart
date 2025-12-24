import '../constants/emv_ids.dart';
import '../models/emv_data.dart';
import 'crc16.dart';

/// The core engine that constructs the EMV QR string from [EmvData].
class EmvBuilder {
  const EmvBuilder._();

  /// Builds the complete QR string payload.
  ///
  /// Returns a string valid for generating a QR Code image.
  static String build(EmvData data) {
    final buffer = StringBuffer();

    // 1. Payload Format Indicator (ID 00)
    // Always "01" according to spec version 1.0
    buffer.write(_formatTlv(EmvIds.payloadFormat, '01'));

    // 2. Point of Initiation Method (ID 01)
    final methodValue = data.isDynamic ? '12' : '11';
    buffer.write(_formatTlv(EmvIds.pointOfInitiation, methodValue));

    // 3. Merchant Account Information (IDs 26-51)
    // Sorting keys to ensure deterministic output (optional but recommended)
    final sortedKeys = data.merchantAccountInfo.keys.toList()..sort();
    for (final key in sortedKeys) {
      final value = data.merchantAccountInfo[key];
      if (value != null && value.isNotEmpty) {
        buffer.write(_formatTlv(key, value));
      }
    }

    // 4. Merchant Category Code (ID 52)
    buffer.write(_formatTlv(EmvIds.merchantCategory, data.merchantCategory));

    // 5. Transaction Currency (ID 53)
    buffer.write(_formatTlv(EmvIds.currency, data.currency));

    // 6. Transaction Amount (ID 54) - Optional
    if (data.amount != null && data.amount!.isNotEmpty) {
      buffer.write(_formatTlv(EmvIds.amount, data.amount!));
    }

    // 7. Country Code (ID 58)
    buffer.write(_formatTlv(EmvIds.country, data.country));

    // 8. Merchant Name (ID 59)
    buffer.write(_formatTlv(EmvIds.merchantName, data.merchantName));

    // 9. Merchant City (ID 60)
    buffer.write(_formatTlv(EmvIds.merchantCity, data.merchantCity));

    // 10. Additional Data (ID 62) - Optional
    if (data.additionalData != null && data.additionalData!.isNotEmpty) {
      buffer.write(_formatTlv(EmvIds.additionalData, data.additionalData!));
    }

    // 11. CRC (ID 63)
    // Append ID and Length '04' before calculating checksum
    final dataWithoutCrc = '${buffer.toString()}${EmvIds.crc}04';
    final checksum = Crc16.calculate(dataWithoutCrc);

    return '$dataWithoutCrc$checksum';
  }

  /// Helper to format data in TLV (Tag-Length-Value) format.
  ///
  /// Example: id="00", value="01" -> "000201"
  static String _formatTlv(String id, String value) {
    if (value.isEmpty) return '';
    final length = value.length.toString().padLeft(2, '0');
    return '$id$length$value';
  }
}
