import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'plat.dart';

const Color kOrange = Color(0xFFFF6B35);
const Color kOrangeLight = Color(0xFFFDF3EE);

/// Page "Ajouter un Plat" / "Modifier un Plat".
/// Pas de RestaurantBottomNav ici : c'est une sous-page avec bouton retour,
/// pas un onglet principal du profil restaurant.
///
/// Utilisation pour AJOUTER un plat :
/// ```dart
/// final nouveauPlat = await Navigator.push<Plat>(
///   context,
///   MaterialPageRoute(builder: (context) => const PublicationMenu()),
/// );
/// ```
///
/// Utilisation pour MODIFIER un plat existant :
/// ```dart
/// final platModifie = await Navigator.push<Plat>(
///   context,
///   MaterialPageRoute(builder: (context) => PublicationMenu(platExistant: monPlat)),
/// );
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
  bool _disponible = true;
  File? _photo;

  final ImagePicker _picker = ImagePicker();

  final List<String> _categories = ['Riz', 'Viande', 'Poisson', 'Boisson', 'Dessert'];

  bool get _modeEdition => widget.platExistant != null;

  @override
  void initState() {
    super.initState();
    final plat = widget.platExistant;
    _nomController = TextEditingController(text: plat?.nom ?? '');
    _prixController = TextEditingController(text: plat != null ? plat.prix.toString() : '');
    _descriptionController = TextEditingController(text: plat?.description ?? '');
    _categorieSelectionnee = plat?.categorie;
    _disponible = plat?.disponible ?? true;
    _photo = plat?.imagePath;
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prixController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _choisirPhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _photo = File(image.path));
    }
  }

  void _enregistrer() {
    if (!_formKey.currentState!.validate()) return;

    if (_categorieSelectionnee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Merci de sélectionner une catégorie')),
      );
      return;
    }

    final plat = Plat(
      id: widget.platExistant?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      nom: _nomController.text.trim(),
      categorie: _categorieSelectionnee!,
      prix: int.tryParse(_prixController.text.trim()) ?? 0,
      description: _descriptionController.text.trim(),
      imagePath: _photo,
      disponible: _disponible,
    );

    // TODO: brancher ici l'enregistrement réel (backend / Firebase).

    Navigator.pop(context, plat);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF6F0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _modeEdition ? 'Modifier un Plat' : 'Ajouter un Plat',
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F6E9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Ouvert',
              style: TextStyle(color: Color(0xFF2E7D4F), fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Photo du plat',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              _buildPhotoPicker(),
              const SizedBox(height: 20),
              const Text('Nom du plat',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nomController,
                decoration: _inputDecoration('Ex: Thieboudienne Royal'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 20),
              const Text('Catégorie',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _categorieSelectionnee,
                decoration: _inputDecoration('Sélectionner une catégorie'),
                items: _categories
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (value) => setState(() => _categorieSelectionnee = value),
              ),
              const SizedBox(height: 20),
              const Text('Prix (FCFA)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _prixController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('2500').copyWith(
                  suffixText: 'CFA',
                  suffixStyle: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Requis';
                  if (int.tryParse(v.trim()) == null) return 'Nombre invalide';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text('Description',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: _inputDecoration('Ingrédients, portions...'),
              ),
              const SizedBox(height: 20),
              _buildDisponibiliteSwitch(),
              const SizedBox(height: 28),
              _buildBoutonEnregistrer(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoPicker() {
    return GestureDetector(
      onTap: _choisirPhoto,
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kOrange.withOpacity(0.4), width: 1.4),
        ),
        clipBehavior: Clip.antiAlias,
        child: _photo != null
            ? Image.file(_photo!, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(color: kOrangeLight, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt_outlined, color: kOrange, size: 26),
                  ),
                  const SizedBox(height: 10),
                  const Text('Cliquez pour ajouter une photo',
                      style: TextStyle(color: Colors.black54, fontSize: 13)),
                ],
              ),
      ),
    );
  }

  Widget _buildDisponibiliteSwitch() {
    return Container(
      padding: const EdgeInsets.all(16),
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
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Text('Le plat apparaîtra immédiatement sur le menu',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: _disponible,
            activeThumbColor: Colors.white,
            activeTrackColor: kOrange,
            onChanged: (value) => setState(() => _disponible = value),
          ),
        ],
      ),
    );
  }

  Widget _buildBoutonEnregistrer() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _enregistrer,
        icon: const Icon(Icons.save_outlined, color: Colors.white, size: 20),
        label: const Text(
          'Enregistrer le plat',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: kOrange,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          elevation: 0,
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
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kOrange, width: 1.5),
      ),
    );
  }
}