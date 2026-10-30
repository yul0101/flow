import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// 登录用户模型。
@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String username,
    required String avatar,
    String? bio,
    required DateTime createdAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
