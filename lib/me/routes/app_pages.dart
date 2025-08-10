import 'package:flutter/material.dart';
import 'package:test_app_divkit/me/views/auth/login_screen.dart';
import 'package:test_app_divkit/me/views/auth/myHome.dart';
import 'package:test_app_divkit/me/views/auth/splash_screen.dart';
import 'package:test_app_divkit/me/views/auth/sync_screen.dart';
import 'package:test_app_divkit/me/views/inspection/inspection_detail_screen.dart';
import 'package:test_app_divkit/me/views/inspection/inspection_form_screen.dart';
import 'package:test_app_divkit/me/views/inspection/inspection_list_screen.dart';
import 'package:test_app_divkit/me/views/inspection/section_inspection_form/step_1/informations_initiales.dart';
import 'package:test_app_divkit/me/views/inspection/section_inspection_form/step_2/informations_responsables.dart';
import 'package:test_app_divkit/me/views/inspection/section_inspection_form/step_3/inspection_documents.dart';
import 'package:test_app_divkit/me/views/inspection/section_inspection_form/step_4/informations_engins.dart';
import 'package:test_app_divkit/me/views/inspection/section_inspection_form/step_5/informations_infractions.dart';
import 'package:test_app_divkit/me/views/inspection/section_inspection_form/step_6/inspection_soumission.dart';

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

      // case AppRoutes.home:
      //   return MaterialPageRoute(builder: (_) => Home1Page());

      case AppRoutes.homeMenu:
        return MaterialPageRoute(builder: (_) => HomeMenuPage());

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
      case AppRoutes.inspectionInformationsInfractions:
        return MaterialPageRoute<Map<String, dynamic>?>(
          builder: (_) => const FormInfosInfractionsScreen(),
          settings: settings,
        );
      case AppRoutes.inspectionSoumission:
        return MaterialPageRoute<Map<String, dynamic>?>(
          builder: (_) => const FormInspectionSoumissionScreen(),
          settings: settings,
        );

      case AppRoutes.pendingInspection:
        return MaterialPageRoute(builder: (_) => PendingInspectionPage());

      case AppRoutes.navireStatus:
        return MaterialPageRoute(builder: (_) => NavireStatusPage());
      // //
      // case AppRoutes.inspections:
      //   return MaterialPageRoute(builder: (_) => InspectionListScreen());
      //
      // case AppRoutes.inspectionDetail:
      //   final args = settings.arguments as Map<String, dynamic>?;
      //   return MaterialPageRoute(
      //     builder: (_) => InspectionDetailScreen(
      //       inspectionId: args?['id'],
      //     ),
      //   );
      //
      // case AppRoutes.inspectionForm:
      //   final args = settings.arguments as Map<String, dynamic>?;
      //   return MaterialPageRoute(
      //     builder: (_) => InspectionFormScreen(
      //       inspectionId: args?['id'],
      //     ),
      //   );
      //
      // case AppRoutes.profile:
      //   return MaterialPageRoute(builder: (_) => UserProfileScreen());

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
