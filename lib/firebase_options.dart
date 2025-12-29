import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:lucky_parcel/common/constants/api_keys.dart';

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: ApiKeys.firebaseWebAppKey,
    appId: '1:1061558079901:web:873e3bb974b1d7aeb0df74',
    messagingSenderId: '1061558079901',
    projectId: 'parcel-1594',
    authDomain: 'parcel-1594.firebaseapp.com',
    storageBucket: 'parcel-1594.firebasestorage.app',
    measurementId: 'G-FJNHZZEKQP',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: ApiKeys.firebaseAndroidAppKey,
    appId: '1:1061558079901:android:03295dc97c5018b9b0df74',
    messagingSenderId: '1061558079901',
    projectId: 'parcel-1594',
    storageBucket: 'parcel-1594.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: ApiKeys.firebaseIosAppKey,
    appId: '1:1061558079901:ios:918f608e7d062efcb0df74',
    messagingSenderId: '1061558079901',
    projectId: 'parcel-1594',
    storageBucket: 'parcel-1594.firebasestorage.app',
    iosBundleId: 'com.example.parcel',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: ApiKeys.firebaseMacosAppKey,
    appId: '1:1061558079901:ios:918f608e7d062efcb0df74',
    messagingSenderId: '1061558079901',
    projectId: 'parcel-1594',
    storageBucket: 'parcel-1594.firebasestorage.app',
    iosBundleId: 'com.example.parcel',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: ApiKeys.firebaseWindowsAppKey,
    appId: '1:1061558079901:web:c08f21e61a9a9a07b0df74',
    messagingSenderId: '1061558079901',
    projectId: 'parcel-1594',
    authDomain: 'parcel-1594.firebaseapp.com',
    storageBucket: 'parcel-1594.firebasestorage.app',
    measurementId: 'G-V5R2QX6G1J',
  );
}
