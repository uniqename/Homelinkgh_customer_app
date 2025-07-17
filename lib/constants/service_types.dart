class ServiceTypes {
  static const Map<String, String> serviceIcons = {
    'House Cleaning': '🧹',
    'Plumbing': '🔧',
    'Electrical Services': '⚡',
    'Electrical Work': '⚡',
    'Food Delivery': '🍽️',
    'Grocery Shopping': '🛒',
    'Transportation': '🚗',
    'Nail Tech': '💅',
    'Makeup Artist': '💄',
    'Cooking Service': '👩‍🍳',
    'Laundry Service': '👕',
    'AC Repair': '❄️',
    'Generator Service': '🔌',
    'Default': '🏠',
  };

  static String getIconForService(String serviceName) {
    return serviceIcons[serviceName] ?? serviceIcons['Default']!;
  }

  static List<String> getAllServiceTypes() {
    return serviceIcons.keys.where((key) => key != 'Default').toList();
  }

  static bool isValidServiceType(String serviceName) {
    return serviceIcons.containsKey(serviceName);
  }
}