import '../models/emv_data.dart';
import '../utils/vietqr_helper.dart';

/// A factory class to create [EmvData] specifically for VietQR (NAPAS).
///
/// Note: For a list of supported banks, you can use the static list in this package
/// or fetch the latest data from: https://api.vietqr.io/v2/banks
class VietQrFactory {
  const VietQrFactory._();

  static const String _napasGuid = 'A000000727';
  static const String _serviceToAccount = 'QRIBFTTA';
  // static const String _serviceToCard = 'QRIBFTTC'; // Reserved for future use

  /// Creates an [EmvData] instance configured for Personal 24/7 Bank Transfer.
  ///
  /// [bankBin]: The 6-digit BIN code of the bank (e.g., '970436').
  /// [accountNumber]: The beneficiary account number.
  /// [amount]: (Optional) The amount to transfer.
  /// [description]: (Optional) The transaction description/content. Will be normalized.
  /// [accountName]: (Optional) Used for EMV 'Merchant Name' field. Will be normalized.
  /// Defaults to 'KHACH HANG' to satisfy EMV requirements without affecting NAPAS lookup.
  static EmvData createPersonal({
    required String bankBin,
    required String accountNumber,
    String? amount,
    String? description,
    String accountName = 'KHACH HANG',
  }) {
    // Sanitize inputs to ensure compatibility with banking systems
    final safeAccountName = StringUtils.normalize(accountName);
    final safeDescription = description != null
        ? StringUtils.normalize(description)
        : null;

    // Step 1: Build the Beneficiary Info (Sub-field 01 of ID 38)
    // Structure: [00][Len][BIN] + [01][Len][AccountNum]
    final beneficiaryValue =
        _formatTlv('00', bankBin) + _formatTlv('01', accountNumber);

    // Step 2: Build the Merchant Account Information (ID 38)
    // Structure:
    // [00][Len][GUID] +
    // [01][Len][BeneficiaryInfo] +
    // [02][Len][ServiceCode]
    final id38Value =
        _formatTlv('00', _napasGuid) +
        _formatTlv('01', beneficiaryValue) +
        _formatTlv('02', _serviceToAccount);

    // Step 3: Build Additional Data (ID 62)
    // VietQR uses sub-ID '08' for the description/message.
    String? additionalData;
    if (safeDescription != null && safeDescription.isNotEmpty) {
      additionalData = _formatTlv('08', safeDescription);
    }

    // Step 4: Return the standardized EMV Data
    return EmvData(
      currency: '704', // VND
      country: 'VN',
      merchantName: safeAccountName,
      merchantCity: 'Vietnam', // Generic city to satisfy requirements
      merchantAccountInfo: {'38': id38Value},
      amount: amount,
      additionalData: additionalData,
      isDynamic: amount != null && amount.isNotEmpty,
    );
  }

  /// Internal helper for TLV formatting (Duplicates logic in Builder for independence)
  static String _formatTlv(String id, String value) {
    final length = value.length.toString().padLeft(2, '0');
    return '$id$length$value';
  }
}
