import 'package:flutter_bloc/flutter_bloc.dart';

// States
class BiometricState {
  final bool faceIdEnabled;
  final bool fingerprintEnabled;

  const BiometricState({
    required this.faceIdEnabled,
    required this.fingerprintEnabled,
  });

  BiometricState copyWith({bool? faceIdEnabled, bool? fingerprintEnabled}) {
    return BiometricState(
      faceIdEnabled: faceIdEnabled ?? this.faceIdEnabled,
      fingerprintEnabled: fingerprintEnabled ?? this.fingerprintEnabled,
    );
  }
}

class BiometricCubit extends Cubit<BiometricState> {
  BiometricCubit()
    : super(
        const BiometricState(faceIdEnabled: false, fingerprintEnabled: false),
      );

  void toggleFaceId(bool value) {
    emit(state.copyWith(faceIdEnabled: value));
  }

  void toggleFingerprint(bool value) {
    emit(state.copyWith(fingerprintEnabled: value));
  }
}
