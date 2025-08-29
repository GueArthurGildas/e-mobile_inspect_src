import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_app_divkit/me/controllers/inspections_controller.dart';
import 'package:test_app_divkit/me/views/form_managing_test/state/inspection_wizard_ctrl.dart';
import 'package:test_app_divkit/me/views/form_managing_test/ui/inspection_list_screen.dart';
import 'package:test_app_divkit/me/views/form_managing_test/ui/app_theme.dart';



//*** my simple main_form
// void main() {
//   runApp( MaterialApp(
//     debugShowCheckedModeBanner: false,
//     theme: buildAppTheme(),
//     home: InspectionListScreen(),
//   ));
// }
//**@e *******


/********************************************************************************************/

//
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:test_app_divkit/me/views/auth/splash_screen.dart';
import 'package:test_app_divkit/me/views/shared/app_preferences.dart';
import 'package:test_app_divkit/me/views/users/screen_test.dart';
import 'me/routes//app_pages.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await initializeDateFormatting('fr_FR');
//   await AppPrefs.instance.init();
//
//   runApp(MyApp());
// }


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR');
  await AppPrefs.instance.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InspectionWizardCtrl()),
      ],
      child: const MyApp(),
    ),);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: MaterialApp(
        title: 'Mirah App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
        ),
        home:
        SplashScreen(), //UsersPage(),//plashScreen1(),//,//PendingInspectionPage(),//NavireStatusPage(),//HeroWidgetListPage(),//AnimatedListWidgetListPage(),//FormInfosGeneralesScreen(),//FormulaireStyleImage(),//InspectionWizardScreen(),//NavireStatusPage(), //HomeMenuPage(),//SplashScreen1(),

        onGenerateRoute:
        AppPages.generateRoute, // gestion des routes dynamiques
        //routes: AppPages.routes,
      ),
    );
  }
}




