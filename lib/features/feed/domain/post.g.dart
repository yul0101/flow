// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Post _$PostFromJson(Map<String, dynamic> json) => _Post(
  id: json['id'] as String,
  content: json['content'] as String,
  imageUrl: json['imageUrl'] as String?,
  author: User.fromJson(json['author'] as Map<String, dynamic>),
  likes: (json['likes'] as num).toInt(),
  comments: (json['comments'] as num).toInt(),
  liked: json['liked'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$PostToJson(_Post instance) => <String, dynamic>{
  'id': instance.id,
  'content': instance.content,
  'imageUrl': instance.imageUrl,
  'author': instance.author,
  'likes': instance.likes,
  'comments': instance.comments,
  'liked': instance.liked,
  'createdAt': instance.createdAt.toIso8601String(),
};
