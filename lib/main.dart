import 'package:fin_trackr/constants/constant.dart';
import 'package:fin_trackr/db/functions/account_group_function.dart';
import 'package:fin_trackr/db/functions/category_functions.dart';
import 'package:fin_trackr/db/functions/currency_function.dart';
import 'package:fin_trackr/db/functions/transaction_function.dart';
import 'package:fin_trackr/models/account_group/account_group_model_db.dart';
import 'package:fin_trackr/models/category/category_model_db.dart';
import 'package:fin_trackr/models/currency/curency_model.db.dart';
import 'package:fin_trackr/models/transactions/transaction_model_db.dart';
import 'package:fin_trackr/screens/welcome_screen/welcome_screen1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fin_trackr/screens/splash_screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/accounts_screen/balance_calculation.dart';
import 'package:local_auth/local_auth.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(CategoryTypeAdapter().typeId)) {
    Hive.registerAdapter(CategoryTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(CategoryModelAdapter().typeId)) {
    Hive.registerAdapter(CategoryModelAdapter());
  }
  if (!Hive.isAdapterRegistered(CurrencyModelAdapter().typeId)) {
    Hive.registerAdapter(CurrencyModelAdapter());
  }
  if (!Hive.isAdapterRegistered(AccountTypeAdapter().typeId)) {
    Hive.registerAdapter(AccountTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(AccountGroupModelAdapter().typeId)) {
    Hive.registerAdapter(AccountGroupModelAdapter());
  }
  if (!Hive.isAdapterRegistered(TransactionModelAdapter().typeId)) {
    Hive.registerAdapter(TransactionModelAdapter());
  }

 // Fingerprint authentication
  final LocalAuthentication auth = LocalAuthentication();
  bool authenticated = false;
  try {
    authenticated = await auth.authenticate(
      localizedReason: 'Please authenticate to access the app',
      options: const AuthenticationOptions(
        biometricOnly: false,
        stickyAuth: true,
      ),
    );
  } on PlatformException catch (e) {
    print('Error authenticating: $e');
  }

  // Proceed to the app if authenticated
  if (authenticated) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      bool hasSeenWelcomeScreen = preferences.getBool('hasSeenWelcomeScreen') ?? false;
      runApp(MyApp(hasSeenWelcomeScreen));
    });
  } else {
    print('Authentication failed');
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) async {
      // Quit the application if not authenticated
      SystemNavigator.pop();
    });
  }
}


  // await addInitialData();
  // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
  //     .then((_) async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   bool hasSeenWelcomeScreen =
  //       preferences.getBool('hasSeenWelcomeScreen') ?? false;
  //   runApp(MyApp(hasSeenWelcomeScreen));
//   });
// }



class MyApp extends StatelessWidget {
  final bool hasScreenWelcomeScreen;
  const MyApp(this.hasScreenWelcomeScreen, {super.key});

  @override
  Widget build(BuildContext context) {
    TransactionDB.instance.refresh();
    CategoryDB.instance.getAllCategory();
    getAllAccountGroup();
    getCurrency();
    getAllAccountAmount();
    accountGroupBalanceAmount();

    // Disables landscape and portrait mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'Budget Buddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(color: AppColor.ftScafoldColor),
        primaryColor: AppColor.ftScafoldColor,
        splashFactory: NoSplash.splashFactory,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColor.ftScafoldColor),
        useMaterial3: true,
      ),
      builder: (context, child) => MaterialApp(
        home: hasScreenWelcomeScreen
            ? const SplashScreen()
            : const WelcomeScreenOne(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
