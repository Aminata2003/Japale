import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:japale/acceuil_client.dart';
import 'package:japale/liste_restaurants.dart';
import 'package:japale/suivi_commande.dart';
import 'package:japale/alerte_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:japale/services/cloudinary_service.dart';

import 'package:japale/models/user_session.dart';
import '../widgets/japale_bottom_nav.dart';
import 'package:japale/widgets/connexion.dart';

class ProfilEtudiant extends StatefulWidget {
  const ProfilEtudiant({super.key});

  @override
  State<ProfilEtudiant> createState() => _ProfilEtudiantState();
}

class _ProfilEtudiantState extends State<ProfilEtudiant> {
  int _currentNavIndex = 4;

  bool _isInfoExpanded = false;
  bool _isAddressExpanded = false;

  static const Color kOrange = Color(0xFFFF6B35);
  static const Color kOrangeLight = Color(0xFFFFE4D6);

  final ImagePicker _picker = ImagePicker();

  File? _photoProfil;

  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();

    _chargerProfilFirebase();
  }

  Future<void> _chargerProfilFirebase() async {
    try {
      User? user = _auth.currentUser;

      if (user == null) {
        return;
      }

      DocumentSnapshot doc = await _firestore
          .collection('etudiants')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        doc = await _firestore.collection('users').doc(user.uid).get();
      }

      if (doc.exists) {
        setState(() {
          _userData = doc.data() as Map<String, dynamic>;

          UserSession.prenom = _userData?['prenom'] ?? UserSession.prenom ?? '';
          UserSession.nom = _userData?['nom'] ?? UserSession.nom ?? '';
          UserSession.email = _userData?['email'] ?? UserSession.email ?? '';
          UserSession.telephone = _userData?['telephone'] ?? UserSession.telephone ?? '';
          UserSession.village = _userData?['village'] ?? UserSession.village ?? '';

          if (_userData?['photoProfil'] != null) {
            UserSession.photoProfil = _userData!['photoProfil'];
          }
        });
      }
    } catch (e) {
      print("Erreur chargement profil Firebase : $e");
    }
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
                    await _updatePhoto(File(image.path));
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
                    await _updatePhoto(File(image.path));
                  }
                },
              ),

              if (_photoProfil != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),

                  title: const Text(
                    'Supprimer la photo',
                    style: TextStyle(color: Colors.red),
                  ),

                  onTap: () {
                    Navigator.pop(context);

                    _supprimerPhoto();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updatePhoto(File photo) async {
    try {
      setState(() {
        _isLoading = true;
      });

      User? user = _auth.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      final String? photoUrl = await CloudinaryService.uploadImage(
        photo,
        folder: 'photos_profils',
      );

      if (photoUrl == null) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Échec de l'upload de la photo"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await _firestore.collection('etudiants').doc(user.uid).update({
        "photoProfil": photoUrl,
      });

      setState(() {
        _photoProfil = photo;
        _isLoading = false;
        UserSession.photoProfil = photoUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Photo mise à jour avec succès"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Erreur upload photo : $e");
    }
  }

  Future<void> _supprimerPhoto() async {
    try {
      User? user = _auth.currentUser;

      if (user == null) {
        return;
      }

      await _firestore.collection('etudiants').doc(user.uid).update({
        "photoProfil": null,
      });

      setState(() {
        _photoProfil = null;

        UserSession.photoProfil = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Photo supprimée"),

          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      print("Erreur suppression photo : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    String prenom = _userData?['prenom'] ?? UserSession.prenom ?? 'Prénom';

    String nom = _userData?['nom'] ?? UserSession.nom ?? 'Nom';

    String email =
        _userData?['email'] ?? UserSession.email ?? 'email@example.com';

    String telephone =
        _userData?['telephone'] ?? UserSession.telephone ?? 'Non renseigné';

    String village =
        _userData?['village'] ?? UserSession.village ?? 'Non renseigné';

    String nomComplet = '$prenom $nom';

    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F0),

      appBar: AppBar(
        backgroundColor: kOrange,

        elevation: 0,

        title: const Text(
          'Mon Profil',

          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),

        centerTitle: true,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),

          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            _buildHeader(nomComplet),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),

              child: Column(
                children: [
                  _buildExpandableInfoTile(
                    icon: Icons.person_outline,

                    label: 'Mes informations',

                    isExpanded: _isInfoExpanded,

                    onTap: () {
                      setState(() {
                        _isInfoExpanded = !_isInfoExpanded;

                        if (_isInfoExpanded) {
                          _isAddressExpanded = false;
                        }
                      });
                    },

                    children: [
                      _buildInfoRow(Icons.person_outline, 'Prénom', prenom),

                      _buildInfoRow(Icons.person, 'Nom', nom),

                      _buildInfoRow(Icons.email_outlined, 'Email', email),

                      _buildInfoRow(
                        Icons.phone_outlined,
                        'Téléphone',
                        telephone,
                      ),

                      _buildInfoRow(Icons.home_outlined, 'Village', village),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _buildExpandableInfoTile(
                    icon: Icons.location_on_outlined,

                    label: 'Mes adresses',

                    isExpanded: _isAddressExpanded,

                    onTap: () {
                      setState(() {
                        _isAddressExpanded = !_isAddressExpanded;

                        if (_isAddressExpanded) {
                          _isInfoExpanded = false;
                        }
                      });
                    },

                    children: [
                      _buildInfoRow(
                        Icons.location_on_outlined,

                        'Village de résidence',

                        village,

                        isAddress: true,
                      ),

                      const SizedBox(height: 8),

                      Container(
                        padding: const EdgeInsets.all(12),

                        decoration: BoxDecoration(
                          color: kOrangeLight,

                          borderRadius: BorderRadius.circular(8),
                        ),

                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: kOrange, size: 16),

                            const SizedBox(width: 8),

                            const Expanded(
                              child: Text(
                                'Cette adresse sera utilisée pour les livraisons',

                                style: TextStyle(
                                  fontSize: 12,

                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      _buildActionButton(
                        icon: Icons.add_location_alt,

                        label: 'Ajouter une nouvelle adresse',

                        onTap: _showAddAddressDialog,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _buildMenuTile(
                    Icons.payments_outlined,

                    'Mes moyens de paiement',
                  ),

                  const SizedBox(height: 12),

                  _buildMenuTile(
                    Icons.receipt_long_outlined,

                    'Historique des commandes',
                  ),

                  const SizedBox(height: 12),

                  _buildMenuTile(Icons.settings_outlined, 'Paramètres'),

                  const SizedBox(height: 24),

                  _buildLogoutButton(),

                  const SizedBox(height: 16),

                  Text(
                    'Version 2.4.0 • Fabriqué pour UGB',

                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: JapaleBottomNav(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          if (index == _currentNavIndex) return;

          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AccueilClient()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ListeRestaurantsPage()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SuiviCommandePage()),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AlertePage()),
              );
              break;
            case 4:
              setState(() => _currentNavIndex = index);
              break;
          }
        },
      ),
    );
  }

  Future<void> _mettreAJourAdresse(String nouvelleAdresse) async {
    try {
      User? user = _auth.currentUser;

      if (user == null) {
        return;
      }

      await _firestore.collection('etudiants').doc(user.uid).update({
        "village": nouvelleAdresse,
      });

      setState(() {
        UserSession.village = nouvelleAdresse;

        _userData?['village'] = nouvelleAdresse;
      });
    } catch (e) {
      print("Erreur modification adresse : $e");
    }
  }

  Widget _buildMenuTile(IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(label)));
      },

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

        decoration: BoxDecoration(
          color: Colors.grey.shade50,

          borderRadius: BorderRadius.circular(14),

          border: Border.all(color: Colors.grey.shade200),
        ),

        child: Row(
          children: [
            Container(
              width: 40,

              height: 40,

              decoration: BoxDecoration(
                color: kOrangeLight,

                borderRadius: BorderRadius.circular(12),
              ),

              child: Icon(icon, color: kOrange, size: 20),
            ),

            const SizedBox(width: 14),

            Expanded(child: Text(label, style: const TextStyle(fontSize: 15))),

            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  ImageProvider? _getProfileImageProvider() {
    if (_photoProfil != null) {
      return FileImage(_photoProfil!);
    }
    final String? photoUrl = _userData?['photoProfil'] ?? UserSession.photoProfil;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      if (photoUrl.startsWith('http')) {
        return NetworkImage(photoUrl);
      } else if (photoUrl.startsWith('assets/')) {
        return AssetImage(photoUrl);
      }
    }
    return null;
  }

  Widget _buildHeader(String nomComplet) {
    final imageProvider = _getProfileImageProvider();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: const BoxDecoration(
        color: kOrange,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _choisirPhoto,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: kOrangeLight,
                  backgroundImage: imageProvider,
                  child: imageProvider == null
                      ? const Icon(Icons.person, size: 50, color: kOrange)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.camera_alt, size: 18, color: kOrange),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          Text(
            nomComplet,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text("Étudiant UGB", style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildExpandableInfoTile({
    required IconData icon,
    required String label,
    required bool isExpanded,
    required VoidCallback onTap,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),

      child: Column(
        children: [
          ListTile(
            leading: Icon(icon, color: kOrange),
            title: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            trailing: Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            ),

            onTap: onTap,
          ),

          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(children: children),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isAddress = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),

      child: Row(
        children: [
          Icon(icon, color: kOrange),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),

                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          if (isAddress)
            IconButton(
              icon: Icon(Icons.edit, color: kOrange),

              onPressed: () {
                _showEditAddressDialog(value);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color: kOrangeLight,
          borderRadius: BorderRadius.circular(12),
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(icon, color: kOrange),

            const SizedBox(width: 8),

            Text(
              label,
              style: TextStyle(color: kOrange, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,

      height: 50,

      child: ElevatedButton.icon(
        onPressed: _showLogoutDialog,

        icon: const Icon(Icons.logout),

        label: const Text("Se déconnecter"),

        style: ElevatedButton.styleFrom(
          backgroundColor: kOrange,
          foregroundColor: Colors.white,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  void _showAddAddressDialog() {
    final TextEditingController addressController = TextEditingController();

    showDialog(
      context: context,

      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.add_location, color: kOrange),

            const SizedBox(width: 10),

            const Text('Ajouter une adresse'),
          ],
        ),

        content: TextField(
          controller: addressController,

          decoration: InputDecoration(
            hintText: 'Ex: Village B, Chambre 12',

            prefixIcon: Icon(Icons.location_on, color: kOrange),

            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),

        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },

            child: const Text('Annuler'),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kOrange),

            onPressed: () async {
              if (addressController.text.trim().isEmpty) {
                return;
              }

              await _mettreAJourAdresse(addressController.text.trim());

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Adresse ajoutée avec succès'),

                  backgroundColor: Colors.green,
                ),
              );
            },

            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _showEditAddressDialog(String currentAddress) {
    final TextEditingController addressController = TextEditingController(
      text: currentAddress,
    );

    showDialog(
      context: context,

      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit_location, color: kOrange),

            const SizedBox(width: 10),

            const Text('Modifier l\'adresse'),
          ],
        ),

        content: TextField(
          controller: addressController,

          decoration: InputDecoration(
            hintText: 'Nouvelle adresse',

            prefixIcon: Icon(Icons.edit_location, color: kOrange),

            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),

        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },

            child: const Text('Annuler'),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kOrange),

            onPressed: () async {
              if (addressController.text.trim().isEmpty) {
                return;
              }

              await _mettreAJourAdresse(addressController.text.trim());

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Adresse modifiée avec succès'),

                  backgroundColor: Colors.green,
                ),
              );
            },

            child: const Text('Modifier'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,

      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),

        content: const Text('Voulez-vous vraiment vous déconnecter ?'),

        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },

            child: const Text('Annuler'),
          ),

          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),

            onPressed: () async {
              try {
                await _auth.signOut();

                UserSession.clear();

                Navigator.pop(context);

                Navigator.pushReplacement(
                  context,

                  MaterialPageRoute(
                    builder: (context) =>
                        const ConnexionPage(profil: "etudiant"),
                  ),
                );
              } catch (e) {
                print("Erreur déconnexion : $e");
              }
            },

            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }
}
