import 'package:flutter/material.dart';
import '../models/service_request.dart';
import '../models/provider.dart';

class ServiceFlowManager {
  static final ServiceFlowManager _instance = ServiceFlowManager._internal();
  factory ServiceFlowManager() => _instance;
  ServiceFlowManager._internal();

  /// Gets smart service flow configuration for different service types
  ServiceFlowConfig getServiceFlow(String serviceName) {
    switch (serviceName.toLowerCase()) {
      case 'food delivery':
        return _getFoodDeliveryFlow();
      case 'house cleaning':
      case 'cleaning':
        return _getCleaningFlow();
      case 'transportation':
        return _getTransportationFlow();
      case 'beauty services':
      case 'nail tech / makeup':
        return _getBeautyFlow();
      case 'plumbing':
        return _getPlumbingFlow();
      case 'electrical':
        return _getElectricalFlow();
      case 'babysitting':
        return _getBabysittingFlow();
      case 'adult sitter':
        return _getElderCareFlow();
      case 'laundry':
        return _getLaundryFlow();
      case 'grocery':
        return _getGroceryFlow();
      default:
        return _getDefaultFlow(serviceName);
    }
  }

  ServiceFlowConfig _getFoodDeliveryFlow() {
    return ServiceFlowConfig(
      serviceName: 'Food Delivery',
      diasporaFriendly: true,
      smartFeatures: [
        'Real-time GPS tracking',
        'Smart restaurant recommendations',
        'Dietary preference matching',
        'Group order coordination',
        'Scheduled delivery options',
      ],
      requiredInfo: [
        ServiceField('restaurant', 'Restaurant Selection', FieldType.selection, isRequired: true),
        ServiceField('delivery_address', 'Delivery Address', FieldType.address, isRequired: true),
        ServiceField('phone', 'Contact Number', FieldType.phone, isRequired: true),
        ServiceField('delivery_instructions', 'Delivery Instructions', FieldType.text),
      ],
      estimatedDuration: '20-45 minutes',
      priceRange: 'GH₵15-50 + food cost',
      diasporaInstructions: 'Order food for family in Ghana from abroad. We coordinate with local restaurants and ensure safe delivery.',
      cancellationPolicy: '48-hour cancellation policy applies. Food orders can be cancelled up to 30 minutes after confirmation.',
      smartWorkflow: FoodDeliveryWorkflow(),
    );
  }

  ServiceFlowConfig _getCleaningFlow() {
    return ServiceFlowConfig(
      serviceName: 'House Cleaning',
      diasporaFriendly: true,
      smartFeatures: [
        'Pre-visit property assessment',
        'Before/after photo documentation',
        'Recurring schedule management',
        'Supply inventory tracking',
        'Quality assurance checklist',
      ],
      requiredInfo: [
        ServiceField('property_type', 'Property Type', FieldType.selection, isRequired: true),
        ServiceField('rooms', 'Number of Rooms', FieldType.number, isRequired: true),
        ServiceField('cleaning_type', 'Cleaning Type', FieldType.selection, isRequired: true),
        ServiceField('special_instructions', 'Special Instructions', FieldType.text),
        ServiceField('supplies_needed', 'Cleaning Supplies Needed', FieldType.multiSelect),
      ],
      estimatedDuration: '2-6 hours',
      priceRange: 'GH₵80-300',
      diasporaInstructions: 'Prepare your family home before your visit. We ensure thorough cleaning and provide photo updates.',
      cancellationPolicy: '48-hour cancellation policy applies for scheduled cleanings.',
      smartWorkflow: CleaningWorkflow(),
    );
  }

  ServiceFlowConfig _getTransportationFlow() {
    return ServiceFlowConfig(
      serviceName: 'Transportation',
      diasporaFriendly: true,
      smartFeatures: [
        'Airport pickup coordination',
        'Multi-stop journey planning',
        'Vehicle type selection',
        'Driver verification',
        'Real-time location sharing',
      ],
      requiredInfo: [
        ServiceField('pickup_location', 'Pickup Location', FieldType.address, isRequired: true),
        ServiceField('destination', 'Destination', FieldType.address, isRequired: true),
        ServiceField('passenger_count', 'Number of Passengers', FieldType.number, isRequired: true),
        ServiceField('vehicle_preference', 'Vehicle Type', FieldType.selection),
        ServiceField('special_needs', 'Special Requirements', FieldType.text),
      ],
      estimatedDuration: 'Variable',
      priceRange: 'GH₵15-200',
      diasporaInstructions: 'Arrange reliable transport for family or coordinate airport transfers for your visit.',
      cancellationPolicy: '48-hour cancellation policy. Same-day bookings may incur fees.',
      smartWorkflow: TransportationWorkflow(),
    );
  }

  ServiceFlowConfig _getBeautyFlow() {
    return ServiceFlowConfig(
      serviceName: 'Beauty Services',
      diasporaFriendly: true,
      smartFeatures: [
        'Portfolio showcase',
        'Style consultation',
        'Product recommendation',
        'Appointment reminders',
        'Look documentation',
      ],
      requiredInfo: [
        ServiceField('service_type', 'Service Type', FieldType.multiSelect, isRequired: true),
        ServiceField('occasion', 'Occasion/Event', FieldType.text),
        ServiceField('style_preference', 'Style Preference', FieldType.text),
        ServiceField('skin_type', 'Skin Type/Concerns', FieldType.text),
        ServiceField('location_preference', 'Service Location', FieldType.selection, isRequired: true),
      ],
      estimatedDuration: '1-4 hours',
      priceRange: 'GH₵150-800',
      diasporaInstructions: 'Book beauty services for special occasions or treat family to professional services.',
      cancellationPolicy: '48-hour cancellation policy. Beauty appointments require advance notice.',
      smartWorkflow: BeautyWorkflow(),
    );
  }

  ServiceFlowConfig _getPlumbingFlow() {
    return ServiceFlowConfig(
      serviceName: 'Plumbing',
      diasporaFriendly: true,
      smartFeatures: [
        'Emergency response system',
        'Problem diagnosis',
        'Parts cost estimation',
        'Warranty tracking',
        'Maintenance scheduling',
      ],
      requiredInfo: [
        ServiceField('problem_type', 'Plumbing Issue', FieldType.selection, isRequired: true),
        ServiceField('urgency', 'Urgency Level', FieldType.selection, isRequired: true),
        ServiceField('problem_description', 'Detailed Description', FieldType.text, isRequired: true),
        ServiceField('property_access', 'Property Access Instructions', FieldType.text),
        ServiceField('preferred_time', 'Preferred Service Time', FieldType.selection),
      ],
      estimatedDuration: '1-4 hours',
      priceRange: 'GH₵120-500',
      diasporaInstructions: 'Handle plumbing emergencies for family property or prepare home for your arrival.',
      cancellationPolicy: '48-hour cancellation policy. Emergency services may have different terms.',
      smartWorkflow: PlumbingWorkflow(),
    );
  }

  ServiceFlowConfig _getElectricalFlow() {
    return ServiceFlowConfig(
      serviceName: 'Electrical',
      diasporaFriendly: true,
      smartFeatures: [
        'Safety assessment',
        'Code compliance check',
        'Energy efficiency advice',
        'Installation documentation',
        'Maintenance planning',
      ],
      requiredInfo: [
        ServiceField('electrical_issue', 'Electrical Work Needed', FieldType.selection, isRequired: true),
        ServiceField('safety_urgency', 'Safety Urgency', FieldType.selection, isRequired: true),
        ServiceField('work_description', 'Detailed Work Description', FieldType.text, isRequired: true),
        ServiceField('power_requirements', 'Power Requirements', FieldType.text),
        ServiceField('installation_location', 'Installation Location', FieldType.text),
      ],
      estimatedDuration: '1-6 hours',
      priceRange: 'GH₵100-600',
      diasporaInstructions: 'Ensure electrical safety for family home or upgrade systems before your visit.',
      cancellationPolicy: '48-hour cancellation policy. Safety-critical work may have priority scheduling.',
      smartWorkflow: ElectricalWorkflow(),
    );
  }

  ServiceFlowConfig _getBabysittingFlow() {
    return ServiceFlowConfig(
      serviceName: 'Babysitting',
      diasporaFriendly: true,
      smartFeatures: [
        'Background verification',
        'Childcare certification check',
        'Emergency contact system',
        'Activity reporting',
        'Parent communication portal',
      ],
      requiredInfo: [
        ServiceField('children_ages', 'Children Ages', FieldType.text, isRequired: true),
        ServiceField('children_count', 'Number of Children', FieldType.number, isRequired: true),
        ServiceField('duration', 'Care Duration', FieldType.selection, isRequired: true),
        ServiceField('special_needs', 'Special Care Instructions', FieldType.text),
        ServiceField('emergency_contacts', 'Emergency Contacts', FieldType.text, isRequired: true),
        ServiceField('activities', 'Preferred Activities', FieldType.text),
      ],
      estimatedDuration: 'Variable',
      priceRange: 'GH₵50-200',
      diasporaInstructions: 'Provide trusted childcare for family while coordinating from abroad.',
      cancellationPolicy: '48-hour cancellation policy. Last-minute changes may incur fees.',
      smartWorkflow: BabysittingWorkflow(),
    );
  }

  ServiceFlowConfig _getElderCareFlow() {
    return ServiceFlowConfig(
      serviceName: 'Elder Care',
      diasporaFriendly: true,
      smartFeatures: [
        'Health monitoring',
        'Medication reminders',
        'Companion services',
        'Medical appointment coordination',
        'Family communication updates',
      ],
      requiredInfo: [
        ServiceField('care_type', 'Type of Care Needed', FieldType.multiSelect, isRequired: true),
        ServiceField('health_conditions', 'Health Conditions', FieldType.text),
        ServiceField('medications', 'Current Medications', FieldType.text),
        ServiceField('mobility_needs', 'Mobility Assistance Needed', FieldType.selection),
        ServiceField('emergency_contacts', 'Emergency Contacts', FieldType.text, isRequired: true),
        ServiceField('care_duration', 'Care Duration', FieldType.selection, isRequired: true),
      ],
      estimatedDuration: 'Variable',
      priceRange: 'GH₵80-300',
      diasporaInstructions: 'Ensure quality care for elderly family members with professional, compassionate service.',
      cancellationPolicy: '48-hour cancellation policy. Ongoing care arrangements have flexible rescheduling.',
      smartWorkflow: ElderCareWorkflow(),
    );
  }

  ServiceFlowConfig _getLaundryFlow() {
    return ServiceFlowConfig(
      serviceName: 'Laundry Service',
      diasporaFriendly: true,
      smartFeatures: [
        'Pickup and delivery tracking',
        'Fabric care optimization',
        'Special treatment options',
        'Inventory management',
        'Quality assurance checks',
      ],
      requiredInfo: [
        ServiceField('laundry_type', 'Laundry Type', FieldType.multiSelect, isRequired: true),
        ServiceField('pickup_address', 'Pickup Address', FieldType.address, isRequired: true),
        ServiceField('delivery_address', 'Delivery Address', FieldType.address, isRequired: true),
        ServiceField('special_instructions', 'Special Care Instructions', FieldType.text),
        ServiceField('preferred_detergent', 'Detergent Preference', FieldType.selection),
      ],
      estimatedDuration: '24-48 hours',
      priceRange: 'GH₵30-150',
      diasporaInstructions: 'Keep family clothes clean and fresh with pickup/delivery laundry service.',
      cancellationPolicy: '48-hour cancellation policy. Items in process may have limited cancellation options.',
      smartWorkflow: LaundryWorkflow(),
    );
  }

  ServiceFlowConfig _getGroceryFlow() {
    return ServiceFlowConfig(
      serviceName: 'Grocery Shopping',
      diasporaFriendly: true,
      smartFeatures: [
        'Smart shopping lists',
        'Price comparison',
        'Fresh produce selection',
        'Dietary restriction filtering',
        'Delivery time optimization',
      ],
      requiredInfo: [
        ServiceField('shopping_list', 'Shopping List', FieldType.text, isRequired: true),
        ServiceField('store_preference', 'Preferred Store', FieldType.selection),
        ServiceField('budget_limit', 'Budget Limit', FieldType.number),
        ServiceField('dietary_restrictions', 'Dietary Restrictions', FieldType.multiSelect),
        ServiceField('delivery_address', 'Delivery Address', FieldType.address, isRequired: true),
      ],
      estimatedDuration: '2-4 hours',
      priceRange: 'GH₵25-100 + groceries',
      diasporaInstructions: 'Stock family home with groceries and essentials before your arrival or for ongoing support.',
      cancellationPolicy: '48-hour cancellation policy. Orders in progress may have limited cancellation.',
      smartWorkflow: GroceryWorkflow(),
    );
  }

  ServiceFlowConfig _getDefaultFlow(String serviceName) {
    return ServiceFlowConfig(
      serviceName: serviceName,
      diasporaFriendly: true,
      smartFeatures: [
        'Professional service delivery',
        'Quality assurance',
        'Customer support',
        'Flexible scheduling',
      ],
      requiredInfo: [
        ServiceField('service_description', 'Service Description', FieldType.text, isRequired: true),
        ServiceField('service_address', 'Service Address', FieldType.address, isRequired: true),
        ServiceField('contact_phone', 'Contact Number', FieldType.phone, isRequired: true),
        ServiceField('special_instructions', 'Special Instructions', FieldType.text),
      ],
      estimatedDuration: 'Variable',
      priceRange: 'GH₵50-300',
      diasporaInstructions: 'Professional service delivery with diaspora-friendly coordination and communication.',
      cancellationPolicy: '48-hour cancellation policy applies to all scheduled services.',
      smartWorkflow: DefaultWorkflow(),
    );
  }
}

class ServiceFlowConfig {
  final String serviceName;
  final bool diasporaFriendly;
  final List<String> smartFeatures;
  final List<ServiceField> requiredInfo;
  final String estimatedDuration;
  final String priceRange;
  final String diasporaInstructions;
  final String cancellationPolicy;
  final ServiceWorkflow smartWorkflow;

  ServiceFlowConfig({
    required this.serviceName,
    required this.diasporaFriendly,
    required this.smartFeatures,
    required this.requiredInfo,
    required this.estimatedDuration,
    required this.priceRange,
    required this.diasporaInstructions,
    required this.cancellationPolicy,
    required this.smartWorkflow,
  });
}

class ServiceField {
  final String id;
  final String label;
  final FieldType type;
  final bool isRequired;
  final List<String>? options;

  ServiceField(
    this.id,
    this.label,
    this.type, {
    this.isRequired = false,
    this.options,
  });
}

enum FieldType {
  text,
  number,
  phone,
  email,
  address,
  selection,
  multiSelect,
  date,
  time,
  boolean,
}

// Abstract base class for service workflows
abstract class ServiceWorkflow {
  String getWorkflowStep(int step);
  List<String> getWorkflowSteps();
  Map<String, dynamic> getStepRequirements(int step);
  bool validateStep(int step, Map<String, dynamic> data);
}

// Concrete workflow implementations
class FoodDeliveryWorkflow extends ServiceWorkflow {
  @override
  List<String> getWorkflowSteps() => [
    'Restaurant Selection',
    'Menu & Order Details',
    'Delivery Information',
    'Payment & Confirmation'
  ];

  @override
  String getWorkflowStep(int step) => getWorkflowSteps()[step];

  @override
  Map<String, dynamic> getStepRequirements(int step) {
    switch (step) {
      case 0: return {'restaurant': 'required', 'cuisine_type': 'optional'};
      case 1: return {'items': 'required', 'special_requests': 'optional'};
      case 2: return {'address': 'required', 'phone': 'required', 'instructions': 'optional'};
      case 3: return {'payment_method': 'required', 'tip': 'optional'};
      default: return {};
    }
  }

  @override
  bool validateStep(int step, Map<String, dynamic> data) {
    final requirements = getStepRequirements(step);
    return requirements.entries.where((e) => e.value == 'required').every((e) => data.containsKey(e.key) && data[e.key] != null);
  }
}

class CleaningWorkflow extends ServiceWorkflow {
  @override
  List<String> getWorkflowSteps() => [
    'Property Assessment',
    'Cleaning Specifications',
    'Schedule & Access',
    'Confirmation'
  ];

  @override
  String getWorkflowStep(int step) => getWorkflowSteps()[step];

  @override
  Map<String, dynamic> getStepRequirements(int step) {
    switch (step) {
      case 0: return {'property_type': 'required', 'rooms': 'required', 'size': 'optional'};
      case 1: return {'cleaning_type': 'required', 'supplies': 'optional', 'special_areas': 'optional'};
      case 2: return {'date': 'required', 'time': 'required', 'access_instructions': 'required'};
      case 3: return {'payment_method': 'required', 'recurring': 'optional'};
      default: return {};
    }
  }

  @override
  bool validateStep(int step, Map<String, dynamic> data) {
    final requirements = getStepRequirements(step);
    return requirements.entries.where((e) => e.value == 'required').every((e) => data.containsKey(e.key) && data[e.key] != null);
  }
}

class TransportationWorkflow extends ServiceWorkflow {
  @override
  List<String> getWorkflowSteps() => [
    'Trip Details',
    'Vehicle Selection',
    'Schedule & Pickup',
    'Confirmation'
  ];

  @override
  String getWorkflowStep(int step) => getWorkflowSteps()[step];

  @override
  Map<String, dynamic> getStepRequirements(int step) {
    switch (step) {
      case 0: return {'pickup': 'required', 'destination': 'required', 'passengers': 'required'};
      case 1: return {'vehicle_type': 'required', 'special_needs': 'optional'};
      case 2: return {'date': 'required', 'time': 'required', 'contact': 'required'};
      case 3: return {'payment_method': 'required', 'driver_contact': 'optional'};
      default: return {};
    }
  }

  @override
  bool validateStep(int step, Map<String, dynamic> data) {
    final requirements = getStepRequirements(step);
    return requirements.entries.where((e) => e.value == 'required').every((e) => data.containsKey(e.key) && data[e.key] != null);
  }
}

// Additional workflow classes for other services...
class BeautyWorkflow extends ServiceWorkflow {
  @override
  List<String> getWorkflowSteps() => ['Service Selection', 'Style Consultation', 'Appointment Booking', 'Confirmation'];
  @override
  String getWorkflowStep(int step) => getWorkflowSteps()[step];
  @override
  Map<String, dynamic> getStepRequirements(int step) => {};
  @override
  bool validateStep(int step, Map<String, dynamic> data) => true;
}

class PlumbingWorkflow extends ServiceWorkflow {
  @override
  List<String> getWorkflowSteps() => ['Problem Assessment', 'Solution Planning', 'Scheduling', 'Confirmation'];
  @override
  String getWorkflowStep(int step) => getWorkflowSteps()[step];
  @override
  Map<String, dynamic> getStepRequirements(int step) => {};
  @override
  bool validateStep(int step, Map<String, dynamic> data) => true;
}

class ElectricalWorkflow extends ServiceWorkflow {
  @override
  List<String> getWorkflowSteps() => ['Safety Assessment', 'Work Planning', 'Scheduling', 'Confirmation'];
  @override
  String getWorkflowStep(int step) => getWorkflowSteps()[step];
  @override
  Map<String, dynamic> getStepRequirements(int step) => {};
  @override
  bool validateStep(int step, Map<String, dynamic> data) => true;
}

class BabysittingWorkflow extends ServiceWorkflow {
  @override
  List<String> getWorkflowSteps() => ['Child Information', 'Care Requirements', 'Caregiver Matching', 'Confirmation'];
  @override
  String getWorkflowStep(int step) => getWorkflowSteps()[step];
  @override
  Map<String, dynamic> getStepRequirements(int step) => {};
  @override
  bool validateStep(int step, Map<String, dynamic> data) => true;
}

class ElderCareWorkflow extends ServiceWorkflow {
  @override
  List<String> getWorkflowSteps() => ['Care Assessment', 'Service Planning', 'Caregiver Selection', 'Confirmation'];
  @override
  String getWorkflowStep(int step) => getWorkflowSteps()[step];
  @override
  Map<String, dynamic> getStepRequirements(int step) => {};
  @override
  bool validateStep(int step, Map<String, dynamic> data) => true;
}

class LaundryWorkflow extends ServiceWorkflow {
  @override
  List<String> getWorkflowSteps() => ['Item Collection', 'Care Instructions', 'Pickup/Delivery', 'Confirmation'];
  @override
  String getWorkflowStep(int step) => getWorkflowSteps()[step];
  @override
  Map<String, dynamic> getStepRequirements(int step) => {};
  @override
  bool validateStep(int step, Map<String, dynamic> data) => true;
}

class GroceryWorkflow extends ServiceWorkflow {
  @override
  List<String> getWorkflowSteps() => ['Shopping List', 'Store Selection', 'Delivery Details', 'Confirmation'];
  @override
  String getWorkflowStep(int step) => getWorkflowSteps()[step];
  @override
  Map<String, dynamic> getStepRequirements(int step) => {};
  @override
  bool validateStep(int step, Map<String, dynamic> data) => true;
}

class DefaultWorkflow extends ServiceWorkflow {
  @override
  List<String> getWorkflowSteps() => ['Service Details', 'Requirements', 'Scheduling', 'Confirmation'];
  @override
  String getWorkflowStep(int step) => getWorkflowSteps()[step];
  @override
  Map<String, dynamic> getStepRequirements(int step) => {};
  @override
  bool validateStep(int step, Map<String, dynamic> data) => true;
}