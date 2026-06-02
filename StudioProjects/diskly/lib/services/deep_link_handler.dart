import 'dart:async';
import 'dart:developer';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

class DeepLinkHandler {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  void init(BuildContext context) {
    // Check initial link if app was closed


    // Listen for links while app is running
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(context, uri);
      }
    }, onError: (err) {
      log('Deep Link Error: $err');
    });
  }

  void _handleDeepLink(BuildContext context, Uri uri) {
    log('Received deep link: $uri');
    // Implement routing logic based on the URI here
    // Example: if (uri.path == '/video') { ... }
    
    // For now, show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Deep link received: ${uri.toString()}')),
    );
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}
