import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'your-web-api-key',
    appId: 'your-web-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'ngo-support-app',
    authDomain: 'ngo-support-app.firebaseapp.com',
    storageBucket: 'ngo-support-app.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDemo-Key-For-Testing-Only-Not-Real',
    appId: '1:123456789:android:demo-app-id',
    messagingSenderId: '123456789',
    projectId: 'beacon-new-beginnings-demo',
    storageBucket: 'beacon-new-beginnings-demo.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'your-ios-api-key',
    appId: 'your-ios-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'ngo-support-app',
    storageBucket: 'ngo-support-app.appspot.com',
    iosBundleId: 'com.beaconnewbeginnings.ngo-support-app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'your-macos-api-key',
    appId: 'your-macos-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'ngo-support-app',
    storageBucket: 'ngo-support-app.appspot.com',
    iosBundleId: 'com.beaconnewbeginnings.ngo-support-app',
  );
}