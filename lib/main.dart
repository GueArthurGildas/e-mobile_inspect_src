import 'package:flutter/material.dart';
import 'package:test_app_divkit/me/controllers/user_controller.dart';
import 'package:test_app_divkit/me/services/api_get/user_api_service.dart';
import 'package:test_app_divkit/me/views/auth/myHome.dart';
import 'package:test_app_divkit/me/views/auth/splash_screen1.dart';
import 'package:test_app_divkit/me/views/inspection/inspection_detail_screen.dart';
import 'package:test_app_divkit/me/views/inspection/inspection_form_screen.dart';
import 'package:test_app_divkit/me/views/inspection/inspection_list_screen.dart';
import 'package:test_app_divkit/me/views/inspection/section_inspection_form/model_form_exempl/form_1.dart';
import 'package:test_app_divkit/me/views/inspection/section_inspection_form/model_form_exempl/form_2.dart';
import 'package:test_app_divkit/me/views/inspection/section_inspection_form/model_form_exempl/form_3.dart';
import 'package:test_app_divkit/me/views/inspection/section_inspection_form/section1.dart';
import 'package:test_app_divkit/me/views/tbl_ref_screen/pays.dart';
import 'package:test_app_divkit/me/views/tbl_ref_screen/activites_navires_screen.dart';
import 'package:test_app_divkit/me/views/tbl_ref_screen/agents_shiping_screen.dart';
import 'package:test_app_divkit/me/views/tbl_ref_screen/conservations_screen.dart';
import 'package:test_app_divkit/me/views/tbl_ref_screen/consignations_screen.dart';
import 'package:test_app_divkit/me/views/tbl_ref_screen/especes_screen.dart';
import 'package:test_app_divkit/me/views/tbl_ref_screen/etats_engins_screen.dart';
import 'package:test_app_divkit/me/views/tbl_ref_screen/pavillons_screen.dart';
import 'package:test_app_divkit/me/views/tbl_ref_screen/ports_screen.dart';
import 'package:test_app_divkit/me/views/tbl_ref_screen/presentations_screen.dart';
import 'package:test_app_divkit/me/views/tbl_ref_screen/typenavires_screen.dart';
import 'package:test_app_divkit/me/views/tbl_ref_screen/types_documents_screen.dart';
import 'package:test_app_divkit/me/views/tbl_ref_screen/types_engins_screen.dart';
import 'package:test_app_divkit/me/views/tbl_ref_screen/zones_capture_screen.dart';
import 'package:test_app_divkit/me/views/users/screen_test.dart';
import 'package:test_app_divkit/ui/screen/home/home1.dart';
import 'package:test_app_divkit/ui/screen/timeline/timeline_list.dart';
import 'package:test_app_divkit/ui/widget/animated_cross_fade/animated_cross_fade_list.dart';
import 'package:test_app_divkit/ui/widget/animated_list/animated_list_widget_list.dart';
import 'package:test_app_divkit/ui/widget/app_bar/app_bar_list.dart';
import 'package:test_app_divkit/ui/widget/back_drop_filter/back_drop_filter_widget.dart';
import 'package:test_app_divkit/ui/widget/card/card_widget_list.dart';
import 'package:test_app_divkit/ui/widget/chip/chip_widget.dart';
import 'package:test_app_divkit/ui/widget/column/column_widget_list.dart';
import 'package:test_app_divkit/ui/widget/datatable/datatable_widget_list.dart';
import 'package:test_app_divkit/ui/widget/fade_transition/fade_transition.dart';
import 'package:test_app_divkit/ui/widget/hero/hero_widget_list.dart';
import 'package:test_app_divkit/ui/widget/image/image_widget.dart';
import 'package:test_app_divkit/ui/widget/scale_transition/scale_transition.dart';
import 'me/routes//app_pages.dart';

// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Synchronisation API ↔ SQLite',
      theme: ThemeData(primarySwatch: Colors.green),
      home: MenuPrincipalScreen(),
    ),
  );
}

class MenuPrincipalScreen extends StatelessWidget {
  final List<Map<String, dynamic>> ressources = [
    {'title': 'Pavillons', 'screen': const PaysScreen()},
    {'title': 'Typenavires', 'screen': const TypenaviresScreen()},
    {'title': 'Ports', 'screen': const PortsScreen()},
    {'title': 'ActivitesNavires', 'screen': const ActivitesNaviresScreen()},
    {'title': 'Consignations', 'screen': const ConsignationsScreen()},
    {'title': 'AgentsShiping', 'screen': const AgentsShipingScreen()},
    {'title': 'TypesDocuments', 'screen': const TypesDocumentsScreen()},
    {'title': 'TypesEngins', 'screen': const TypesEnginsScreen()},
    {'title': 'EtatsEngins', 'screen': const EtatsEnginsScreen()},
    {'title': 'Especes', 'screen': const EspecesScreen()},
    {'title': 'ZonesCapture', 'screen': const ZonesCaptureScreen()},
    {'title': 'Presentations', 'screen': const PresentationsScreen()},
    {'title': 'Conservations', 'screen': const ConservationsScreen()},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Menu Synchronisation")),
      body: ListView.builder(
        itemCount: ressources.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(ressources[index]['title']),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ressources[index]['screen']),
              );
            },
          );
        },
      ),
    );
  }
}

// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider<UserController>(
//       create: (_) => UserController()..loadUsers(),
//       child: MaterialApp(
//         title: 'Flutter CRUD Demo',
//         theme: ThemeData(
//           primarySwatch: Colors.blue,
//         ),
//         home: ActivitesNaviresScreen(),//PaysScreen(),//UsersPage(),
//       ),
//     );
//   }
// }

// Liste des screen que je souhaite utiliser dans mon application
//InspectionWizardScreen(),//PendingInspectionPage(),//NavireStatusPage(),//HeroWidgetListPage(),//AnimatedListWidgetListPage(),//FormInfosGeneralesScreen(),//FormulaireStyleImage(),//InspectionWizardScreen(),//NavireStatusPage(), //HomeMenuPage(),//SplashScreen1(),
//home: SplashScreen1(),//InspectionWizardScreen(),//PendingInspectionPage(),//NavireStatusPage(),//HeroWidgetListPage(),//AnimatedListWidgetListPage(),//FormInfosGeneralesScreen(),//FormulaireStyleImage(),//InspectionWizardScreen(),//NavireStatusPage(), //HomeMenuPage(),//SplashScreen1(),
