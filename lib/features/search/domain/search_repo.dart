import 'package:flowpay/features/profile_and_setting/domain/entities/profile_user.dart';

abstract class SearchRepo {
  Future<List<ProfileUser>> searchUsers(String query);
}
