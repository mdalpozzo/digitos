import 'package:flutter_dotenv/flutter_dotenv.dart';

class ConfigManager {
  static final ConfigManager _instance =
      ConfigManager._internal();

  factory ConfigManager() {
    return _instance;
  }

  ConfigManager._internal();

  Future<void> loadEnv() async {
    await dotenv.load(fileName: ".env");
  }

  // Generic method to get environment variables
  String? get(String name) => dotenv.env[name];

  // Specific getters for expected environment variables
  String get nhostGraphqlEndpoint {
    final endpoint = dotenv.env['NHOST_GRAPHQL_ENDPOINT'];
    if (endpoint == null) {
      throw Exception(
          'NHOST_GRAPHQL_ENDPOINT not found in environment variables');
    }
    return endpoint;
  }

  String get nhostGraphqlAdminSecret {
    final adminSecret = dotenv.env['NHOST_GRAPHQL_ADMIN_SECRET'];
    if (adminSecret == null) {
      throw Exception(
          'NHOST_GRAPHQL_ADMIN_SECRET not found in environment variables');
    }
    return adminSecret;
  }
}
