import 'package:cloud_firestore/cloud_firestore.dart';

enum CaseType { 
  shelter, 
  counseling, 
  legal, 
  medical, 
  financial, 
  employment, 
  education,
  emergency 
}

enum CasePriority { low, medium, high, critical }

enum CaseStatus { pending, active, inProgress, completed, closed }

class SupportCase {
  final String id;
  final String survivorId;
  final String? assignedCounselorId;
  final CaseType type;
  final CasePriority priority;
  final CaseStatus status;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final List<String> notes;
  final List<String> attachments;
  final Map<String, dynamic>? metadata;
  final bool isAnonymous;
  final String? location;

  const SupportCase({
    required this.id,
    required this.survivorId,
    this.assignedCounselorId,
    required this.type,
    required this.priority,
    required this.status,
    required this.title,
    required this.description,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.notes = const [],
    this.attachments = const [],
    this.metadata,
    this.isAnonymous = true,
    this.location,
  });

  factory SupportCase.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SupportCase(
      id: doc.id,
      survivorId: data['survivorId'] ?? '',
      assignedCounselorId: data['assignedCounselorId'],
      type: CaseType.values.firstWhere(
        (e) => e.toString().split('.').last == data['type'],
        orElse: () => CaseType.emergency,
      ),
      priority: CasePriority.values.firstWhere(
        (e) => e.toString().split('.').last == data['priority'],
        orElse: () => CasePriority.medium,
      ),
      status: CaseStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => CaseStatus.pending,
      ),
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
      completedAt: data['completedAt'] != null 
          ? (data['completedAt'] as Timestamp).toDate() 
          : null,
      notes: data['notes'] != null ? List<String>.from(data['notes']) : [],
      attachments: data['attachments'] != null 
          ? List<String>.from(data['attachments']) 
          : [],
      metadata: data['metadata'],
      isAnonymous: data['isAnonymous'] ?? true,
      location: data['location'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'survivorId': survivorId,
      'assignedCounselorId': assignedCounselorId,
      'type': type.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'status': status.toString().split('.').last,
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'notes': notes,
      'attachments': attachments,
      'metadata': metadata,
      'isAnonymous': isAnonymous,
      'location': location,
    };
  }

  SupportCase copyWith({
    String? assignedCounselorId,
    CasePriority? priority,
    CaseStatus? status,
    String? title,
    String? description,
    DateTime? updatedAt,
    DateTime? completedAt,
    List<String>? notes,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
    bool? isAnonymous,
    String? location,
  }) {
    return SupportCase(
      id: id,
      survivorId: survivorId,
      assignedCounselorId: assignedCounselorId ?? this.assignedCounselorId,
      type: type,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      location: location ?? this.location,
    );
  }

  String get priorityDisplayName {
    switch (priority) {
      case CasePriority.low:
        return 'Low';
      case CasePriority.medium:
        return 'Medium';
      case CasePriority.high:
        return 'High';
      case CasePriority.critical:
        return 'Critical';
    }
  }

  String get typeDisplayName {
    switch (type) {
      case CaseType.shelter:
        return 'Shelter';
      case CaseType.counseling:
        return 'Counseling';
      case CaseType.legal:
        return 'Legal Support';
      case CaseType.medical:
        return 'Medical Care';
      case CaseType.financial:
        return 'Financial Aid';
      case CaseType.employment:
        return 'Employment';
      case CaseType.education:
        return 'Education';
      case CaseType.emergency:
        return 'Emergency';
    }
  }
}