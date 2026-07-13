import 'package:flutter/material.dart';
import 'inscription_etudiant.dart';
// import 'inscription_livreur.dart'; // décommente et adapte le nom de la classe

class ChoixProfilPage extends StatelessWidget {
  const ChoixProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F2EE),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bienvenue sur Japale 👋',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2B1F18),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Quel est votre profil ?',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6D574C),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        children: [
                          Image.asset(
                            'assets/images/livreur.jpg',
                            width: double.infinity,
                            height: 190,
                            fit: BoxFit.cover,
                          ),
                          Container(
                            width: double.infinity,
                            height: 190,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.08),
                                  Colors.black.withOpacity(0.18),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 16,
                            bottom: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.favorite, color: Color(0xFFFF6B35), size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Entraide Universitaire',
                                    style: TextStyle(
                                      color: Color(0xFFFF6B35),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    _OptionCard(
                      title: 'Étudiant / Client',
                      subtitle: 'Commandez vos repas',
                      icon: Icons.person,
                      color: const Color(0xFFF7D0BF),
                      accentColor: const Color(0xFFFF6B35),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const InscriptionEtudiant(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _OptionCard(
                      title: 'Livreur Étudiant',
                      subtitle: "Gagnez de l'argent en livrant",
                      icon: Icons.delivery_dining,
                      color: const Color(0xFFFCE0D4),
                      accentColor: const Color(0xFFFF6B35),
                      onTap: () {
                        // Décommente une fois l'import de inscription_livreur.dart activé
                        // et adapte le nom de la classe si besoin :
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => const InscriptionLivreur(),
                        //   ),
                        // );
                      },
                    ),
                    const SizedBox(height: 16),
                    _OptionCard(
                      title: 'Restaurant',
                      subtitle: 'Gérez vos menus et commandes',
                      icon: Icons.storefront,
                      color: const Color(0xFFFAE6D9),
                      accentColor: const Color(0xFFFF6B35),
                      onTap: () {
                        // TODO: brancher la page d'inscription restaurant
                        // quand elle sera créée
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Déjà un compte ?',
                    style: TextStyle(color: Color(0xFF5F4B43)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Se connecter',
                      style: TextStyle(
                        color: Color(0xFFFF6B35),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.accentColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: accentColor, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF6B35),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6D574C),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Color(0xFFFF6B35), size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
