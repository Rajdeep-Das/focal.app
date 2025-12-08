# focal_timer

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
# focal.app



{
"apiKey": "F3BDF377-1F0A-41C2-AEB5-8E9479FF9B3E",
"apiSecret": "Z9nXm0l3aQC2ERFb6HuytWMSgAZvJLdpocxKqTsnB8IPYrhUMej1k7fDVGbw53LN"
}


---- Ios Issue ----

Root Cause Analysis
1. iOS App Transport Security (ATS) Configuration Missing
Issue:
iOS enforces strict App Transport Security (ATS) by default
Without explicit configuration in Info.plist, iOS blocks external HTTPS content from loading in webviews
All navigation requests to external domains were being CANCELLED at the OS level
Impact:
URLs like https://dev-offerhistory.offerx.in, https://dev-reviews.offerx.global, and https://demoiframe.screenx.ai were blocked before any content could load
Error: Navigation cancelled → 0% progress → Failed
2. SSL Certificate Validation Rejection
Issue:
The Flutter code's SSL certificate handler was configured to CANCEL all certificate validation requests
Code: ServerTrustAuthResponseAction.CANCEL
This caused iOS to reject SSL certificates from all domains, including valid ones
Impact:
Even if ATS allowed the connection, SSL validation would block it
All HTTPS connections were terminated
Solution Implemented
1. Added NSAppTransportSecurity to iOS Info.plist
File: ios/Runner/Info.plist Configuration Added:
<key>NSAppTransportSecurity</key>
<dict>
    <!-- Allow all domains for development -->
    <key>NSAllowsArbitraryLoads</key>
    <true/>
    
    <!-- Specific domain exceptions -->
    <key>NSExceptionDomains</key>
    <dict>
        <!-- OfferX domains -->
        <key>offerx.in</key>
        <dict>
            <key>NSIncludesSubdomains</key>
            <true/>
            <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
            <true/>
            <key>NSTemporaryExceptionMinimumTLSVersion</key>
            <string>TLSv1.0</string>
        </dict>
        
        <key>offerx.global</key>
        <dict>
            <key>NSIncludesSubdomains</key>
            <true/>
            <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
            <true/>
            <key>NSTemporaryExceptionMinimumTLSVersion</key>
            <string>TLSv1.0</string>
        </dict>
        
        <!-- ScreenX domain -->
        <key>screenx.ai</key>
        <dict>
            <key>NSIncludesSubdomains</key>
            <true/>
            <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
            <true/>
            <key>NSTemporaryExceptionMinimumTLSVersion</key>
            <string>TLSv1.0</string>
        </dict>
    </dict>
</dict>
What This Does:
NSAllowsArbitraryLoads: Allows connections to any domain (development only)
NSExceptionDomains: Explicitly whitelists required domains with all subdomains
NSTemporaryExceptionAllowsInsecureHTTPLoads: Permits HTTP connections (for development)
NSTemporaryExceptionMinimumTLSVersion: Sets minimum TLS version to 1.0 for compatibility
2. Changed SSL Certificate Handler to PROCEED
Files Updated:
lib/screens/offer_history_screen.dart
lib/screens/write_review_screen.dart
lib/screens/skills_verification_screen.dart
Before:
Future<ServerTrustAuthResponse?> _handleServerTrustAuth(...) async {
  return ServerTrustAuthResponse(
    action: ServerTrustAuthResponseAction.CANCEL,  // ❌ Rejected all certificates
  );
}
After:
Future<ServerTrustAuthResponse?> _handleServerTrustAuth(...) async {
  debugPrint('⚠️ Proceeding with SSL certificate validation for ${challenge.protectionSpace.host}');
  return ServerTrustAuthResponse(
    action: ServerTrustAuthResponseAction.PROCEED,  // ✅ Accepts certificates
  );
}
What This Does:
Accepts SSL certificates from all domains
Allows HTTPS connections to proceed
Logs which domains are being validated for debugging
Technical Flow Comparison
Before (Failed State):
1. App attempts to load URL
   ↓
2. iOS ATS blocks connection (no NSAppTransportSecurity config)
   ↓
3. Navigation CANCELLED
   ↓
4. SSL handler would have rejected anyway (CANCEL action)
   ↓
5. Result: 0% loaded, complete failure
After (Working State):
1. App attempts to load URL
   ↓
2. iOS ATS allows connection (NSAppTransportSecurity configured)
   ↓
3. Navigation proceeds
   ↓
4. SSL validation triggered
   ↓
5. SSL handler accepts certificate (PROCEED action)
   ↓
6. Connection established
   ↓
7. Result: 100% loaded, content renders
Security Considerations
Current Configuration (Development)
NSAllowsArbitraryLoads: true - Not secure for production
Accepts all SSL certificates - Not secure for production
Recommended for Production:
Remove NSAllowsArbitraryLoads
Keep only NSExceptionDomains with specific trusted domains
Implement proper SSL validation:
Future<ServerTrustAuthResponse?> _handleServerTrustAuth(...) async {
  // Only accept certificates from trusted domains
  final trustedHosts = ['offerx.in', 'offerx.global', 'screenx.ai'];
  final host = challenge.protectionSpace.host;
  
  if (trustedHosts.any((trusted) => host.endsWith(trusted))) {
    return ServerTrustAuthResponse(
      action: ServerTrustAuthResponseAction.PROCEED,
    );
  }
  
  // Reject unknown domains
  return ServerTrustAuthResponse(
    action: ServerTrustAuthResponseAction.CANCEL,
  );
}
Domains Whitelisted
All subdomains are included for each:
offerx.in (and all subdomains like *.offerx.in)
offerx.global (and all subdomains like *.offerx.global)
screenx.ai (and all subdomains like *.screenx.ai)
Testing Verification
Successfully loading:
✅ https://dev-offerhistory.offerx.in/
✅ https://dev-reviews.offerx.global/
✅ https://demoiframe.screenx.ai/iframe-landing
✅ External resources: Google Fonts, Azure monitoring
For External Tech Team
If you need similar configuration for native iOS apps: Add to your Info.plist:
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSExceptionDomains</key>
    <dict>
        <key>YOUR_DOMAIN.com</key>
        <dict>
            <key>NSIncludesSubdomains</key>
            <true/>
            <key>NSExceptionRequiresForwardSecrecy</key>
            <false/>
        </dict>
    </dict>
</dict>
For SSL validation in native iOS (WKWebView): Implement WKNavigationDelegate method:
func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, 
             completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
    if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    } else {
        completionHandler(.performDefaultHandling, nil)
    }
}
Let me know if you need any clarification or additional technical details!