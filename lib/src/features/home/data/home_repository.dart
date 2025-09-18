import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../network/dio_provider.dart';

part 'home_repository.g.dart';

class HomeRepository {
  HomeRepository({required this.ref, required this.dio});

  final Ref ref;
  final Dio dio;
}

@riverpod
HomeRepository homeRepository(HomeRepositoryRef ref) {
  return HomeRepository(dio: ref.watch(dioProvider), ref: ref);
}
