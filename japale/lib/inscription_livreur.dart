import 'package:flutter/material.dart';

class InscriptionLivreur extends StatefulWidget {
  const InscriptionLivreur({super.key});

  @override
  State<InscriptionLivreur> createState() => _InscriptionLivreurState();
}

class _InscriptionLivreurState extends State<InscriptionLivreur> {
   final _formKey = GlobalKey<FormState>();
  String _transportChoisi = 'Vélo';
  Set<String> _disponibilites = {'Soir'};

 @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFFDF6F0),
    body: Form(
  key: _formKey,
  child: SingleChildScrollView(
    child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildForm(),
                const SizedBox(height: 28),
                _buildMoyenDeTransportSection(),
                const SizedBox(height: 28),
                _buildDisponibilitesSection(),
                const SizedBox(height: 28),
                _buildVerificationSection(),
                const SizedBox(height: 28),
                _buildPaiementsSection(),
                const SizedBox(height: 28),
                _buildImageEtBouton(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    ),
    ),
  );
}
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFFFF6B35),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Devenir Livreur Japale',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: const [
          Icon(Icons.info_outline, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Votre profil sera vérifié avant activation ✓',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ⬇️ tout ce qui suit était en dehors de la classe, maintenant dedans

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color:  Color(0xFFFF6B35), width: 1.5),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "INFORMATIONS PERSONNELLES",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFF6B35),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Prénom', style: TextStyle(fontSize: 14, color: Colors.black87)),
                  const SizedBox(height: 6),
                  TextFormField(decoration: _fieldDecoration('Abdou')),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nom', style: TextStyle(fontSize: 14, color: Colors.black87)),
                  const SizedBox(height: 6),
                  TextFormField(decoration: _fieldDecoration('Diop')),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Email', style: TextStyle(fontSize: 14, color: Colors.black87)),
        const SizedBox(height: 6),
        TextFormField(
          keyboardType: TextInputType.emailAddress,
          decoration: _fieldDecoration('abdou.diop@ugb.sn'),
          validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Email requis';
    }
    if (!value.contains('@')) {
      return 'Email invalide';
    }
    return null; // null = pas d'erreur
  },
        ),
        const SizedBox(height: 16),
        const Text('Téléphone', style: TextStyle(fontSize: 14, color: Colors.black87)),
        const SizedBox(height: 6),
        TextFormField(
          keyboardType: TextInputType.phone,
          decoration: _fieldDecoration('77 000 00 00'),
          validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Téléphone requis';
    }
    if (!value.contains('77,70,75,77,76,71') && !value.contains('70') && !value.contains('76') && !value.contains('78')) {
      return 'Téléphone invalide';
    }
    return null; // null = pas d'erreur
  },
        ),
      ],
    );
  }

  Widget _buildMoyenDeTransportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "MOYEN DE TRANSPORT",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFF6B35),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildTransportOption(Icons.directions_bike, 'Vélo'),
            _buildTransportOption(Icons.moped, 'Moto'),
            _buildTransportOption(Icons.directions_walk, 'À pied'),
          ],
        ),
        
      ],
    );
  }

  Widget _buildTransportOption(IconData icon, String label) {
    final bool isSelected = _transportChoisi == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _transportChoisi = label;
        });
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFFF1EB) : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? const Color(0xFFFF6B35) : Colors.transparent,
                width: 2,
              ),
            ),
            child: Icon(icon, size: 30, color: const Color(0xFFFF6B35)),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildDisponibilitesSection() {
  final options = ['Matin', 'Midi', 'Soir', 'Week-end'];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "DISPONIBILITÉS",
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFF6B35),
          letterSpacing: 0.5,
        ),
      ),
      const SizedBox(height: 16),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: options.map((option) {
          final bool isSelected = _disponibilites.contains(option);
          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _disponibilites.remove(option);
                } else {
                  _disponibilites.add(option);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ?Color(0xFFFF6B35) : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    option,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.check, color: Colors.white, size: 16),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    ],
  );
}
Widget _buildVerificationSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "VÉRIFICATION D'IDENTITÉ",
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFF6B35),
          letterSpacing: 0.5,
        ),
      ),
      const SizedBox(height: 16),
      const Text(
        'Numéro CNI ou carte étudiant',
        style: TextStyle(fontSize: 14, color: Colors.black87),
      ),
      const SizedBox(height: 6),
      Row(
        children: [
          Expanded(
            child: TextFormField(
              decoration: _fieldDecoration('2 123 2000 00123'),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFFFA726),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.upload, color: Colors.white),
              onPressed: () {
                // TODO: logique d'upload de fichier (plus tard, avec un package comme file_picker)
              },
            ),
          ),
        ],
      ),
      const SizedBox(height: 6),
      Text(
        'Téléchargez un scan recto-verso lisible.',
        style: TextStyle(
          fontSize: 12,
          fontStyle: FontStyle.italic,
          color: Colors.grey.shade600,
        ),
      ),
    ],
  );
}
Widget _buildPaiementsSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "PAIEMENTS",
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFF6B35),
          letterSpacing: 0.5,
        ),
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Numéro Wave ou Orange Money',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextFormField(
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '7x xxx xx xx',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: InputBorder.none, // pas de bordure ici, le Container s'en charge déjà
                  suffixText: 'W/OM',
                  suffixStyle: const TextStyle(
                    color: Color(0xFFB5401A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
Widget _buildImageEtBouton() {
  return Column(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          'assets/images/livreur.jpg', // remplace par ton image locale
          height: 160,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
      const SizedBox(height: 20),
      SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
    // tous les champs sont valides
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Formulaire valide ! (envoi à connecter plus tard)')),
    );
  }
            // TODO: logique de soumission du formulaire
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B35),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Soumettre ma demande',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.send, color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    ],
  );
}
} // ✅ une seule accolade de fermeture, ici, à la toute fin