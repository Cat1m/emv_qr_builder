# EMV QR Builder

[![Pub Version](https://img.shields.io/pub/v/emv_qr_builder)](https://pub.dev/packages/emv_qr_builder)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Dart SDK](https://img.shields.io/badge/Dart-3.0%2B-blue)](https://dart.dev/)

A lightweight, pure Dart library for generating **EMVCo Compliant QR Code** payloads.

Designed to be the core engine for payment QR codes, specialized for **VietQR (NapAS 247)** including both Personal and Business transfer standards.

## ⚠️ Important Limitations

**This package is ideal for:**
- Small local businesses (cafes, shops, street vendors)
- Freelancers and individuals receiving payments
- Anyone comfortable with manual payment verification (customers send transfer screenshots or payment confirmations)

**What you need to know:**
- ✅ **Anyone with a bank account** can generate VietQR codes - no special merchant registration required
- ✅ Use the **`description`** field (Field 62, ID 08) for order numbers, invoice references, or reconciliation info
- ⚠️ **Business QR fields have limited effect without merchant registration**: For unregistered accounts, Business QR codes work similarly to Personal QR codes. Fields like `mcc`, `billNumber`, `storeId`, and `terminalId` are included in the QR code but **won't be processed** by banks without a formal merchant agreement
- ⚠️ **MCC codes**: While not required for basic transfers, using the correct MCC from the start is good practice if you plan to register as a merchant later
- ❌ **Not suitable for**: Businesses requiring automated payment reconciliation, real-time payment confirmation APIs, or official merchant features (these require bank registration and integration)

**Recommended workflow**: Generate QR → Customer scans and pays → Customer sends payment confirmation (screenshot or bank notification) → You verify manually.

## 🔄 Workflow

```mermaid
graph LR
    A[Input Data] -->|VietQrFactory| B(EmvData Object)
    B -->|EmvBuilder| C{CRC Valid?}
    C -->|Yes| D[QR String Payload]
    D -->|QR Widget/Lib| E[Scanable QR Image]
    style D stroke:#f66,stroke-width:2px,stroke-dasharray: 5, 5

## ✨ Features

- 🚀 **Pure Dart**: Zero Flutter UI dependencies. Runs on Mobile, Web, Desktop, and Server.
- 🛠 **Standard Compliant**: Follows EMVCo QR Code Specification for Payment Systems (Consumer-Presented Mode).
- 🇻🇳 **VietQR Pro**: Specialized factory for generating Vietnam Bank Transfer QRs (NapAS) for Personal (P2P) and Business (Merchants).
- 🏪 **MCC Support**: Built-in dictionary for common Merchant Category Codes (ISO 18245) + support for custom codes.
- 🛡 **Safe & Tested**: 100% unit test coverage for CRC16 generation and field formatting.
- 🧩 **Extensible**: Easily adaptable for other regional standards (Thailand PromptPay, Singapore PayNow...).

## 📦 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  emv_qr_builder: ^1.0.2
```

## 🚀 Usage

### 1. VietQR Personal (Chuyển khoản cá nhân)

The easiest way to generate a QR code for standard P2P transfers between individuals.

```dart
import 'package:emv_qr_builder/emv_qr_builder.dart';

void main() {
  final qrData = VietQrFactory.createPersonal(
    bankBin: '970415',        // Vietcombank
    accountNumber: '1122334455',
    amount: '50000',          // Optional: 50,000 VND
    description: 'Pay for coffee',
  );

  final qrString = EmvBuilder.build(qrData);
  print(qrString);
  // Output: 00020101021238540010A000000727...6304ABCD
}
```

### 2. VietQR Business (Thanh toán doanh nghiệp)

Generate QRs for Merchants with full tracking information (Bill Number, Terminal ID, Store ID).

**Important Notes**: 
- Without a registered Merchant Account, this QR will work like a Personal QR - customers can still pay, but advanced fields (`mcc`, `billNumber`, `storeId`, `terminalId`) won't be processed by the bank
- **Use the `description` field** for order tracking instead of `billNumber` if you don't have merchant registration
- To get full merchant features (brand name display, automatic reconciliation), you need to register with your bank as a business account

```dart
final businessData = VietQrFactory.createBusiness(
  bankBin: '970418',           // BIDV
  accountNumber: '1122334455',
  merchantName: 'CHIEN BUSINESS',
  merchantCity: 'HANOI',
  mcc: '8062',                 // Hospitals (See MCC section below)
  amount: '500000',
  description: 'Order #999',
  // Additional Data (Field 62) - Crucial for Accounting software reconciliation
  billNumber: 'INV-2023-001',
  terminalId: 'POS-01',
  storeId: 'MAIN-STORE',
);

final qrString = EmvBuilder.build(businessData);
```

### 3. Custom / International EMV QR

You can build any EMV-compliant QR code (e.g., Thai PromptPay) by manually constructing the `EmvData`.

```dart
final customData = EmvData(
  currency: '764', // THB (Thai Baht)
  country: 'TH',
  merchantName: 'Street Food Stall',
  merchantCity: 'Bangkok',
  merchantCategory: '5411', // Grocery
  merchantAccountInfo: {
    '29': '0016A00000067701011101130066891234567', // PromptPay ID (Field 29)
  },
  amount: '100.00',
  isDynamic: true,
);

final qrPayload = EmvBuilder.build(customData);
```

## 🏪 Merchant Category Codes (MCC)

For Business QRs, the MCC (Field 52) classifies the type of goods or services the merchant provides.

**Note**: Without merchant registration, MCC codes are included in the QR but not enforced by banks. However, using the correct MCC from the start is recommended if you plan to register later.

### 📋 Built-in Common Codes

This package includes a `MccData` dictionary with the most common codes used in Vietnam. You can access them via `MccUtil`:

| Code | Category |
|------|----------|
| 5411 | Grocery Stores, Supermarkets |
| 5812 | Restaurants, Eating Places |
| 5814 | Fast Food & Coffee |
| 8062 | Hospitals, Medical Services |
| 4121 | Taxi / Ride Hailing |
| 5311 | Department Stores |
| 5691 | Clothing Stores |
| 5732 | Electronics Stores |
| 5999 | General Merchant / Retail (Default) |

### 🔍 How to find other MCCs?

If your business type is not in the list above, you can find the correct 4-digit code by searching on Google:

**Keywords**: "ISO 18245 MCC list" or "Visa Merchant Category Codes PDF"

### 🛠 How to use a Custom MCC?

You are not limited to the built-in list. You can pass any 4-digit string directly to the factory:

```dart
// Example: Using a custom MCC for "Funeral Services" (7261)
final data = VietQrFactory.createBusiness(
  // ... other fields
  mcc: '7261', // Just pass the code as a string
);
```

## 🏗 Architecture

This package follows Clean Architecture principles:

- **EmvData**: Immutable Data Transfer Object (DTO) holding the QR information.
- **EmvBuilder**: Pure logic class that constructs the TLV (Tag-Length-Value) string and calculates CRC.
- **VietQrFactory**: A helper factory that abstracts the complexity of NapAS specifications (Field 38 structure).
- **MccUtil**: Helper to manage/lookup Merchant Category Codes without external assets.

## 🧪 Testing

The package includes a comprehensive suite of unit tests.

```bash
dart test
```

## 🏦 Supported Banks & Data

This package includes a static list of popular Vietnamese banks in `VietQrFactory` and `BankCodes` for convenience.

### 📡 Dynamic Bank List (Real-time)

If you need the most up-to-date list of banks (including new logos, status, or newly merged banks), you should fetch data directly from the VietQR API:

- **API Endpoint**: https://api.vietqr.io/v2/banks
- **Method**: GET

**⚠️ Disclaimer**: The API endpoint https://api.vietqr.io is a third-party service managed by VietQR.io. This package (`emv_qr_builder`) is not affiliated with VietQR.io. We are not responsible for the availability, uptime, rate limits, or data accuracy of this API. Use it at your own discretion.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

Contributions are welcome! If you find a bug or want to add a new feature (e.g., new standard support), please open an issue or submit a Pull Request.