import 'package:auto_route/auto_route.dart' show AutoRouter;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/data/blocs/connectivity/connectivity_manager.dart';
import 'package:netflox/data/blocs/theme/theme_cubit_cubit.dart';
import 'package:netflox/data/models/user/user.dart';
import 'package:netflox/data/repositories/tmdb_repository.dart';
import 'package:netflox/services/local_storage_manager.dart';
import 'package:netflox/services/notification_service.dart';
import 'package:netflox/services/shared_preferences.dart';
import 'package:netflox/services/tmdb_service.dart';
import 'package:netflox/ui/router/idle_timed_auto_push_route.dart';
import 'package:netflox/ui/router/router.gr.dart';
import 'package:netflox/ui/screens/auths/auth_screen.dart';
import 'package:netflox/ui/screens/auths/unverified_user_screen.dart';
import 'package:netflox/ui/screens/error_screen.dart';
import 'package:netflox/ui/widgets/custom_snackbar.dart';
import 'package:netflox/ui/widgets/error_widget.dart';
import 'package:netflox/ui/screens/loading_screen.dart';
import 'package:netflox/ui/widgets/upload_process_provider_widget.dart';
import 'package:nil/nil.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/utils/responsive_utils.dart';
import 'data/blocs/account/auth/auth_cubit.dart';
import 'data/blocs/app_localization/app_localization_cubit.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'data/blocs/sftp_server/ssh_connection/ssh_connection.dart';
import 'data/blocs/app_config.dart';
import 'firebase_options.dart';

Future<void> main() async {
  await initApp();
  runApp(MultiProvider(providers: [
    ListenableProvider(
      dispose: (context, value) => value.dispose(),
      create: (context) => NetfloxRouter(),
    ),
    BlocProvider(
      create: (context) => ConnectivityManager(),
    ),
    BlocProvider(create: (BuildContext context) => AppLocalization()),
    BlocProvider(create: (BuildContext context) => ThemeDataCubit()),
  ], child: const NetfloxApp()));
}

Future<void> initApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.init();
  await SharedPreferenceService.init();
  if (!kIsWeb) {
    await LocalStorageManager.init();
  }
  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
    if (kDebugMode) {
      return CustomErrorWidget(
        errorDescription: errorDetails.exceptionAsString(),
      );
    }
    return const Nil();
  };
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight
  ]);
}

class NetfloxApp extends StatefulWidget {
  const NetfloxApp({super.key});

  @override
  State<NetfloxApp> createState() => _NetfloxAppState();
}

class _NetfloxAppState extends State<NetfloxApp> {
  @override
  void dispose() {
    super.dispose();
    NotificationService.cancelAll();
  }

  Widget _buildResponsiveLayout(context, child) {
    return ResponsiveWrapper.builder(ClampingScrollWrapper(child: child!),
        breakpoints: [
          const ResponsiveBreakpoint.resize(300, name: MOBILE),
          const ResponsiveBreakpoint.autoScale(700, name: TABLET),
          const ResponsiveBreakpoint.resize(1000, name: DESKTOP),
          const ResponsiveBreakpoint.autoScaleDown(1400),
          const ResponsiveBreakpoint.autoScale(1700, name: "XL"),
        ],
        landscapePlatforms: ResponsiveTargetPlatform.values,
        breakpointsLandscape: [
          const ResponsiveBreakpoint.autoScale(500,
              scaleFactor: 0.5, name: MOBILE),
          const ResponsiveBreakpoint.autoScale(800,
              scaleFactor: 0.7, name: TABLET),
          const ResponsiveBreakpoint.autoScale(1100, name: DESKTOP),
          const ResponsiveBreakpoint.autoScale(
            1400,
          ),
          const ResponsiveBreakpoint.autoScale(1700, name: "XL"),
        ],
        defaultScale: false,
        minWidth: 200,
        minWidthLandscape: 300,
        background: Container(color: Theme.of(context).backgroundColor));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeDataCubit, ThemeDataState>(
        builder: (context, themeState) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: _statusBarStyle(themeState.brightness),
        child: BlocBuilder<AppLocalization, AppLocalizationState>(
            builder: (context, state) => KeyedSubtree(
                key: ValueKey(state),
                child: MaterialApp.router(
                  builder: _buildResponsiveLayout,
                  scrollBehavior: const MaterialScrollBehavior().copyWith(
                    dragDevices: {
                      PointerDeviceKind.mouse,
                      PointerDeviceKind.touch,
                      PointerDeviceKind.stylus,
                      PointerDeviceKind.trackpad,
                      PointerDeviceKind.unknown
                    },
                  ),
                  routerDelegate: context.router.delegate(),
                  supportedLocales: AppLocalization.supportedLocales,
                  locale: state.currentLocale,
                  localizationsDelegates: const [
                    AppLocalizationsDelegate(),
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  routeInformationParser: context.router
                      .defaultRouteParser(includePrefixMatches: true),
                  theme: themeState.data,
                  debugShowCheckedModeBanner: false,
                ))),
      );
    });
  }

  SystemUiOverlayStyle _statusBarStyle(Brightness brightness) {
    final androidStatusBarBrightness =
        brightness == Brightness.dark ? Brightness.light : Brightness.dark;
    return SystemUiOverlayStyle(
        statusBarBrightness: brightness,
        statusBarIconBrightness: androidStatusBarBrightness,
        statusBarColor: Colors.transparent);
  }
}

class StackScreen extends StatelessWidget {
  const StackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(),
          ),
          BlocProvider(create: (context) => AppConfigCubit()),
        ],
        child: BlocConsumer<ConnectivityManager, ConnectivityState>(
          builder: (context, state) {
            return const ConnectedScreen();
          },
          listenWhen: (previous, current) => previous != ConnectivityState.init,
          listener: (context, state) {
            final String text;
            Widget? icon;
            if (state.hasNetworkAccess()) {
              text = 'network-connection-success';
            } else {
              text = 'network-connection-problem';
              icon = const Icon(Icons.warning);
            }
            showSnackBar(context, text: text.tr(context), leading: icon);
          },
        ));
  }
}

class ConnectedScreen extends StatelessWidget {
  const ConnectedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) => AutoRouter(
              builder: (context, content) {
                if (state.isAuthenticated()) {
                  final user = state.user!;
                  if (user.verified) {
                    return _buildVerifiedUser(context, user, content);
                  }
                  return const UnverifiedUserScreen();
                } else if (state.isUnauthenticated()) {
                  return const AuthScreen();
                }
                return const LoadingScreen();
              },
            ));
  }

  Widget _buildVerifiedUser(
      BuildContext context, NetfloxUser user, Widget child) {
    return BlocBuilder<AppConfigCubit, AppConfig>(
      builder: (context, state) {
        if (state.success()) {
          final tmdbRepository = TMDBRepository(state.tmdbApiConfig!);
          final language = context.read<AppLocalization>().state.currentLocale;
          final tmdbService = TMDBService(
              repository: tmdbRepository, defaultLanguage: language);
          if (!kIsWeb) {
            return MultiProvider(
              providers: [
                BlocProvider<SSHConnectionCubit>(
                    create: (BuildContext context) =>
                        SSHConnectionCubit.fromUser(user, state.sshConfig!)),
                Provider(
                  create: (context) => tmdbService,
                  dispose: (context, value) => value.close(true),
                )
              ],
              child: UploadProcessManager(child: child),
            );
          } else {
            return Provider(
              create: (context) => tmdbService,
              child: child,
            );
          }
        } else if (state.isLoading()) {
          return LoadingScreen(
            loadingMessage: 'fetching-app-config'.tr(context),
          );
        } else {
          return ErrorScreen(errorCode: state.error);
        }
      },
    );
  }
}
