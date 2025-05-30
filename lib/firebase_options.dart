// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyDnEIgcrjpT2yt42rFH_laBIstpZBI0jfw',
    appId: '1:325469832093:web:797d915e5d1e0ec849a574',
    messagingSenderId: '325469832093',
    projectId: 'boticas-toty-farma',
    authDomain: 'boticas-toty-farma.firebaseapp.com',
    storageBucket: 'boticas-toty-farma.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBZhMJNjhLE4jqZ-kr71nVLBY8h8W2H3cA',
    appId: '1:325469832093:android:3a131e1edb1b440549a574',
    messagingSenderId: '325469832093',
    projectId: 'boticas-toty-farma',
    storageBucket: 'boticas-toty-farma.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDQAuFA6Fgn7Ns05_SpuKtP0osZ5YkGL30',
    appId: '1:325469832093:ios:f11ec7be1ae7a5b649a574',
    messagingSenderId: '325469832093',
    projectId: 'boticas-toty-farma',
    storageBucket: 'boticas-toty-farma.firebasestorage.app',
    iosBundleId: 'com.example.boticasTotyFarma02',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDQAuFA6Fgn7Ns05_SpuKtP0osZ5YkGL30',
    appId: '1:325469832093:ios:f11ec7be1ae7a5b649a574',
    messagingSenderId: '325469832093',
    projectId: 'boticas-toty-farma',
    storageBucket: 'boticas-toty-farma.firebasestorage.app',
    iosBundleId: 'com.example.boticasTotyFarma02',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDnEIgcrjpT2yt42rFH_laBIstpZBI0jfw',
    appId: '1:325469832093:web:c34b391242f2b77b49a574',
    messagingSenderId: '325469832093',
    projectId: 'boticas-toty-farma',
    authDomain: 'boticas-toty-farma.firebaseapp.com',
    storageBucket: 'boticas-toty-farma.firebasestorage.app',
  );
}
