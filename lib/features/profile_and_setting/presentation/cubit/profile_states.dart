import 'dart:io';

import 'package:flowpay/features/profile_and_setting/domain/entities/profile_user.dart';

abstract class ProfileStates {}

// initial
class ProfileInitial extends ProfileStates {}

// loading
class ProfileLoading extends ProfileStates {}

// laoded
class ProfileLoaded extends ProfileStates {
  final ProfileUser profileUser;
  final File? pickedImage; // NEW: local image from picker

  ProfileLoaded(this.profileUser, {this.pickedImage});
}

// error
class ProfileError extends ProfileStates {
  final String message;
  ProfileError(this.message);
}

// updated
class ProfileUpdated extends ProfileStates {
  final ProfileUser profileUser;
  ProfileUpdated(this.profileUser);
}
