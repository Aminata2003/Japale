import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japale/models/commande.dart';

void main() {
  test('Commande.fromFirestore accepts Firebase Timestamp values', () {
    final timestamp = Timestamp.fromDate(DateTime(2024, 1, 2, 3, 4, 5));

    final commande = Commande.fromFirestore({
      'restaurant': 'Resto Test',
      'menu': 'Burger',
      'client': 'Client Test',
      'lieu': 'Dakar',
      'montant': 2500,
      'statut': 'disponible',
      'timestamp': timestamp,
    }, 'abc123');

    expect(commande.id, 'abc123');
    expect(commande.timestamp, equals(timestamp.toDate()));
    expect(commande.statut, 'disponible');
  });
}
