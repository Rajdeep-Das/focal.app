# Iframe Loading Issue - Debug Guide

## Current Status
Based on the logs, here's what we know:

### ✅ What's Working
1. WebView loads successfully
2. Wrapper HTML loads (100% progress)
3. iframe.onload fires
4. postMessage is sent successfully
5. No network errors

### ❌ The Problem
The iframe at `https://dev-offerhistory.offerx.in` **loads but shows a blank/loading screen**.

This is **NOT a Flutter issue** - it's an issue with the iframe website itself.

## Root Cause Analysis

The iframe website is likely:

1. **Waiting for a response** to the postMessage that never comes
2. **Not designed for mobile WebView** - might have mobile-specific issues
3. **Using features not available** in Android WebView (e.g., certain APIs)
4. **Checking user agent** and blocking mobile WebViews
5. **Has rendering issues** specific to the nested iframe context

## Debugging Steps

### Step 1: Use the Debug Button
The app now has a "Show Debug" button in the top right. Tap it to see real-time logs of:
- When the iframe loads
- When postMessages are sent/received
- Any errors or status updates

### Step 2: Test Direct Load
Change line 24 in `offer_history_screen.dart`:
```dart
static const bool useDirectLoad = true;  // Changed from false
```

This will load the URL directly without the wrapper. If it works:
- Problem is with the wrapper approach
- Need to modify how postMessage is sent

If it still doesn't work:
- The website itself has issues with mobile WebView
- Contact the backend team

### Step 3: Check Network Tab
Run `flutter run -v` and look for:
- Any failed HTTP requests (status 4xx or 5xx)
- Blocked resources (CSP violations)
- CORS errors

### Step 4: Inspect the Iframe Response
The iframe might be expecting a specific response. Check the console for messages like:
- "📥 Received message from origin"
- This would indicate the iframe IS responding

## Possible Solutions

### Solution 1: Increase postMessage Delay
The iframe might not be ready when we send the postMessage. Try increasing the delay:

In `offer_history_screen.dart` around line 250, change:
```javascript
setTimeout(() => {
  iframe.src = IFRAME_URL;
  // ...
}, 50);  // Try changing to 500 or 1000
```

### Solution 2: Send postMessage Multiple Times
The iframe might miss the first postMessage. Modify `generateAsyncToken()` to retry:

```javascript
function generateAsyncToken() {
  try {
    const message = { /* ... */ };
    sendLog(JSON.stringify(message));

    // Send immediately
    safePostMessage(message, TARGET_ORIGIN);

    // Retry after delays
    setTimeout(() => safePostMessage(message, TARGET_ORIGIN), 500);
    setTimeout(() => safePostMessage(message, TARGET_ORIGIN), 1000);
    setTimeout(() => safePostMessage(message, TARGET_ORIGIN), 2000);
  } catch (err) {
    sendLog("Error: " + err);
  }
}
```

### Solution 3: Check User Agent
The iframe might be blocking mobile browsers. Add this to see the user agent:

```dart
onWebViewCreated: (controller) async {
  final ua = await controller.evaluateJavascript(source: "navigator.userAgent");
  debugPrint("User Agent: $ua");
  // ... rest of the code
}
```

### Solution 4: Contact Backend Team
If none of the above work, the issue is likely server-side. Ask the backend team:

1. Does the iframe work in mobile Chrome browser?
2. Are there any user-agent restrictions?
3. Does the iframe require specific headers or cookies?
4. Can they check server logs for this URL when accessed from mobile?
5. Is there a mobile-specific version of this page?

## Test in Mobile Chrome
To verify it's not a Flutter issue:

1. Open Chrome on Android
2. Navigate to `https://dev-offerhistory.offerx.in`
3. Does it load correctly?

If NO: The website has mobile compatibility issues
If YES: There might be WebView-specific issues

## Next Steps
1. ✅ Added debug overlay - Check what it shows
2. Test direct load (change `useDirectLoad` to true)
3. Test in mobile Chrome browser
4. If still not working, contact backend team with logs
