import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EnhancedBeautyServicesScreen extends StatefulWidget {
  final String serviceType; // 'nail_tech' or 'makeup_artist'
  
  const EnhancedBeautyServicesScreen({
    super.key,
    required this.serviceType,
  });

  @override
  State<EnhancedBeautyServicesScreen> createState() => _EnhancedBeautyServicesScreenState();
}

class _EnhancedBeautyServicesScreenState extends State<EnhancedBeautyServicesScreen> {
  final List<Map<String, dynamic>> _nailTechs = [
    {
      'name': 'Akosua Mensah',
      'rating': 4.9,
      'reviewCount': 127,
      'experience': '5 years',
      'location': 'East Legon, Accra',
      'profileImage': 'assets/profiles/akosua_nail.jpg',
      'verified': true,
      'specialties': ['Gel Nails', 'Nail Art', 'Manicures', 'Pedicures'],
      'pricing': {
        'Basic Manicure': 30.0,
        'Gel Polish': 45.0,
        'Nail Art (Simple)': 60.0,
        'Nail Art (Complex)': 85.0,
        'Full Set Acrylic': 120.0,
        'Pedicure': 40.0,
      },
      'socialMedia': {
        'instagram': '@akosua_nails_gh',
        'tiktok': '@akosua_nails',
        'facebook': 'Akosua Professional Nails',
        'whatsapp': '+233241234567',
      },
      'portfolio': [
        {
          'image': 'assets/portfolio/nail1.jpg',
          'description': 'Elegant French tips with gold accents',
          'category': 'Nail Art',
        },
        {
          'image': 'assets/portfolio/nail2.jpg',
          'description': 'Bridal nail design with crystals',
          'category': 'Bridal',
        },
        {
          'image': 'assets/portfolio/nail3.jpg',
          'description': 'Colorful summer nail art',
          'category': 'Seasonal',
        },
      ],
      'aboutMe': 'Professional nail technician with 5 years of experience specializing in gel applications and intricate nail art. Certified in sanitation and safety protocols. Available for home visits, salon appointments, and special events.',
      'workTypes': ['Home Service', 'Salon Visit', 'Events'],
      'availability': {
        'monday': '9:00 AM - 6:00 PM',
        'tuesday': '9:00 AM - 6:00 PM',
        'wednesday': '9:00 AM - 6:00 PM',
        'thursday': '9:00 AM - 6:00 PM',
        'friday': '9:00 AM - 8:00 PM',
        'saturday': '8:00 AM - 8:00 PM',
        'sunday': 'By Appointment',
      },
    },
    {
      'name': 'Adjoa Asante',
      'rating': 4.8,
      'reviewCount': 89,
      'experience': '3 years',
      'location': 'Kumasi, Ashanti Region',
      'profileImage': 'assets/profiles/adjoa_nail.jpg',
      'verified': true,
      'specialties': ['Acrylic Nails', 'Nail Extensions', 'Natural Nails'],
      'pricing': {
        'Basic Manicure': 25.0,
        'Gel Polish': 40.0,
        'Acrylic Full Set': 100.0,
        'Nail Art': 50.0,
        'Pedicure': 35.0,
      },
      'socialMedia': {
        'instagram': '@adjoa_acrylics',
        'facebook': 'Adjoa Nail Studio',
        'whatsapp': '+233245678901',
      },
      'portfolio': [
        {
          'image': 'assets/portfolio/acrylic1.jpg',
          'description': 'Long acrylic nails with ombre design',
          'category': 'Acrylic',
        },
        {
          'image': 'assets/portfolio/acrylic2.jpg',
          'description': 'Natural-looking acrylic extensions',
          'category': 'Extensions',
        },
      ],
      'aboutMe': 'Acrylic nail specialist focused on natural-looking extensions and durable applications. Passionate about nail health and proper aftercare.',
      'workTypes': ['Home Service', 'Events'],
      'availability': {
        'tuesday': '10:00 AM - 7:00 PM',
        'wednesday': '10:00 AM - 7:00 PM',
        'thursday': '10:00 AM - 7:00 PM',
        'friday': '10:00 AM - 9:00 PM',
        'saturday': '9:00 AM - 9:00 PM',
        'sunday': '12:00 PM - 6:00 PM',
      },
    },
  ];

  final List<Map<String, dynamic>> _makeupArtists = [
    {
      'name': 'Efua Boateng',
      'rating': 4.9,
      'reviewCount': 156,
      'experience': '7 years',
      'location': 'Cantonments, Accra',
      'profileImage': 'assets/profiles/efua_makeup.jpg',
      'verified': true,
      'specialties': ['Bridal Makeup', 'Event Makeup', 'Photoshoot Makeup', 'Everyday Glam'],
      'pricing': {
        'Everyday Makeup': 80.0,
        'Event Makeup': 120.0,
        'Bridal Makeup': 200.0,
        'Photoshoot Makeup': 150.0,
        'Makeup Trial': 60.0,
        'Group Booking (per person)': 90.0,
      },
      'socialMedia': {
        'instagram': '@efua_makeup_artistry',
        'tiktok': '@efua_glam',
        'facebook': 'Efua Boateng Makeup Artistry',
        'youtube': 'Efua Makeup Tutorials',
        'whatsapp': '+233201234567',
      },
      'portfolio': [
        {
          'image': 'assets/portfolio/bridal1.jpg',
          'description': 'Traditional Ghanaian bridal makeup',
          'category': 'Bridal',
        },
        {
          'image': 'assets/portfolio/event1.jpg',
          'description': 'Glamorous evening event makeup',
          'category': 'Events',
        },
        {
          'image': 'assets/portfolio/photoshoot1.jpg',
          'description': 'Professional photoshoot makeup',
          'category': 'Photoshoot',
        },
        {
          'image': 'assets/portfolio/traditional1.jpg',
          'description': 'Cultural ceremony makeup',
          'category': 'Traditional',
        },
      ],
      'aboutMe': 'Professional makeup artist with 7 years of experience in bridal, event, and photoshoot makeup. Specializing in both traditional Ghanaian and modern Western styles. Certified in MAC and Urban Decay techniques. Winner of Best Bridal Makeup Artist 2023.',
      'workTypes': ['Home Service', 'Studio Visit', 'Events', 'Photoshoots', 'Weddings'],
      'availability': {
        'monday': '10:00 AM - 7:00 PM',
        'tuesday': '10:00 AM - 7:00 PM',
        'wednesday': '10:00 AM - 7:00 PM',
        'thursday': '10:00 AM - 7:00 PM',
        'friday': '9:00 AM - 9:00 PM',
        'saturday': '7:00 AM - 10:00 PM',
        'sunday': '8:00 AM - 8:00 PM',
      },
      'certifications': ['MAC Pro Certification', 'Urban Decay Certified', 'Bridal Makeup Specialist'],
      'awards': ['Best Bridal Makeup Artist 2023', 'Top Rated Service Provider 2022'],
    },
    {
      'name': 'Ama Kuffour',
      'rating': 4.7,
      'reviewCount': 98,
      'experience': '4 years',
      'location': 'Tema, Greater Accra',
      'profileImage': 'assets/profiles/ama_makeup.jpg',
      'verified': true,
      'specialties': ['Natural Makeup', 'Editorial Makeup', 'Special Effects'],
      'pricing': {
        'Natural Day Look': 60.0,
        'Evening Glam': 100.0,
        'Editorial Makeup': 180.0,
        'Special Effects': 250.0,
        'Makeup Lessons': 120.0,
      },
      'socialMedia': {
        'instagram': '@ama_artistry_gh',
        'tiktok': '@ama_sfx_makeup',
        'whatsapp': '+233207891234',
      },
      'portfolio': [
        {
          'image': 'assets/portfolio/natural1.jpg',
          'description': 'Fresh natural everyday look',
          'category': 'Natural',
        },
        {
          'image': 'assets/portfolio/editorial1.jpg',
          'description': 'Bold editorial makeup for magazine',
          'category': 'Editorial',
        },
        {
          'image': 'assets/portfolio/sfx1.jpg',
          'description': 'Halloween special effects makeup',
          'category': 'Special Effects',
        },
      ],
      'aboutMe': 'Creative makeup artist passionate about natural beauty enhancement and special effects. Specializes in editorial and conceptual makeup for magazines and creative projects.',
      'workTypes': ['Home Service', 'Studio Visit', 'Creative Projects'],
      'availability': {
        'wednesday': '11:00 AM - 8:00 PM',
        'thursday': '11:00 AM - 8:00 PM',
        'friday': '11:00 AM - 9:00 PM',
        'saturday': '9:00 AM - 9:00 PM',
        'sunday': '10:00 AM - 6:00 PM',
      },
    },
  ];

  List<Map<String, dynamic>> get _currentProviders => 
      widget.serviceType == 'nail_tech' ? _nailTechs : _makeupArtists;

  String get _serviceTitle => 
      widget.serviceType == 'nail_tech' ? 'Nail Technicians' : 'Makeup Artists';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_serviceTitle),
        backgroundColor: widget.serviceType == 'nail_tech' ? Colors.pink : Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _currentProviders.length,
        itemBuilder: (context, index) {
          final provider = _currentProviders[index];
          return _buildProviderCard(provider);
        },
      ),
    );
  }

  Widget _buildProviderCard(Map<String, dynamic> provider) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showProviderProfile(provider),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Profile Image
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Icon(
                      widget.serviceType == 'nail_tech' ? Icons.colorize : Icons.face,
                      size: 40,
                      color: widget.serviceType == 'nail_tech' ? Colors.pink : Colors.purple,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              provider['name'],
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            if (provider['verified'])
                              const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Icon(Icons.verified, color: Colors.blue, size: 16),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            Text(' ${provider['rating']} (${provider['reviewCount']} reviews)'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${provider['experience']} experience • ${provider['location']}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Specialties
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: (provider['specialties'] as List<String>).map((specialty) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (widget.serviceType == 'nail_tech' ? Colors.pink : Colors.purple).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      specialty,
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.serviceType == 'nail_tech' ? Colors.pink : Colors.purple,
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 12),
              
              // Social Media Links
              Row(
                children: [
                  const Text('Follow: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  ..._buildSocialMediaIcons(provider['socialMedia']),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showProviderProfile(provider),
                      child: const Text('View Profile'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _bookService(provider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.serviceType == 'nail_tech' ? Colors.pink : Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Book Now'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSocialMediaIcons(Map<String, String> socialMedia) {
    final List<Widget> icons = [];
    
    socialMedia.forEach((platform, handle) {
      IconData iconData;
      Color color;
      
      switch (platform) {
        case 'instagram':
          iconData = Icons.camera_alt;
          color = Colors.purple;
          break;
        case 'tiktok':
          iconData = Icons.music_note;
          color = Colors.black;
          break;
        case 'facebook':
          iconData = Icons.facebook;
          color = Colors.blue;
          break;
        case 'youtube':
          iconData = Icons.play_circle;
          color = Colors.red;
          break;
        case 'whatsapp':
          iconData = Icons.phone;
          color = Colors.green;
          break;
        default:
          iconData = Icons.link;
          color = Colors.grey;
      }
      
      icons.add(
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: InkWell(
            onTap: () => _openSocialMedia(platform, handle),
            child: Icon(iconData, color: color, size: 20),
          ),
        ),
      );
    });
    
    return icons;
  }

  void _showProviderProfile(Map<String, dynamic> provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildProviderProfileModal(provider),
    );
  }

  Widget _buildProviderProfileModal(Map<String, dynamic> provider) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Icon(
                          widget.serviceType == 'nail_tech' ? Icons.colorize : Icons.face,
                          size: 40,
                          color: widget.serviceType == 'nail_tech' ? Colors.pink : Colors.purple,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  provider['name'],
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                                if (provider['verified'])
                                  const Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: Icon(Icons.verified, color: Colors.blue, size: 20),
                                  ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 18),
                                Text(' ${provider['rating']} (${provider['reviewCount']} reviews)'),
                              ],
                            ),
                            Text(
                              '${provider['experience']} experience',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // About Me
                  const Text('About Me', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(provider['aboutMe']),
                  
                  const SizedBox(height: 20),
                  
                  // Specialties & Certifications
                  const Text('Specialties', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: (provider['specialties'] as List<String>).map((specialty) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: (widget.serviceType == 'nail_tech' ? Colors.pink : Colors.purple).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(specialty),
                      );
                    }).toList(),
                  ),
                  
                  if (provider['certifications'] != null) ...[
                    const SizedBox(height: 16),
                    const Text('Certifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...((provider['certifications'] as List<String>).map((cert) => 
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.verified, color: Colors.green, size: 16),
                            const SizedBox(width: 8),
                            Text(cert),
                          ],
                        ),
                      ),
                    )),
                  ],
                  
                  const SizedBox(height: 20),
                  
                  // Portfolio
                  const Text('Portfolio', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: provider['portfolio'].length,
                      itemBuilder: (context, index) {
                        final portfolioItem = provider['portfolio'][index];
                        return Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Icon(
                                    widget.serviceType == 'nail_tech' ? Icons.colorize : Icons.face,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                portfolioItem['category'],
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                portfolioItem['description'],
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Pricing
                  const Text('Pricing', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: (provider['pricing'] as Map<String, double>).entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(entry.key),
                              Text(
                                'GH₵${entry.value.toStringAsFixed(0)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Work Types
                  const Text('Service Options', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: (provider['workTypes'] as List<String>).map((type) {
                      return Chip(
                        label: Text(type),
                        backgroundColor: Colors.blue.withValues(alpha: 0.1),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Social Media
                  const Text('Connect', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...(provider['socialMedia'] as Map<String, String>).entries.map((entry) {
                    return ListTile(
                      leading: Icon(_getSocialMediaIcon(entry.key)),
                      title: Text(entry.key.toUpperCase()),
                      subtitle: Text(entry.value),
                      trailing: const Icon(Icons.open_in_new),
                      onTap: () => _openSocialMedia(entry.key, entry.value),
                    );
                  }),
                  
                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ),
          
          // Book Service Button
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _bookService(provider);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.serviceType == 'nail_tech' ? Colors.pink : Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Book Service', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSocialMediaIcon(String platform) {
    switch (platform) {
      case 'instagram': return Icons.camera_alt;
      case 'tiktok': return Icons.music_note;
      case 'facebook': return Icons.facebook;
      case 'youtube': return Icons.play_circle;
      case 'whatsapp': return Icons.phone;
      default: return Icons.link;
    }
  }

  void _openSocialMedia(String platform, String handle) async {
    String url;
    
    switch (platform) {
      case 'instagram':
        url = 'https://instagram.com/${handle.replaceAll('@', '')}';
        break;
      case 'tiktok':
        url = 'https://tiktok.com/${handle.replaceAll('@', '')}';
        break;
      case 'facebook':
        url = 'https://facebook.com/$handle';
        break;
      case 'youtube':
        url = 'https://youtube.com/c/$handle';
        break;
      case 'whatsapp':
        url = 'https://wa.me/${handle.replaceAll('+', '')}';
        break;
      default:
        url = handle;
    }
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $platform')),
        );
      }
    }
  }

  void _bookService(Map<String, dynamic> provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Book with ${provider['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You are about to book a ${widget.serviceType == 'nail_tech' ? 'nail' : 'makeup'} service with ${provider['name']}.'),
            const SizedBox(height: 16),
            const Text('Available booking options:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...(provider['workTypes'] as List<String>).map((type) => 
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Text('• $type'),
              ),
            ),
            const SizedBox(height: 16),
            const Text('They will contact you within 10 minutes to confirm details and scheduling.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Booking request sent to ${provider['name']}! They will contact you shortly.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.serviceType == 'nail_tech' ? Colors.pink : Colors.purple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm Booking'),
          ),
        ],
      ),
    );
  }
}