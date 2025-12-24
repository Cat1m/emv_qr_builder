/// Defines standard Field IDs according to EMVCo QR Code Specification.
class EmvIds {
  const EmvIds._(); // Private constructor to prevent instantiation

  // --- Root Fields ---

  /// Payload Format Indicator (Mandatory).
  /// Fixed value: "01"
  static const String payloadFormat = '00';

  /// Point of Initiation Method (Mandatory).
  /// "11" for Static, "12" for Dynamic.
  static const String pointOfInitiation = '01';

  // ID 02-25: Reserved for primitives

  // ID 26-51: Merchant Account Information
  // VietQR uses ID '38'.

  /// Merchant Category Code (Mandatory).
  /// ISO 18245 - 4 digits.
  static const String merchantCategory = '52';

  /// Transaction Currency (Mandatory).
  /// ISO 4217 - 3 digits (e.g., "704" for VND).
  static const String currency = '53';

  /// Transaction Amount (Optional).
  static const String amount = '54';

  /// Tip or Convenience Indicator (Optional).
  static const String tipOrFeeIndicator = '55';

  /// Value of Convenience Fee Fixed (Optional).
  static const String feeFixed = '56';

  /// Value of Convenience Fee Percentage (Optional).
  static const String feePercentage = '57';

  /// Country Code (Mandatory).
  /// ISO 3166-1 alpha-2 (e.g., "VN").
  static const String country = '58';

  /// Merchant Name (Mandatory).
  static const String merchantName = '59';

  /// Merchant City (Mandatory).
  static const String merchantCity = '60';

  /// Postal Code (Optional).
  static const String postalCode = '61';

  /// Additional Data Field Template (Optional).
  static const String additionalData = '62';

  /// Cyclic Redundancy Check (Mandatory).
  /// CRC-16-CCITT.
  static const String crc = '63';
}
