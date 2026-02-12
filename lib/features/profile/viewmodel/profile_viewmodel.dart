import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/firestore_service.dart';
import '../../../data/models/profile.dart';

final profileViewModelProvider =
    AsyncNotifierProvider<ProfileViewModel, Profile?>(
  ProfileViewModel.new,
);

class ProfileViewModel extends AsyncNotifier<Profile?> {
  late final FirestoreService _firestoreService;

  @override
  Future<Profile?> build() async {
    _firestoreService = FirestoreService();
    return _firestoreService.fetchProfile();
  }

  Future<void> saveProfile({
    required String brandName,
    required String termsAndConditions,
  }) async {
    final current = state.value;
    final profile = Profile(
      brandName: brandName,
      termsAndConditions: termsAndConditions,
      imageUrl: current?.imageUrl,
    );

    state = const AsyncLoading();
    try {
      await _firestoreService.saveProfile(profile);
      state = AsyncData(profile);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

