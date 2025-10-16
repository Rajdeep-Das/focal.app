# ScreenX Skills Verification Integration

## Overview
This document describes the ScreenX skills verification integration in the Flutter app.

## Configuration

### URLs
- **Iframe URL:** `https://demoiframe.screenx.ai/iframe-landing`
- **Target Origin:** `https://demoiframe.screenx.ai`

### Token
The JWT token is currently hardcoded for testing:
```
lmTFyN8EmdRq2Sv3JSsgmVLQbXUgYuwb+ff5wHa3C6Hr4KLn/O7SFEhrfyABlMZ0KWqcSmjqn3q8bFvlAeERVtemFzCKdiO9tKNUwu4zNX9RX3lfyuEBRmcyitdArEEZcKsK0yAkVz9S1em+B/bg0qjMngFfSVi91kToKoM3kvpXeqlDqW2Zt6fT9P7QsNWPexBXT2pA0skkipMJLpm00PpHGg2RHi4PI4RD4nfsdjxbNseoKecuHBL8TslGQJTRZ42GZAa55k+IUKliw23LyaYjaEjuMAoiF8iIlf4TG3VydYYtjihHYBU1dpYVVmAMOBu4QGmEH4H48oDj0nl2JICeHTNNR0mUwKBpkKO4TEnpUNhxyak7dOW7RRHENQjuHt1zQLqK/PgzIR1rpHK3vK04KGilsXiGWN8i0lnAZNv7OODOLvTwPL0uNBu9yFpXZVJNGV2sfErm8SuB7Rg9+/h2i4S548qy868U5t5hnc2MHDRxEnAcZ/WkftHtkTKy+zixN0aKhiF6CGUesY85jBRnpz0cGIPEmfhaFwakRHzptzmajiDEqJOFoUYFnS1mkkupwIz5W/qNdqewq6AIcQ==
```

**Location:** `lib/services/screenx_api_service.dart:9`

## Message Flow

The integration follows this exact message sequence:

```
1. iframe_ready (from iframe)
   ↓
   Parent sends: load_iframe

2. iframe_loaded (from iframe)
   ↓
   Parent fetches JWT token
   ↓
   Parent sends: initialize + headers (Authorization, X-Trigger-Type)

3. auth_success (from iframe)
   ↓
   Parent sends: candidate_data + payload

4. Verification begins in iframe
```

## File Structure

### Core Files
- `lib/models/candidate_model.dart` - Candidate data model
- `lib/services/screenx_api_service.dart` - Token fetching service
- `lib/screens/skills_verification_screen.dart` - Main verification screen with WebView
- `lib/screens/candidate_profile_screen.dart` - Profile page with "Skills Unverified" button

### Navigation
Access via shield icon (🛡️) in the home screen app bar.

## Testing

### Run the App
```bash
flutter run
```

### Test HTML File
A standalone test file is available at:
```
/Users/rajdeepdas/Development/projects/focal/focal_timer/test_iframe.html
```

Open it in a browser to test the iframe integration without Flutter.

## Production Deployment

### Required Changes

1. **Update Token Endpoint**
   - File: `lib/services/screenx_api_service.dart:15-47`
   - Uncomment the API call code
   - Remove the hardcoded token
   - Update `_tokenEndpoint` to your backend API

2. **Replace Example Candidate Data**
   - File: `lib/screens/home_screen.dart:46`
   - Replace `CandidateModel.example` with actual candidate data

3. **Backend API Setup**
   Your backend should call:
   ```
   POST https://demoopenapi.screenx.ai/api/v1/Auth/generate-token
   ```

## Debugging

### Enable WebView Debugging
WebView debugging is automatically enabled in the app.

### View Console Logs
- **Android:** Chrome → `chrome://inspect`
- **iOS:** Safari → Develop → [Your Device] → [Your App]

### Debug Messages
The app logs all message exchanges:
- "Received message from iframe: {type}"
- "Sending to iframe: {message}"
- "JWT Token fetched successfully"

## Security Features

✅ Origin validation (only accepts messages from `https://demoiframe.screenx.ai`)
✅ Uses specific targetOrigin (never "*")
✅ JWT token fetched from backend (in production)
✅ Proper postMessage implementation

## Troubleshooting

### "API key was not provided"
- Check that iframe URL is `https://demoiframe.screenx.ai` (not `demoopenapi`)
- Verify token is being sent in initialize message
- Check console logs for message flow

### Iframe not loading
- Verify internet connection
- Check WebView permissions
- Review error logs in console

### Authentication fails
- Verify token is valid
- Check token format: `Bearer <token>`
- Ensure `X-Trigger-Type: skill_verification` header is present

## Support
For issues with the ScreenX API, contact ScreenX support.
For Flutter integration issues, check the console logs and error messages.
