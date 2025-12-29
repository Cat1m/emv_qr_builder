import '../constants/mcc_data.dart';

/// Utility class to manage Merchant Category Codes (MCC).
class MccUtil {
  const MccUtil._();

  /// Retrieves the category name for a given MCC [code].
  ///
  /// Returns the name if found, otherwise returns a generic fallback.
  static String getName(String code) {
    return MccData.codes[code] ?? 'Unknown Category ($code)';
  }

  /// Checks if a given [code] exists in the standard list.
  ///
  /// Note: Even if this returns false, the code might still be valid
  /// according to ISO 18245 but not present in our common list.
  static bool isRecognized(String code) {
    return MccData.codes.containsKey(code);
  }

  /// Returns all available MCC entries for UI selection/dropdowns.
  static Map<String, String> getAll() {
    return MccData.codes;
  }
}
