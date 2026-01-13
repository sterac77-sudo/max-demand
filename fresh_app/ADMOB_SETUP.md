# AdMob and Subscription Integration - Setup Guide

## Overview
This guide explains how to complete the AdMob and subscription setup for the Max Demand Calculator app.

## What's Been Implemented

### ✅ Code Complete
- AdMob SDK integrated with banner and interstitial ads
- In-app purchase/subscription system
- Premium features logic (hide ads, enable PDF export)
- Banner ad widget displayed at bottom of screen
- Interstitial ads shown every 3rd calculation
- Premium upgrade dialog
- PDF export locked behind premium subscription

### 📋 Configuration Needed

## Step 1: Create AdMob Account and App

1. **Go to AdMob Console**
   - Visit: https://admob.google.com
   - Sign in with your Google account
   - Click "Get Started" if first time

2. **Add Your App**
   - Click "Apps" → "Add App"
   - Select "Yes, it's listed on a supported app store"
   - Enter package name: `au.co.seaspray.maxdemand`
   - Click "Add"

3. **Create Ad Units**
   You need to create TWO ad units:
   
   **Banner Ad:**
   - Go to "Ad units" → "Add ad unit"
   - Select "Banner"
   - Name it "Main Banner"
   - Click "Create ad unit"
   - **Copy the Ad Unit ID** (looks like: ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY)
   
   **Interstitial Ad:**
   - Go to "Ad units" → "Add ad unit"
   - Select "Interstitial"
   - Name it "Calculation Interstitial"
   - Click "Create ad unit"
   - **Copy the Ad Unit ID**

4. **Get App ID**
   - Go to "Apps" → Click your app
   - **Copy the App ID** (looks like: ca-app-pub-XXXXXXXXXXXXXXXX~ZZZZZZZZZZ)

## Step 2: Update Code with Real AdMob IDs

### File 1: `android/app/src/main/AndroidManifest.xml`
Replace the test App ID:
```xml
<!-- Replace this line: -->
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-3940256099942544~3347511713"/>

<!-- With your real App ID: -->
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXXXXXXXXXX~ZZZZZZZZZZ"/>
```

### File 2: `lib/services/ad_manager.dart`
Replace the test ad unit IDs (lines 13-14):
```dart
// Replace these:
static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
static const String interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

// With your real IDs:
static const String bannerAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
static const String interstitialAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
```

## Step 3: Create Subscription Product in Play Console

1. **Go to Play Console**
   - Visit: https://play.google.com/console
   - Select your "Max Demand Calculator" app

2. **Create Subscription**
   - Go to **Monetize** → **Subscriptions**
   - Click **Create subscription**
   - Product ID: `premium_monthly` (must match code!)
   - Name: "Premium Monthly"
   - Description: "Remove ads and unlock PDF exports"
   - Price: $2.99 USD/month
   - Billing period: Monthly
   - Click **Save**

3. **Activate Subscription**
   - After saving, click **Activate** on the subscription

## Step 4: Update Subscription Product ID (if needed)

If you used a different product ID, update it in:

### File: `lib/services/subscription_manager.dart` (line 15)
```dart
static const String premiumSubscriptionId = 'premium_monthly'; // Match Play Console
```

## Step 5: Testing

### Test Ads (Already Configured)
The current code uses Google's test ad IDs, so you can test immediately:
1. Build and install the app on a real Android device
2. Calculations should trigger interstitial ads every 3rd time
3. Banner ad should appear at the bottom of the screen

### Test Subscription
1. **Add Test Account in Play Console**:
   - Go to Play Console → **Setup** → **License testing**
   - Add your Gmail account as a tester
   
2. **Test the Purchase Flow**:
   - Install the app from Internal Testing
   - Try to export PDF → Premium dialog should appear
   - Click "Subscribe" → Google Play dialog appears
   - Test accounts won't be charged

3. **Verify Premium Features**:
   - After "purchasing", ads should disappear
   - PDF export should work without prompt

## Step 6: Deploy New Version

1. **Update Version**:
   Edit `pubspec.yaml`:
   ```yaml
   version: 1.0.0+3  # Increment from +2 to +3
   ```

2. **Build Release AAB**:
   ```bash
   cd fresh_app
   flutter clean
   flutter build appbundle --release
   ```

3. **Upload to Play Console**:
   - Go to **Release** → **Production** (or Testing track)
   - Create new release
   - Upload the AAB from `build/app/outputs/bundle/release/app-release.aab`
   - Add release notes mentioning new features
   - Submit for review

## Features Summary

### Free Version
- ✓ Full calculation functionality
- ✓ Banner ad at bottom of screen
- ✓ Interstitial ad every 3rd calculation
- ✗ PDF export blocked (shows upgrade prompt)

### Premium Version ($2.99/month)
- ✓ Full calculation functionality
- ✓ No ads
- ✓ Unlimited PDF exports
- ✓ Priority support

## Troubleshooting

### "Ads not showing"
- Make sure you're testing on a real device (emulator doesn't show ads)
- Check LogCat for ad errors: `adb logcat | grep -i "ad"`
- Test IDs are currently in use; replace with real IDs for production

### "Subscription not working"
- Verify product ID in Play Console matches code (`premium_monthly`)
- Make sure subscription is activated in Play Console
- Check you're testing with a license testing account
- Real subscriptions only work with signed APK/AAB from Play Store

### "Build errors after adding packages"
- Run `flutter clean` then `flutter pub get`
- Make sure you're building from `fresh_app` directory
- Check that AndroidManifest.xml has the AdMob App ID

## Next Steps

1. ✅ Dependencies installed
2. ✅ Code implemented
3. ⏳ Create AdMob account and get IDs
4. ⏳ Update code with real AdMob IDs
5. ⏳ Create subscription product in Play Console
6. ⏳ Test on real device
7. ⏳ Build and deploy new version

## Support

For issues:
- AdMob: https://support.google.com/admob
- In-app purchases: https://support.google.com/googleplay/android-developer
