/// Utility class to sanitize strings for banking compatibility.
class StringUtils {
  const StringUtils._();

  /// Normalizes the input string to be compatible with banking systems.
  ///
  /// This method performs the following operations:
  /// 1. Removes Vietnamese diacritics (accents).
  /// 2. Filters out unsafe characters, keeping only [a-z], [A-Z], [0-9], space, dot, and dash.
  /// 3. Truncates the result to a maximum of 50 characters to prevent overflow errors.
  static String normalize(String input) {
    if (input.isEmpty) return '';

    // 1. Remove Vietnamese diacritics
    var result = _removeDiacritics(input);

    // 2. Keep only safe characters (A-Z, 0-9, space, dot, dash)
    result = result.replaceAll(RegExp(r'[^a-zA-Z0-9 .-]'), ' ');

    // 3. Truncate if exceeding maximum length (50 characters)
    if (result.length > 50) {
      result = result.substring(0, 50);
    }

    return result.trim();
  }

  /// Internal helper to replace Vietnamese accented characters with their ASCII equivalents.
  static String _removeDiacritics(String str) {
    const vietnamese = 'aAeEoOuUiIdDyY';
    final vietnameseRegex = <RegExp>[
      RegExp(r'[àáạảãâầấậẩẫăằắặẳẵ]'),
      RegExp(r'[ÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴ]'),
      RegExp(r'[èéẹẻẽêềếệểễ]'),
      RegExp(r'[ÈÉẸẺẼÊỀẾỆỂỄ]'),
      RegExp(r'[òóọỏõôồốộổỗơờớợởỡ]'),
      RegExp(r'[ÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠ]'),
      RegExp(r'[ùúụủũưừứựửữ]'),
      RegExp(r'[ÙÚỤỦŨƯỪỨỰỬỮ]'),
      RegExp(r'[ìíịỉĩ]'),
      RegExp(r'[ÌÍỊỈĨ]'),
      RegExp(r'[đ]'),
      RegExp(r'[Đ]'),
      RegExp(r'[ỳýỵỷỹ]'),
      RegExp(r'[ỲÝỴỶỸ]'),
    ];

    for (var i = 0; i < vietnameseRegex.length; i++) {
      str = str.replaceAll(vietnameseRegex[i], vietnamese[i]);
    }
    return str;
  }
}

/// Helper class to format data according to TLV (Tag-Length-Value) standard.
class TlvHelper {
  const TlvHelper._();

  /// Formats the [id] and [value] into a TLV string.
  ///
  /// Format: [ID (2 chars)][Length (2 chars)][Value]
  /// Example: id="01", value="ABC" -> "0103ABC"
  ///
  /// Returns an empty string if [value] is null or empty.
  static String format(String id, String? value) {
    if (value == null || value.isEmpty) return '';

    final length = value.length.toString().padLeft(2, '0');
    return '$id$length$value';
  }
}
