import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class SignatureScreen extends StatefulWidget {
  final List<Map<String, dynamic>> participants;
  final String inspectionId;

  const SignatureScreen({
    super.key,
    required this.participants,
    required this.inspectionId,
  });

  @override
  State<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  late PageController _pageController;
  int _currentParticipant = 0;
  final Map<int, Uint8List> _signatures = {};
  final Map<int, SignatureController> _controllers = {};

  // Données pour la signature du capitaine (après tous les participants)
  SignatureController? _captainController;
  Uint8List? _captainSignature;
  bool _isShowingCaptainSignature = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Créer un contrôleur pour chaque participant
    for (int i = 0; i < widget.participants.length; i++) {
      _controllers[i] = SignatureController(
        penStrokeWidth: 2,
        penColor: const Color(0xFF1BB35B),
        exportBackgroundColor: Colors.white,
      );
    }

    // Contrôleur pour le capitaine (couleur différente)
    _captainController = SignatureController(
      penStrokeWidth: 3,
      penColor: const Color(0xFFFF6A00), // Orange pour le capitaine
      exportBackgroundColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _captainController?.dispose();
    super.dispose();
  }

  SignatureController get _currentController {
    if (_isShowingCaptainSignature) {
      return _captainController!;
    }
    return _controllers[_currentParticipant]!;
  }

  Future<void> _saveCurrentSignature() async {
    if (_currentController.isEmpty) {
      _showSnackBar('Veuillez signer avant de continuer');
      return;
    }

    try {
      final signature = await _currentController.toPngBytes();
      if (signature != null) {
        if (_isShowingCaptainSignature) {
          // Sauvegarder la signature du capitaine
          setState(() {
            _captainSignature = signature;
          });
          _completeAllSignatures();
        } else {
          // Sauvegarder la signature du participant actuel
          final participantId = widget.participants[_currentParticipant]['id'] as int;
          setState(() {
            _signatures[participantId] = signature;
          });

          if (_currentParticipant < widget.participants.length - 1) {
            _nextParticipant();
          } else {
            // Tous les participants ont signé, passer au capitaine
            _showCaptainSignature();
          }
        }
      }
    } catch (e) {
      _showSnackBar('Erreur lors de la sauvegarde de la signature');
    }
  }

  void _nextParticipant() {
    setState(() => _currentParticipant++);
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousParticipant() {
    if (_isShowingCaptainSignature) {
      // Retour du capitaine vers le dernier participant
      setState(() {
        _isShowingCaptainSignature = false;
        _currentParticipant = widget.participants.length - 1;
      });
      _pageController.animateToPage(
        _currentParticipant,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (_currentParticipant > 0) {
      setState(() => _currentParticipant--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showCaptainSignature() {
    setState(() {
      _isShowingCaptainSignature = true;
    });
    // Pas besoin de PageController pour le capitaine, on change juste l'état
  }

  void _completeAllSignatures() {
    // Préparer les données de signatures pour le retour
    final signaturesData = <String, Map<String, dynamic>>{};

    // Ajouter les signatures des participants
    for (final entry in _signatures.entries) {
      final participantId = entry.key;
      final signatureBytes = entry.value;
      final base64Signature = base64Encode(signatureBytes);

      signaturesData[participantId.toString()] = {
        'signature_data': base64Signature,
        'participant_id': participantId,
        'signed_at': DateTime.now().toIso8601String(),
        'type': 'participant',
      };
    }

    // Ajouter la signature du capitaine
    if (_captainSignature != null) {
      final base64CaptainSignature = base64Encode(_captainSignature!);
      signaturesData['captain'] = {
        'signature_data': base64CaptainSignature,
        'signed_at': DateTime.now().toIso8601String(),
        'type': 'captain',
      };
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF1BB35B)),
            SizedBox(width: 8),
            Text('Signatures complètes'),
          ],
        ),
        content: Text(
          'Toutes les signatures ont été collectées :\n'
              '• ${_signatures.length} participant(s)\n'
              '• 1 signature capitaine\n\n'
              'Retour à la validation de l\'inspection.',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fermer le dialogue
              // Retourner les données de signatures
              Navigator.of(context).pop(signaturesData);
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1BB35B),
              foregroundColor: Colors.white,
            ),
            child: const Text('Continuer la validation'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF6A00),
      ),
    );
  }

  Widget _buildSignaturePreview(Uint8List signatureBytes) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: Image.memory(
          signatureBytes,
          fit: BoxFit.contain,
          width: double.infinity,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalSteps = widget.participants.length + 1; // +1 pour le capitaine
    final currentStep = _isShowingCaptainSignature
        ? totalSteps
        : _currentParticipant + 1;

    return Scaffold(
      appBar: AppBar(
        title: Text('Signatures - Inspection #${widget.inspectionId}'),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF6A00), Color(0xFF1BB35B)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF4EB), Color(0xFFEFFBF4)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Indicateur de progression
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    _isShowingCaptainSignature
                        ? 'Signature du capitaine'
                        : 'Signature ${currentStep} sur $totalSteps',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _isShowingCaptainSignature
                          ? const Color(0xFFFF6A00)
                          : const Color(0xFF1BB35B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: currentStep / totalSteps,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _isShowingCaptainSignature
                          ? const Color(0xFFFF6A00)
                          : const Color(0xFF1BB35B),
                    ),
                  ),
                ],
              ),
            ),

            // Zone de signature
            Expanded(
              child: _isShowingCaptainSignature
                  ? _buildCaptainSignatureView()
                  : _buildParticipantSignatureView(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(currentStep, totalSteps),
    );
  }

  Widget _buildParticipantSignatureView() {
    return PageView.builder(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.participants.length,
      itemBuilder: (context, index) {
        final participant = widget.participants[index];
        final name = participant['name'] ?? 'Participant ${participant['id']}';
        final participantId = participant['id'] as int;
        final hasSignature = _signatures.containsKey(participantId);

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFF1BB35B),
                        child: Text(
                          name[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (participant['email'] != null)
                              Text(
                                participant['email'],
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (hasSignature)
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF1BB35B),
                          size: 24,
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    hasSignature
                        ? 'Signature enregistrée. Vous pouvez modifier si nécessaire :'
                        : 'Veuillez signer dans la zone ci-dessous :',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),

                  // Zone de signature
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF1BB35B),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Signature(
                          controller: _controllers[index]!,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Boutons d'action
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _controllers[index]!.clear(),
                          icon: const Icon(Icons.clear),
                          label: const Text('Effacer'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFFF6A00),
                            side: const BorderSide(color: Color(0xFFFF6A00)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          onPressed: _saveCurrentSignature,
                          icon: Icon(_currentParticipant == widget.participants.length - 1
                              ? Icons.supervisor_account
                              : Icons.arrow_forward),
                          label: Text(_currentParticipant == widget.participants.length - 1
                              ? 'Signature capitaine'
                              : 'Suivant'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF1BB35B),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCaptainSignatureView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFFFF6A00),
                    child: const Icon(
                      Icons.supervisor_account,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Signature du Capitaine',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Validation finale de l\'inspection',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_captainSignature != null)
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFFFF6A00),
                      size: 24,
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                _captainSignature != null
                    ? 'Signature du capitaine enregistrée. Vous pouvez modifier si nécessaire :'
                    : 'Signature du capitaine requise pour valider l\'inspection :',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),

              // Zone de signature du capitaine
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFFF6A00),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Signature(
                      controller: _captainController!,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Boutons d'action pour le capitaine
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _captainController!.clear(),
                      icon: const Icon(Icons.clear),
                      label: const Text('Effacer'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFF6A00),
                        side: const BorderSide(color: Color(0xFFFF6A00)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: _saveCurrentSignature,
                      icon: const Icon(Icons.check),
                      label: const Text('Valider l\'inspection'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6A00),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(int currentStep, int totalSteps) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (currentStep > 1)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _previousParticipant,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Précédent'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFF6A00),
                    side: const BorderSide(color: Color(0xFFFF6A00)),
                  ),
                ),
              ),
            if (currentStep > 1) const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFF1BB35B),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_signatures.length}/${widget.participants.length} participants signés',
                      style: const TextStyle(
                        color: Color(0xFF1BB35B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}