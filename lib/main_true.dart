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






void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mirah App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: UsersPage(),//plashScreen1(),//,//PendingInspectionPage(),//NavireStatusPage(),//HeroWidgetListPage(),//AnimatedListWidgetListPage(),//FormInfosGeneralesScreen(),//FormulaireStyleImage(),//InspectionWizardScreen(),//NavireStatusPage(), //HomeMenuPage(),//SplashScreen1(),
      onGenerateRoute: AppPages.generateRoute, // gestion des routes dynamiques
      //routes: AppPages.routes,
    );
  }
}


// Liste des screen que je souhaite utiliser dans mon application
//InspectionWizardScreen(),//PendingInspectionPage(),//NavireStatusPage(),//HeroWidgetListPage(),//AnimatedListWidgetListPage(),//FormInfosGeneralesScreen(),//FormulaireStyleImage(),//InspectionWizardScreen(),//NavireStatusPage(), //HomeMenuPage(),//SplashScreen1(),
//home: SplashScreen1(),//InspectionWizardScreen(),//PendingInspectionPage(),//NavireStatusPage(),//HeroWidgetListPage(),//AnimatedListWidgetListPage(),//FormInfosGeneralesScreen(),//FormulaireStyleImage(),//InspectionWizardScreen(),//NavireStatusPage(), //HomeMenuPage(),//SplashScreen1(),

