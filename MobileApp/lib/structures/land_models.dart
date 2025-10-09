import 'package:cloud_firestore/cloud_firestore.dart';

class LandModel {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final String location;
  final double size;
  final String intendedCrop;
  final List<String> images;
  final List<String> sponsors;
  final Map<String, double> needs;
  final Map<String, double> fulfilled;
  final DateTime createdAt;
  final bool isActive;

  LandModel({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.location,
    required this.size,
    required this.intendedCrop,
    required this.images,
    required this.sponsors,
    required this.needs,
    required this.fulfilled,
    required this.createdAt,
    this.isActive = true,
  });

  factory LandModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LandModel(
      id: doc.id,
      ownerId: data['ownerId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      size: (data['size'] ?? 0).toDouble(),
      intendedCrop: data['intendedCrop'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      sponsors: List<String>.from(data['sponsors'] ?? []),
      needs: Map<String, double>.from(
          (data['needs'] ?? {}).map((k, v) => MapEntry(k, v.toDouble()))
      ),
      fulfilled: Map<String, double>.from(
          (data['fulfilled'] ?? {}).map((k, v) => MapEntry(k, v.toDouble()))
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'location': location,
      'size': size,
      'intendedCrop': intendedCrop,
      'images': images,
      'sponsors': sponsors,
      'needs': needs,
      'fulfilled': fulfilled,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }

  double get totalNeeded => needs.values.fold(0.0, (sum, amount) => sum + amount);
  double get totalFulfilled => fulfilled.values.fold(0.0, (sum, amount) => sum + amount);
  double get progressPercentage => totalNeeded > 0 ? (totalFulfilled / totalNeeded) * 100 : 0;
  bool get isFullyFunded => totalFulfilled >= totalNeeded;

  LandModel copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? description,
    String? location,
    double? size,
    String? intendedCrop,
    List<String>? images,
    List<String>? sponsors,
    Map<String, double>? needs,
    Map<String, double>? fulfilled,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return LandModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      size: size ?? this.size,
      intendedCrop: intendedCrop ?? this.intendedCrop,
      images: images ?? this.images,
      sponsors: sponsors ?? this.sponsors,
      needs: needs ?? this.needs,
      fulfilled: fulfilled ?? this.fulfilled,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

class LandUpdateModel {
  final String id;
  final String landId;
  final String farmerId;
  final String note;
  final List<String> images;
  final DateTime timestamp;
  final String updateType; // 'weekly', 'milestone', 'issue'

  LandUpdateModel({
    required this.id,
    required this.landId,
    required this.farmerId,
    required this.note,
    required this.images,
    required this.timestamp,
    this.updateType = 'weekly',
  });

  factory LandUpdateModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LandUpdateModel(
      id: doc.id,
      landId: data['landId'] ?? '',
      farmerId: data['farmerId'] ?? '',
      note: data['note'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updateType: data['updateType'] ?? 'weekly',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'landId': landId,
      'farmerId': farmerId,
      'note': note,
      'images': images,
      'timestamp': Timestamp.fromDate(timestamp),
      'updateType': updateType,
    };
  }
}

class ChatMessage {
  final String id;
  final String landId;
  final String senderId;
  final String senderName;
  final String senderRole; // 'farmer', 'sponsor', 'ai'
  final String text;
  final String? imageUrl;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.landId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.text,
    this.imageUrl,
    required this.timestamp,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      landId: data['landId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderRole: data['senderRole'] ?? '',
      text: data['text'] ?? '',
      imageUrl: data['imageUrl'],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'landId': landId,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}