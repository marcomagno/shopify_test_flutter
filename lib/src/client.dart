import 'dart:developer';

import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:flutter_shopify_test/src/constants.dart';
import 'package:http/http.dart' as http;
// import 'package:key_value_store/key_value_store.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:oauth2/oauth2.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OAuthClient {
  OAuthClient._({
    required this.clientId,
    required this.authorizationEndpoint,
    required this.tokenEndpoint,
    required this.redirectUrl,
    required this.logoutEndpoint,
    required this.scopes,
    // required this.keyValueStore,
  });

  final String clientId;
  final Uri authorizationEndpoint;
  final Uri tokenEndpoint;
  final Uri redirectUrl;
  final Uri logoutEndpoint;
  final Iterable<String> scopes;
  // final TannicoKeyValueStore keyValueStore;

  http.BaseClient? _httpClient;
  oauth2.Client? _oauthClient;
  static const keyValueStoreCredentialsKey = "OAuthClient.oauth_credentials";

  http.BaseClient? get httpClient => _httpClient;

  /// Singleton instance
  static final instance = OAuthClient._(
    clientId: Constants.clientId,
    authorizationEndpoint: Constants.authorizationEndpoint,
    tokenEndpoint: Constants.tokenEndpoint,
    redirectUrl: Constants.redirectUrl,
    logoutEndpoint: Constants.logoutEndpoint,
    scopes: const ["openid", "email", "https://api.customers.com/auth/customer.graphql"],
    // keyValueStore: ServiceLocator.instance.keyValueStore,
  );

  Future<void> restoreLogin() async {
    // final credentialsJson = keyValueStore.get<String>(keyValueStoreCredentialsKey);
    final sharedPrefs = await SharedPreferences.getInstance();
    final credentialsJson = sharedPrefs.getString(keyValueStoreCredentialsKey);
    if (credentialsJson == null) {
      log("No restorable credentials found");
      return;
    }

    final credentials = oauth2.Credentials.fromJson(credentialsJson);
    _oauthClient = oauth2.Client(credentials, identifier: credentials.idToken, secret: credentials.accessToken);
    _httpClient = ChuckerHttpClient(_oauthClient!);

    log("Client restored: $_oauthClient");
  }

  Future<void> login({required Future<Uri?> Function(Uri uri) onRedirect}) async {
    final grant = oauth2.AuthorizationCodeGrant(clientId, authorizationEndpoint, tokenEndpoint);
    final authorizationUrl = grant.getAuthorizationUrl(redirectUrl, scopes: scopes);
    // authorizationUrl = authorizationUrl.replace(queryParameters: {
    //   ...authorizationUrl.queryParameters,
    //   "prompt": "none",
    // });
    final responseUrl = await onRedirect(authorizationUrl);
    _oauthClient = responseUrl != null ? await grant.handleAuthorizationResponse(responseUrl.queryParameters) : null;
    _httpClient = ChuckerHttpClient(_oauthClient!);
    log("New client created: $_oauthClient");

    // await keyValueStore.set(keyValueStoreCredentialsKey, _client?.credentials.toJson());
    if (_oauthClient?.credentials.toJson() case final jsonString?) {
      final sharedPrefs = await SharedPreferences.getInstance();
      await sharedPrefs.setString(keyValueStoreCredentialsKey, jsonString);
    }
  }

  Future<void> logout({required Future<void> Function(Uri uri) onRedirect}) async {
    final uri = logoutEndpoint.replace(
      queryParameters: {
        ...logoutEndpoint.queryParameters,
        if (_oauthClient?.credentials.idToken != null) "id_token_hint": _oauthClient?.credentials.idToken,
      },
    );
    onRedirect(uri);
    _httpClient = null;
    _oauthClient = null;

    // await keyValueStore.set(keyValueStoreCredentialsKey, null);
    final sharedPrefs = await SharedPreferences.getInstance();
    await sharedPrefs.remove(keyValueStoreCredentialsKey);
  }

  Credentials? get credentials => _oauthClient?.credentials;
}
