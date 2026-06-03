// File manually generated using Firebase configuration from google-services.json
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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyACPgTn3M3aSVNNEDrCVc28JN0ozsW88vQ',
    appId: '1:537535855427:web:eb3f5a11c84bdc1fc4df6',
    messagingSenderId: '537535855427',
    projectId: 'alpamys-74a69',
    authDomain: 'alpamys-74a69.firebaseapp.com',
    storageBucket: 'alpamys-74a69.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyACPgTn3M3aSVNNEDrCVc28JN0ozsW88vQ',
    appId: '1:537535855427:android:222f8eb0f7260173fc4df6',
    messagingSenderId: '537535855427',
    projectId: 'alpamys-74a69',
    storageBucket: 'alpamys-74a69.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyACPgTn3M3aSVNNEDrCVc28JN0ozsW88vQ',
    appId: '1:537535855427:ios:c4a8fd2b3ce27a1dfc4df6',
    messagingSenderId: '537535855427',
    projectId: 'alpamys-74a69',
    storageBucket: 'alpamys-74a69.firebasestorage.app',
    iosBundleId: 'com.example.alpamys',
  );
}
