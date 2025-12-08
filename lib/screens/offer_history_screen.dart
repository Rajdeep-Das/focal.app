import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class OfferHistoryScreen extends StatefulWidget {
  final String? customToken;

  const OfferHistoryScreen({super.key, this.customToken});

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
    // Only allow HTTPS content (secure mode)
    mixedContentMode: MixedContentMode.MIXED_CONTENT_NEVER_ALLOW,
    // Additional settings for better iframe support
    javaScriptCanOpenWindowsAutomatically: true,
    supportMultipleWindows: false,
    // Cache and loading optimizations
    cacheEnabled: true,
    clearCache: false,
    // DOM storage
    //domStorageEnabled: true,
    //databaseEnabled: true,
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
    // Escape the custom token for safe injection into JavaScript
    final String? escapedToken = widget.customToken?.replaceAll("'", "\\'").replaceAll("\n", "\\n");
    final String tokenInitScript = escapedToken != null
        ? "const CUSTOM_TOKEN = '$escapedToken';"
        : "const CUSTOM_TOKEN = null;";

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
    $tokenInitScript
    const TARGET_ORIGIN = "$targetOrigin";
    const IFRAME_URL = "$iframeUrl";
    const iframe = document.getElementById("writeReviewIframe");
    const debugOverlay = document.getElementById("debugOverlay");
    let debugLogs = [];

    // New implementation to handle READY message from iframe
    let isIframeReady = false;
    let latestToken = CUSTOM_TOKEN; // Use custom token if provided

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

    function sendPayload() {
      if (!iframe.contentWindow) {
        sendLog("❌ iframe.contentWindow not available");
        return;
      }

      const message = {
        apiPayload: [
          {
            iframeType: "offerHistory",
            token: latestToken,
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

      try {
        sendLog("📤 Sending payload to iframe");
        iframe.contentWindow.postMessage(message, TARGET_ORIGIN);
        sendLog("✅ Payload sent successfully");
      } catch (err) {
        sendLog("❌ Error sending payload: " + err.message);
        console.error("Error sending payload:", err);
      }
    }

    async function fetchToken() {
      try {
        sendLog("🔑 Fetching token from API...");
        const response = await fetch(
          "https://devopenapi.offerx.global/GenerateTokenAsync",
          { method: "POST" }
        );
        const data = await response.json();
        latestToken = data?.resultObject?.accessToken;

        if (!latestToken) {
          sendLog("❌ Failed to retrieve token");
          console.error("Failed to retrieve token");
          return;
        }

        sendLog("✅ Token received successfully");

        // If iframe is already ready, send payload immediately
        if (isIframeReady) {
          sendLog("🚀 Iframe already ready, sending payload");
          sendPayload();
        }
      } catch (error) {
        sendLog("❌ Token generation failed: " + error.message);
        console.error("Token generation failed:", error);
      }
    }

    function launchIframe() {
      sendLog("🚀 Loading iframe...");
      // Add cache-busting timestamp like in React Native code
      iframe.src = IFRAME_URL + "?t=" + Date.now();
      sendLog("🌐 iframe URL set: " + iframe.src);

      iframe.onload = function() {
        sendLog("✅ iframe.onload fired - waiting for READY message from iframe");
      };

      iframe.onerror = function(err) {
        sendLog("❌ iframe.onerror fired: " + JSON.stringify(err));
      };
    }

    // New implementation to handle READY message from iframe (similar to React Native code)
    window.addEventListener('message', function(event) {
      sendLog('📥 Received message from origin: ' + event.origin);
      sendLog('📥 Message type: ' + (event.data?.type || 'unknown'));

      if (event.origin !== TARGET_ORIGIN) {
        console.warn('⚠️ Message from untrusted origin:', event.origin);
        sendLog('⚠️ Expected: ' + TARGET_ORIGIN + ', Got: ' + event.origin);
        return;
      }

      // Handle READY message from iframe
      if (event.data?.type === 'READY') {
        sendLog('✅ Received READY message from iframe!');
        isIframeReady = true;

        // Send acknowledgment back to iframe
        event.source.postMessage({ type: 'ACK_PARENT' }, TARGET_ORIGIN);
        sendLog('📤 Sent ACK_PARENT to iframe');

        // If we have token, send payload. Otherwise fetch it first.
        if (latestToken) {
          sendLog('🚀 Token available, sending payload now');
          sendPayload();
        } else {
          sendLog('🔑 Token not available, fetching it first');
          fetchToken();
        }
      } else {
        sendLog('📩 Other message from iframe: ' + JSON.stringify(event.data));
      }
    });

    // Start loading iframe when window loads
    window.onload = function() {
      sendLog("🎬 Window loaded, launching iframe...");
      if (CUSTOM_TOKEN) {
        sendLog("✅ Using custom token from Flutter");
      } else {
        sendLog("🔑 No custom token, will fetch from API when needed");
      }
      launchIframe();
    };

    // Also try immediate start if document is already ready
    if (document.readyState === 'complete' || document.readyState === 'interactive') {
      sendLog("🎬 Document already ready, launching iframe immediately...");
      if (CUSTOM_TOKEN) {
        sendLog("✅ Using custom token from Flutter");
      } else {
        sendLog("🔑 No custom token, will fetch from API when needed");
      }
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
    // Perform proper SSL certificate validation
    debugPrint('🔒 Validating SSL certificate for ${challenge.protectionSpace.host}');

    // Return null to use default system certificate validation
    // This ensures secure connections with valid certificates only
    return null;
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
