/// Represents the data structure for an EMV Compliant QR Code.
///
/// This model holds raw data that will be processed by the [EmvBuilder].
class EmvData {
  // --- DI CHUYỂN CONSTRUCTOR LÊN ĐẦU ---

  /// Creates an instance of [EmvData] containing all QR payload information.
  const EmvData({
    this.isDynamic = false,
    required this.currency,
    this.amount,
    required this.country,
    required this.merchantName,
    required this.merchantCity,
    this.merchantCategory = '0000',
    required this.merchantAccountInfo,
    this.additionalData,
  });

  // --- SAU ĐÓ MỚI ĐẾN CÁC FIELD ---

  /// Defines if the QR is Dynamic (one-time use) or Static.
  final bool isDynamic;

  /// ISO 4217 Currency Code (e.g., '704' for VND).
  final String currency;

  /// Transaction amount.
  /// Note: Kept as String to preserve precision and formatting.
  final String? amount;

  /// ISO 3166-1 alpha-2 Country Code (e.g., 'VN').
  final String country;

  /// Merchant Name (Mandatory by EMVCo).
  final String merchantName;

  /// Merchant City (Mandatory by EMVCo).
  final String merchantCity;

  /// Merchant Category Code (MCC).
  /// Defaults to '0000' for general undefined category.
  final String merchantCategory;

  /// Map of Merchant Account Information (IDs 26-51).
  /// Key: ID (e.g., '38'), Value: The raw string content of that field.
  final Map<String, String> merchantAccountInfo;

  /// Additional Data Field (ID 62).
  /// Contains extra info like Terminal ID, Bill Number, or Reference Label.
  final String? additionalData;
}
