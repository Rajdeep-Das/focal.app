import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class OfferHistoryScreen extends StatefulWidget {
  const OfferHistoryScreen({super.key});

  @override
  State<OfferHistoryScreen> createState() => _OfferHistoryScreenState();
}

class _OfferHistoryScreenState extends State<OfferHistoryScreen> {
  static const String iframeUrl = 'https://dev-offerhistory.offerx.in';
  static const String targetOrigin = 'https://dev-offerhistory.offerx.in';

  bool _isLoading = true;

  final InAppWebViewSettings _settings = InAppWebViewSettings(
    javaScriptEnabled: true,
    iframeAllowFullscreen: true,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    useHybridComposition: true,
    // Allow mixed content for development
    mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
  );

  @override
  void initState() {
    super.initState();
    debugPrint('Initializing OfferHistory WebView');
  }

  void _handleWebViewCreated(InAppWebViewController controller) {
    debugPrint('OfferHistory WebView created');

    // Add JavaScript handler for Flutter channel communication
    controller.addJavaScriptHandler(
      handlerName: 'FlutterChannel',
      callback: _handleMessageFromIframe,
    );
  }

  void _handleLoadStop(InAppWebViewController controller, WebUri? url) async {
    debugPrint('OfferHistory page finished loading: $url');
    setState(() {
      _isLoading = false;
    });
  }

  void _handleLoadError(InAppWebViewController controller,
      WebResourceRequest request, WebResourceError error) {
    debugPrint('OfferHistory web resource error: ${error.description}');
    setState(() {
      _isLoading = false;
    });
  }

  String _getWrapperHtml() {
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>ScreenX Offer History</title>
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }
    html, body {
      width: 100%;
      height: 100%;
      overflow: hidden;
      margin: 0;
      padding: 0;
      position: fixed;
    }
    #writeReviewIframe {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      border: none;
      display: block;
    }
  </style>
</head>
<body>
  <iframe id="writeReviewIframe" src="about:blank" allowFullScreen></iframe>

  <script>
    const TARGET_ORIGIN = "$targetOrigin";
    const IFRAME_URL = "$iframeUrl";
    const iframe = document.getElementById("writeReviewIframe");

    function sendLog(msg) {
      try {
        if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
          window.flutter_inappwebview.callHandler('FlutterChannel', msg);
        }
      } catch (e) {
        console.error('Error sending log to Flutter:', e);
      }
    }

    sendLog("IFRAME_URL: " + IFRAME_URL);

    function safePostMessage(message, targetOrigin) {
      try {
        sendLog("📤 Attempting to send postMessage: " + JSON.stringify(message) + " → " + targetOrigin);

        if (!iframe) {
          console.error("❌ iframe element not found");
          sendLog("❌ iframe element not found");
          return;
        }

        if (!iframe.contentWindow) {
          console.error("⚠️ iframe.contentWindow not available yet");
          sendLog("⚠️ iframe.contentWindow not available yet");
          return;
        }

        iframe.contentWindow.postMessage(message, targetOrigin);
        console.log("✅ postMessage executed successfully");
        sendLog("✅ postMessage executed successfully with: " + JSON.stringify(message));
      } catch (err) {
        console.error("💥 Error in postMessage:", err);
        sendLog("💥 Error in postMessage: " + err.message);
      }
    }

    async function generateAsyncToken() {
      try {
        const message = {
          apiPayload: [
            {
              iframeType: "offerHistory",
              token: "nRxD/od/IW4qmGb0flA2CFFe3DBkb/rOuLllCQ+hgDgxJyodMeCwXtIXbAMikzbfvCa44VmMhk1HRuZUYwsBVgJuh89Ssua60UbwdrXjOA5bc5w2DlwHP9PPHng6HZaOKfPLfNv++5816zbjxkwgO5drEHMJT5Cbd7rcJJ6yJO03A3OA/UPhGCQ1DeyEhHedoWpxpqwp/BMsqmxmZ3cJ+MIQB7ByA5YCmVoVGAefZTn4wkT9ggejIeZDflY+ynNCA0v2d+sF/MUSld4GUr/8tmXPvYHH20/rmEhn6xndDiBOFfv/1BbDTQkWyjkhZUgbVD7HvyfKn2LOpOridPIAOrvQ/OEQMKZkId4xZe/4rrTCqBl/VvyYjuQj6y6EQssjWbK2Pa4dansXja1TgLv/IUsZCeauB113BCRMPK/3d4hqWGVLS80DNsC/m4fH0LRjFuUeo/Ku9XPMyFuJ9DjfnQ/h4sJWMLTSky2gFnslqX4IdQCxS37jUsgZQR5yJws7FNcgb4cddixgYNzxO0ubJVaiHfFduLf01PDGxeiq2ddjD9gNVOx8yzYtmW9TSyKrcO2oe7Gsv5hJ4Zib1H5JJhPQGrZ7G75hXZrQeOdiUCMGOGr9RfKQCfxrQqWPrIbmxz+wyVguqQx/jloqO1urrIiMLRgtR/whCfQm31E4QvH7rBWQQlmPXlDUem7OsgOpDPAzKcT2LSRg67FfCyUUs/1vz12Vbvi/YVkf8Anb6PIUmWV4EPS2h+dNP4a+PgOThDPX5kVrGtBcAxB9w8nFA97MVK29RB1eV5Z165gWoBp2n6qxgWVqWHxe063Cr6cssjGZSZaUdcVzz8sAZoGYUaiZt/CicHhhCsQ4rZhlWnjnUv0QY0uOwPwH1w68AMxOOgaZXMgXxYSVg6jo09zIXB2kzmqX2qgh8Q77FmOgBjfxiYmT0+3/4UHP4bO/teXpR+75rzuynkon+USFvwMwUA==",
              payLoad: {
                companyName: "Aspiriasdasdsas Limited",
                companyEmail: "testketni2@gmail.com",
                companyWebsite: "https://www.aspire.com",
                ownerFirstName: "John",
                ownerLastName: "Doe",
                companyOwnerPhone: "2548758458",
                candidateName: "Jane Smith",
                candidatePhone: "5555555874",
                companyOwnerEmail: "testketni2@gmail.com",
                candidateEmail: "loadtest49@gmail.com",
              },
            },
          ],
        };
        sendLog(JSON.stringify(message));
        safePostMessage(message, TARGET_ORIGIN);
        console.log("Offer History message sent:", JSON.stringify(message));
      } catch (err) {
        sendLog("Error generating token or sending message: " + err);
        console.error("Error generating token or sending message:", err);
      }
    }

    function launchIframe() {
      sendLog("Loading iframe...");
      iframe.src = "about:blank";
      setTimeout(() => {
        iframe.src = IFRAME_URL;
        iframe.onload = generateAsyncToken;
        sendLog("iframe: " + IFRAME_URL + ", " + iframe.src);
      }, 50);
      sendLog("generateAsyncToken called");
    }

    // Listen for messages from iframe
    window.addEventListener('message', function(event) {
      if (event.origin !== TARGET_ORIGIN) {
        console.warn('Message from untrusted origin:', event.origin);
        return;
      }

      sendLog('Message from iframe: ' + JSON.stringify(event.data));
    });

    document.addEventListener("DOMContentLoaded", () => {
      sendLog("Starting automatic integration...");
      launchIframe();
    });

    // Start immediately if DOMContentLoaded already fired
    if (document.readyState === 'loading') {
      // Still loading, wait for event
    } else {
      // DOMContentLoaded has already fired
      sendLog("Starting automatic integration (immediate)...");
      launchIframe();
    }
  </script>
</body>
</html>
    ''';
  }

  void _handleMessageFromIframe(List<dynamic> args) {
    if (args.isEmpty) return;

    final messageStr = args[0].toString();
    debugPrint('=== RECEIVED MESSAGE FROM OFFER HISTORY IFRAME ===');
    debugPrint('Message: $messageStr');
  }

  Future<ServerTrustAuthResponse?> _handleServerTrustAuth(
      InAppWebViewController controller,
      URLAuthenticationChallenge challenge) async {
    // Only bypass SSL in debug mode
    if (kDebugMode) {
      debugPrint('⚠️ DEBUG MODE: Bypassing SSL certificate validation for ${challenge.protectionSpace.host}');
      return ServerTrustAuthResponse(
        action: ServerTrustAuthResponseAction.PROCEED,
      );
    }
    // In release mode, use default behavior (validate certificates)
    return ServerTrustAuthResponse(
      action: ServerTrustAuthResponseAction.CANCEL,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offer History'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialSettings: _settings,
            initialData: InAppWebViewInitialData(
              data: _getWrapperHtml(),
              baseUrl: WebUri(targetOrigin),
            ),
            onWebViewCreated: _handleWebViewCreated,
            onLoadStop: _handleLoadStop,
            onReceivedError: _handleLoadError,
            onReceivedServerTrustAuthRequest: _handleServerTrustAuth,
            onConsoleMessage: (controller, consoleMessage) {
              debugPrint('Console: ${consoleMessage.message}');
            },
            onLoadStart: (controller, url) {
              debugPrint('Page started loading: $url');
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Loading Offer History...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
