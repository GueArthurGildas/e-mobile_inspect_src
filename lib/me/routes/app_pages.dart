import 'package:flutter/material.dart';
import 'package:test_app_divkit/me/views/auth/myHome.dart';
import 'package:test_app_divkit/me/views/auth/splash_screen1.dart';
import 'package:test_app_divkit/me/views/auth/splash_screen2.dart';
import 'package:test_app_divkit/me/views/inspection/inspection_detail_screen.dart';
import 'package:test_app_divkit/me/views/inspection/inspection_form_screen.dart';
import 'package:test_app_divkit/me/views/inspection/inspection_list_screen.dart';
import 'package:test_app_divkit/ui/screen/home/home1.dart';
import 'package:test_app_divkit/ui/screen/signin/signin1.dart';

//



//
import 'app_routes.dart';
//
class AppPages {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => SplashScreen1());

      case AppRoutes.splash2:
        return MaterialPageRoute(builder: (_) => SplashScreen2());

      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => Signin1Page());

      // case AppRoutes.home:
      //   return MaterialPageRoute(builder: (_) => Home1Page());

      case AppRoutes.homeMenu:
        return MaterialPageRoute(builder: (_) => HomeMenuPage());

      case AppRoutes.inspectionWizard:
        return MaterialPageRoute(builder: (_) => InspectionWizardScreen());

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
