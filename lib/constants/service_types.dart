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
    'HVAC Services': '🌡️',
    'Beauty Services': '💄',
    'Hair Braiding': '💇‍♀️',
    'Painting': '🎨',
    'Carpentry': '🔨',
    'Landscaping': '🌳',
    'Security Services': '🛡️',
    'Babysitting': '👶',
    'Elderly Care': '👵',
    'Pet Care': '🐕',
    'Event Planning': '🎉',
    'Catering': '🍴',
    'Masonry': '🧱',
    'Roofing': '🏠',
    'Default': '🏠',
  };

  // General framework questions that apply to ALL services
  static const List<Map<String, dynamic>> generalFrameworkFields = [
    {'name': 'serviceType', 'label': 'What type of service are you looking for?', 'type': 'text', 'required': true, 'category': 'general'},
    {'name': 'jobLocation', 'label': 'Where is the location of the job?', 'type': 'text', 'required': true, 'category': 'general'},
    {'name': 'urgency', 'label': 'Is this urgent or scheduled?', 'type': 'dropdown', 'options': ['Emergency (within 2 hours)', 'Urgent (same day)', 'Scheduled (within 3 days)', 'Flexible (within a week)', 'When convenient'], 'required': true, 'category': 'general'},
    {'name': 'frequency', 'label': 'Is this a one-time job or recurring?', 'type': 'dropdown', 'options': ['One-time job', 'Weekly recurring', 'Bi-weekly recurring', 'Monthly recurring', 'As needed'], 'required': true, 'category': 'general'},
    {'name': 'budgetRange', 'label': 'What\'s your budget range? (GH₵)', 'type': 'dropdown', 'options': ['Under ₵50', '₵50-100', '₵100-200', '₵200-500', '₵500-1000', '₵1000+', 'Open to quotes'], 'required': false, 'category': 'general'},
    {'name': 'preferredDate', 'label': 'When would you like this done?', 'type': 'date', 'required': true, 'category': 'general'},
    {'name': 'preferredTime', 'label': 'Preferred time of day', 'type': 'dropdown', 'options': ['Morning (6AM-12PM)', 'Afternoon (12PM-6PM)', 'Evening (6PM-10PM)', 'Anytime', 'Discuss with provider'], 'required': false, 'category': 'general'},
    {'name': 'accessParking', 'label': 'Is there parking or access for heavy equipment/tools?', 'type': 'dropdown', 'options': ['Yes, direct access', 'Limited access', 'No vehicle access', 'Need to discuss'], 'required': false, 'category': 'general'},
    {'name': 'photos', 'label': 'Can you share photos or videos of the space/work area?', 'type': 'file_upload', 'accept': 'image/*,video/*', 'required': false, 'category': 'general'},
    {'name': 'additionalNotes', 'label': 'Additional details or special requirements', 'type': 'textarea', 'required': false, 'category': 'general'},
  ];

  static const Map<String, Map<String, dynamic>> serviceDetails = {
    'House Cleaning': {
      'description': 'Professional house cleaning services for Ghanaian homes',
      'detailedDescription': 'Expert cleaning for compound houses, apartments, and family homes. We understand Ghanaian home layouts including boys\' quarters, verandas, and traditional courtyards.',
      'ghanaSpecific': true,
      'dynamicFields': [
        {'name': 'houseType', 'label': 'House Type', 'type': 'dropdown', 'options': ['Single room', '2 bedroom', '3 bedroom', '4+ bedroom', 'Storey building', 'Compound house', 'Boys quarters']},
        {'name': 'roomsToClean', 'label': 'Specific Rooms', 'type': 'multiselect', 'options': ['Living room', 'Bedrooms', 'Kitchen', 'Bathrooms', 'Veranda', 'Boys quarters', 'Compound area']},
        {'name': 'cleaningType', 'label': 'Cleaning Type', 'type': 'dropdown', 'options': ['Regular cleaning', 'Deep cleaning', 'Move-in/out cleaning', 'Post-construction cleaning']},
        {'name': 'suppliesProvided', 'label': 'Cleaning Supplies', 'type': 'dropdown', 'options': ['I will provide supplies', 'Provider brings supplies', 'We discuss supplies']},
      ],
    },
    'Laundry Service': {
      'description': 'Pickup, wash, and delivery laundry service',
      'detailedDescription': 'Professional laundry service including traditional Ghanaian clothing care (kente, batik, etc.), school uniforms, and everyday wear.',
      'ghanaSpecific': true,
      'dynamicFields': [
        {'name': 'clothingType', 'label': 'Clothing Types', 'type': 'multiselect', 'options': ['Regular clothes', 'Traditional wear (kente/batik)', 'School uniforms', 'Work clothes', 'Delicate fabrics', 'Bedding/linens']},
        {'name': 'pickupLocation', 'label': 'Pickup Location', 'type': 'text', 'required': true},
        {'name': 'dropoffLocation', 'label': 'Dropoff Location', 'type': 'text', 'required': true},
        {'name': 'urgency', 'label': 'Service Speed', 'type': 'dropdown', 'options': ['Same day (extra charge)', 'Next day', '2-3 days (standard)', 'When ready']},
        {'name': 'specialInstructions', 'label': 'Special Care Instructions', 'type': 'textarea', 'required': false},
      ],
    },
    'Plumbing': {
      'description': 'Professional plumbing services for pipes, fixtures, and water systems',
      'detailedDescription': 'Expert plumbing for Ghanaian homes including water storage systems, pipe repairs, and modern fixtures installation.',
      'ghanaSpecific': true,
      'dynamicFields': [
        {'name': 'specificIssue', 'label': 'What specific plumbing issue are you experiencing?', 'type': 'dropdown', 'options': ['Leak (pipes/faucets)', 'Clog/blockage', 'Low water pressure', 'No water flow', 'Water heater problems', 'Toilet issues', 'New installation needed', 'Pipe replacement', 'Other'], 'required': true, 'category': 'specific'},
        {'name': 'issueLocation', 'label': 'Is it in the kitchen, bathroom, outdoor area, or elsewhere?', 'type': 'dropdown', 'options': ['Kitchen', 'Main bathroom', 'Guest bathroom', 'Boys quarters', 'Outdoor/compound area', 'Water tank area', 'Multiple locations'], 'required': true, 'category': 'specific'},
        {'name': 'issueDuration', 'label': 'How long has this issue been occurring?', 'type': 'dropdown', 'options': ['Just started (today)', 'Few days', '1-2 weeks', 'Several weeks', 'Months', 'Getting worse over time'], 'required': true, 'category': 'specific'},
        {'name': 'appliancesInvolved', 'label': 'Are any appliances or fixtures involved?', 'type': 'multiselect', 'options': ['Washing machine', 'Water heater', 'Dishwasher', 'Toilet', 'Sink', 'Shower', 'Bathtub', 'Water pump', 'None'], 'required': false, 'category': 'specific'},
        {'name': 'waterLeaking', 'label': 'Is water leaking or pooling anywhere?', 'type': 'dropdown', 'options': ['Yes, actively leaking', 'Yes, pooling water visible', 'Occasional drips', 'Water stains/damage visible', 'No visible water'], 'required': true, 'category': 'specific'},
        {'name': 'previousWork', 'label': 'Has any previous work been done on this plumbing?', 'type': 'dropdown', 'options': ['No previous work', 'Recent repair (within 6 months)', 'Old repair (over 6 months)', 'Multiple previous repairs', 'Unsure/inherited problem'], 'required': false, 'category': 'specific'},
        {'name': 'waterSystem', 'label': 'Water System Type', 'type': 'dropdown', 'options': ['Poly tank system', 'Borehole with pump', 'Pipe-borne water (Ghana Water)', 'Well water', 'Mixed system', 'Not sure'], 'required': false, 'category': 'specific'},
        {'name': 'emergencyShutoff', 'label': 'Do you know where the main water shutoff is?', 'type': 'dropdown', 'options': ['Yes, can access it', 'Yes, but cannot access', 'No, need help finding it', 'Already shut off'], 'required': false, 'category': 'specific'},
      ],
    },
    'Electrical Services': {
      'description': 'Electrical installations, repairs, and maintenance',
      'detailedDescription': 'Safe electrical services for Ghanaian homes including wiring, outlets, and generator connections with ECG compliance.',
      'ghanaSpecific': true,
      'dynamicFields': [
        {'name': 'workNeeded', 'label': 'What needs to be done: installation, repair, rewiring, or inspection?', 'type': 'dropdown', 'options': ['New installation', 'Repair existing', 'Complete rewiring', 'Electrical inspection', 'Upgrade/modernize', 'Generator connection', 'Solar installation', 'Other'], 'required': true, 'category': 'specific'},
        {'name': 'devicesAffected', 'label': 'Which devices/outlets/lights are affected?', 'type': 'multiselect', 'options': ['Lights not working', 'Outlets not working', 'Switches not working', 'Ceiling fans', 'AC units', 'Water heater', 'Security lights', 'All electricity out', 'Intermittent power'], 'required': true, 'category': 'specific'},
        {'name': 'buildingAge', 'label': 'How old is the building or the wiring?', 'type': 'dropdown', 'options': ['Less than 5 years', '5-10 years', '10-20 years', '20+ years', 'Very old/unknown', 'Recently renovated'], 'required': false, 'category': 'specific'},
        {'name': 'knownIssues', 'label': 'Are there any known issues (power surges, tripped breakers)?', 'type': 'multiselect', 'options': ['Frequent power surges', 'Breakers keep tripping', 'Lights dim when appliances start', 'Sparking outlets', 'Burning smell', 'Shock from switches', 'No known issues', 'Other'], 'required': false, 'category': 'specific'},
        {'name': 'roomsOutlets', 'label': 'How many rooms or outlets need work?', 'type': 'dropdown', 'options': ['1 outlet/switch', '2-3 outlets', 'Whole room', '2-3 rooms', 'Whole house', 'Just outdoor area', 'Compound lighting'], 'required': true, 'category': 'specific'},
        {'name': 'breakerAccess', 'label': 'Will this require access to the circuit breaker/fuse box?', 'type': 'dropdown', 'options': ['Yes, can provide access', 'Yes, but need to find it', 'No access needed', 'Not sure', 'Need new breaker box'], 'required': false, 'category': 'specific'},
        {'name': 'powerSource', 'label': 'Power Source', 'type': 'dropdown', 'options': ['ECG mains only', 'Generator only', 'Solar system', 'ECG + Generator backup', 'Mixed/complex setup', 'Not sure'], 'required': false, 'category': 'specific'},
        {'name': 'safetyUrgency', 'label': 'Is this a safety emergency?', 'type': 'dropdown', 'options': ['Yes - sparks/burning smell', 'Yes - no power at all', 'Somewhat - intermittent issues', 'No - planned upgrade/install'], 'required': true, 'category': 'specific'},
      ],
    },
    'Beauty Services': {
      'description': 'Professional beauty services at your location',
      'detailedDescription': 'Full beauty services including makeup, hair styling, nail care, and traditional Ghanaian beauty treatments.',
      'ghanaSpecific': true,
      'dynamicFields': [
        {'name': 'serviceType', 'label': 'Beauty Services', 'type': 'multiselect', 'options': ['Makeup application', 'Hair styling', 'Hair braiding', 'Natural hair care', 'Nail manicure', 'Nail pedicure', 'Eyebrow shaping', 'Facial treatment']},
        {'name': 'occasion', 'label': 'Occasion', 'type': 'dropdown', 'options': ['Wedding', 'Traditional ceremony', 'Birthday party', 'Work event', 'Date night', 'Photo shoot', 'Regular maintenance']},
        {'name': 'numberOfPeople', 'label': 'Number of People', 'type': 'number', 'required': true},
        {'name': 'hairType', 'label': 'Hair Type/Style', 'type': 'dropdown', 'options': ['Natural hair', 'Relaxed hair', 'Braids needed', 'Weave/extensions', 'Dreadlocks', 'Mixed textures']},
        {'name': 'preferredProducts', 'label': 'Product Preference', 'type': 'dropdown', 'options': ['Natural/organic products', 'International brands', 'Local Ghanaian products', 'No preference']},
      ],
    },
    'Nail Tech': {
      'description': 'Professional nail care and nail art services',
      'detailedDescription': 'Expert nail services including manicures, pedicures, and creative nail art with both local and international techniques.',
      'ghanaSpecific': true,
      'dynamicFields': [
        {'name': 'serviceType', 'label': 'Nail Services', 'type': 'multiselect', 'options': ['Basic manicure', 'Basic pedicure', 'Gel manicure', 'Acrylic nails', 'Nail art', 'French manicure', 'Nail repair', 'Nail removal']},
        {'name': 'nailLength', 'label': 'Preferred Nail Length', 'type': 'dropdown', 'options': ['Short and natural', 'Medium length', 'Long nails', 'Extra long', 'Maintain current length']},
        {'name': 'designStyle', 'label': 'Design Style', 'type': 'dropdown', 'options': ['Simple/minimalist', 'Colorful patterns', 'Ghana flag colors', 'Traditional African patterns', 'Modern nail art', 'Seasonal designs']},
        {'name': 'numberOfPeople', 'label': 'Number of People', 'type': 'number', 'required': true},
      ],
    },
    'Cooking Service': {
      'description': 'Professional cooking services for Ghanaian and international cuisine',
      'detailedDescription': 'Expert cooks specializing in Ghanaian traditional meals, party food, and international cuisine for your events.',
      'ghanaSpecific': true,
      'dynamicFields': [
        {'name': 'cuisineType', 'label': 'Cuisine Type', 'type': 'multiselect', 'options': ['Traditional Ghanaian', 'Northern Ghanaian', 'International', 'Chinese', 'Lebanese', 'Indian', 'Continental']},
        {'name': 'mealType', 'label': 'Meal Type', 'type': 'dropdown', 'options': ['Daily meals', 'Party/event', 'Special occasion', 'Weekly meal prep', 'One-time cooking']},
        {'name': 'numberOfPeople', 'label': 'Number of People', 'type': 'number', 'required': true},
        {'name': 'dietaryReqs', 'label': 'Dietary Requirements', 'type': 'multiselect', 'options': ['No restrictions', 'Vegetarian', 'No pork', 'No beef', 'Diabetic-friendly', 'Low salt', 'Allergies (specify)']},
        {'name': 'groceryShopping', 'label': 'Grocery Shopping', 'type': 'dropdown', 'options': ['I provide ingredients', 'Cook does shopping (with my money)', 'Cook provides ingredients (extra cost)']},
      ],
    },
    'Transportation': {
      'description': 'Reliable transportation services across Ghana',
      'detailedDescription': 'Professional drivers and vehicles for airport transfers, city rides, long-distance travel, and special occasions.',
      'ghanaSpecific': true,
      'dynamicFields': [
        {'name': 'serviceType', 'label': 'Service Type', 'type': 'dropdown', 'options': ['Airport transfer', 'City ride', 'Long distance', 'Wedding transport', 'Funeral transport', 'Tourist guide', 'Monthly contract']},
        {'name': 'vehicleType', 'label': 'Vehicle Preference', 'type': 'dropdown', 'options': ['Saloon car', 'SUV', 'Bus/Trotro', 'Taxi', 'Uber-style', 'Luxury car', 'Any available']},
        {'name': 'numberOfPeople', 'label': 'Number of Passengers', 'type': 'number', 'required': true},
        {'name': 'pickupLocation', 'label': 'Pickup Location', 'type': 'text', 'required': true},
        {'name': 'destination', 'label': 'Destination', 'type': 'text', 'required': true},
        {'name': 'returnTrip', 'label': 'Return Trip Needed', 'type': 'boolean', 'required': false},
      ],
    },
    'Generator Service': {
      'description': 'Generator installation, repair, and maintenance',
      'detailedDescription': 'Expert generator services for homes and businesses including installation, repairs, and regular maintenance.',
      'ghanaSpecific': true,
      'dynamicFields': [
        {'name': 'serviceType', 'label': 'Service Type', 'type': 'dropdown', 'options': ['New installation', 'Repair service', 'Regular maintenance', 'Emergency repair', 'Generator house construction']},
        {'name': 'generatorType', 'label': 'Generator Type', 'type': 'dropdown', 'options': ['Small portable (1-5KVA)', 'Medium (6-15KVA)', 'Large (16-50KVA)', 'Industrial (50KVA+)', 'Not sure/need advice']},
        {'name': 'problem', 'label': 'Problem Description', 'type': 'textarea', 'required': false},
        {'name': 'fuelType', 'label': 'Fuel Type', 'type': 'dropdown', 'options': ['Petrol', 'Diesel', 'Gas', 'Mixed', 'Not sure']},
      ],
    },
    'AC Repair': {
      'description': 'Air conditioning installation, repair, and maintenance',
      'detailedDescription': 'Professional AC services for Ghana\'s climate including installation, repairs, and energy-efficient solutions.',
      'ghanaSpecific': true,
      'dynamicFields': [
        {'name': 'serviceType', 'label': 'Service Type', 'type': 'dropdown', 'options': ['New installation', 'Repair service', 'Regular maintenance', 'Gas refill', 'Cleaning service', 'Energy audit']},
        {'name': 'acType', 'label': 'AC Type', 'type': 'dropdown', 'options': ['Window AC', 'Split AC', 'Ceiling mounted', 'Floor standing', 'Central AC', 'Not sure']},
        {'name': 'numberOfUnits', 'label': 'Number of AC Units', 'type': 'number', 'required': true},
        {'name': 'roomSize', 'label': 'Room Size', 'type': 'dropdown', 'options': ['Small room', 'Medium room', 'Large room', 'Hall/living room', 'Office space', 'Multiple rooms']},
        {'name': 'problem', 'label': 'Problem Description', 'type': 'textarea', 'required': false},
      ],
    },
    'Masonry': {
      'description': 'Professional masonry work - bricklaying, concrete, and stonework',
      'detailedDescription': 'Expert masonry services for Ghanaian construction including compound walls, foundations, and decorative stonework using local materials.',
      'ghanaSpecific': true,
      'dynamicFields': [
        {'name': 'workType', 'label': 'What structure or area needs masonry work?', 'type': 'dropdown', 'options': ['Compound wall/fence', 'Building foundation', 'Floor (concrete/tile)', 'Interior wall', 'Exterior wall', 'Steps/stairs', 'Decorative work', 'Repair work', 'Other'], 'required': true, 'category': 'specific'},
        {'name': 'approximateSize', 'label': 'What is the approximate size? (length x height or square meters)', 'type': 'text', 'required': true, 'category': 'specific'},
        {'name': 'constructionType', 'label': 'Is this new construction, repair, or renovation?', 'type': 'dropdown', 'options': ['New construction', 'Repair existing', 'Renovation/upgrade', 'Extension/addition', 'Replacement'], 'required': true, 'category': 'specific'},
        {'name': 'currentMaterial', 'label': 'What material is currently there, if any?', 'type': 'dropdown', 'options': ['Nothing (new build)', 'Concrete blocks', 'Clay bricks', 'Sandcrete blocks', 'Stone', 'Old/damaged concrete', 'Mixed materials', 'Not sure'], 'required': false, 'category': 'specific'},
        {'name': 'materialSupply', 'label': 'Do you already have materials or need the provider to supply them?', 'type': 'dropdown', 'options': ['I have all materials', 'I have some materials', 'Provider should supply all', 'Provider should quote materials', 'Need advice on materials'], 'required': true, 'category': 'specific'},
        {'name': 'siteAccess', 'label': 'Is the area accessible for delivery of sand, stone, cement?', 'type': 'dropdown', 'options': ['Yes, truck can reach site', 'Partial access (wheelbarrow needed)', 'No vehicle access', 'Need to discuss access', 'Materials already on site'], 'required': true, 'category': 'specific'},
        {'name': 'foundationNeeded', 'label': 'Does this work require foundation or ground preparation?', 'type': 'dropdown', 'options': ['Yes, need foundation work', 'Ground needs leveling', 'Site is ready', 'Not sure, need assessment'], 'required': false, 'category': 'specific'},
        {'name': 'finishRequired', 'label': 'What type of finish is needed?', 'type': 'dropdown', 'options': ['Smooth cement finish', 'Textured finish', 'Paint-ready surface', 'Natural stone look', 'No special finish', 'Discuss with mason'], 'required': false, 'category': 'specific'},
      ],
    },
    'Carpentry': {
      'description': 'Custom carpentry and woodworking services',
      'detailedDescription': 'Expert carpentry using local and imported woods for furniture, doors, windows, and custom woodwork for Ghanaian homes.',
      'ghanaSpecific': true,
      'dynamicFields': [
        {'name': 'projectType', 'label': 'What needs to be built or repaired?', 'type': 'dropdown', 'options': ['Cabinet/wardrobe', 'Table/desk', 'Bed/bedroom furniture', 'Door (interior/exterior)', 'Window frames', 'Shelving/storage', 'Kitchen units', 'Repair existing furniture', 'Custom design', 'Other'], 'required': true, 'category': 'specific'},
        {'name': 'designPlans', 'label': 'Do you have a design or should the provider suggest options?', 'type': 'dropdown', 'options': ['I have detailed plans/drawings', 'I have rough ideas/sketches', 'I have photos of what I want', 'Need design suggestions', 'Want to see samples first'], 'required': true, 'category': 'specific'},
        {'name': 'woodType', 'label': 'What type of wood do you prefer?', 'type': 'dropdown', 'options': ['Mahogany (local)', 'Teak', 'Cedar', 'Wawa (local softwood)', 'Plywood/engineered', 'Budget-friendly options', 'Need recommendations', 'Imported hardwood'], 'required': false, 'category': 'specific'},
        {'name': 'measurements', 'label': 'Do you have specific measurements or need a site visit?', 'type': 'dropdown', 'options': ['I have exact measurements', 'I have approximate sizes', 'Need professional measuring', 'Site visit required', 'Standard sizes okay'], 'required': true, 'category': 'specific'},
        {'name': 'workLocation', 'label': 'Is this indoor or outdoor work?', 'type': 'dropdown', 'options': ['Indoor only', 'Outdoor only', 'Both indoor/outdoor', 'Workshop build then install', 'On-site custom build'], 'required': true, 'category': 'specific'},
        {'name': 'finishingIncluded', 'label': 'Do you need painting/staining/finishing included?', 'type': 'dropdown', 'options': ['Yes, full finishing', 'Just sanding/prep for paint', 'Natural wood finish/stain', 'I will finish myself', 'Discuss options'], 'required': false, 'category': 'specific'},
        {'name': 'hardwareIncluded', 'label': 'Should hardware (handles, hinges, locks) be included?', 'type': 'dropdown', 'options': ['Yes, include quality hardware', 'Basic hardware only', 'I will provide hardware', 'Quote hardware separately', 'Need recommendations'], 'required': false, 'category': 'specific'},
        {'name': 'installationNeeded', 'label': 'Will installation/delivery be needed?', 'type': 'dropdown', 'options': ['Yes, delivery and installation', 'Delivery only', 'I will pick up', 'Build on-site', 'Discuss logistics'], 'required': true, 'category': 'specific'},
      ],
    },
    'Roofing': {
      'description': 'Professional roofing and ceiling services',
      'detailedDescription': 'Expert roofing for Ghanaian climate including metal sheets, tiles, and traditional roofing with proper drainage and ventilation.',
      'ghanaSpecific': true,
      'dynamicFields': [
        {'name': 'roofSize', 'label': 'What\'s the size or number of rooms involved?', 'type': 'dropdown', 'options': ['Single room', '2-3 rooms', '4-6 rooms', 'Whole house', 'Boys quarters', 'Compound structure', 'Very large building'], 'required': true, 'category': 'specific'},
        {'name': 'workType', 'label': 'Is this leak repair, full replacement, or new installation?', 'type': 'dropdown', 'options': ['Leak repair only', 'Partial roof replacement', 'Complete roof replacement', 'New roof installation', 'Ceiling work only', 'Roof + ceiling combo', 'Gutter work'], 'required': true, 'category': 'specific'},
        {'name': 'currentMaterial', 'label': 'What materials are currently on the roof or ceiling?', 'type': 'dropdown', 'options': ['Aluminum sheets', 'Iron sheets (zinc)', 'Clay tiles', 'Concrete tiles', 'Thatch/traditional', 'Asbestos (old)', 'Mixed materials', 'No existing roof'], 'required': true, 'category': 'specific'},
        {'name': 'damageDescription', 'label': 'Are there signs of damage (leaks, sagging, mold)?', 'type': 'multiselect', 'options': ['Active leaks during rain', 'Water stains on ceiling', 'Sagging roof/ceiling', 'Mold/fungus growth', 'Rust/corrosion', 'Missing/loose sheets', 'Structural damage', 'No visible damage'], 'required': true, 'category': 'specific'},
        {'name': 'roofAge', 'label': 'How old is the current roof/ceiling?', 'type': 'dropdown', 'options': ['Less than 5 years', '5-10 years', '10-20 years', '20+ years', 'Very old/unknown age', 'Recently repaired'], 'required': false, 'category': 'specific'},
        {'name': 'accessRequirements', 'label': 'Is scaffolding or special ladder access needed?', 'type': 'dropdown', 'options': ['Ground level/single story', '2-story building', '3+ story building', 'Difficult access/steep', 'Scaffolding required', 'Provider brings equipment', 'Not sure'], 'required': true, 'category': 'specific'},
        {'name': 'weatherUrgency', 'label': 'How urgent is this (considering weather)?', 'type': 'dropdown', 'options': ['Emergency - water coming in', 'Before next rainy season', 'During dry season only', 'Flexible timing', 'Scheduled maintenance'], 'required': true, 'category': 'specific'},
        {'name': 'insulationNeeded', 'label': 'Do you need ceiling insulation or ventilation?', 'type': 'dropdown', 'options': ['Yes, for heat reduction', 'Basic ventilation needed', 'Insulation + ventilation', 'No special requirements', 'Need recommendations'], 'required': false, 'category': 'specific'},
      ],
    },
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

  static Map<String, dynamic>? getServiceDetails(String serviceName) {
    return serviceDetails[serviceName];
  }

  static String getServiceDescription(String serviceName) {
    final details = serviceDetails[serviceName];
    return details?['description'] ?? 'Professional service at your convenience';
  }

  static String getDetailedServiceDescription(String serviceName) {
    final details = serviceDetails[serviceName];
    return details?['detailedDescription'] ?? 'Professional service at your convenience';
  }

  static List<Map<String, dynamic>> getDynamicFields(String serviceName) {
    final details = serviceDetails[serviceName];
    return List<Map<String, dynamic>>.from(details?['dynamicFields'] ?? []);
  }

  static List<Map<String, dynamic>> getAllFieldsForService(String serviceName) {
    // Combine general framework fields with service-specific fields
    final List<Map<String, dynamic>> allFields = [...generalFrameworkFields];
    allFields.addAll(getDynamicFields(serviceName));
    return allFields;
  }

  static List<Map<String, dynamic>> getFieldsByCategory(String serviceName, String category) {
    final allFields = getAllFieldsForService(serviceName);
    return allFields.where((field) => field['category'] == category).toList();
  }

  static List<Map<String, dynamic>> getGeneralFields() {
    return List<Map<String, dynamic>>.from(generalFrameworkFields);
  }

  static List<Map<String, dynamic>> getServiceSpecificFields(String serviceName) {
    return getDynamicFields(serviceName);
  }

  static bool isGhanaSpecificService(String serviceName) {
    final details = serviceDetails[serviceName];
    return details?['ghanaSpecific'] == true;
  }

  // Calculate rough pricing based on answers (basic implementation)
  static Map<String, dynamic> calculateRoughPricing(String serviceName, Map<String, dynamic> answers) {
    // Base pricing structure for Ghana (in GH₵)
    final Map<String, Map<String, dynamic>> basePricing = {
      'Plumbing': {
        'basePrice': 80,
        'urgencyMultiplier': {'Emergency (within 2 hours)': 2.0, 'Urgent (same day)': 1.5, 'Scheduled (within 3 days)': 1.0},
        'complexityFactors': {'Multiple locations': 1.5, 'Water tank area': 1.3, 'Boys quarters': 1.2}
      },
      'Electrical Services': {
        'basePrice': 100,
        'urgencyMultiplier': {'Emergency (no power)': 2.5, 'Urgent (safety issue)': 2.0, 'Normal priority': 1.0},
        'complexityFactors': {'Whole house': 3.0, '2-3 rooms': 2.0, 'Complete rewiring': 4.0}
      },
      'House Cleaning': {
        'basePrice': 40,
        'urgencyMultiplier': {'Same day (extra charge)': 1.5, 'Next day': 1.2, '2-3 days (standard)': 1.0},
        'complexityFactors': {'4+ bedroom': 2.5, '3 bedroom': 2.0, '2 bedroom': 1.5, 'Deep cleaning': 1.8}
      },
      'Masonry': {
        'basePrice': 200,
        'urgencyMultiplier': {'Emergency - water coming in': 2.0, 'Before next rainy season': 1.3, 'Flexible timing': 1.0},
        'complexityFactors': {'Whole house': 5.0, 'Compound wall/fence': 3.0, 'Building foundation': 4.0}
      },
      'Carpentry': {
        'basePrice': 150,
        'urgencyMultiplier': {'Emergency (within 2 hours)': 2.0, 'Urgent (same day)': 1.5, 'Scheduled (within 3 days)': 1.0},
        'complexityFactors': {'Custom design': 2.0, 'Kitchen units': 2.5, 'Yes, full finishing': 1.5}
      },
      'Roofing': {
        'basePrice': 300,
        'urgencyMultiplier': {'Emergency - water coming in': 3.0, 'Before next rainy season': 1.5, 'Flexible timing': 1.0},
        'complexityFactors': {'Whole house': 4.0, '4-6 rooms': 2.5, 'Complete roof replacement': 3.0}
      },
    };

    final serviceData = basePricing[serviceName];
    if (serviceData == null) {
      return {'estimatedPrice': 0, 'priceRange': '₵0 - ₵0', 'note': 'Custom quote required'};
    }

    double basePrice = serviceData['basePrice'].toDouble();
    double finalPrice = basePrice;

    // Apply urgency multiplier
    final urgency = answers['urgency'];
    final urgencyMultipliers = serviceData['urgencyMultiplier'] as Map<String, dynamic>;
    if (urgency != null && urgencyMultipliers.containsKey(urgency)) {
      finalPrice *= urgencyMultipliers[urgency];
    }

    // Apply complexity factors
    final complexityFactors = serviceData['complexityFactors'] as Map<String, dynamic>;
    for (final factor in complexityFactors.keys) {
      for (final answer in answers.values) {
        if (answer is String && answer.contains(factor)) {
          finalPrice *= complexityFactors[factor];
          break;
        }
        if (answer is List && answer.any((item) => item.toString().contains(factor))) {
          finalPrice *= complexityFactors[factor];
          break;
        }
      }
    }

    // Apply budget constraints
    final budgetRange = answers['budgetRange'];
    String note = 'Estimated quote based on your requirements';

    final lowerBound = (finalPrice * 0.8).round();
    final upperBound = (finalPrice * 1.2).round();

    return {
      'estimatedPrice': finalPrice.round(),
      'priceRange': '₵$lowerBound - ₵$upperBound',
      'note': note,
      'basePrice': basePrice.round(),
    };
  }
}