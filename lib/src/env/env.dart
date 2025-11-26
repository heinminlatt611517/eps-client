import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
class Env {
  @EnviedField(varName: 'GOOGLE_CLIENT_ID', defaultValue: '')
  static const String googleClientId = _Env.googleClientId;
}
