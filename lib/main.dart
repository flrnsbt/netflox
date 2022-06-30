import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:netflox/data/blocs/netflox_db_manager.dart/netflox_db_manager_cubit.dart';
import 'package:netflox/services/tmdb_service.dart';

import 'package:netflox/ui/widgets/custom_snackbar.dart';
import 'package:netflox/ui/widgets/dialogs.dart';
import 'data/blocs/account_manager/account_manager_bloc.dart';
import 'package:netflox/ui/router/router.dart';

import 'data/blocs/app_localization/app_localization_cubit.dart';
import 'data/repositories/tmdb_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initApp();
  runApp(const NetfloxApp());
}

Future<void> initApp() async {}

class NetfloxApp extends StatelessWidget {
  const NetfloxApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = NetfloxRouter();
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => AppLocalization.init()),
          BlocProvider(
            create: (context) => AccountManager(),
          ),
          BlocProvider(
              create: (context) => NetfloxDBManager(TMDBService(TMDBRepository(
                  defaultLanguage: AppLocalization.instance!.locale)))),
        ],
        child: MaterialApp.router(
          routerDelegate: router.delegate(),
          supportedLocales: AppLocalization.supportedLocales,
          locale: AppLocalization.instance?.locale,
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routeInformationParser: router.defaultRouteParser(),
          theme: ThemeData(
              primaryColor: Colors.deepOrangeAccent,
              colorScheme:
                  ColorScheme.fromSwatch(primarySwatch: Colors.deepOrange)),
          debugShowCheckedModeBanner: false,
        ));
  }
}

class AppGenerator extends StatelessWidget {
  const AppGenerator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AccountManager, AccountManagerState>(
      listener: (context, state) {
        switch (state.runtimeType) {
          case AccountStateSignedOut:
            context.pushRoute(const SignInScreenRoute());
            break;
          case AccountStateSignedIn:
            ScaffoldMessenger.of(context)
                .showSnackBar(CustomSnackBar(text: "Signed In"));
            break;
          case AccountStateError:
            break;
          case AccountStateLoading:
            showDialog(
              context: context,
              builder: (context) => loadingDialog(),
            );
            break;
        }
      },
      builder: (context, state) {
        return AutoTabsScaffold(
            routes: const [
              HomeScreenRoute(),
              LibraryScreenRoute(),
              MyAccountScreenRoute()
            ],
            bottomNavigationBuilder: (_, tabsRouter) {
              return BottomNavigationBar(
                  items: const <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.video_library),
                      label: 'Library',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.account_box),
                      label: 'My Account',
                    ),
                  ],
                  currentIndex: tabsRouter.activeIndex,
                  onTap: tabsRouter.setActiveIndex);
            });
      },
    );
  }
}
