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
    // if (kIsWeb) {
    //   throw UnsupportedError(
    //     'DefaultFirebaseOptions have not been configured for web - '
    //         'you can reconfigure this by running the FlutterFire CLI again.',
    //   );
    // }
    switch (defaultTargetPlatform) {
      // case TargetPlatform.android:
      //   return android;
      // case TargetPlatform.iOS:
      //   throw UnsupportedError(
      //     'DefaultFirebaseOptions have not been configured for ios - '
      //         'you can reconfigure this by running the FlutterFire CLI again.',
      //   );
      // case TargetPlatform.macOS:
      //   throw UnsupportedError(
      //     'DefaultFirebaseOptions have not been configured for macos - '
      //         'you can reconfigure this by running the FlutterFire CLI again.',
      //   );
      // case TargetPlatform.windows:
      //   throw UnsupportedError(
      //     'DefaultFirebaseOptions have not been configured for windows - '
      //         'you can reconfigure this by running the FlutterFire CLI again.',
      //   );
      // case TargetPlatform.linux:
      //   throw UnsupportedError(
      //     'DefaultFirebaseOptions have not been configured for linux - '
      //         'you can reconfigure this by running the FlutterFire CLI again.',
      //   );
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyArDI3xF8FBD3yCnIMC79Da4Iq65AlCCbE',
    appId: '1:1068606934178:android:ecb168d8c9f03081239bfb',
    messagingSenderId: '1068606934178',
    projectId: 'pageup-7eae9',
    storageBucket: 'pageup-7eae9.firebasestorage.app',
  );
}
