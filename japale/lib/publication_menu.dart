import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:japale/services/cloudinary_service.dart';
import 'models/plat.dart';

const Color kOrange = Color(0xFFFF6B35);
const Color kOrangeLight = Color(0xFFFDF3EE);

/// Page "Ajouter un Plat" / "Modifier le Plat".
/// Écrit directement dans Firestore : restaurants/{uid}/plats/{platId}
/// et héberge la photo sur Firebase Storage.
///
/// Utilisation depuis gestion_menu.dart :
/// ```dart
/// final resultat = await Navigator.push<bool>(
///   context,
///   MaterialPageRoute(builder: (context) => PublicationMenu(platExistant: plat)),
/// );
/// // resultat == true si un plat a été créé/modifié — pas besoin de
/// // gérer la liste manuellement, le StreamBuilder de gestion_menu.dart
/// // se met à jour automatiquement depuis Firestore.
/// ```
class PublicationMenu extends StatefulWidget {
  const PublicationMenu({super.key, this.platExistant});

  final Plat? platExistant;

  @override
  State<PublicationMenu> createState() => _PublicationMenuState();
}

class _PublicationMenuState extends State<PublicationMenu> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nomController;
  late final TextEditingController _prixController;
  late final TextEditingController _descriptionController;

  String? _categorieSelectionnee;
  final List<String> _categories = ['Riz', 'Viande', 'Poisson', 'Boisson'];

  File? _photoPlat; // nouvelle photo choisie localement (pas encore uploadée)
  String? _photoUrlExistante; // photo déjà présente (mode édition)
  final ImagePicker _picker = ImagePicker();

  bool _disponible = true;
  bool _enCoursDEnregistrement = false;

  @override
  void initState() {
    super.initState();
    final plat = widget.platExistant;
    _nomController = TextEditingController(text: plat?.nom ?? '');
    _prixController = TextEditingController(
      text: plat != null ? plat.prixFcfa.toString() : '',
    );
    _descriptionController = TextEditingController(
      text: plat?.description ?? '',
    );
    _categorieSelectionnee = plat?.categorie;
    _photoUrlExistante = plat?.imageUrl;
    _disponible = plat?.disponible ?? true;
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prixController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _choisirPhoto() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: kOrange),
                title: const Text('Choisir depuis la galerie'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image != null) {
                    setState(() => _photoPlat = File(image.path));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: kOrange),
                title: const Text('Prendre une photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (image != null) {
                    setState(() => _photoPlat = File(image.path));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _enregistrerLePlat() async {
    if (!_formKey.currentState!.validate()) return;

    if (_categorieSelectionnee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Merci de sélectionner une catégorie')),
      );
      return;
    }

    final restaurantId = FirebaseAuth.instance.currentUser?.uid;
    if (restaurantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous devez être connecté pour publier un plat'),
        ),
      );
      return;
    }

    setState(() => _enCoursDEnregistrement = true);

    try {
      final modeEdition = widget.platExistant != null;
      final platsRef = FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurantId)
          .collection('plats');

      // Détermine l'id du document : existant en mode édition, sinon
      // généré à l'avance pour pouvoir nommer la photo sur Storage.
      final String platId = modeEdition
          ? widget.platExistant!.id
          : platsRef.doc().id;

      // Upload de la nouvelle photo si l'utilisateur en a choisi une.
      String? urlPhoto = _photoUrlExistante;
      if (_photoPlat != null) {
        urlPhoto = await CloudinaryService.uploadImage(
          _photoPlat!,
          folder: 'plats/$restaurantId',
        );
        if (urlPhoto == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Échec de l'upload de la photo du plat"),
            ),
          );
          setState(() => _enCoursDEnregistrement = false);
          return;
        }
      }

      final plat = Plat(
        id: platId,
        nom: _nomController.text.trim(),
        prixFcfa: int.tryParse(_prixController.text.trim()) ?? 0,
        description: _descriptionController.text.trim(),
        categorie: _categorieSelectionnee!,
        imageUrl: urlPhoto,
        disponible: _disponible,
      );

      await platsRef.doc(platId).set(plat.toFirestore());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            modeEdition
                ? 'Plat modifié avec succès !'
                : 'Plat ajouté avec succès !',
          ),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'enregistrement : $e')),
      );
    } finally {
      if (mounted) setState(() => _enCoursDEnregistrement = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final modeEdition = widget.platExistant != null;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF6F0),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          modeEdition ? 'Modifier le Plat' : 'Ajouter un Plat',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Ouvert',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Photo du plat',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              _buildZonePhoto(),
              const SizedBox(height: 20),
              const Text(
                'Nom du plat',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nomController,
                decoration: _inputDecoration('Ex: Thieboudienne Royal'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 20),
              const Text(
                'Catégorie',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _categorieSelectionnee,
                decoration: _inputDecoration('Sélectionner une catégorie'),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _categorieSelectionnee = value),
              ),
              const SizedBox(height: 20),
              const Text(
                'Prix (FCFA)',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _prixController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('2500').copyWith(
                  suffixText: 'CFA',
                  suffixStyle: TextStyle(color: Colors.grey.shade600),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Requis';
                  if (int.tryParse(v.trim()) == null) return 'Nombre invalide';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Description',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: _inputDecoration('Ingrédients, portions...'),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Disponible dès maintenant',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Le plat apparaîtra immédiatement sur le menu',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _disponible,
                      activeThumbColor: kOrange,
                      onChanged: (value) => setState(() => _disponible = value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _enCoursDEnregistrement
                      ? null
                      : _enregistrerLePlat,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  icon: _enCoursDEnregistrement
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save_outlined, color: Colors.white),
                  label: Text(
                    _enCoursDEnregistrement
                        ? 'Enregistrement...'
                        : 'Enregistrer le plat',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildZonePhoto() {
    return GestureDetector(
      onTap: _choisirPhoto,
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          color: kOrangeLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: kOrange.withOpacity(0.4),
            style: BorderStyle.solid,
            width: 1.4,
          ),
        ),
        child: _buildContenuPhoto(),
      ),
    );
  }

  Widget _buildContenuPhoto() {
    // Priorité à la photo tout juste choisie localement (prévisualisation).
    if (_photoPlat != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.file(_photoPlat!, fit: BoxFit.cover),
      );
    }
    // Sinon, si on est en mode édition, on affiche la photo déjà en ligne.
    if (_photoUrlExistante != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(_photoUrlExistante!, fit: BoxFit.cover),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.camera_alt, color: kOrange, size: 28),
        const SizedBox(height: 8),
        Text(
          'Cliquez pour ajouter une photo',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kOrange, width: 1.5),
      ),
    );
  }
}
