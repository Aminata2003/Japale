import 'package:cloud_firestore/cloud_firestore.dart';

class Commande {
  final String id;
  final String restaurant;
  final String menu;
  final String client;
  final String lieu;
  final int montant;
  final String statut; // 'disponible', 'en_cours', 'livree'
  final String? heure;
  final double? note;
  final String? clientEmail;
  final String? clientPhone;
  final String? livreurId;
  final String? livreurNom;
  final DateTime? timestamp;

  Commande({
    required this.id,
    required this.restaurant,
    required this.menu,
    required this.client,
    required this.lieu,
    required this.montant,
    required this.statut,
    this.heure,
    this.note,
    this.clientEmail,
    this.clientPhone,
    this.livreurId,
    this.livreurNom,
    this.timestamp,
  });

  factory Commande.fromFirestore(Map<String, dynamic> data, String docId) {
    final rawTimestamp = data['timestamp'];
    DateTime? parsedTimestamp;

    if (rawTimestamp is Timestamp) {
      parsedTimestamp = rawTimestamp.toDate();
    } else if (rawTimestamp is DateTime) {
      parsedTimestamp = rawTimestamp;
    } else if (rawTimestamp is String) {
      try {
        parsedTimestamp = DateTime.parse(rawTimestamp);
      } catch (_) {
        parsedTimestamp = null;
      }
    }

    return Commande(
      id: docId,
      restaurant: data['restaurant'] ?? '',
      menu: data['menu'] ?? '',
      client: data['client'] ?? '',
      lieu: data['lieu'] ?? '',
      montant: data['montant'] ?? 0,
      statut: data['statut'] ?? 'disponible',
      heure: data['heure'],
      note: data['note']?.toDouble(),
      clientEmail: data['clientEmail'],
      clientPhone: data['clientPhone'],
      livreurId: data['livreurId'],
      livreurNom: data['livreurNom'],
      timestamp: parsedTimestamp,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'restaurant': restaurant,
      'menu': menu,
      'client': client,
      'lieu': lieu,
      'montant': montant,
      'statut': statut,
      'heure': heure,
      'note': note,
      'clientEmail': clientEmail,
      'clientPhone': clientPhone,
      'livreurId': livreurId,
      'livreurNom': livreurNom,
      'timestamp': timestamp ?? DateTime.now(),
    };
  }

  Commande copyWith({
    String? id,
    String? restaurant,
    String? menu,
    String? client,
    String? lieu,
    int? montant,
    String? statut,
    String? heure,
    double? note,
    String? clientEmail,
    String? clientPhone,
    String? livreurId,
    String? livreurNom,
    DateTime? timestamp,
  }) {
    return Commande(
      id: id ?? this.id,
      restaurant: restaurant ?? this.restaurant,
      menu: menu ?? this.menu,
      client: client ?? this.client,
      lieu: lieu ?? this.lieu,
      montant: montant ?? this.montant,
      statut: statut ?? this.statut,
      heure: heure ?? this.heure,
      note: note ?? this.note,
      clientEmail: clientEmail ?? this.clientEmail,
      clientPhone: clientPhone ?? this.clientPhone,
      livreurId: livreurId ?? this.livreurId,
      livreurNom: livreurNom ?? this.livreurNom,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}