class GhanaLocations {
  static const List<Map<String, dynamic>> regions = [
    {
      'name': 'Greater Accra',
      'code': 'GA',
      'cities': [
        'Accra',
        'Tema',
        'Kasoa',
        'Madina',
        'Adenta',
        'Weija',
        'Dansoman',
        'Tesano',
        'Legon',
        'East Legon',
        'Airport Residential',
        'Cantonments',
        'Labone',
        'Osu',
        'Dzorwulu',
        'Roman Ridge',
        'Ridge',
        'North Ridge',
        'Abelemkpe',
        'Spintex',
        'Community 25',
        'Sakumono',
        'Nungua',
        'Teshie',
      ]
    },
    {
      'name': 'Ashanti',
      'code': 'AS',
      'cities': [
        'Kumasi',
        'Obuasi',
        'Ejisu',
        'Bekwai',
        'Konongo',
        'Mampong',
        'Offinso',
        'Agona',
        'Bantama',
        'Adum',
        'Asokwa',
        'Suame',
        'Tafo',
        'Pankrono',
      ]
    },
    {
      'name': 'Western',
      'code': 'WR',
      'cities': [
        'Takoradi',
        'Sekondi',
        'Tarkwa',
        'Axim',
        'Half Assini',
        'Prestea',
        'Bogoso',
        'Elubo',
      ]
    },
    {
      'name': 'Central',
      'code': 'CR',
      'cities': [
        'Cape Coast',
        'Elmina',
        'Winneba',
        'Kasoa',
        'Swedru',
        'Saltpond',
        'Mankessim',
        'Agona Swedru',
      ]
    },
    {
      'name': 'Eastern',
      'code': 'ER',
      'cities': [
        'Koforidua',
        'Akosombo',
        'Nkawkaw',
        'Mpraeso',
        'Begoro',
        'Suhum',
        'Nsawam',
        'Kibi',
        'Akim Oda',
      ]
    },
    {
      'name': 'Volta',
      'code': 'VR',
      'cities': [
        'Ho',
        'Keta',
        'Aflao',
        'Hohoe',
        'Kpando',
        'Sogakope',
        'Denu',
        'Anloga',
      ]
    },
    {
      'name': 'Northern',
      'code': 'NR',
      'cities': [
        'Tamale',
        'Yendi',
        'Salaga',
        'Bimbilla',
        'Gushegu',
        'Karaga',
        'Saboba',
      ]
    },
    {
      'name': 'Upper East',
      'code': 'UER',
      'cities': [
        'Bolgatanga',
        'Navrongo',
        'Bawku',
        'Paga',
        'Zebilla',
      ]
    },
    {
      'name': 'Upper West',
      'code': 'UWR',
      'cities': [
        'Wa',
        'Lawra',
        'Jirapa',
        'Tumu',
        'Nadowli',
      ]
    },
    {
      'name': 'Brong-Ahafo',
      'code': 'BAR',
      'cities': [
        'Sunyani',
        'Techiman',
        'Berekum',
        'Dormaa Ahenkro',
        'Wenchi',
        'Kintampo',
        'Nkoranza',
      ]
    },
  ];

  static const List<String> popularAreas = [
    'East Legon',
    'Airport Residential',
    'Cantonments',
    'Ridge',
    'Roman Ridge',
    'Dzorwulu',
    'Labone',
    'Osu',
    'Adenta',
    'Madina',
    'Tema',
    'Spintex',
    'Dansoman',
    'Kumasi',
    'Cape Coast',
    'Takoradi',
  ];

  static const List<Map<String, String>> landmarks = [
    {'name': 'Kotoka International Airport', 'city': 'Accra'},
    {'name': 'University of Ghana', 'city': 'Legon'},
    {'name': 'Accra Mall', 'city': 'Accra'},
    {'name': 'West Hills Mall', 'city': 'Accra'},
    {'name': 'A&C Mall', 'city': 'East Legon'},
    {'name': 'Marina Mall', 'city': 'Accra'},
    {'name': 'Oxford Street', 'city': 'Osu'},
    {'name': 'Labadi Beach', 'city': 'Labadi'},
    {'name': 'National Theatre', 'city': 'Accra'},
    {'name': 'Independence Arch', 'city': 'Accra'},
    {'name': 'Kejetia Market', 'city': 'Kumasi'},
    {'name': 'Cape Coast Castle', 'city': 'Cape Coast'},
    {'name': 'Elmina Castle', 'city': 'Elmina'},
    {'name': 'Tema Harbour', 'city': 'Tema'},
  ];

  static List<String> getCitiesForRegion(String regionName) {
    final region = regions.firstWhere(
      (r) => r['name'] == regionName,
      orElse: () => {'cities': <String>[]},
    );
    return List<String>.from(region['cities']);
  }

  static List<String> getAllCities() {
    List<String> allCities = [];
    for (var region in regions) {
      allCities.addAll(List<String>.from(region['cities']));
    }
    return allCities;
  }

  static List<String> getRegionNames() {
    return regions.map((r) => r['name'] as String).toList();
  }
}