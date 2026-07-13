import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'models/plat.dart';

const Color kOrange = Color(0xFFFF6B35);
const Color kOrangeLight = Color(0xFFFDF3EE);

/// Page "Ajouter un Plat".
/// C'est une sous-page (accessible depuis le bouton + de Gestion du Menu),
/// PAS d'onglet de navigation en bas ici — juste un bouton retour.
///
/// Utilisation depuis gestion_menu.dart :
/// ```dart
/// final nouveauPlat = await Navigator.push<Plat>(
///   context,
///   MaterialPageRoute(builder: (context) => const PublicationMenu()),
/// );
/// if (nouveauPlat != null) {
///   setState(() => _plats.add(nouveauPlat));
/// }
/// ```
class PublicationMenu extends StatefulWidget {
  const PublicationMenu({super.key, this.platExistant});

  /// Si non-null, on est en mode "modifier un plat existant" plutôt que
  /// "ajouter un nouveau plat".
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

  File? _photoPlat;
  final ImagePicker _picker = ImagePicker();

  bool _disponible = true;

  @override
  void initState() {
    super.initState();
    final plat = widget.platExistant;
    _nomController = TextEditingController(text: plat?.nom ?? '');
    _prixController =
        TextEditingController(text: plat != null ? plat.prixFcfa.toString() : '');
    _descriptionController = TextEditingController(text: plat?.description ?? '');
    _categorieSelectionnee = plat?.categorie;
    _photoPlat = plat?.image;
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
                  final XFile? image =
                      await _picker.pickImage(source: ImageSource.gallery);
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
                  final XFile? image =
                      await _picker.pickImage(source: ImageSource.camera);
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

  void _enregistrerLePlat() {
    if (!_formKey.currentState!.validate()) return;

    if (_categorieSelectionnee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Merci de sélectionner une catégorie')),
      );
      return;
    }

    final plat = Plat(
      id: widget.platExistant?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      nom: _nomController.text.trim(),
      prixFcfa: int.tryParse(_prixController.text.trim()) ?? 0,
      description: _descriptionController.text.trim(),
      categorie: _categorieSelectionnee!,
      image: _photoPlat,
      disponible: _disponible,
    );

    // TODO: brancher ici l'appel backend/Firebase pour sauvegarder le plat.

    Navigator.pop(context, plat);
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              const Text('Photo du plat',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              _buildZonePhoto(),
              const SizedBox(height: 20),
              const Text('Nom du plat',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nomController,
                decoration: _inputDecoration('Ex: Thieboudienne Royal'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 20),
              const Text('Catégorie',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
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
              const Text('Prix (FCFA)',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
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
              const Text('Description',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
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
                          const Text('Disponible dès maintenant',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(
                            'Le plat apparaîtra immédiatement sur le menu',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600),
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
                  onPressed: _enregistrerLePlat,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kOrange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28)),
                  ),
                  icon: const Icon(Icons.save_outlined, color: Colors.white),
                  label: const Text(
                    'Enregistrer le plat',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
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
        child: _photoPlat != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(_photoPlat!, fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt, color: kOrange, size: 28),
                  const SizedBox(height: 8),
                  Text(
                    'Cliquez pour ajouter une photo',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
      ),
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