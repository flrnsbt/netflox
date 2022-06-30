// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************
//
// ignore_for_file: type=lint

part of 'router.dart';

class _$NetfloxRouter extends RootStackRouter {
  _$NetfloxRouter([GlobalKey<NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, PageFactory> pagesMap = {
    AppGeneratorRoute.name: (routeData) {
      return MaterialPageX<dynamic>(
          routeData: routeData, child: const AppGenerator());
    },
    HomeScreenRoute.name: (routeData) {
      return MaterialPageX<dynamic>(
          routeData: routeData, child: const HomeScreen());
    },
    LibraryScreenRoute.name: (routeData) {
      return MaterialPageX<dynamic>(
          routeData: routeData, child: const LibraryScreen());
    },
    MyAccountScreenRoute.name: (routeData) {
      return MaterialPageX<dynamic>(
          routeData: routeData, child: const MyAccountScreen());
    },
    SignInScreenRoute.name: (routeData) {
      return MaterialPageX<dynamic>(
          routeData: routeData, child: const SignInScreen());
    },
    SignUpScreenRoute.name: (routeData) {
      return MaterialPageX<dynamic>(
          routeData: routeData, child: const SignUpScreen());
    }
  };

  @override
  List<RouteConfig> get routes => [
        RouteConfig('/#redirect', path: '/', redirectTo: '', fullMatch: true),
        RouteConfig(AppGeneratorRoute.name, path: '', children: [
          RouteConfig('#redirect',
              path: '',
              parent: AppGeneratorRoute.name,
              redirectTo: 'dashboard',
              fullMatch: true),
          RouteConfig(HomeScreenRoute.name,
              path: 'dashboard', parent: AppGeneratorRoute.name),
          RouteConfig(LibraryScreenRoute.name,
              path: 'library-screen', parent: AppGeneratorRoute.name),
          RouteConfig(MyAccountScreenRoute.name,
              path: 'my-account-screen', parent: AppGeneratorRoute.name),
          RouteConfig(SignInScreenRoute.name,
              path: 'sign-in-screen', parent: AppGeneratorRoute.name),
          RouteConfig(SignUpScreenRoute.name,
              path: 'sign-up-screen', parent: AppGeneratorRoute.name)
        ])
      ];
}

/// generated route for
/// [AppGenerator]
class AppGeneratorRoute extends PageRouteInfo<void> {
  const AppGeneratorRoute({List<PageRouteInfo>? children})
      : super(AppGeneratorRoute.name, path: '', initialChildren: children);

  static const String name = 'AppGeneratorRoute';
}

/// generated route for
/// [HomeScreen]
class HomeScreenRoute extends PageRouteInfo<void> {
  const HomeScreenRoute() : super(HomeScreenRoute.name, path: 'dashboard');

  static const String name = 'HomeScreenRoute';
}

/// generated route for
/// [LibraryScreen]
class LibraryScreenRoute extends PageRouteInfo<void> {
  const LibraryScreenRoute()
      : super(LibraryScreenRoute.name, path: 'library-screen');

  static const String name = 'LibraryScreenRoute';
}

/// generated route for
/// [MyAccountScreen]
class MyAccountScreenRoute extends PageRouteInfo<void> {
  const MyAccountScreenRoute()
      : super(MyAccountScreenRoute.name, path: 'my-account-screen');

  static const String name = 'MyAccountScreenRoute';
}

/// generated route for
/// [SignInScreen]
class SignInScreenRoute extends PageRouteInfo<void> {
  const SignInScreenRoute()
      : super(SignInScreenRoute.name, path: 'sign-in-screen');

  static const String name = 'SignInScreenRoute';
}

/// generated route for
/// [SignUpScreen]
class SignUpScreenRoute extends PageRouteInfo<void> {
  const SignUpScreenRoute()
      : super(SignUpScreenRoute.name, path: 'sign-up-screen');

  static const String name = 'SignUpScreenRoute';
}
