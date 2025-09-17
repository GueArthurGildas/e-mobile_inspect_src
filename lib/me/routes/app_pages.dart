import 'package:flutter/material.dart';
import 'package:test_app_divkit/me/views/auth/login_screen.dart';
import 'package:test_app_divkit/me/views/auth/myHome.dart';
import 'package:test_app_divkit/me/views/auth/splash_screen.dart';
import 'package:test_app_divkit/me/views/auth/sync_screen.dart';
import 'package:test_app_divkit/me/views/dashboard/test_welcome_screen.dart';
import 'package:test_app_divkit/me/views/form_managing_test/ui/Groups_teams_screen.dart';
import 'package:test_app_divkit/me/views/form_managing_test/ui/inspection_detail_screen.dart';
import 'package:test_app_divkit/me/views/form_managing_test/ui/inspection_list_screen.dart';
import 'package:test_app_divkit/me/views/form_managing_test/ui/profile_current.dart';
import 'package:test_app_divkit/me/views/form_managing_test/ui/side_bar_menu/config_wallet_screen.dart';
import 'package:test_app_divkit/me/views/inspection/inspection_detail_screen.dart';
import 'package:test_app_divkit/me/views/inspection/inspection_form_screen.dart';
import 'package:test_app_divkit/me/views/inspection/inspection_list_screen.dart';
import 'package:test_app_divkit/me/views/inspection/section_inspection_form/step_1/informations_initiales.dart';
import 'package:test_app_divkit/me/views/inspection/section_inspection_form/step_2/informations_responsables.dart';
import 'package:test_app_divkit/me/views/inspection/section_inspection_form/step_3/inspection_documents.dart';
import 'package:test_app_divkit/me/views/inspection/section_inspection_form/step_4/informations_engins.dart';
import 'package:test_app_divkit/me/views/inspection/section_inspection_form/step_5/controle_captures.dart';
import 'package:test_app_divkit/me/views/inspection/section_inspection_form/step_6/inspection_last_step.dart';
import 'package:test_app_divkit/me/views/form_managing_test/ui/validation_screen.dart';
import 'package:test_app_divkit/me/views/form_managing_test/ui/wizard_screen.dart';

import 'app_routes.dart';

class AppPages {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => SplashScreen());

      case AppRoutes.sync:
        return MaterialPageRoute(builder: (_) => SyncScreen());

      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => LoginPage());

      case AppRoutes.homeMenu:
        return MaterialPageRoute(builder: (_) => WalletScreen());

      case AppRoutes.inspectionWizard:
        return MaterialPageRoute(builder: (_) => InspectionWizardScreen());

      case AppRoutes.inspectionInformationsInitiales:
        return MaterialPageRoute<Map<String, dynamic>?>(
          builder: (_) => const FormInfosInitialesScreen(),
          settings: settings,
        );

      case AppRoutes.inspectionInformationsResponsables:
        return MaterialPageRoute<Map<String, dynamic>?>(
          builder: (_) => const FormInfosResponsablesScreen(),
          settings: settings,
        );

      case AppRoutes.inspectionDocuments:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const FormInspectionDocumentsScreen(),
          settings: settings,
        );

      case AppRoutes.inspectionInformationsEngins:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const FormInfosEnginsScreen(),
          settings: settings,
        );

      case AppRoutes.inspectionControleCaptures:
        return MaterialPageRoute<Map<String, dynamic>?>(
          builder: (_) => const FormControleCapturesScreen(),
          settings: settings,
        );

      case AppRoutes.inspectionLastStep:
        return MaterialPageRoute<Map<String, dynamic>?>(
          builder: (_) => const InspectionLastStep(),
          settings: settings,
        );

      case AppRoutes.pendingInspection:
        return MaterialPageRoute(builder: (_) => PendingInspectionPage());

      case AppRoutes.navireStatus:
        return MaterialPageRoute(builder: (_) => NavireStatusPage());

    // ✅ Ajout des 4 classes demandées
      case AppRoutes.inspectionList:
        return MaterialPageRoute(builder: (_) => InspectionListScreen());

      // case AppRoutes.inspectionDetail:
      //   final args = settings.arguments as Map<String, dynamic>?;
      //   return MaterialPageRoute(
      //     builder: (_) => InspectionDetailScreen(
      //       inspectionId: args?['id'],
      //     ),
      //   );

      case AppRoutes.validation:
        return MaterialPageRoute(builder: (_) => ValidationScreen());

      case AppRoutes.wizard:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => WizardScreen(
            inspectionId: args?['id'],
          ),
        );


    case AppRoutes.profile:
      return MaterialPageRoute(builder: (_) => ProfileScreen());
    case AppRoutes.inspections:
      return MaterialPageRoute(builder: (_) => MyInspectionsScreen());
    case AppRoutes.sync:
      return MaterialPageRoute(builder: (_) => SyncCenterScreen());
    case AppRoutes.groups:
      return MaterialPageRoute(builder: (_) => GroupsTeamsScreen());
    case AppRoutes.records:
      return MaterialPageRoute(builder: (_) => RecordsScreen());
    case AppRoutes.settings:
      return MaterialPageRoute(builder: (_) => SettingsScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Aucune route définie pour ${settings.name}'),
            ),
          ),
        );
    }
  }
}
