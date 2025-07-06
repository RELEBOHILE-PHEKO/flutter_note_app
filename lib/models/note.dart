import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String id;
  final String text;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<String> tags;

  Note({
    required this.id,
    required this.text,
    this.createdAt,
    this.updatedAt,
    this.tags = const [],
  });

  factory Note.fromJson(String id, Map<String, dynamic> json) {
    return Note(
      id: id,
      text: json['text'] ?? '',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'tags': tags,
    };
  }
}
