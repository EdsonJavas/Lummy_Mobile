import 'package:cloud_firestore/cloud_firestore.dart';

class FamilyService {
  final FirebaseFirestore _firestore;

  FamilyService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<String> createResponsavel({
    required String nome,
    required String cpf,
    required String email,
    required String senha,
  }) async {
    final docRef = await _firestore.collection('responsaveis').add({
      'nome': nome,
      'cpf': cpf,
      'email': email,
      'senha': senha,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Future<void> addChild({
    required String responsavelId,
    required String nome,
    required String cpf,
    required String email,
    required String senha,
    required int idade,
    required String sexo,
  }) async {
    await _firestore
        .collection('responsaveis')
        .doc(responsavelId)
        .collection('children')
        .add({
      'nome': nome,
      'cpf': cpf,
      'email': email,
      'senha': senha,
      'idade': idade,
      'sexo': sexo,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
