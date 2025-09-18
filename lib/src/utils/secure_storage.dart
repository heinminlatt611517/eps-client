import 'package:get_storage/get_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_storage.g.dart';

enum SecureDataList {
  token,
  fCMToken,
  isAlreadyLogin,
  isSignedIn,
  authToken,
  baseApiUrl,
  userData,
  leaveTypes,
}

class SecureStorage {
  final GetStorage _box = GetStorage();

  ///auth flow
  saveAuthStatus(String status) async {
    await _box.write(SecureDataList.isSignedIn.name, status);
  }

  Future<String?> getAuthStatus() async {
    final res = await _box.read(SecureDataList.isSignedIn.name);
    return res;
  }

  ///fcm token
  saveFCMToken(String fcmToken) async {
    await _box.write(SecureDataList.fCMToken.name, fcmToken);
  }

  ///get fcm token
  getFCMToken() {
    return _box.read(SecureDataList.fCMToken.name);
  }

  ///auth token
  saveAuthToken(String authToken) async {
    await _box.write(SecureDataList.authToken.name, authToken);
  }

  getAuthToken() {
    return _box.read(SecureDataList.authToken.name);
  }
}

@Riverpod(keepAlive: true)
SecureStorage secureStorage(SecureStorageRef ref) {
  return SecureStorage();
}

@riverpod
Future<String?> getAuthStatus(GetAuthStatusRef ref) {
  final provider = ref.watch(secureStorageProvider);
  return provider.getAuthStatus();
}

