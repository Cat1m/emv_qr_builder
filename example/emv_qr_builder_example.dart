// ignore_for_file: avoid_print

import 'package:emv_qr_builder/emv_qr_builder.dart';

/// === 1. PERSONAL CONFIGURATION ===
/// Use this for standard P2P transfers (Person to Person).
class PersonalConfig {
  static const String bankBin = '970407'; // Techcombank
  static const String accountNumber = '19033804311013';
  static const String accountName = 'LE MINH CHIEN';
}

/// === 2. BUSINESS CONFIGURATION (FOR DEMO) ===
/// Use this to simulate a Merchant/Business environment.
///
/// NOTE:
/// In a real production environment, [accountNumber] should be a registered
/// Merchant Account (Business Account).
///
/// For this demo, we reuse the Personal Account so the QR remains valid/scannable,
/// but we set the [merchantName] to a business name to demonstrate the field usage.
class BusinessConfig {
  static const String bankBin = '970407'; // Reuse Techcombank for valid test
  static const String accountNumber = '19033804311013'; // Reuse for valid test

  static const String merchantName = 'CHIEN BUSINESS';
  static const String merchantCity = 'HO CHI MINH';
  static const String mcc = '5999'; // 5999: General Merchant / Retail
}

void main() {
  print('=== EMV QR Builder Example ===');
  print('Generating QRs for User: ${PersonalConfig.accountName}');
  print('Business Entity: ${BusinessConfig.merchantName}\n');

  // ---------------------------------------------------------------------------
  // EXAMPLE 1: Personal Static QR
  // Use case: A simple QR code for friends to transfer money to you.
  // The sender enters the amount manually.
  // ---------------------------------------------------------------------------
  final personalStaticData = VietQrFactory.createPersonal(
    bankBin: PersonalConfig.bankBin,
    accountNumber: PersonalConfig.accountNumber,
    accountName: PersonalConfig.accountName,
  );

  final personalStaticQr = EmvBuilder.build(personalStaticData);
  print('--- 1. Personal Static QR (User enters amount) ---');
  print(personalStaticQr);
  print('--------------------------------------------------\n');

  // ---------------------------------------------------------------------------
  // EXAMPLE 2: Personal Dynamic QR
  // Use case: Requesting a specific amount (e.g., splitting a bill).
  // The amount is pre-filled in the banking app.
  // ---------------------------------------------------------------------------
  final personalDynamicData = VietQrFactory.createPersonal(
    bankBin: PersonalConfig.bankBin,
    accountNumber: PersonalConfig.accountNumber,
    amount: '20000', // 20,000 VND
    description: 'Coffee money',
  );

  final personalDynamicQr = EmvBuilder.build(personalDynamicData);
  print('--- 2. Personal Dynamic QR (20,000 VND) ---');
  print(personalDynamicQr);
  print('-------------------------------------------\n');

  // ---------------------------------------------------------------------------
  // EXAMPLE 3: Business Dynamic QR (Complex Invoice)
  // Use case: Integrating into POS software or ERP systems.
  // Includes Bill Number, Terminal ID, and Store ID for reconciliation.
  // ---------------------------------------------------------------------------
  final businessDynamicData = VietQrFactory.createBusiness(
    bankBin: BusinessConfig.bankBin,
    accountNumber: BusinessConfig.accountNumber,
    merchantName: BusinessConfig.merchantName,
    merchantCity: BusinessConfig.merchantCity,
    mcc: BusinessConfig.mcc,
    amount: '500000', // 500,000 VND
    description: 'Order #999',
    // Additional Data (Field 62) - Critical for Accounting
    billNumber: 'INV-2023-001',
    terminalId: 'POS-01',
    storeId: 'MAIN-STORE',
  );

  final businessDynamicQr = EmvBuilder.build(businessDynamicData);
  print('--- 3. Business Dynamic QR (with Bill & Terminal ID) ---');
  print(
    'Type: ${businessDynamicData.isDynamic ? "Dynamic (One-time)" : "Static"}',
  );
  print('MCC Category: ${businessDynamicData.merchantCategory}');
  print('Payload:');
  print(businessDynamicQr);
  print('----------------------------------------------------\n');

  // ---------------------------------------------------------------------------
  // EXAMPLE 4: Business Static QR
  // Use case: Printed QR sticker placed at a specific Checkout Counter.
  // Contains Terminal ID so the system knows which counter received the money.
  // ---------------------------------------------------------------------------
  final businessStaticData = VietQrFactory.createBusiness(
    bankBin: BusinessConfig.bankBin,
    accountNumber: BusinessConfig.accountNumber,
    merchantName: BusinessConfig.merchantName,
    merchantCity: BusinessConfig.merchantCity,
    mcc: BusinessConfig.mcc,
    // amount: null, // Leaving amount null makes it a Static QR
    terminalId: 'COUNTER_05', // Money is flowing to Counter 05
    description: 'Payment for Service',
  );

  final businessStaticQr = EmvBuilder.build(businessStaticData);
  print('--- 4. Business Static QR (Counter Print) ---');
  print('Type: ${businessStaticData.isDynamic ? "Dynamic" : "Static"}');
  print(
    'Tracking Terminal: ${businessStaticData.additionalData?.contains("COUNTER_05") ?? false ? "COUNTER_05" : "N/A"}',
  );
  print('Payload:');
  print(businessStaticQr);
  print('---------------------------------------------\n');

  // ---------------------------------------------------------------------------
  // EXAMPLE 5: International Custom QR (Thai PromptPay)
  // Use case: Demonstrating that the EmvBuilder is generic and works for
  // other EMV standards (like Thailand, Singapore, etc.)
  // ---------------------------------------------------------------------------
  final customThaiData = const EmvData(
    currency: '764', // THB (Thai Baht)
    country: 'TH',
    merchantName: 'Street Food Stall',
    merchantCity: 'Bangkok',
    merchantCategory: '5411', // Grocery
    merchantAccountInfo: {
      '29': '0016A00000067701011101130066891234567', // PromptPay ID (ID 29)
    },
    amount: '100.00',
    isDynamic: true,
  );

  final thaiQrString = EmvBuilder.build(customThaiData);
  print('--- 5. International Custom QR (Thai PromptPay) ---');
  print('Currency: ${customThaiData.currency} (THB)');
  print('Payload:');
  print(thaiQrString);
  print('---------------------------------------------------\n');

  print(
    '✅ DONE: Copy the strings above and paste them into a QR Generator (or zxing.org) to test!',
  );
}
