# flutter_shopify_test

Test project for Shopify integration.

## Setup

1. Clone the repository.
2. Create a local copy of `lib/src/constants.dart` in order to provide your secrets:

```dart
abstract class Constants {
  static const clientId = "{{value}}";
  static final authorizationEndpoint = Uri.parse("https://shopify.com/{{value}}/auth/oauth/authorize");
  static final tokenEndpoint = Uri.parse("https://shopify.com/{{value}}/auth/oauth/token");
  static final redirectUrl = Uri.parse("shop.{{value}}.app://callback");
  static final logoutEndpoint = Uri.parse("https://shopify.com/{{value}}/auth/logout");
  static const storefrontAccessToken = "{{value}}";
  static const gqlEndpoint = 'https://{{value}}.myshopify.com/api/2023-04/graphql.json';
  static const gqlAuthEndpoint = 'https://shopify.com/{{value}}/account/customer/api/2025-01/graphql';
}

```

## Directions

- The GraphQL calls are placed in `lib/src/main_screen.dart`.
