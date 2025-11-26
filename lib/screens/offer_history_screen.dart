import 'dart:async';
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

  //https://dev-offerhistory.offerx.in
  //static const String iframeUrl = 'https://dev-offerhistory.offerx.global';
  //static const String targetOrigin = 'https://dev-offerhistory.offerx.global';

  bool _isLoading = true;
  Timer? _loadingTimeout;

  // Toggle this to test loading the URL directly vs wrapped in HTML
  static const bool useDirectLoad = false;

  final InAppWebViewSettings _settings = InAppWebViewSettings(
    javaScriptEnabled: true,
    iframeAllowFullscreen: true,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    useHybridComposition: true,
    // Allow mixed content for development
    mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
    // Additional settings for better iframe support
    javaScriptCanOpenWindowsAutomatically: true,
    supportMultipleWindows: false,
    // Cache and loading optimizations
    cacheEnabled: true,
    clearCache: false,
    // DOM storage
    domStorageEnabled: true,
    databaseEnabled: true,
  );

  @override
  void initState() {
    super.initState();
    debugPrint('Initializing OfferHistory WebView');

    // Set a timeout to hide loading indicator if iframe takes too long
    _loadingTimeout = Timer(const Duration(seconds: 10), () {
      debugPrint('⏰ Loading timeout reached - hiding loading indicator');
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _loadingTimeout?.cancel();
    super.dispose();
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
    debugPrint('✅ OfferHistory page finished loading: $url');

    // Cancel the timeout since loading completed
    _loadingTimeout?.cancel();

    // Add a small delay to ensure iframe has time to initialize
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isLoading = false;
    });
  }

  void _handleLoadError(InAppWebViewController controller,
      WebResourceRequest request, WebResourceError error) {
    debugPrint('❌ OfferHistory web resource error: ${error.description}');
    debugPrint('❌ Error type: ${error.type}');
    debugPrint('❌ Failed URL: ${request.url}');

    // Cancel the timeout since we got an error
    _loadingTimeout?.cancel();

    setState(() {
      _isLoading = false;
    });
  }

  void _handleLoadHttpError(InAppWebViewController controller,
      WebResourceRequest request, WebResourceResponse errorResponse) {
    debugPrint('⚠️ HTTP Error ${errorResponse.statusCode} for ${request.url}');
  }

  String _getWrapperHtml() {
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
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
      background: white;
    }
    #debugOverlay {
      position: fixed;
      top: 60px;
      left: 10px;
      right: 10px;
      background: rgba(0, 0, 0, 0.8);
      color: #0f0;
      padding: 10px;
      font-family: monospace;
      font-size: 11px;
      z-index: 9999;
      max-height: 200px;
      overflow-y: auto;
      display: none;
      border-radius: 4px;
    }
    #debugOverlay.show {
      display: block;
    }
    #debugToggle {
      position: fixed;
      top: 60px;
      right: 10px;
      background: rgba(0, 0, 0, 0.7);
      color: white;
      padding: 5px 10px;
      border: 1px solid #666;
      border-radius: 4px;
      z-index: 10000;
      font-size: 12px;
      cursor: pointer;
    }
  </style>
</head>
<body>
  <button id="debugToggle" onclick="toggleDebug()">Show Debug</button>
  <div id="debugOverlay"></div>
  <iframe id="writeReviewIframe" src="about:blank" allowFullScreen></iframe>

  <script>
    const TARGET_ORIGIN = "$targetOrigin";
    const IFRAME_URL = "$iframeUrl";
    const iframe = document.getElementById("writeReviewIframe");
    const debugOverlay = document.getElementById("debugOverlay");
    let debugLogs = [];

    function toggleDebug() {
      debugOverlay.classList.toggle('show');
      const btn = document.getElementById('debugToggle');
      btn.textContent = debugOverlay.classList.contains('show') ? 'Hide Debug' : 'Show Debug';
    }

    function addDebugLog(msg) {
      const timestamp = new Date().toLocaleTimeString();
      debugLogs.push(timestamp + ': ' + msg);
      if (debugLogs.length > 20) debugLogs.shift();
      debugOverlay.innerHTML = debugLogs.join('<br>');
    }

    function sendLog(msg) {
      try {
        addDebugLog(msg);
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
              token: "nRxD/od/IW4qmGb0flA2CFFe3DBkb/rOuLllCQ+hgDgxJyodMeCwXtIXbAMikzbfvCa44VmMhk1HRuZUYwsBVgJuh89Ssua60UbwdrXjOA5bc5w2DlwHP9PPHng6HZaOKfPLfNv++5816zbjxkwgO5drEHMJT5Cbd7rcJJ6yJO03A3OA/UPhGCQ1DeyEhHedoWpxpqwp/BMsqmxmZ3cJ+MIQB7ByA5YCmVoVGAefZTn4wkT9ggejIeZDflY+ynNCA0v2d+sF/MUSld4GUr/8tmXPvYHH20/rmEhn6xndDiBOFfv/1BbDTQkWyjkhZUgbVD7HvyfKn2LOpOridPIAOrvQ/OEQMKZkId4xZe/4rrTCqBl/VvyYjuQj6y6EQssjWbK2Pa4dansXja1TgLv/IUsZCeauB113BCRMPK/3d4hqWGVLS80DNsC/m4fH0LRjFuUeo/Ku9XPMyFuJ9DjfnQ/h4sJWMLTSky2gFnslqX4IdQCxS37jUsgZQR5yJws7FNcgb4cddixgYNzxO0ubJVaiHfFduLf01PDGxeiq2ddjD9gNVOx8yzYtmW9TSyKrcO2oe7Gsv5hJ4Zib1H5JJhPQGrZ7G75hXZrQeOdiUCMGOGr9RfKQCfxrQqWPrIbmxz+wyVguqQx/jloqO1urrIiMLRgtR/whCfQm31E4QvH7rBWQQlmPXlDUem7OsgOpDPAzKcT2LSRg67FfCyUUs/1vz12Vbvi/YVkf8Anb6PIUmWV4EPS2h+dNP4a+PgOTJKjcBA9ouYOrdDU3Ch3GbWDQxgPTqgl4xPsB+AzZm5/GAgGIymOYTUxix5qHm3pzAHTzAmacqUE5N3Irofq1k+vUwcGv0G88VJesJHjMFvmV+qeUma9mv0lDd8IFG6eIcBdzPxaVxKw62VAhNEzTnO5DCjyefy6OY6MesAE9sdP8rp1NSOljzr06jvzzFzQCWrEMY67BbcOoGiBbAGJwww==",
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
        sendLog("📦 Sending initial postMessage");
        safePostMessage(message, TARGET_ORIGIN);

        // Retry mechanism - iframe might not be ready on first send
        sendLog("⏱️ Setting up retry mechanism");
        setTimeout(() => {
          sendLog("🔁 Retry 1: Sending postMessage");
          safePostMessage(message, TARGET_ORIGIN);
        }, 500);

        setTimeout(() => {
          sendLog("🔁 Retry 2: Sending postMessage");
          safePostMessage(message, TARGET_ORIGIN);
        }, 1000);

        setTimeout(() => {
          sendLog("🔁 Retry 3: Sending postMessage");
          safePostMessage(message, TARGET_ORIGIN);
        }, 2000);

        setTimeout(() => {
          sendLog("🔁 Retry 4: Sending postMessage");
          safePostMessage(message, TARGET_ORIGIN);
        }, 3000);

        console.log("Offer History message sent with retries");
      } catch (err) {
        sendLog("❌ Error generating token or sending message: " + err);
        console.error("Error generating token or sending message:", err);
      }
    }

    function checkIframeStatus() {
      try {
        sendLog("🔍 Checking iframe status...");
        sendLog("🔍 iframe.src: " + iframe.src);
        sendLog("🔍 iframe.contentWindow exists: " + (iframe.contentWindow !== null));

        // Try to check if iframe has loaded content
        setTimeout(() => {
          try {
            const iframeDoc = iframe.contentDocument || iframe.contentWindow.document;
            sendLog("🔍 iframe readyState: " + iframeDoc.readyState);
          } catch (e) {
            sendLog("🔍 Cannot access iframe document (CORS): " + e.message);
          }
        }, 1000);
      } catch (err) {
        sendLog("❌ Error checking iframe status: " + err.message);
      }
    }

    function launchIframe() {
      sendLog("🚀 Loading iframe...");
      iframe.src = "about:blank";
      setTimeout(() => {
        sendLog("🌐 Setting iframe src to: " + IFRAME_URL);
        iframe.src = IFRAME_URL;
        iframe.onload = function() {
          sendLog("✅ iframe.onload fired!");
          checkIframeStatus();
          // Wait a bit more before sending postMessage to ensure iframe is fully rendered
          setTimeout(() => {
            sendLog("🎯 iframe should be ready now, sending data");
            generateAsyncToken();
          }, 1000);
        };
        iframe.onerror = function(err) {
          sendLog("❌ iframe.onerror fired: " + JSON.stringify(err));
        };
        sendLog("iframe URL set: " + iframe.src);
      }, 100);
    }

    // Listen for messages from iframe
    window.addEventListener('message', function(event) {
      sendLog('📥 Received message from origin: ' + event.origin);
      sendLog('📥 Message data: ' + JSON.stringify(event.data));

      if (event.origin !== TARGET_ORIGIN) {
        console.warn('⚠️ Message from untrusted origin:', event.origin);
        sendLog('⚠️ Expected: ' + TARGET_ORIGIN + ', Got: ' + event.origin);
        // Don't return - still log it for debugging
      }

      sendLog('✅ Message from iframe accepted: ' + JSON.stringify(event.data));
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
    // if (kDebugMode) {
    //   debugPrint('⚠️ DEBUG MODE: Bypassing SSL certificate validation for ${challenge.protectionSpace.host}');
    //   return ServerTrustAuthResponse(
    //     action: ServerTrustAuthResponseAction.PROCEED,
    //   );
    // }
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
            initialData: useDirectLoad
                ? null
                : InAppWebViewInitialData(
                    data: _getWrapperHtml(),
                    baseUrl: WebUri(targetOrigin),
                  ),
            initialUrlRequest:
                useDirectLoad ? URLRequest(url: WebUri(iframeUrl)) : null,
            onWebViewCreated: _handleWebViewCreated,
            onLoadStop: _handleLoadStop,
            onReceivedError: _handleLoadError,
            onReceivedHttpError: _handleLoadHttpError,
            onLoadResourceWithCustomScheme: null,
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              debugPrint(
                  '🔗 Navigation action: ${navigationAction.request.url}');
              return NavigationActionPolicy.ALLOW;
            },
            onReceivedServerTrustAuthRequest: _handleServerTrustAuth,
            onConsoleMessage: (controller, consoleMessage) {
              debugPrint(
                  '🖥️ Console [${consoleMessage.messageLevel}]: ${consoleMessage.message}');
            },
            onLoadStart: (controller, url) {
              debugPrint('🔄 Page started loading: $url');
            },
            onProgressChanged: (controller, progress) {
              debugPrint('📊 Loading progress: $progress%');
              if (progress == 100) {
                debugPrint('✅ WebView reached 100% progress');
              }
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
