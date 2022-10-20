import 'package:auto_route/auto_route.dart';
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
import 'package:netflox/services/shared_preferences.dart';
import 'package:netflox/services/tmdb_service.dart';
import 'package:netflox/ui/router/router.gr.dart';
import 'package:netflox/ui/screens/auths/auth_screen.dart';
import 'package:netflox/ui/screens/auths/unverified_user_screen.dart';
import 'package:netflox/ui/screens/error_screen.dart';
import 'package:netflox/ui/widgets/custom_snackbar.dart';
import 'package:netflox/ui/widgets/error_widget.dart';
import 'package:netflox/ui/screens/loading_screen.dart';
import 'package:nil/nil.dart';
import 'package:provider/provider.dart';
import 'data/blocs/account/auth/auth_cubit.dart';
import 'data/blocs/app_localization/app_localization_cubit.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'data/blocs/sftp_server/ssh_connection/ssh_connection.dart';
import 'data/blocs/app_config.dart';
import 'firebase_options.dart';

Future<void> main() async {
  await initApp();
  runApp(MultiProvider(providers: [
    BlocProvider(
      create: (context) => ConnectivityManager(),
    ),
    BlocProvider(create: (BuildContext context) => AppLocalization()),
    BlocProvider(create: (BuildContext context) => ThemeDataCubit()),
  ], child: NetfloxApp()));
}

Future<void> initApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
    if (kDebugMode) {
      return CustomErrorWidget(
        errorDescription: errorDetails.exceptionAsString(),
      );
    }
    return const Nil();
  };
  await SharedPreferenceService.init();
  if (!kIsWeb) {
    await LocalStorageManager.init();
  }
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight
  ]);
}

class NetfloxApp extends StatelessWidget {
  final NetfloxRouter _router;
  NetfloxApp({super.key, NetfloxRouter? router})
      : _router = router ?? NetfloxRouter();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeDataCubit, ThemeDataState>(
        builder: (context, themeState) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarIconBrightness: MediaQuery.platformBrightnessOf(context),
          statusBarColor: Colors.transparent));
      return BlocBuilder<AppLocalization, AppLocalizationState>(
          builder: (context, state) => KeyedSubtree(
              key: ValueKey(state),
              child: MaterialApp.router(
                builder: (context, child) {
                  return ResponsiveWrapper.builder(
                      ClampingScrollWrapper(child: child!),
                      breakpoints: [
                        const ResponsiveBreakpoint.resize(300, name: MOBILE),
                        const ResponsiveBreakpoint.autoScale(700,
                            scaleFactor: 1.1, name: TABLET),
                        const ResponsiveBreakpoint.resize(1000, name: DESKTOP),
                        const ResponsiveBreakpoint.autoScale(1700, name: "XL"),
                      ],
                      breakpointsLandscape: [
                        const ResponsiveBreakpoint.autoScale(500,
                            scaleFactor: 0.5, name: MOBILE),
                        const ResponsiveBreakpoint.autoScale(800,
                            scaleFactor: 0.7, name: TABLET),
                        const ResponsiveBreakpoint.autoScale(1100,
                            name: DESKTOP),
                        const ResponsiveBreakpoint.autoScale(1700, name: "XL"),
                      ],
                      defaultScale: false,
                      minWidth: 200,
                      background:
                          Container(color: Theme.of(context).backgroundColor));
                },
                scrollBehavior: const MaterialScrollBehavior().copyWith(
                  dragDevices: {
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.touch,
                    PointerDeviceKind.stylus,
                    PointerDeviceKind.trackpad,
                    PointerDeviceKind.unknown
                  },
                ),
                routerDelegate: _router.delegate(),
                supportedLocales: AppLocalization.supportedLocales,
                locale: state.currentLocale,
                localizationsDelegates: const [
                  AppLocalizationsDelegate(),
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                routeInformationParser:
                    _router.defaultRouteParser(includePrefixMatches: true),
                theme: themeState.data,
                debugShowCheckedModeBanner: false,
              )));
    });
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
            child: child,
          );
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
