/// Utility class to calculate CRC-16-CCITT checksums.
///
/// Compliant with ISO/IEC 13239.
/// Polynomial: 0x1021
/// Initial Value: 0xFFFF
class Crc16 {
  const Crc16._();

  static const int _polynomial = 0x1021;
  static const int _initialValue = 0xFFFF;

  /// Calculates the CRC-16 checksum for the given [data].
  ///
  /// Returns a 4-character uppercase hexadecimal string.
  static String calculate(String data) {
    var crc = _initialValue;

    for (var i = 0; i < data.length; i++) {
      // Get the ASCII code unit of the character
      var byte = data.codeUnitAt(i) << 8;

      // Update the CRC value
      crc ^= byte;

      for (var j = 0; j < 8; j++) {
        if ((crc & 0x8000) != 0) {
          crc = (crc << 1) ^ _polynomial;
        } else {
          crc = (crc << 1);
        }
      }
    }

    // Mask to 16-bit and convert to Hex
    return (crc & 0xFFFF).toRadixString(16).toUpperCase().padLeft(4, '0');
  }
}
