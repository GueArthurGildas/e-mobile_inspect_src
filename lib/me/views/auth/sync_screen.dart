import 'package:flutter/material.dart';
import 'package:test_app_divkit/me/controllers/sync_controller.dart';
import 'package:test_app_divkit/me/routes/app_routes.dart';
import 'package:test_app_divkit/me/views/shared/app_preferences.dart';
import 'package:test_app_divkit/me/views/shared/common.dart';


enum SyncStatus {
  initializing, // initial state, checking connection and sync status
  syncing,      // curr syncing
  needsInternetToSync, // not connected, and first-time sync is required
  readyToProceed,   // either synced, or offline but previously synced
  error         // handling errors during sync
}

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  final SyncController _syncController = SyncController.instance;

  SyncStatus _status = SyncStatus.initializing;
  String _errorMessage = '';

  static const Color _primaryColor = Color(0xFFFF6A00);
  static const Color _syncProgressColor = Colors.green;
  static const TextStyle _titleStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 1.0,
  );
  static const TextStyle _subtitleStyle = TextStyle(fontSize: 16, color: Colors.white70);


  @override
  void initState() {
    super.initState();
    _initializeSync();
  }

  Future<void> _initializeSync() async {
    if (!mounted) return;

    final bool isConnected = await Common.checkInternetConnection();
    final bool isAlreadySynced = await AppPrefs.instance.getBool("sync") ?? false;

    if (isConnected) {
      if (!isAlreadySynced) {
        setState(() {
          _status = SyncStatus.syncing;
        });
        try {
          await _syncController.syncAll();
          await AppPrefs.instance.setBool("sync", true);
          if (mounted) {
            setState(() {
              _status = SyncStatus.readyToProceed;
            });
          }
        } catch (e) {
          print("Error during sync: $e");
          if (mounted) {
            setState(() {
              _status = SyncStatus.error;
              _errorMessage = "Erreur de synchronisation: $e";
            });
          }
        }
      } else {
        // connected and already synced
        if (mounted) {
          setState(() {
            _status = SyncStatus.readyToProceed;
          });
        }
      }
    } else {
      // not connected
      if (isAlreadySynced) {
        if (mounted) {
          setState(() {
            _status = SyncStatus.readyToProceed;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _status = SyncStatus.needsInternetToSync;
          });
        }
      }
    }
  }

  void _navigateToNextScreen() {
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.inspectionWizard, // AppRoutes.home
            (route) => false,
      );
    }
  }

  Widget _buildInitializingView() {
    return _buildMessageView(
      icon: Icons.hourglass_empty,
      message: "Initialisation...",
      showProgress: true,
    );
  }

  Widget _buildSyncingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: CircularProgressIndicator(
              strokeWidth: 8,
              valueColor: const AlwaysStoppedAnimation<Color>(_syncProgressColor),
              backgroundColor: Colors.white.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 40),
          const Text("Synchronisation en cours...", style: _titleStyle),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              "Veuillez patienter pendant que nous mettons à jour les données locales.",
              textAlign: TextAlign.center,
              style: _subtitleStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageView({
    required IconData icon,
    required String message,
    String? details,
    bool showProgress = false,
    Widget? actionButton,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.white70),
            const SizedBox(height: 24),
            Text(message, style: _titleStyle, textAlign: TextAlign.center),
            if (details != null) ...[
              const SizedBox(height: 12),
              Text(details, style: _subtitleStyle, textAlign: TextAlign.center),
            ],
            if (showProgress) ...[
              const SizedBox(height: 32),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withValues(alpha: 0.7)),
              ),
            ],
            if (actionButton != null) ...[
              const SizedBox(height: 32),
              actionButton,
            ]
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    // navigate after the build cycle if status is readyToProceed
    if (_status == SyncStatus.readyToProceed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToNextScreen();
      });

      return const Scaffold(
        backgroundColor: _primaryColor,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    Widget bodyContent;
    switch (_status) {
      case SyncStatus.initializing:
        bodyContent = _buildInitializingView();
        break;
      case SyncStatus.syncing:
        bodyContent = _buildSyncingView();
        break;
      case SyncStatus.needsInternetToSync:
        bodyContent = _buildMessageView(
            icon: Icons.wifi_off,
            message: "Connexion internet requise",
            details: "Veuillez vous connecter à internet pour la synchronisation initiale des données.",
            actionButton: ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text("Réessayer"),
              onPressed: () {
                setState(() {
                  _status = SyncStatus.initializing;
                });
                _initializeSync();
              },
              style: ElevatedButton.styleFrom(
                  foregroundColor: _primaryColor, backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)
              ),
            )
        );
        break;
      case SyncStatus.error:
        bodyContent = _buildMessageView(
            icon: Icons.error_outline,
            message: "Erreur",
            details: _errorMessage.isNotEmpty ? _errorMessage : "Une erreur inconnue s'est produite.",
            actionButton: ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text("Réessayer la synchronisation"),
              onPressed: () {
                setState(() {
                  _status = SyncStatus.initializing;
                });
                _initializeSync();
              },
              style: ElevatedButton.styleFrom(
                  foregroundColor: _primaryColor, backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)
              ),
            )
        );
        break;
      case SyncStatus.readyToProceed:  // alr handled but needed to avoid dart error
        bodyContent = const Center(child: CircularProgressIndicator(color: Colors.white));
        break;
    }

    return Scaffold(
      backgroundColor: _primaryColor,
      body: SafeArea(
        child: AnimatedSwitcher( // smooth transition between states
          duration: const Duration(milliseconds: 300),
          child: Container(
            key: ValueKey<SyncStatus>(_status),
            child: bodyContent,
          ),
        ),
      ),
    );
  }
}