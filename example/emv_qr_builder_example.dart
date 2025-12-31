// ignore_for_file: avoid_print

import 'package:emv_qr_builder/emv_qr_builder.dart';

/// === IMPORTANT: READ THIS FIRST ===
///
/// This package generates valid VietQR codes that work with ANY bank account.
/// However, advanced Business QR features (MCC enforcement, billNumber, storeId,
/// terminalId processing) only work if you have a REGISTERED MERCHANT ACCOUNT
/// with your bank.
///
/// For most small businesses and individuals:
/// - Use Personal QR or Business QR (they work the same without merchant registration)
/// - Put tracking info in the 'description' field
/// - Customers scan → pay → send you a screenshot/confirmation
/// - You verify payments manually
///
/// This is perfectly fine for cafes, shops, freelancers, and local businesses!

/// === 1. PERSONAL CONFIGURATION ===
/// Use this for standard P2P transfers (Person to Person).
class PersonalConfig {
  static const String bankBin = '970407'; // Techcombank
  static const String accountNumber = '19033804311013';
  static const String accountName = 'LE MINH CHIEN';
}

/// === 2. BUSINESS CONFIGURATION (FOR DEMO) ===
/// Use this to demonstrate Business QR format.
///
/// ⚠️ IMPORTANT:
/// Without a registered Merchant Account, this will work like a Personal QR.
/// Fields like mcc, billNumber, storeId, terminalId are included in the QR
/// but won't be processed by the bank.
///
/// ✅ RECOMMENDED: Use 'description' field for order tracking instead.
class BusinessConfig {
  static const String bankBin = '970418'; // BIDV
  static const String accountNumber = '19033804311013';
  static const String merchantName = 'CHIEN BUSINESS';
  static const String merchantCity = 'HO CHI MINH';
  static const String mcc =
      '8062'; // Hospital (good practice to use correct MCC)
}

void main() {
  print('=== EMV QR Builder Example ===');
  print('User: ${PersonalConfig.accountName}');
  print('Business: ${BusinessConfig.merchantName}\n');

  // ---------------------------------------------------------------------------
  // EXAMPLE 1: Personal Static QR
  // ✅ RECOMMENDED for most small businesses and individuals
  // Use case: A simple QR code for customers to transfer money.
  // The customer enters the amount manually.
  // ---------------------------------------------------------------------------
  final personalStaticData = VietQrFactory.createPersonal(
    bankBin: PersonalConfig.bankBin,
    accountNumber: PersonalConfig.accountNumber,
    accountName: PersonalConfig.accountName,
  );

  final personalStaticQr = EmvBuilder.build(personalStaticData);
  print('--- 1. Personal Static QR (Customer enters amount) ---');
  print('✅ Works for everyone - no merchant registration needed');
  print(personalStaticQr);
  print('------------------------------------------------------\n');

  // ---------------------------------------------------------------------------
  // EXAMPLE 2: Personal Dynamic QR with Description
  // ✅ RECOMMENDED for tracking orders/invoices
  // Use case: Requesting a specific amount with order reference.
  // The amount and description are pre-filled in the banking app.
  // ---------------------------------------------------------------------------
  final personalDynamicData = VietQrFactory.createPersonal(
    bankBin: PersonalConfig.bankBin,
    accountNumber: PersonalConfig.accountNumber,
    amount: '20000', // 20,000 VND
    description: 'Order #INV-001 - Coffee', // ✅ Use this for tracking!
  );

  final personalDynamicQr = EmvBuilder.build(personalDynamicData);
  print('--- 2. Personal Dynamic QR (20,000 VND + Order Info) ---');
  print('✅ Customer pays → sends screenshot → you verify manually');
  print('Tracking via description: "Order #INV-001 - Coffee"');
  print(personalDynamicQr);
  print('--------------------------------------------------------\n');

  // ---------------------------------------------------------------------------
  // EXAMPLE 3: Business QR with Description (Practical Approach)
  // ✅ RECOMMENDED for small businesses without merchant registration
  // Use case: Same as Personal QR but with business name display.
  // Put all tracking info in 'description' field.
  // ---------------------------------------------------------------------------
  final businessPracticalData = VietQrFactory.createBusiness(
    bankBin: BusinessConfig.bankBin,
    accountNumber: BusinessConfig.accountNumber,
    merchantName: BusinessConfig.merchantName,
    merchantCity: BusinessConfig.merchantCity,
    mcc: BusinessConfig.mcc,
    amount: '500000', // 500,000 VND
    description: 'Order #999 | Table 5 | POS-01', // ✅ All tracking info here!
  );

  final businessPracticalQr = EmvBuilder.build(businessPracticalData);
  print('--- 3. Business QR (Practical for Small Businesses) ---');
  print('✅ No merchant registration needed');
  print('✅ All tracking info in description field');
  print('Type: ${businessPracticalData.isDynamic ? "Dynamic" : "Static"}');
  print('MCC: ${businessPracticalData.merchantCategory} (good practice)');
  print(businessPracticalQr);
  print('-------------------------------------------------------\n');

  // ---------------------------------------------------------------------------
  // EXAMPLE 4: Business QR with Advanced Fields (Requires Merchant Account)
  /// ⚠️ ADVANCED: Requires Merchant Account WITH API Integration
  /// Use case: POS/ERP integration with automatic reconciliation (Webhook/IPN).
  ///
  /// Note: Standard business bank accounts may ignore 'billNumber' or 'storeId'.
  /// You typically need a Payment Gateway or Bank Open API registration
  /// to receive these fields via callback.
  // ---------------------------------------------------------------------------
  final businessAdvancedData = VietQrFactory.createBusiness(
    bankBin: BusinessConfig.bankBin,
    accountNumber: BusinessConfig.accountNumber,
    merchantName: BusinessConfig.merchantName,
    merchantCity: BusinessConfig.merchantCity,
    mcc: BusinessConfig.mcc,
    amount: '500000',
    description: 'Order #999',
    // ⚠️ These fields only work with merchant registration:
    billNumber: 'INV-2023-001',
    terminalId: 'POS-01',
    storeId: 'MAIN-STORE',
  );

  final businessAdvancedQr = EmvBuilder.build(businessAdvancedData);
  print('--- 4. Business QR (Advanced - Requires Merchant Account) ---');
  print('⚠️  Without merchant registration, this works like Example 3');
  print(
    '⚠️  Advanced fields (billNumber, terminalId, storeId) won\'t be processed',
  );
  print('✅ With merchant account: Automatic reconciliation & reporting');
  print(businessAdvancedQr);
  print('--------------------------------------------------------------\n');

  // ---------------------------------------------------------------------------
  // EXAMPLE 5: Business Static QR (For Printed Stickers)
  // ✅ RECOMMENDED for physical stores
  // Use case: Print and place at checkout counter.
  // Track location via description field.
  // ---------------------------------------------------------------------------
  final businessStaticData = VietQrFactory.createBusiness(
    bankBin: BusinessConfig.bankBin,
    accountNumber: BusinessConfig.accountNumber,
    merchantName: BusinessConfig.merchantName,
    merchantCity: BusinessConfig.merchantCity,
    mcc: BusinessConfig.mcc,
    // No amount = Static QR (customer enters amount)
    description: 'Counter 5 - Main Store', // ✅ Track location here
  );

  final businessStaticQr = EmvBuilder.build(businessStaticData);
  print('--- 5. Business Static QR (For Counter/Store Print) ---');
  print('✅ Customer scans → enters amount → pays → shows confirmation');
  print('Type: ${businessStaticData.isDynamic ? "Dynamic" : "Static"}');
  print('Location tracking: "Counter 5 - Main Store"');
  print(businessStaticQr);
  print('-------------------------------------------------------\n');

  // ---------------------------------------------------------------------------
  // EXAMPLE 6: International Custom QR (Thai PromptPay)
  // Demonstrates that EmvBuilder works for other EMV standards.
  // ---------------------------------------------------------------------------
  final customThaiData = const EmvData(
    currency: '764', // THB (Thai Baht)
    country: 'TH',
    merchantName: 'Street Food Stall',
    merchantCity: 'Bangkok',
    merchantCategory: '5411', // Grocery
    merchantAccountInfo: {
      '29': '0016A00000067701011101130066891234567', // PromptPay ID
    },
    amount: '100.00',
    isDynamic: true,
  );

  final thaiQrString = EmvBuilder.build(customThaiData);
  print('--- 6. International Custom QR (Thai PromptPay) ---');
  print('Currency: ${customThaiData.currency} (THB)');
  print(thaiQrString);
  print('---------------------------------------------------\n');

  print('✅ DONE! Copy the strings above and paste into a QR Generator');
  print('   (e.g., zxing.org/w/chart, qr-code-generator.com)');
  print('');
  print('💡 TIP: For most users, Examples 1-3 and 5 are all you need!');
  print(
    '   Example 4 is only for businesses with registered merchant accounts.',
  );
}
