import 'package:get_storage/get_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/home/model/category_response.dart';

part 'secure_storage.g.dart';

enum SecureDataList {
  token,
  fCMToken,
  isAlreadyLogin,
  isSignedIn,
  authToken,
  baseApiUrl,
  userName,
  leaveTypes,
  categories,
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

  ///user name
  saveUserName(String userName) async {
    await _box.write(SecureDataList.userName.name, userName);
  }

  ///get userName
  getUserName() {
    return _box.read(SecureDataList.userName.name);
  }

  ///auth token
  saveAuthToken(String authToken) async {
    await _box.write(SecureDataList.authToken.name, authToken);
  }

  getAuthToken() {
    return _box.read(SecureDataList.authToken.name);
  }


  /// Save categories list
  Future<void> saveCategories(List<CategoryVO> items) async {
    final jsonList = items.map((e) => e.toJson()).toList();
    await _box.write(SecureDataList.categories.name, jsonList);
  }

  /// Get categories list (sync)
  List<CategoryVO> getCategoriesSync() {
    final raw = _box.read(SecureDataList.categories.name);
    if (raw is List) {
      return raw.map((e) => CategoryVO.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    return <CategoryVO>[];
  }

  /// Get categories list (async)
  Future<List<CategoryVO>> getCategories() async => getCategoriesSync();

  /// Clear categories (optional)
  Future<void> clearCategories() => _box.remove(SecureDataList.categories.name);


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

@riverpod
Future<String?> getUserName(GetAuthStatusRef ref) {
  final provider = ref.watch(secureStorageProvider);
  return provider.getUserName();
}

@riverpod
Future<List<CategoryVO>> categoriesLocal(CategoriesLocalRef ref) async {
  final store = ref.read(secureStorageProvider);
  return store.getCategories();
}

@riverpod
String? getFcmToken(GetFcmTokenRef ref) {
  final store = ref.watch(secureStorageProvider);
  return store.getFCMToken();
}
