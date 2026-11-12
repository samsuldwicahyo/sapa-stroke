import 'package:flutter/material.dart';

class CommunicationItem {
  const CommunicationItem({
    required this.id,
    required this.title,
    required this.spokenText,
    required this.icon,
    required this.category,
    required this.color,
    required this.isFavorite,
    required this.position,
    required this.requiresConfirmation,
    this.audioAsset,
    this.semanticLabel,
  });

  final String id;
  final String title;
  final String spokenText;
  final IconData icon;
  final String category;
  final Color color;
  final bool isFavorite;
  final int position;
  final bool requiresConfirmation;
  final String? audioAsset;
  final String? semanticLabel;

  CommunicationItem copyWith({
    String? id,
    String? title,
    String? spokenText,
    IconData? icon,
    String? category,
    Color? color,
    bool? isFavorite,
    int? position,
    bool? requiresConfirmation,
    String? audioAsset,
    String? semanticLabel,
  }) {
    return CommunicationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      spokenText: spokenText ?? this.spokenText,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      color: color ?? this.color,
      isFavorite: isFavorite ?? this.isFavorite,
      position: position ?? this.position,
      requiresConfirmation: requiresConfirmation ?? this.requiresConfirmation,
      audioAsset: audioAsset ?? this.audioAsset,
      semanticLabel: semanticLabel ?? this.semanticLabel,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'spokenText': spokenText,
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'category': category,
      'color': color.value,
      'isFavorite': isFavorite,
      'position': position,
      'requiresConfirmation': requiresConfirmation,
      'audioAsset': audioAsset,
      'semanticLabel': semanticLabel,
    };
  }

  factory CommunicationItem.fromMap(Map<String, dynamic> map) {
    return CommunicationItem(
      id: map['id'] as String,
      title: map['title'] as String,
      spokenText: map['spokenText'] as String,
      icon: IconData(
        map['iconCodePoint'] as int,
        fontFamily: map['iconFontFamily'] as String?,
      ),
      category: map['category'] as String,
      color: Color(map['color'] as int),
      isFavorite: map['isFavorite'] as bool? ?? false,
      position: map['position'] as int? ?? 0,
      requiresConfirmation: map['requiresConfirmation'] as bool? ?? false,
      audioAsset: map['audioAsset'] as String?,
      semanticLabel: map['semanticLabel'] as String?,
    );
  }
}
