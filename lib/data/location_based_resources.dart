import '../models/resource.dart';

class LocationBasedResources {
  static List<Resource> getGhanaResources() {
    return [
      Resource(
        id: 'gh_1',
        name: 'DOVVSU (Domestic Violence Support Unit)',
        category: 'Legal Support',
        description: 'Ghana Police domestic violence and victim support unit',
        phoneNumber: '+233302773906',
        website: 'https://dovvsu.police.gov.gh',
        address: 'Police Headquarters, Accra',
        isEmergency: true,
      ),
      Resource(
        id: 'gh_2',
        name: 'WiLDAF Ghana',
        category: 'Legal Support',
        description: 'Women in Law and Development in Africa - Ghana',
        phoneNumber: '+233302761170',
        website: 'https://wildafghana.org',
        address: 'East Legon, Accra',
        isEmergency: false,
      ),
      Resource(
        id: 'gh_3',
        name: 'Ark Foundation',
        category: 'Shelter & Housing',
        description: 'Domestic violence shelter and support services',
        phoneNumber: '+233244765988',
        website: 'https://arkfoundationghana.org',
        address: 'Tema, Greater Accra',
        isEmergency: true,
      ),
      Resource(
        id: 'gh_4',
        name: 'Mental Health Authority Ghana',
        category: 'Mental Health',
        description: 'Mental health services and crisis support',
        phoneNumber: '+233302684054',
        website: 'https://moh.gov.gh',
        address: 'Accra, Ghana',
        isEmergency: false,
      ),
      Resource(
        id: 'gh_5',
        name: 'Legal Aid Board Ghana',
        category: 'Legal Support',
        description: 'Free legal aid and representation',
        phoneNumber: '+233302685995',
        website: 'https://legalaid.gov.gh',
        address: 'Accra, Ghana',
        isEmergency: false,
      ),
      Resource(
        id: 'gh_6',
        name: 'Ghana Health Service',
        category: 'Healthcare',
        description: 'Public healthcare services and medical support',
        phoneNumber: '+233302681109',
        website: 'https://ghs.gov.gh',
        address: 'Accra, Ghana',
        isEmergency: false,
      ),
    ];
  }

  static List<Resource> getUSAResources(String? state) {
    List<Resource> baseResources = [
      Resource(
        id: 'us_1',
        name: 'National Domestic Violence Hotline',
        category: 'Crisis Support',
        description: '24/7 confidential domestic violence support',
        phoneNumber: '1-800-799-7233',
        website: 'https://thehotline.org',
        address: 'National Service',
        isEmergency: true,
      ),
      Resource(
        id: 'us_2',
        name: 'National Sexual Assault Hotline',
        category: 'Crisis Support',
        description: '24/7 sexual assault crisis support',
        phoneNumber: '1-800-656-4673',
        website: 'https://rainn.org',
        address: 'National Service',
        isEmergency: true,
      ),
      Resource(
        id: 'us_3',
        name: 'Crisis Text Line',
        category: 'Mental Health',
        description: 'Text HOME to 741741 for crisis support',
        phoneNumber: '741741',
        website: 'https://crisistextline.org',
        address: 'National Service',
        isEmergency: true,
      ),
      Resource(
        id: 'us_4',
        name: 'National Suicide Prevention Lifeline',
        category: 'Mental Health',
        description: '24/7 suicide prevention and mental health crisis support',
        phoneNumber: '988',
        website: 'https://suicidepreventionlifeline.org',
        address: 'National Service',
        isEmergency: true,
      ),
    ];

    // Add state-specific resources
    if (state != null) {
      baseResources.addAll(_getStateSpecificResources(state));
    }

    return baseResources;
  }

  static List<Resource> _getStateSpecificResources(String state) {
    switch (state.toLowerCase()) {
      case 'california':
        return [
          Resource(
            id: 'ca_1',
            name: 'California Partnership to End Domestic Violence',
            category: 'Legal Support',
            description: 'California domestic violence resources and advocacy',
            phoneNumber: '1-916-444-7163',
            website: 'https://cpedv.org',
            address: 'Sacramento, CA',
            isEmergency: false,
          ),
          Resource(
            id: 'ca_2',
            name: 'Los Angeles Domestic Violence Hotline',
            category: 'Crisis Support',
            description: 'LA County domestic violence support',
            phoneNumber: '1-877-531-2522',
            website: 'https://lacounty.gov',
            address: 'Los Angeles County, CA',
            isEmergency: true,
          ),
        ];
      case 'new york':
        return [
          Resource(
            id: 'ny_1',
            name: 'New York State Domestic Violence Hotline',
            category: 'Crisis Support',
            description: 'NY state domestic violence support',
            phoneNumber: '1-800-942-6906',
            website: 'https://opdv.ny.gov',
            address: 'New York State',
            isEmergency: true,
          ),
          Resource(
            id: 'ny_2',
            name: 'Safe Horizon',
            category: 'Shelter & Housing',
            description: 'NYC domestic violence shelter and services',
            phoneNumber: '1-800-621-4673',
            website: 'https://safehorizon.org',
            address: 'New York City, NY',
            isEmergency: true,
          ),
        ];
      case 'texas':
        return [
          Resource(
            id: 'tx_1',
            name: 'Texas Council on Family Violence',
            category: 'Legal Support',
            description: 'Texas domestic violence resources',
            phoneNumber: '1-512-794-1133',
            website: 'https://tcfv.org',
            address: 'Austin, TX',
            isEmergency: false,
          ),
          Resource(
            id: 'tx_2',
            name: 'Family Place',
            category: 'Shelter & Housing',
            description: 'Dallas domestic violence shelter',
            phoneNumber: '1-214-941-1991',
            website: 'https://familyplace.org',
            address: 'Dallas, TX',
            isEmergency: true,
          ),
        ];
      case 'florida':
        return [
          Resource(
            id: 'fl_1',
            name: 'Florida Coalition Against Domestic Violence',
            category: 'Legal Support',
            description: 'Florida domestic violence resources',
            phoneNumber: '1-850-425-2749',
            website: 'https://fcadv.org',
            address: 'Tallahassee, FL',
            isEmergency: false,
          ),
        ];
      default:
        return [
          Resource(
            id: 'state_generic',
            name: '$state Department of Health and Human Services',
            category: 'Government Services',
            description: 'State health and human services department',
            phoneNumber: '211',
            website: 'https://hhs.gov',
            address: state,
            isEmergency: false,
          ),
        ];
    }
  }

  static List<Resource> getInternationalResources() {
    return [
      Resource(
        id: 'intl_1',
        name: 'International Direct Dial Emergency',
        category: 'Emergency Services',
        description: 'International emergency services',
        phoneNumber: '911',
        website: '',
        address: 'International',
        isEmergency: true,
      ),
      Resource(
        id: 'intl_2',
        name: 'World Health Organization',
        category: 'Healthcare',
        description: 'Global health information and resources',
        phoneNumber: '',
        website: 'https://who.int',
        address: 'International',
        isEmergency: false,
      ),
    ];
  }
}