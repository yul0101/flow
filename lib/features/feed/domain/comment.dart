import 'package:freezed_annotation/freezed_annotation.dart';

import '../../auth/domain/user.dart';

part 'comment.freezed.dart';
part 'comment.g.dart';

/// 帖子评论模型。
@freezed
abstract class Comment with _$Comment {
  const factory Comment({
    required String id,
    required String postId,
    required String content,
    required User author,
    required DateTime createdAt,
  }) = _Comment;

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);
}
