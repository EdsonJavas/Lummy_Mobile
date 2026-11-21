// Configuração do Firebase do Lummy (projeto lummy-dce58), no formato do
// `flutterfire configure`. Os valores são a configuração pública dos apps
// registrados no console (não são segredos).
//
// - iOS: com.lummy.app (apelido "Lummy iOS")
// - Android: com.example.lummy (apelido "Lummy Android"). Se o applicationId
//   mudar, registre o novo pacote no Firebase e troque o appId abaixo.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  /// Opções da plataforma atual. Nulo onde o Lummy não usa Firebase (web,
  /// desktop): quem chama deve pular a inicialização.
  static FirebaseOptions? get currentPlatform {
    if (kIsWeb) return null;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return null;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCF5ldUnKLcj6FvqbN138krm_Wu-y5XNoc',
    appId: '1:1070784005505:android:03bfc628d8ab51cabed480',
    messagingSenderId: '1070784005505',
    projectId: 'lummy-dce58',
    storageBucket: 'lummy-dce58.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDNp2P_tq1N2qo9riTzDVGcDxOsF0ESwO8',
    appId: '1:1070784005505:ios:5ae686224c7a331cbed480',
    messagingSenderId: '1070784005505',
    projectId: 'lummy-dce58',
    storageBucket: 'lummy-dce58.firebasestorage.app',
    iosBundleId: 'com.lummy.app',
  );
}
