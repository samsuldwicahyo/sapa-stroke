class FamilyMember {
  const FamilyMember({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  FamilyMember copyWith({
    String? id,
    String? name,
  }) {
    return FamilyMember(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
    };
  }

  factory FamilyMember.fromMap(Map<String, dynamic> map) {
    return FamilyMember(
      id: map['id'] as String,
      name: map['name'] as String,
    );
  }
}
