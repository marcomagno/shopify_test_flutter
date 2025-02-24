import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_shopify_test/src/client.dart';
import 'package:flutter_shopify_test/src/constants.dart';
import 'package:flutter_shopify_test/src/logout_webview.dart';
import 'package:flutter_shopify_test/src/pigeon.dart';
import 'package:flutter_shopify_test/src/redirect_webview.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  var _cartId = "";
  var _checkoutUrl = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                OAuthClient.instance.restoreLogin();
              },
              child: const Text("Restore Login"),
            ),
            ElevatedButton(
              onPressed: () => _performLogin(),
              child: const Text("Login"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _performLogout(),
              child: const Text("Logout"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _createCart(),
              child: const Text("Create cart"),
            ),
            SelectableText("Cart ID: $_cartId"),
            SelectableText("Checkout URL: $_checkoutUrl"),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _checkout(),
              child: const Text("Checkout"),
            ),
            SelectableText("Will present this URL: ${_checkoutUrlToPresent()}"),
          ],
        ),
      ),
    );
  }

  String _checkoutUrlToPresent() => _checkoutUrl;

  Future<void> _performLogin() async {
    await OAuthClient.instance.login(
      onRedirect: (uri) async {
        final result = await showDialog<Uri>(
          context: context,
          builder: (context) => RedirectWebView(
            initialUri: uri,
            redirectUri: Constants.redirectUrl,
          ),
        );
        return result;
      },
    );
  }

  Future<void> _performLogout() async {
    await OAuthClient.instance.logout(
      onRedirect: (uri) => showDialog(
        context: context,
        builder: (context) => LogoutWebView(uri: uri),
      ),
    );
  }

  Future<void> _createCart() async {
    final httpLink = HttpLink(
      Constants.gqlEndpoint,
      httpClient: OAuthClient.instance.client!,
      defaultHeaders: {
        "X-Shopify-Storefront-Access-Token": Constants.storefrontAccessToken,
      },
    );
    final client = GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(store: InMemoryStore()),
    );

    final authHttpLink = HttpLink(Constants.gqlAuthEndpoint, defaultHeaders: {
      "Authorization": OAuthClient.instance.credentials?.accessToken ?? "",
    });
    final authClient = GraphQLClient(
      link: authHttpLink,
      cache: GraphQLCache(store: InMemoryStore()),
    );

    var mutation = r'''
mutation storefrontCustomerAccessTokenCreate {
        storefrontCustomerAccessTokenCreate {
          userErrors {
            message
            field
          }
          customerAccessToken
        }
      }
''';
    var options = MutationOptions(
      document: gql(mutation),
    );

    var customerAccessToken = "";
    var result = await authClient.mutate(options);
    if (result.hasException) {
      print(result.exception.toString());
    } else {
      customerAccessToken = result.data!['storefrontCustomerAccessTokenCreate']['customerAccessToken'];
    }

    log("Customer Access Token => $customerAccessToken");

    mutation = r'''
mutation createCart($cartInput: CartInput) {
  cartCreate(input: $cartInput) {
    userErrors {
      message
      field
    }
    cart {
      id
      createdAt
      updatedAt
      checkoutUrl
      lines(first: 10) {
        edges {
          node {
            id
            merchandise {
              ... on ProductVariant {
                id
              }
            }
          }
        }
      }
      attributes {
        key
        value
      }
      cost {
        totalAmount {
          amount
          currencyCode
        }
        subtotalAmount {
          amount
          currencyCode
        }
        totalTaxAmount {
          amount
          currencyCode
        }
        totalDutyAmount {
          amount
          currencyCode
        }
      }
      buyerIdentity {
        email
      }
    }
  }
}
  ''';
    final variables = <String, dynamic>{
      "cartInput": {
        "lines": const [
          {
            "quantity": 1,
            "merchandiseId": "gid://shopify/ProductVariant/49577410494756",
          },
        ],
        "attributes": const {
          "key": "cart_attribute_key",
          "value": "This is a cart attribute value",
        },
        "buyerIdentity": {
          "customerAccessToken": customerAccessToken,
        }
      },
    };
    options = MutationOptions(
      document: gql(mutation),
      variables: variables,
    );

    result = await client.mutate(options);
    if (result.hasException) {
      print(result.exception.toString());
    } else {
      print("Created a cart with buyer identity: ${result.data?["cartCreate"]["cart"]["buyerIdentity"]["email"]}");
      setState(() {
        _cartId = result.data!["cartCreate"]["cart"]["id"];
        _checkoutUrl = result.data!["cartCreate"]["cart"]["checkoutUrl"];
      });
    }
  }

  Future<void> _checkout() async {
    await ExampleHostApi().presentCheckout(_checkoutUrlToPresent());
  }
}
