/// Standard Merchant Category Codes (ISO 18245) commonly used in Vietnam.
///
/// This is a subset of the full ISO list, focusing on popular retail and service categories.
class MccData {
  const MccData._(); // Private constructor

  /// A map of common Merchant Category Codes (MCC) to their English descriptions.
  ///
  /// Key: 4-digit ISO 18245 code.
  /// Value: Description of the category.
  static const Map<String, String> codes = {
    // Retail
    '5411': 'Grocery Stores, Supermarkets',
    '5311': 'Department Stores',
    '5691': 'Men\'s and Women\'s Clothing Stores',
    '5732': 'Electronics Sales',
    '5912': 'Pharmacies',
    '5999': 'Miscellaneous and Specialty Retail Stores',

    // Food & Beverage
    '5812': 'Eating places and Restaurants',
    '5814': 'Fast Food Restaurants',

    // Services
    '4121': 'Taxicabs and Limousines',
    '4900': 'Utilities (Electric, Gas, Water)',
    '5541': 'Service Stations (Gas, Fuel)',
    '7298': 'Health and Beauty Spas',
    '8299': 'Schools and Educational Services',

    // Travel & Entertainment
    '7011': 'Hotels, Motels, and Resorts',

    // Medical
    '8062': 'Hospitals',
  };
}
