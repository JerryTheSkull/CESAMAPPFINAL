import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'app_routes.dart';
import 'constants/colors.dart';
import 'models/registration_data.dart';
import 'models/cesam_user.dart';
import 'providers/user_profile_provider.dart';

import 'screens/login_page.dart';
import 'screens/main_screen.dart';
import 'pages/profile_acad_page.dart';
import 'screens/register/step1_personal_info.dart';
import 'screens/register/step2_academic_info.dart';
import 'screens/register/step3_upload_cv.dart';
import 'screens/register/step4_amci.dart';
import 'screens/register/step5_email_verification.dart';
import 'screens/register/step6_waiting_admin.dart';
import 'options/amci_code_page.dart';

// 🔔 Fonction pour gérer les notifications en background
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Notification reçue en background: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Firebase
  await Firebase.initializeApp();

  // 🔔 Récupérer le token FCM - AJOUT ICI
  String? token = await FirebaseMessaging.instance.getToken();
  print('🔔 FCM Token: $token');

  // Configurer le handler pour les messages en background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Demander la permission sur iOS
  NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  print('Permission granted: ${settings.authorizationStatus}');

  runApp(const CesamApp());
}

class CesamApp extends StatelessWidget {
  const CesamApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Écouter les notifications en foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        // Tu peux aussi afficher un SnackBar ou un Dialog ici
        print('Notification reçue: ${message.notification!.title}');
      }
    });

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProfileProvider()),
      ],
      child: MaterialApp(
        title: 'CESAM',
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.login,
        onGenerateRoute: (settings) {
          final args = settings.arguments;

          if (settings.name == AppRoutes.main && args is CesamUser) {
            return MaterialPageRoute(builder: (_) => MainScreen(user: args));
          }

          switch (settings.name) {
            case AppRoutes.login:
              return MaterialPageRoute(builder: (_) => const LoginPage());
            case AppRoutes.profile:
              return MaterialPageRoute(
                builder: (_) => ProfileAcadPage(
                  initialUser: CesamUser(name: 'Invité', email: '', isAdmin: false),
                ),
              );
            case AppRoutes.registerStep1:
              return MaterialPageRoute(
                builder: (_) => Step1PersonalInfo(
                  data: args is RegistrationData ? args : RegistrationData(),
                ),
              );
            case AppRoutes.registerStep2:
              return MaterialPageRoute(
                builder: (_) => Step2AcademicInfo(
                  data: args is RegistrationData ? args : RegistrationData(),
                ),
              );
            case AppRoutes.registerStep3:
              return MaterialPageRoute(
                builder: (_) => Step3UploadCV(
                  data: args is RegistrationData ? args : RegistrationData(),
                ),
              );
            case AppRoutes.registerStep4:
              return MaterialPageRoute(
                builder: (_) => Step4AMCI(
                  data: args is RegistrationData ? args : RegistrationData(),
                ),
              );
            case AppRoutes.registerStep5:
              return MaterialPageRoute(
                builder: (_) => Step5EmailVerification(
                  data: args is RegistrationData ? args : RegistrationData(),
                ),
              );
            case AppRoutes.registerStep6:
              return MaterialPageRoute(
                builder: (_) => Step6WaitingAdmin(
                  data: args is RegistrationData ? args : null,
                ),
              );
            case AppRoutes.amciCode:
              return MaterialPageRoute(builder: (_) => const AmciCodePage());
            default:
              return MaterialPageRoute(
                builder: (_) => const Scaffold(
                  body: Center(child: Text("Page non trouvée")),
                ),
              );
          }
        },
        theme: ThemeData(
          primaryColor: CesamColors.primary,
          scaffoldBackgroundColor: CesamColors.background,
          fontFamily: 'Roboto',
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: CesamColors.primary,
            background: CesamColors.background,
          ),
        ),
      ),
    );
  }
}