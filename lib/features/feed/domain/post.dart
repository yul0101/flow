import 'package:freezed_annotation/freezed_annotation.dart';

import '../../auth/domain/user.dart';

part 'post.freezed.dart';
part 'post.g.dart';

/// Feed 帖子模型。
@freezed
abstract class Post with _$Post {
  const factory Post({
    required String id,
    required String content,
    String? imageUrl,
    required User author,
    required int likes,
    required int comments,
    required bool liked,
    required DateTime createdAt,
  }) = _Post;

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
}
