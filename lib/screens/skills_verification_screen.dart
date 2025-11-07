import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../models/candidate_model.dart';
import '../services/screenx_api_service.dart';
import 'offer_history_screen.dart';

enum VerificationStatus {
  loading,
  loadingIframe,
  authenticating,
  authenticated,
  sendingCandidateData,
  completed,
  error
}

class SkillsVerificationScreen extends StatefulWidget {
  final CandidateModel candidate;

  const SkillsVerificationScreen({
    super.key,
    required this.candidate,
  });

  @override
  State<SkillsVerificationScreen> createState() =>
      _SkillsVerificationScreenState();
}

class _SkillsVerificationScreenState extends State<SkillsVerificationScreen> {
  static const String iframeUrl =
      'https://demoiframe.screenx.ai/iframe-landing';
  static const String targetOrigin = 'https://demoiframe.screenx.ai';

  InAppWebViewController? _webViewController;
  final ScreenXApiService _apiService = ScreenXApiService();

  VerificationStatus _status = VerificationStatus.loading;
  String _statusMessage = 'Initializing...';
  String? _errorMessage;
  String? _jwtToken;
  bool _isFullscreen = false;

  // InAppWebView settings with fullscreen support
  final InAppWebViewSettings _settings = InAppWebViewSettings(
    javaScriptEnabled: true,
    iframeAllowFullscreen: true, // KEY SETTING for iframe fullscreen!
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    useHybridComposition: true,
    // Allow mixed content for development
    mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
  );

  @override
  void initState() {
    super.initState();
    debugPrint('Initializing WebView with fullscreen support');
  }

  void _handleWebViewCreated(InAppWebViewController controller) {
    _webViewController = controller;
    debugPrint('InAppWebView created with fullscreen iframe support enabled');

    // Add JavaScript handler for Flutter channel communication
    controller.addJavaScriptHandler(
      handlerName: 'FlutterChannel',
      callback: _handleMessageFromIframe,
    );
  }

  void _handleLoadStop(InAppWebViewController controller, WebUri? url) async {
    debugPrint('Page finished loading: $url');
    setState(() {
      _status = VerificationStatus.loadingIframe;
      _statusMessage = 'Waiting for iframe to be ready...';
    });
  }

  void _handleLoadError(InAppWebViewController controller,
      WebResourceRequest request, WebResourceError error) {
    debugPrint('Web resource error: ${error.description}');
    _setError('Failed to load verification page: ${error.description}');
  }

  void _handleEnterFullscreen(InAppWebViewController controller) {
    debugPrint('==== ENTERED FULLSCREEN ====');
    setState(() {
      _isFullscreen = true;
    });

    // Hide system UI for true fullscreen experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Allow all orientations - let the content determine the best orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  void _handleExitFullscreen(InAppWebViewController controller) {
    debugPrint('==== EXITED FULLSCREEN ====');
    setState(() {
      _isFullscreen = false;
    });

    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // Keep all orientations available
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  String _getWrapperHtml() {
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>Skills Verification Integration</title>
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
        #screenxFrame {
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
    <script>
        // Configuration
        const IFRAME_SRC = '$iframeUrl';
        const TARGET_ORIGIN = '$targetOrigin';

        console.log('Initializing ScreenX integration...');
        console.log('Iframe URL:', IFRAME_SRC);
        console.log('Target Origin:', TARGET_ORIGIN);

        // 1. Create and mount the iframe
        const frame = document.createElement('iframe');
        frame.id = 'screenxFrame';
        frame.src = IFRAME_SRC;
        frame.allow = 'camera; microphone; fullscreen; display-capture';
        frame.allowFullscreen = true;
        frame.setAttribute('allowfullscreen', 'true');
        frame.setAttribute('webkitallowfullscreen', 'true');
        frame.setAttribute('mozallowfullscreen', 'true');

        // 2. Set up message handler for iframe communication
        function onMessage(event) {
            // Log ALL messages for debugging
            console.log('=== MESSAGE RECEIVED ===');
            console.log('Origin:', event.origin);
            console.log('Data:', event.data);
            console.log('Full event:', event);

            // Security: Only accept messages from the trusted origin
            if (event.origin !== TARGET_ORIGIN) {
                console.warn('Message from untrusted origin:', event.origin, 'expected:', TARGET_ORIGIN);
                return;
            }

            const { type, payload } = event.data || {};
            console.log('Message type:', type);
            console.log('Payload:', payload);

            // Forward to Flutter using InAppWebView's JavaScript handler
            try {
                const messageStr = JSON.stringify(event.data);
                if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                    window.flutter_inappwebview.callHandler('FlutterChannel', messageStr);
                } else {
                    console.error('Flutter handler not available');
                }
                console.log('Forwarded to Flutter');
            } catch (e) {
                console.error('Error forwarding to Flutter:', e);
            }
        }

        // 3. Function to send messages to iframe (called from Flutter)
        window.sendToIframe = function(message) {
            console.log('Sending to iframe:', message);

            // Check if iframe contentWindow is available
            if (!frame.contentWindow) {
                console.error('Iframe contentWindow not available');
                return;
            }

            try {
                // Don't forward internal Flutter control messages to iframe
                if (message.type === 'fullscreen_success' || message.type === 'fullscreen_exit') {
                    console.log('Internal fullscreen control message, not forwarding to iframe');
                    return;
                }

                // Forward message to iframe
                frame.contentWindow.postMessage(message, TARGET_ORIGIN);
                console.log('Message sent successfully to iframe');
            } catch (e) {
                console.error('Error sending message:', e);
            }
        };

        // 4. Register the message listener
        window.addEventListener('message', onMessage);

        // 5. Wait for iframe to load before appending
        frame.onload = function() {
            console.log('Iframe loaded successfully');
        };

        // 6. Append iframe to body
        document.body.appendChild(frame);

        // 7. Intercept fullscreen requests and notify Flutter
        // WebView doesn't support fullscreen API, so we need to handle it in Flutter
        let fullscreenElement = null;

        const handleFullscreenRequest = (element) => {
            console.log('Fullscreen requested from iframe for element:', element?.tagName || 'unknown');

            // Immediately simulate fullscreen state BEFORE doing anything else
            fullscreenElement = element || frame;

            // Update document properties immediately
            Object.defineProperty(document, 'fullscreenElement', {
                get: () => fullscreenElement,
                configurable: true
            });

            // Dispatch fullscreen change event SYNCHRONOUSLY
            const event = new Event('fullscreenchange');
            document.dispatchEvent(event);
            console.log('Dispatched fullscreenchange event synchronously');

            // Also dispatch on the target element if it exists
            if (element && element.dispatchEvent) {
                try {
                    const elementEvent = new Event('fullscreenchange');
                    element.dispatchEvent(elementEvent);
                    console.log('Dispatched fullscreenchange on target element');
                } catch (e) {
                    console.log('Could not dispatch on element:', e);
                }
            }

            // Notify Flutter to make the WebView fullscreen
            try {
                if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                    window.flutter_inappwebview.callHandler('FlutterChannel', JSON.stringify({
                        type: 'request_fullscreen',
                        payload: {}
                    }));
                    console.log('Sent fullscreen request to Flutter');
                }
            } catch (e) {
                console.error('Error sending fullscreen request to Flutter:', e);
            }
        };

        const exitFullscreen = () => {
            console.log('Exit fullscreen requested');
            fullscreenElement = null;

            Object.defineProperty(document, 'fullscreenElement', {
                get: () => null,
                configurable: true
            });

            const event = new Event('fullscreenchange');
            document.dispatchEvent(event);
        };

        // Override requestFullscreen for all elements
        const originalRequestFullscreen = HTMLElement.prototype.requestFullscreen;
        HTMLElement.prototype.requestFullscreen = function() {
            console.log('requestFullscreen called on element:', this.tagName);
            handleFullscreenRequest(this);

            // Return a promise that resolves after ensuring state is set
            // Use queueMicrotask to let events propagate first
            return new Promise((resolve) => {
                queueMicrotask(() => {
                    console.log('requestFullscreen promise resolving');
                    console.log('Current fullscreenElement:', document.fullscreenElement);
                    resolve();
                });
            });
        };

        // Also override webkit and moz variants
        if (HTMLElement.prototype.webkitRequestFullscreen) {
            const originalWebkit = HTMLElement.prototype.webkitRequestFullscreen;
            HTMLElement.prototype.webkitRequestFullscreen = function() {
                console.log('webkitRequestFullscreen called');
                handleFullscreenRequest(this);
                return new Promise((resolve) => {
                    queueMicrotask(() => {
                        console.log('webkitRequestFullscreen promise resolving');
                        resolve();
                    });
                });
            };
        }
        if (HTMLElement.prototype.mozRequestFullScreen) {
            const originalMoz = HTMLElement.prototype.mozRequestFullScreen;
            HTMLElement.prototype.mozRequestFullScreen = function() {
                console.log('mozRequestFullScreen called');
                handleFullscreenRequest(this);
                return new Promise((resolve) => {
                    queueMicrotask(() => {
                        console.log('mozRequestFullScreen promise resolving');
                        resolve();
                    });
                });
            };
        }

        // Override exitFullscreen
        if (document.exitFullscreen) {
            const originalExit = document.exitFullscreen;
            document.exitFullscreen = function() {
                console.log('exitFullscreen called');
                exitFullscreen();
                return Promise.resolve();
            };
        }

        // Make fullscreen API appear fully supported
        Object.defineProperty(document, 'fullscreenEnabled', {
            get: () => true,
            configurable: true
        });

        // Also set webkit and moz variants
        Object.defineProperty(document, 'webkitFullscreenEnabled', {
            get: () => true,
            configurable: true
        });

        Object.defineProperty(document, 'mozFullScreenEnabled', {
            get: () => true,
            configurable: true
        });

        // Initial state - not in fullscreen
        Object.defineProperty(document, 'fullscreenElement', {
            get: () => fullscreenElement,
            configurable: true
        });

        // Also set webkit and moz variants for fullscreen element
        Object.defineProperty(document, 'webkitFullscreenElement', {
            get: () => fullscreenElement,
            configurable: true
        });

        Object.defineProperty(document, 'mozFullScreenElement', {
            get: () => fullscreenElement,
            configurable: true
        });

        // Log initial state
        console.log('Fullscreen API initialized');
        console.log('fullscreenEnabled:', document.fullscreenEnabled);
        console.log('fullscreenElement:', document.fullscreenElement);

        // Cleanup on page unload
        window.addEventListener('beforeunload', () => {
            window.removeEventListener('message', onMessage);
        });

        console.log('Waiting for iframe to load...');
    </script>
</body>
</html>
    ''';
  }

  void _handleMessageFromIframe(List<dynamic> args) {
    if (args.isEmpty) return;

    final messageStr = args[0].toString();
    debugPrint('=== RECEIVED MESSAGE FROM IFRAME ===');
    debugPrint('Raw message: $messageStr');

    try {
      final data = jsonDecode(messageStr);
      final messageType = data['type'] as String?;
      final payload = data['payload'];

      debugPrint('Message type: $messageType');
      debugPrint('Payload: $payload');
      debugPrint('Current fullscreen state: $_isFullscreen');

      if (messageType == null) {
        debugPrint('ERROR: Message type is null');
        return;
      }

      // Origin validation is already done in the wrapper HTML
      // before the message is forwarded to Flutter

      switch (messageType) {
        case 'iframe_ready':
          _handleIframeReady();
          break;
        case 'iframe_loaded':
          _handleIframeLoaded();
          break;
        case 'auth_success':
          _handleAuthSuccess();
          break;
        case 'auth_error':
          _handleAuthError(data);
          break;
        case 'verification_complete':
          _handleVerificationComplete(data);
          break;
        case 'assessment_resumed':
          _handleAssessmentResumed(data);
          break;
        case 'fullscreen_error':
          _handleFullscreenError(data);
          break;
        case 'request_fullscreen':
          _handleFullscreenRequest();
          break;
        case 'fullscreen_change':
          // Handle fullscreen state changes from iframe
          final payload = data['payload'] as Map<String, dynamic>?;
          final isFullscreen = payload?['isFullscreen'] as bool? ?? false;
          debugPrint('Fullscreen change from iframe: $isFullscreen');
          if (isFullscreen && !_isFullscreen) {
            _handleFullscreenRequest();
          } else if (!isFullscreen && _isFullscreen) {
            _exitFullscreen();
          }
          break;
        default:
          debugPrint('Unknown message type: $messageType');
          debugPrint('Full message data: ${jsonEncode(data)}');
      }
    } catch (e) {
      debugPrint('Error parsing message: $e');
    }
  }

  void _handleIframeReady() {
    debugPrint('Iframe is ready, sending load_iframe message');
    setState(() {
      _status = VerificationStatus.loadingIframe;
      _statusMessage = 'Loading verification interface...';
    });

    // Just send load_iframe, don't fetch token yet
    Future.delayed(const Duration(milliseconds: 100), () {
      _postMessageToIframe({'type': 'load_iframe'});
    });
  }

  void _handleIframeLoaded() {
    debugPrint('Iframe loaded, now authenticating...');
    setState(() {
      _status = VerificationStatus.loadingIframe;
      _statusMessage = 'Iframe loaded, waiting for authentication...';
    });

    // Now fetch JWT token and initialize
    _fetchTokenAndInitialize();
  }

  Future<void> _fetchTokenAndInitialize() async {
    setState(() {
      _status = VerificationStatus.authenticating;
      _statusMessage = 'Authenticating...';
    });

    try {
      _jwtToken = await _apiService.fetchJwtToken();
      debugPrint(
          'JWT Token fetched successfully: ${_jwtToken?.substring(0, 20)}...');

      // Send initialize message with authorization headers
      // Add flags to disable fullscreen requirement
      final initMessage = {
        'type': 'initialize',
        'headers': {
          'Authorization': 'Bearer $_jwtToken',
          'X-Trigger-Type': 'skill_verification',
        },
        'config': {
          'fullscreenEnabled': false,
          'skipFullscreen': true,
          'embedded': true,
          'platform': 'mobile',
          'disableFullscreen': true,
        },
      };

      debugPrint('Sending initialize message: ${jsonEncode(initMessage)}');
      _postMessageToIframe(initMessage);
    } catch (e) {
      _setError('Authentication failed: $e');
    }
  }

  void _handleAuthSuccess() {
    debugPrint('Authentication successful, sending candidate data');
    setState(() {
      _status = VerificationStatus.authenticated;
      _statusMessage = 'Authenticated successfully';
    });

    // Send candidate data
    _sendCandidateData();
  }

  void _sendCandidateData() {
    setState(() {
      _status = VerificationStatus.sendingCandidateData;
      _statusMessage = 'Loading candidate information...';
    });

    _postMessageToIframe({
      'type': 'candidate_data',
      'payload': widget.candidate.toJson(),
    });

    // After sending candidate data, mark as completed
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _status = VerificationStatus.completed;
          _statusMessage = 'Verification in progress';
        });
      }
    });
  }

  void _handleAuthError(Map<String, dynamic> data) {
    final errorMessage = data['message'] as String? ?? 'Authentication failed';
    _setError(errorMessage);
  }

  void _handleVerificationComplete(Map<String, dynamic> data) {
    debugPrint('Verification complete: $data');
    // You can handle the verification result here
    // For example, navigate back or show a success message
  }

  DateTime? _lastAssessmentResumed;
  DateTime? _lastFullscreenError;
  int _fullscreenErrorCount = 0;

  void _handleAssessmentResumed(Map<String, dynamic> data) {
    debugPrint('Assessment resumed: ${jsonEncode(data)}');
    debugPrint('Current fullscreen state: $_isFullscreen');

    // Throttle - only handle once per 2 seconds to prevent infinite loops
    final now = DateTime.now();
    if (_lastAssessmentResumed != null &&
        now.difference(_lastAssessmentResumed!).inSeconds < 2) {
      debugPrint('Ignoring assessment_resumed - throttled');
      return;
    }
    _lastAssessmentResumed = now;

    // The assessment is trying to resume/start
    // If we're not in fullscreen yet, activate it
    if (!_isFullscreen) {
      debugPrint('Assessment resumed but not in fullscreen - activating fullscreen');
      _handleFullscreenRequest();
    } else {
      debugPrint('Assessment resumed and already in fullscreen - continuing');
    }

    // Don't acknowledge - let the iframe continue on its own
    // The acknowledgment might be causing it to retry
    debugPrint('Not sending acknowledgment - letting iframe proceed');
  }

  void _handleFullscreenError(Map<String, dynamic> data) {
    final now = DateTime.now();

    // Track error count
    if (_lastFullscreenError == null ||
        now.difference(_lastFullscreenError!).inSeconds > 5) {
      _fullscreenErrorCount = 0;
    }
    _lastFullscreenError = now;
    _fullscreenErrorCount++;

    debugPrint(
        'Fullscreen error #$_fullscreenErrorCount received from iframe: ${jsonEncode(data)}');

    // If we've seen too many errors, stop trying - the iframe might not support our approach
    if (_fullscreenErrorCount > 3) {
      debugPrint(
          'Too many fullscreen errors - iframe may not be compatible with Flutter WebView');
      debugPrint('Stopping fullscreen attempts to prevent infinite loop');
      return;
    }

    // If we're already in fullscreen mode, tell iframe to continue without checking fullscreen
    if (_isFullscreen) {
      debugPrint('Already in fullscreen mode - telling iframe to proceed');
      _tellIframeToProceed();
      return;
    }

    debugPrint('Not in fullscreen yet - handling error by activating fullscreen');
    // The iframe tried to use native fullscreen API and failed
    // We'll handle it at the Flutter level instead
    _handleFullscreenRequest();
  }

  void _tellIframeToProceed() {
    if (_webViewController == null) return;

    debugPrint('Telling iframe to proceed with assessment');

    // Try sending different messages that might tell the iframe to continue
    final script = '''
      (function() {
        try {
          const frame = document.getElementById('screenxFrame');
          if (!frame || !frame.contentWindow) {
            console.error('Could not find iframe');
            return;
          }

          const targetOrigin = '$targetOrigin';

          // Send multiple messages to try to get the iframe to proceed
          const messages = [
            { type: 'fullscreen_bypass', payload: { proceed: true } },
            { type: 'continue_assessment' },
            { type: 'skip_fullscreen' },
            { type: 'fullscreen_not_required' },
            { type: 'proceed_without_fullscreen' },
          ];

          messages.forEach(message => {
            frame.contentWindow.postMessage(message, targetOrigin);
            console.log('Sent message to iframe:', JSON.stringify(message));
          });

        } catch (e) {
          console.error('Error sending messages to iframe:', e);
        }
      })();
    ''';

    _webViewController!.evaluateJavascript(source: script);
  }

  void _handleFullscreenRequest() {
    debugPrint('Fullscreen requested by iframe');

    if (!mounted) return;

    setState(() {
      _isFullscreen = true;
    });

    debugPrint('Fullscreen mode activated at Flutter level');

    // Wait for UI to update, then notify iframe that fullscreen is active
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyIframeFullscreenActive();
    });
  }

  void _notifyIframeFullscreenActive() {
    if (_webViewController == null) return;

    debugPrint('Notifying iframe that fullscreen is active');

    // Send multiple messages to the iframe to tell it fullscreen succeeded
    // Try different message formats in case the iframe expects specific ones
    final script = '''
      (function() {
        try {
          const frame = document.getElementById('screenxFrame');
          if (!frame || !frame.contentWindow) {
            console.error('Could not find iframe to send message');
            return;
          }

          const targetOrigin = '$targetOrigin';

          // Try multiple message types that the iframe might be listening for
          const messages = [
            { type: 'fullscreen_active', payload: { isFullscreen: true } },
            { type: 'fullscreen_success', payload: { isFullscreen: true } },
            { type: 'fullscreen_change', payload: { isFullscreen: true } },
            { type: 'fullscreen_enabled' },
          ];

          messages.forEach(message => {
            frame.contentWindow.postMessage(message, targetOrigin);
            console.log('Sent message to iframe:', JSON.stringify(message));
          });

          // Log current fullscreen state
          console.log('=== FULLSCREEN STATE ===');
          console.log('Wrapper fullscreenElement:', document.fullscreenElement);
          console.log('Wrapper fullscreenEnabled:', document.fullscreenEnabled);
          console.log('Frame element:', frame);

        } catch (e) {
          console.error('Error notifying iframe:', e);
        }
      })();
    ''';

    _webViewController!.evaluateJavascript(source: script);
  }

  void _exitFullscreen() {
    debugPrint('Exiting fullscreen mode');

    if (!mounted) return;

    setState(() {
      _isFullscreen = false;
    });

    if (_webViewController != null) {
      // Trigger the wrapper to exit fullscreen and dispatch events
      final script = '''
        (function() {
          try {
            if (typeof document.exitFullscreen === 'function') {
              document.exitFullscreen();
              console.log('Called exitFullscreen from Flutter');
            }
          } catch (e) {
            console.error('Error calling exitFullscreen:', e);
          }
        })();
      ''';
      _webViewController!.evaluateJavascript(source: script);
    }

    debugPrint('Fullscreen mode exited at Flutter level');
  }

  void _postMessageToIframe(Map<String, dynamic> message) {
    if (_webViewController == null) {
      debugPrint('WebView controller not ready yet');
      return;
    }

    final messageJson = jsonEncode(message);
    debugPrint('=== SENDING MESSAGE TO IFRAME ===');
    debugPrint('Message type: ${message['type']}');
    debugPrint('Full message: $messageJson');

    // Use the sendToIframe function from our wrapper HTML
    final script = '''
      (function() {
        try {
          if (typeof window.sendToIframe === 'function') {
            window.sendToIframe($messageJson);
            console.log("Message sent via sendToIframe:", $messageJson);
          } else {
            console.error("sendToIframe function not available yet");
          }
        } catch (e) {
          console.error("Error calling sendToIframe:", e);
        }
      })();
    ''';

    _webViewController!.evaluateJavascript(source: script);
  }

  void _setError(String error) {
    setState(() {
      _status = VerificationStatus.error;
      _errorMessage = error;
      _statusMessage = 'Error occurred';
    });
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

  Color _getStatusColor() {
    switch (_status) {
      case VerificationStatus.loading:
      case VerificationStatus.loadingIframe:
      case VerificationStatus.authenticating:
      case VerificationStatus.sendingCandidateData:
        return Colors.orange;
      case VerificationStatus.authenticated:
      case VerificationStatus.completed:
        return Colors.green;
      case VerificationStatus.error:
        return Colors.red;
    }
  }

  IconData _getStatusIcon() {
    switch (_status) {
      case VerificationStatus.loading:
      case VerificationStatus.loadingIframe:
      case VerificationStatus.authenticating:
      case VerificationStatus.sendingCandidateData:
        return Icons.hourglass_empty;
      case VerificationStatus.authenticated:
      case VerificationStatus.completed:
        return Icons.check_circle;
      case VerificationStatus.error:
        return Icons.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build the WebView widget
    final webView = _status == VerificationStatus.error
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Verification Failed',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage ?? 'An error occurred',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _status = VerificationStatus.loading;
                        _errorMessage = null;
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          )
        : InAppWebView(
            initialSettings: _settings,
            initialData: InAppWebViewInitialData(
              data: _getWrapperHtml(),
              baseUrl: WebUri('https://demoiframe.screenx.ai'),
            ),
            onWebViewCreated: _handleWebViewCreated,
            onLoadStop: _handleLoadStop,
            onReceivedError: _handleLoadError,
            onReceivedServerTrustAuthRequest: _handleServerTrustAuth,
            onEnterFullscreen: _handleEnterFullscreen,
            onExitFullscreen: _handleExitFullscreen,
            onConsoleMessage: (controller, consoleMessage) {
              debugPrint('Console: ${consoleMessage.message}');
            },
            onLoadStart: (controller, url) {
              debugPrint('Page started loading: $url');
            },
          );

    // In fullscreen mode, return just the WebView without any UI chrome
    if (_isFullscreen) {
      return Scaffold(
        body: webView,
      );
    }

    // Normal mode with AppBar and status indicator
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skills Verification'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Show Offer History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OfferHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Status indicator
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.1),
              border: Border(
                bottom: BorderSide(
                  color: _getStatusColor(),
                  width: 2,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getStatusIcon(),
                  color: _getStatusColor(),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _statusMessage,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(),
                        ),
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (_status == VerificationStatus.loading ||
                    _status == VerificationStatus.loadingIframe ||
                    _status == VerificationStatus.authenticating ||
                    _status == VerificationStatus.sendingCandidateData)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getStatusColor(),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // WebView
          Expanded(
            child: webView,
          ),
        ],
      ),
    );
  }
}
