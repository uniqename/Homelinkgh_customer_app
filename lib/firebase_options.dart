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
    apiKey: 'AIzaSyBsjIkZWvsGtttkUGdePRcuhMLeovfr9LE',
    appId: '1:762633102960:web:homelinkgh-app',
    messagingSenderId: '762633102960',
    projectId: 'homelinkgh-app',
    authDomain: 'homelinkgh-app.firebaseapp.com',
    storageBucket: 'homelinkgh-app.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBfl6Z101buiUpfXYq7i0wrN9q3r1kYB4Y',
    appId: '1:762633102960:android:653dd01a77e55cf94af6b5',
    messagingSenderId: '762633102960',
    projectId: 'homelinkgh-app',
    storageBucket: 'homelinkgh-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBsjIkZWvsGtttkUGdePRcuhMLeovfr9LE',
    appId: '1:762633102960:ios:ab3dbea50d3479934af6b5',
    messagingSenderId: '762633102960',
    projectId: 'homelinkgh-app',
    storageBucket: 'homelinkgh-app.firebasestorage.app',
    iosBundleId: 'com.homelink.provider.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBsjIkZWvsGtttkUGdePRcuhMLeovfr9LE',
    appId: '1:762633102960:ios:ab3dbea50d3479934af6b5',
    messagingSenderId: '762633102960',
    projectId: 'homelinkgh-app',
    storageBucket: 'homelinkgh-app.firebasestorage.app',
    iosBundleId: 'com.homelink.provider.app',
  );
}
