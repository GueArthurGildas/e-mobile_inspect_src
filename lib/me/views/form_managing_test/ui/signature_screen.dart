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

  /// Dialogue de validation finale après collecte des signatures
  Future<bool?> _showFinalValidationDialog(
      BuildContext context,
      Map<String, Map<String, dynamic>> signaturesData,
      int participantCount,
      ) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Validation',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        // Animation de slide du bas vers le haut
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1), // Commence en bas
            end: Offset.zero, // Arrive en position normale
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85, // hauteur max
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header avec icône d'avertissement
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.shade600,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    size: 48,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'VALIDATION FINALE',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'DERNIÈRE ÉTAPE',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red.shade100,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Récapitulatif des signatures
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.green.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green.shade600, size: 24),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Signatures collectées',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green.shade700,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          '$participantCount participants + 1 capitaine',
                                          style: TextStyle(
                                            color: Colors.green.shade600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Avertissement critique
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.shade300, width: 2),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.lock_outline, color: Colors.red.shade600, size: 24),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'ACTION IRRÉVERSIBLE',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red.shade700,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Cette inspection sera définitivement verrouillée.\nAucune modification ne sera plus possible.',
                                      style: TextStyle(
                                        color: Colors.red.shade700,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        height: 1.4,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Question finale
                            Text(
                              'Voulez-vous vraiment finaliser cette inspection ?',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 12),

                            Text(
                              'Vérifiez que toutes les informations sont correctes avant de continuer.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // --- Boutons en bas, toujours visibles ---
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.grey.shade700,
                                side: BorderSide(color: Colors.grey.shade400),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () => Navigator.of(context).pop(false),
                              icon: const Icon(Icons.close_rounded, size: 20),
                              label: const Text(
                                'Annuler',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.red.shade600,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 2,
                              ),
                              onPressed: () => Navigator.of(context).pop(true),
                              icon: const Icon(Icons.gavel, size: 20),
                              label: const Text(
                                'FINALISER',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
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

  void _completeAllSignatures() async {
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

    // Afficher le dialogue de validation finale
    final shouldContinue = await _showFinalValidationDialog(
      context,
      signaturesData,
      _signatures.length,
    );

    // Vérifier la réponse de l'utilisateur
    if (shouldContinue == true) {
      // L'utilisateur a confirmé - retourner les signatures
      Navigator.of(context).pop(signaturesData);
    }
    // Si shouldContinue == false ou null, on ne fait rien
    // L'utilisateur reste sur l'écran de signatures
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
                          '',
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
                      label: const Text('Continuer'),
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