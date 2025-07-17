import 'package:cloud_firestore/cloud_firestore.dart';

enum GroupType { general, survivors, mothers, legal, healing, skills }

enum GroupPrivacy { public, private, anonymous }

class SupportGroup {
  final String id;
  final String name;
  final String description;
  final GroupType type;
  final GroupPrivacy privacy;
  final String? facilitatorId;
  final List<String> memberIds;
  final List<String> moderatorIds;
  final DateTime createdAt;
  final DateTime? lastActivityAt;
  final bool isActive;
  final Map<String, String> guidelines;
  final int maxMembers;
  final List<String> tags;

  const SupportGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.privacy,
    this.facilitatorId,
    this.memberIds = const [],
    this.moderatorIds = const [],
    required this.createdAt,
    this.lastActivityAt,
    this.isActive = true,
    this.guidelines = const {},
    this.maxMembers = 50,
    this.tags = const [],
  });

  factory SupportGroup.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SupportGroup(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      type: GroupType.values.firstWhere(
        (e) => e.toString().split('.').last == data['type'],
        orElse: () => GroupType.general,
      ),
      privacy: GroupPrivacy.values.firstWhere(
        (e) => e.toString().split('.').last == data['privacy'],
        orElse: () => GroupPrivacy.public,
      ),
      facilitatorId: data['facilitatorId'],
      memberIds: data['memberIds'] != null 
          ? List<String>.from(data['memberIds']) 
          : [],
      moderatorIds: data['moderatorIds'] != null 
          ? List<String>.from(data['moderatorIds']) 
          : [],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastActivityAt: data['lastActivityAt'] != null 
          ? (data['lastActivityAt'] as Timestamp).toDate() 
          : null,
      isActive: data['isActive'] ?? true,
      guidelines: data['guidelines'] != null 
          ? Map<String, String>.from(data['guidelines']) 
          : {},
      maxMembers: data['maxMembers'] ?? 50,
      tags: data['tags'] != null 
          ? List<String>.from(data['tags']) 
          : [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'type': type.toString().split('.').last,
      'privacy': privacy.toString().split('.').last,
      'facilitatorId': facilitatorId,
      'memberIds': memberIds,
      'moderatorIds': moderatorIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActivityAt': lastActivityAt != null 
          ? Timestamp.fromDate(lastActivityAt!) 
          : null,
      'isActive': isActive,
      'guidelines': guidelines,
      'maxMembers': maxMembers,
      'tags': tags,
    };
  }

  bool get isFull => memberIds.length >= maxMembers;
  
  int get memberCount => memberIds.length;

  String get typeDisplayName {
    switch (type) {
      case GroupType.general:
        return 'General Support';
      case GroupType.survivors:
        return 'Survivors Circle';
      case GroupType.mothers:
        return 'Mothers Support';
      case GroupType.legal:
        return 'Legal Guidance';
      case GroupType.healing:
        return 'Healing Journey';
      case GroupType.skills:
        return 'Skills & Employment';
    }
  }
}

class GroupMessage {
  final String id;
  final String groupId;
  final String senderId;
  final String? senderDisplayName;
  final String content;
  final DateTime sentAt;
  final bool isAnonymous;
  final List<String> supportedBy;
  final bool isModerated;
  final String? moderatorNote;

  const GroupMessage({
    required this.id,
    required this.groupId,
    required this.senderId,
    this.senderDisplayName,
    required this.content,
    required this.sentAt,
    this.isAnonymous = false,
    this.supportedBy = const [],
    this.isModerated = false,
    this.moderatorNote,
  });

  factory GroupMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GroupMessage(
      id: doc.id,
      groupId: data['groupId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderDisplayName: data['senderDisplayName'],
      content: data['content'] ?? '',
      sentAt: (data['sentAt'] as Timestamp).toDate(),
      isAnonymous: data['isAnonymous'] ?? false,
      supportedBy: data['supportedBy'] != null 
          ? List<String>.from(data['supportedBy']) 
          : [],
      isModerated: data['isModerated'] ?? false,
      moderatorNote: data['moderatorNote'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'groupId': groupId,
      'senderId': senderId,
      'senderDisplayName': senderDisplayName,
      'content': content,
      'sentAt': Timestamp.fromDate(sentAt),
      'isAnonymous': isAnonymous,
      'supportedBy': supportedBy,
      'isModerated': isModerated,
      'moderatorNote': moderatorNote,
    };
  }

  int get supportCount => supportedBy.length;
}

class SupportResource {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String? authorName;
  final DateTime createdAt;
  final List<String> tags;
  final bool isVerified;
  final List<String> helpfulVotes;

  const SupportResource({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    this.authorName,
    required this.createdAt,
    this.tags = const [],
    this.isVerified = false,
    this.helpfulVotes = const [],
  });

  factory SupportResource.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SupportResource(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      tags: data['tags'] != null 
          ? List<String>.from(data['tags']) 
          : [],
      isVerified: data['isVerified'] ?? false,
      helpfulVotes: data['helpfulVotes'] != null 
          ? List<String>.from(data['helpfulVotes']) 
          : [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': Timestamp.fromDate(createdAt),
      'tags': tags,
      'isVerified': isVerified,
      'helpfulVotes': helpfulVotes,
    };
  }

  int get helpfulCount => helpfulVotes.length;
}