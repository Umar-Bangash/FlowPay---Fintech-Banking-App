/* 

Auth Repository: Outline the possible auth operations !!

--------------------------------------------------------------------------------
- login 
- rgister
- forget password
- logout
- get current user

*/

import 'package:flowpay/features/auth/domain/entities/app_user.dart';

abstract class AuthRepo {
  Future<AppUser?> login(String email, password);
  Future<AppUser?> register(String name, email, password, String dob);
  Future<void> forgetPassword(String email);
  Future<void> logout();
  Future<AppUser?> getCurrentUser();
}
