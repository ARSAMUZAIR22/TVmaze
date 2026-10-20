import 'package:equatable/equatable.dart';

class CastMember extends Equatable {
  const CastMember({
    required this.personId,
    required this.personName,
    this.personImage,
    this.characterName,
    this.characterImage,
  });

  factory CastMember.fromJson(Map<String, dynamic> json) {
    final person =
        (json['person'] as Map<String, dynamic>?) ?? const <String, dynamic>{};
    final character =
        (json['character'] as Map<String, dynamic>?) ?? const <String, dynamic>{};
    final personImage = person['image'] as Map<String, dynamic>?;
    final characterImage = character['image'] as Map<String, dynamic>?;

    return CastMember(
      personId: (person['id'] as num?)?.toInt() ?? 0,
      personName: (person['name'] as String?) ?? 'Unknown',
      personImage: personImage?['medium'] as String?,
      characterName: character['name'] as String?,
      characterImage: characterImage?['medium'] as String?,
    );
  }

  final int personId;
  final String personName;
  final String? personImage;
  final String? characterName;
  final String? characterImage;

  String? get imageUrl => personImage ?? characterImage;

  @override
  List<Object?> get props =>
      [personId, personName, personImage, characterName, characterImage];
}
