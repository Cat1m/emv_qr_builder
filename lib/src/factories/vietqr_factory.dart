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
    String accountName = 'Chien',
  }) {
    // Sanitize inputs
    final safeAccountName = StringUtils.normalize(accountName);
    final safeDescription = description != null
        ? StringUtils.normalize(description)
        : null;

    // Build Merchant Account Information (ID 38)
    final id38Value = _buildMerchantAccountInfo(bankBin, accountNumber);

    // Build Additional Data (ID 62) - Sub-id '08' for description
    final additionalData = TlvHelper.format('08', safeDescription);

    return EmvData(
      currency: '704', // VND
      country: 'VN',
      merchantName: safeAccountName,
      merchantCity: 'Vietnam',
      merchantCategory: '0000', // Default for personal transfer
      merchantAccountInfo: {'38': id38Value},
      amount: amount,
      additionalData: additionalData.isNotEmpty ? additionalData : null,
      isDynamic: amount != null && amount.isNotEmpty,
    );
  }

  /// Creates an [EmvData] instance for Business Payments (VietQR Standard).
  ///
  /// [bankBin]: The 6-digit BIN code of the bank.
  /// [accountNumber]: The merchant's account number.
  /// [merchantName]: The display name of the merchant.
  /// [merchantCity]: The city where the merchant is located.
  /// [mcc]: Merchant Category Code (4 digits). Use [MccUtil] to get valid codes.
  /// [amount]: (Optional) Transaction amount. If provided, QR becomes Dynamic.
  /// [description]: (Optional) Content of the transaction (Field 62, ID 08).
  /// [billNumber]: (Optional) Invoice/Bill Code (Field 62, ID 01).
  /// [storeId]: (Optional) Store Label/ID (Field 62, ID 03).
  /// [terminalId]: (Optional) Terminal/POS ID (Field 62, ID 07).
  static EmvData createBusiness({
    required String bankBin,
    required String accountNumber,
    required String merchantName,
    required String merchantCity,
    required String mcc,
    String? amount,
    String? description,
    String? billNumber,
    String? storeId,
    String? terminalId,
  }) {
    // 1. Sanitize inputs
    final safeName = StringUtils.normalize(merchantName);
    final safeCity = StringUtils.normalize(merchantCity);
    final safeDesc = description != null
        ? StringUtils.normalize(description)
        : null;
    final safeBill = billNumber != null
        ? StringUtils.normalize(billNumber)
        : null;
    final safeStore = storeId != null ? StringUtils.normalize(storeId) : null;
    final safeTerminal = terminalId != null
        ? StringUtils.normalize(terminalId)
        : null;

    // 2. Build Merchant Account Information (ID 38)
    final id38Value = _buildMerchantAccountInfo(bankBin, accountNumber);

    // 3. Build Additional Data (ID 62)
    // Concatenate all optional sub-fields
    final addDataBuffer = StringBuffer();
    addDataBuffer.write(TlvHelper.format('01', safeBill)); // Bill Number
    addDataBuffer.write(TlvHelper.format('03', safeStore)); // Store ID
    addDataBuffer.write(TlvHelper.format('07', safeTerminal)); // Terminal ID
    addDataBuffer.write(TlvHelper.format('08', safeDesc)); // Purpose

    final additionalData = addDataBuffer.toString();

    // 4. Return EMV Data
    return EmvData(
      currency: '704', // VND
      country: 'VN',
      merchantName: safeName,
      merchantCity: safeCity,
      merchantCategory: mcc,
      merchantAccountInfo: {'38': id38Value},
      amount: amount,
      additionalData: additionalData.isNotEmpty ? additionalData : null,
      // Logic: If amount is present -> Dynamic ('12'), else Static ('11')
      isDynamic: amount != null && amount.isNotEmpty,
    );
  }

  /// Helper to build the common Merchant Account Info (ID 38) structure.
  static String _buildMerchantAccountInfo(
    String bankBin,
    String accountNumber,
  ) {
    // Sub-field 01: Beneficiary Info ([00][Len][BIN] + [01][Len][AccountNum])
    final beneficiaryValue =
        TlvHelper.format('00', bankBin) + TlvHelper.format('01', accountNumber);

    // ID 38 Structure:
    // [00][Len][GUID] + [01][Len][BeneficiaryInfo] + [02][Len][ServiceCode]
    return TlvHelper.format('00', _napasGuid) +
        TlvHelper.format('01', beneficiaryValue) +
        TlvHelper.format('02', _serviceToAccount);
  }
}
