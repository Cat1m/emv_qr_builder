# EMV QR Builder

[![Pub Version](https://img.shields.io/pub/v/emv_qr_builder)](https://pub.dev/packages/emv_qr_builder)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Dart SDK](https://img.shields.io/badge/Dart-3.0%2B-blue)](https://dart.dev/)

A lightweight, pure Dart library for generating **EMVCo Compliant QR Code** payloads.  
Designed to be the core engine for payment QR codes, including **VietQR (NapAS 247)**, PromptPay, PayNow, and more.

## ✨ Features

- 🚀 **Pure Dart**: Zero Flutter UI dependencies. Runs on Mobile, Web, Desktop, and Server.
- 🛠 **Standard Compliant**: Follows EMVCo QR Code Specification for Payment Systems (Consumer-Presented Mode).
- 🇻🇳 **VietQR Ready**: Specialized factory for generating Vietnam Bank Transfer QR codes (NapAS).
- 🛡 **Safe & Tested**: 100% unit test coverage for CRC16 generation and field formatting.
- 🧩 **Extensible**: Easily adaptable for other regional standards (Thailand, Singapore, India...).

## 📦 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  emv_qr_builder: ^1.0.0
```

## 🚀 Usage

### 1. VietQR (Vietnam Bank Transfer)

The easiest way to generate a QR code for Vietnamese banking apps.

```dart
import 'package:emv_qr_builder/emv_qr_builder.dart';

void main() {
  // Create the data model
  final qrData = VietQrFactory.createPersonal(
    bankBin: '970415',        // Vietcombank
    accountNumber: '1122334455',
    amount: '50000',          // Optional: 50,000 VND
    description: 'Pay for coffee',
  );

  // Generate the payload string
  final qrString = EmvBuilder.build(qrData);

  print(qrString);
  // Output: 00020101021238540010A000000727...6304ABCD
}
```

### 2. Custom / International EMV QR

You can build any EMV-compliant QR code by manually constructing the EmvData. This is useful for implementing PromptPay (Thailand) or generic merchant QRs.

```dart
final customData = EmvData(
  currency: '764', // THB (Thai Baht)
  country: 'TH',
  merchantName: 'Street Food Stall',
  merchantCity: 'Bangkok',
  merchantCategory: '5411', // Grocery
  merchantAccountInfo: {
    '29': '0016A00000067701011101130066891234567', // PromptPay ID
  },
  amount: '100.00',
);

final qrPayload = EmvBuilder.build(customData);
```

## 🏗 Architecture

This package follows Clean Architecture principles:

- **EmvData**: Immutable Data Transfer Object (DTO) holding the QR information.
- **EmvBuilder**: Pure logic class that constructs the TLV (Tag-Length-Value) string and calculates CRC.
- **VietQrFactory**: A helper factory that abstracts the complexity of NapAS specifications (Field 38 structure).

## 🧪 Testing

The package includes a comprehensive suite of unit tests.

```bash
dart test
```

## 🏦 Supported Banks & Data

This package includes a static list of popular Vietnamese banks in VietQrFactory and BankCodes for convenience.

### 🔄 Dynamic Bank List (Real-time)

If you need the most up-to-date list of banks (including new logos, status, or newly merged banks), you should fetch data directly from the VietQR API:

- **API Endpoint**: https://api.vietqr.io/v2/banks
- **Method**: GET

**⚠️ Disclaimer**: The API endpoint https://api.vietqr.io is a third-party service managed by VietQR.io. This package (emv_qr_builder) is not affiliated with VietQR.io. We are not responsible for the availability, uptime, rate limits, or data accuracy of this API. Use it at your own discretion.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.