import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/service_flow_manager.dart';
import 'auth_screen.dart';

class SmartServiceBookingScreen extends StatefulWidget {
  final String serviceName;
  final IconData serviceIcon;
  final Color serviceColor;

  const SmartServiceBookingScreen({
    super.key,
    required this.serviceName,
    required this.serviceIcon,
    required this.serviceColor,
  });

  @override
  State<SmartServiceBookingScreen> createState() => _SmartServiceBookingScreenState();
}

class _SmartServiceBookingScreenState extends State<SmartServiceBookingScreen> {
  final ServiceFlowManager _flowManager = ServiceFlowManager();
  late ServiceFlowConfig _serviceConfig;
  int _currentStep = 0;
  final Map<String, dynamic> _serviceData = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _serviceConfig = _flowManager.getServiceFlow(widget.serviceName);
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    
    if (!isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAuthDialog();
      });
    }
  }

  void _showAuthDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(widget.serviceIcon, color: widget.serviceColor),
            const SizedBox(width: 8),
            Text('Book ${widget.serviceName}'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Please sign in to book this service',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            if (_serviceConfig.diasporaFriendly) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.public, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Diaspora Friendly',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _serviceConfig.diasporaInstructions,
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AuthScreen(userType: 'customer'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.serviceColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book ${widget.serviceName}'),
        backgroundColor: widget.serviceColor.withValues(alpha: 0.1),
        foregroundColor: widget.serviceColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showServiceInfo,
          ),
        ],
      ),
      body: Column(
        children: [
          // Service Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.serviceColor.withValues(alpha: 0.1),
                  widget.serviceColor.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  widget.serviceIcon,
                  size: 48,
                  color: widget.serviceColor,
                ),
                const SizedBox(height: 12),
                Text(
                  widget.serviceName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: widget.serviceColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _serviceConfig.priceRange,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Duration: ${_serviceConfig.estimatedDuration}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                if (_serviceConfig.diasporaFriendly) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.public, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Diaspora Friendly',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Smart Features
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Smart Features',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _serviceConfig.smartFeatures.map((feature) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      feature,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),

          // Service Flow Steps
          Expanded(
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: widget.serviceColor,
                ),
              ),
              child: Stepper(
                currentStep: _currentStep,
                onStepTapped: (step) {
                  if (step <= _currentStep) {
                    setState(() => _currentStep = step);
                  }
                },
                controlsBuilder: (context, details) {
                  return Row(
                    children: [
                      if (details.stepIndex < _serviceConfig.smartWorkflow.getWorkflowSteps().length - 1)
                        ElevatedButton(
                          onPressed: _isLoading ? null : () => _nextStep(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.serviceColor,
                            foregroundColor: Colors.white,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(details.stepIndex == _serviceConfig.smartWorkflow.getWorkflowSteps().length - 2 ? 'Book Now' : 'Next'),
                        ),
                      const SizedBox(width: 8),
                      if (details.stepIndex > 0)
                        TextButton(
                          onPressed: () => _previousStep(),
                          child: const Text('Back'),
                        ),
                    ],
                  );
                },
                steps: _buildSteps(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Step> _buildSteps() {
    final workflow = _serviceConfig.smartWorkflow;
    final steps = workflow.getWorkflowSteps();
    
    return steps.asMap().entries.map((entry) {
      final index = entry.key;
      final title = entry.value;
      
      return Step(
        title: Text(title),
        content: _buildStepContent(index),
        isActive: _currentStep >= index,
        state: _currentStep > index 
            ? StepState.complete 
            : _currentStep == index 
                ? StepState.indexed 
                : StepState.disabled,
      );
    }).toList();
  }

  Widget _buildStepContent(int stepIndex) {
    switch (stepIndex) {
      case 0:
        return _buildInitialStep();
      case 1:
        return _buildRequirementsStep();
      case 2:
        return _buildSchedulingStep();
      case 3:
        return _buildConfirmationStep();
      default:
        return const Text('Step content');
    }
  }

  Widget _buildInitialStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _serviceConfig.diasporaInstructions,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        const Text(
          'Service includes:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        ..._serviceConfig.smartFeatures.map((feature) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: widget.serviceColor, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(feature)),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildRequirementsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Service Requirements',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16),
        ..._serviceConfig.requiredInfo.map((field) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildServiceField(field),
        )),
      ],
    );
  }

  Widget _buildServiceField(ServiceField field) {
    switch (field.type) {
      case FieldType.text:
        return TextFormField(
          decoration: InputDecoration(
            labelText: field.label + (field.isRequired ? ' *' : ''),
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) => _serviceData[field.id] = value,
        );
      case FieldType.phone:
        return TextFormField(
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: field.label + (field.isRequired ? ' *' : ''),
            border: const OutlineInputBorder(),
            prefixText: '+233 ',
          ),
          onChanged: (value) => _serviceData[field.id] = value,
        );
      case FieldType.selection:
        return DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: field.label + (field.isRequired ? ' *' : ''),
            border: const OutlineInputBorder(),
          ),
          items: (field.options ?? _getDefaultOptions(field.id))
              .map((option) => DropdownMenuItem(value: option, child: Text(option)))
              .toList(),
          onChanged: (value) => _serviceData[field.id] = value,
        );
      default:
        return TextFormField(
          decoration: InputDecoration(
            labelText: field.label + (field.isRequired ? ' *' : ''),
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) => _serviceData[field.id] = value,
        );
    }
  }

  List<String> _getDefaultOptions(String fieldId) {
    switch (fieldId) {
      case 'service_type':
        return ['Makeup', 'Hair Styling', 'Nail Care', 'Full Package'];
      case 'cleaning_type':
        return ['Regular Cleaning', 'Deep Cleaning', 'Move-in/out Cleaning'];
      case 'urgency':
        return ['Normal', 'Urgent', 'Emergency'];
      case 'vehicle_type':
        return ['Sedan', 'SUV', 'Van', 'Luxury'];
      default:
        return ['Option 1', 'Option 2', 'Option 3'];
    }
  }

  Widget _buildSchedulingStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Schedule Your Service',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (date != null) {
                    setState(() => _serviceData['date'] = date);
                  }
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(_serviceData['date'] != null 
                    ? '${(_serviceData['date'] as DateTime).day}/${(_serviceData['date'] as DateTime).month}/${(_serviceData['date'] as DateTime).year}'
                    : 'Select Date'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    setState(() => _serviceData['time'] = time);
                  }
                },
                icon: const Icon(Icons.access_time),
                label: Text(_serviceData['time'] != null 
                    ? (_serviceData['time'] as TimeOfDay).format(context)
                    : 'Select Time'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.info, color: Colors.amber, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Cancellation Policy',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(_serviceConfig.cancellationPolicy),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 48,
              ),
              const SizedBox(height: 8),
              const Text(
                'Booking Confirmed!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your service has been successfully booked. You will receive confirmation via SMS and email.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Booking Summary',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...(_serviceData.entries.map((entry) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  '${entry.key}:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Text(entry.value.toString()),
              ),
            ],
          ),
        ))),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.serviceColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Go to Home'),
          ),
        ),
      ],
    );
  }

  void _nextStep() {
    if (_currentStep < _serviceConfig.smartWorkflow.getWorkflowSteps().length - 1) {
      setState(() {
        _currentStep++;
        if (_currentStep == _serviceConfig.smartWorkflow.getWorkflowSteps().length - 1) {
          // Final step - show confirmation
        }
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _showServiceInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${widget.serviceName} Information'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Duration: ${_serviceConfig.estimatedDuration}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Price Range: ${_serviceConfig.priceRange}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Smart Features:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._serviceConfig.smartFeatures.map((feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: Text(feature)),
                  ],
                ),
              )),
              if (_serviceConfig.diasporaFriendly) ...[
                const SizedBox(height: 16),
                const Text(
                  'Diaspora Information:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(_serviceConfig.diasporaInstructions),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}