/// A lightweight Dart library for building EMV Compliant QR Codes (VietQR).
///
/// This library focuses on generating the raw QR payload string.
/// It supports standard EMVCo structure and provides a helper factory for VietQR.
library;

export 'src/models/emv_data.dart';
export 'src/generator/emv_builder.dart';
export 'src/factories/vietqr_factory.dart';
export 'src/utils/vietqr_helper.dart';
// Note: We intentionally do not export 'constants' or 'crc16' 
// to keep the public API clean.