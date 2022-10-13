// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************
//
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i17;
import 'package:flutter/cupertino.dart' as _i19;
import 'package:flutter/material.dart' as _i18;
import 'package:netflox/data/models/exception.dart';

import '../../data/blocs/account/auth/auth_form/auth_form_bloc.dart' as _i22;
import '../../data/models/tmdb/media.dart' as _i21;
import '../../data/models/tmdb/season.dart' as _i20;
import '../../main.dart' as _i1;
import '../screens/admin_screen.dart' as _i10;
import '../screens/auths/auth_screen.dart' as _i8;
import '../screens/auths/forgot_password_screen.dart' as _i9;
import '../screens/auths/my_account_screen.dart' as _i16;
import '../screens/auths/unverified_user_screen.dart' as _i3;
import '../screens/error_screen.dart' as _i2;
import '../screens/main/explore_screen.dart' as _i14;
import '../screens/main/library_screen.dart' as _i15;
import '../screens/main/search_screen.dart' as _i13;
import '../screens/main/tab_home_screen.dart' as _i21;
import '../screens/settings_screen.dart' as _i11;
import '../screens/stream_media_screen.dart' as _i7;
import '../screens/tmdb/media_screen.dart' as _i4;
import '../screens/tmdb/tv_show_episode_screen.dart' as _i6;
import '../screens/tmdb/tv_show_season_screen.dart' as _i5;
import '../screens/upload_screen.dart' as _i12;

class NetfloxRouter extends _i17.RootStackRouter {
  NetfloxRouter([_i18.GlobalKey<_i18.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i17.PageFactory> pagesMap = {
    StackRoute.name: (routeData) {
      return _i17.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i1.StackScreen(),
      );
    },
    ErrorRoute.name: (routeData) {
      final args = routeData.argsAs<ErrorRouteArgs>(
          orElse: () => const ErrorRouteArgs());
      return _i17.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i2.ErrorScreen(
          errorCode: args.errorCode ?? 'unknown-error',
        ),
      );
    },
    TabHomeRoute.name: (routeData) {
      return _i17.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i21.TabHomeScreen(),
      );
    },
    UnverifiedUserRoute.name: (routeData) {
      return _i17.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i3.UnverifiedUserScreen(),
      );
    },
    MediaRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<MediaRouteArgs>(
          orElse: () => MediaRouteArgs(
                id: pathParams.getString('id'),
                mediaType: pathParams.get('mediaType'),
              ));
      return _i17.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i17.WrappedRoute(
            child: _i4.MediaScreen(
          key: args.key,
          id: args.id,
          mediaType: args.mediaType,
        )),
      );
    },
    TVShowSeasonRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<TVShowSeasonRouteArgs>(
          orElse: () => TVShowSeasonRouteArgs(
                seasonNumber: pathParams.getInt('seasonNumber'),
                tvShowId: pathParams.getString('tvShowId'),
              ));
      return _i17.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i5.TVShowSeasonScreen(
          key: args.key,
          seasonNumber: args.seasonNumber,
          tvShowId: args.tvShowId,
        ),
      );
    },
    TVShowEpisodeRoute.name: (routeData) {
      final args = routeData.argsAs<TVShowEpisodeRouteArgs>();
      return _i17.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i6.TVShowEpisodeScreen(
          key: args.key,
          episode: args.episode,
        ),
      );
    },
    StreamMediaRoute.name: (routeData) {
      final args = routeData.argsAs<StreamMediaRouteArgs>();
      return _i17.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i7.StreamMediaScreen(
          key: args.key,
          playableMedia: args.playableMedia,
        ),
        fullscreenDialog: true,
      );
    },
    AuthRoute.name: (routeData) {
      final args =
          routeData.argsAs<AuthRouteArgs>(orElse: () => const AuthRouteArgs());
      return _i17.MaterialPageX<bool>(
        routeData: routeData,
        child: _i8.AuthScreen(
          key: args.key,
          onFinish: args.onFinish,
          mode: args.mode,
        ),
      );
    },
    ForgotPasswordRoute.name: (routeData) {
      return _i17.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i9.ForgotPasswordScreen(),
      );
    },
    AdminRoute.name: (routeData) {
      return _i17.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i10.AdminScreen(),
      );
    },
    SettingsRoute.name: (routeData) {
      return _i17.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i11.SettingsScreen(),
      );
    },
    UploadRoute.name: (routeData) {
      return _i17.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i12.UploadScreen(),
      );
    },
    SearchRoute.name: (routeData) {
      final args = routeData.argsAs<SearchRouteArgs>(
          orElse: () => const SearchRouteArgs());
      return _i17.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i17.WrappedRoute(child: _i13.SearchScreen(key: args.key)),
      );
    },
    DiscoverRoute.name: (routeData) {
      final args = routeData.argsAs<DiscoverRouteArgs>(
          orElse: () => const DiscoverRouteArgs());
      return _i17.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i17.WrappedRoute(child: _i14.ExploreScreen(key: args.key)),
      );
    },
    LibraryRoute.name: (routeData) {
      final args = routeData.argsAs<LibraryRouteArgs>(
          orElse: () => const LibraryRouteArgs());
      return _i17.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i17.WrappedRoute(child: _i15.LibraryScreen(key: args.key)),
      );
    },
    MyAccountRoute.name: (routeData) {
      return _i17.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i16.MyAccountScreen(),
      );
    },
  };

  @override
  List<_i17.RouteConfig> get routes => [
        _i17.RouteConfig(
          '/#redirect',
          path: '/',
          redirectTo: '',
          fullMatch: true,
        ),
        _i17.RouteConfig(
          StackRoute.name,
          path: '',
          children: [
            _i17.RouteConfig(
              '#redirect',
              path: '',
              parent: StackRoute.name,
              redirectTo: 'dashboard',
              fullMatch: true,
            ),
            _i17.RouteConfig(
              TabHomeRoute.name,
              path: 'dashboard',
              parent: StackRoute.name,
              children: [
                _i17.RouteConfig(
                  '#redirect',
                  path: '',
                  parent: TabHomeRoute.name,
                  redirectTo: 'search',
                  fullMatch: true,
                ),
                _i17.RouteConfig(
                  SearchRoute.name,
                  path: 'search',
                  parent: TabHomeRoute.name,
                ),
                _i17.RouteConfig(
                  DiscoverRoute.name,
                  path: 'discover',
                  parent: TabHomeRoute.name,
                ),
                _i17.RouteConfig(
                  LibraryRoute.name,
                  path: 'library',
                  parent: TabHomeRoute.name,
                ),
                _i17.RouteConfig(
                  MyAccountRoute.name,
                  path: 'my-account',
                  parent: TabHomeRoute.name,
                ),
              ],
            ),
            _i17.RouteConfig(
              UnverifiedUserRoute.name,
              path: 'unverified-user',
              parent: StackRoute.name,
            ),
            _i17.RouteConfig(
              MediaRoute.name,
              path: ':mediaType/:id',
              parent: StackRoute.name,
            ),
            _i17.RouteConfig(
              TVShowSeasonRoute.name,
              path: 'tv/:tvShowId/:seasonNumber',
              parent: StackRoute.name,
            ),
            _i17.RouteConfig(
              TVShowEpisodeRoute.name,
              path: 't-vshow-episode-screen',
              parent: StackRoute.name,
            ),
            _i17.RouteConfig(
              StreamMediaRoute.name,
              path: 'stream',
              parent: StackRoute.name,
            ),
            _i17.RouteConfig(
              AuthRoute.name,
              path: 'auth',
              parent: StackRoute.name,
            ),
            _i17.RouteConfig(
              ForgotPasswordRoute.name,
              path: 'forgot-password',
              parent: StackRoute.name,
            ),
            _i17.RouteConfig(
              AdminRoute.name,
              path: 'admin-panel',
              parent: StackRoute.name,
            ),
            _i17.RouteConfig(
              SettingsRoute.name,
              path: 'settings',
              parent: StackRoute.name,
            ),
            _i17.RouteConfig(
              UploadRoute.name,
              path: 'upload-file',
              parent: StackRoute.name,
            ),
          ],
        ),
        _i17.RouteConfig(
          ErrorRoute.name,
          path: 'error/:error',
        ),
        _i17.RouteConfig(
          '*#redirect',
          path: '*',
          redirectTo: 'error/404-not-found',
          fullMatch: true,
        ),
      ];
}

/// generated route for
/// [_i1.StackScreen]
class StackRoute extends _i17.PageRouteInfo<void> {
  const StackRoute({List<_i17.PageRouteInfo>? children})
      : super(
          StackRoute.name,
          path: '',
          initialChildren: children,
        );

  static const String name = 'StackRoute';
}

/// generated route for
/// [_i2.ErrorScreen]
class ErrorRoute extends _i17.PageRouteInfo<ErrorRouteArgs> {
  ErrorRoute({_i19.Key? key, String? error})
      : super(
          ErrorRoute.name,
          path: 'error/:error',
          args: ErrorRouteArgs(
            key: key,
            errorCode: error,
          ),
          rawPathParams: {
            'error': error,
          },
        );

  static const String name = 'ErrorRoute';
}

class ErrorRouteArgs {
  const ErrorRouteArgs({this.key, this.errorCode});

  final _i19.Key? key;

  final String? errorCode;

  @override
  String toString() {
    return 'ErrorRouteArgs{key: $key, error: $errorCode}';
  }
}

/// generated route for
/// [_i1.TabHomeScreen]
class TabHomeRoute extends _i17.PageRouteInfo<void> {
  const TabHomeRoute({List<_i17.PageRouteInfo>? children})
      : super(
          TabHomeRoute.name,
          path: 'dashboard',
          initialChildren: children,
        );

  static const String name = 'TabHomeRoute';
}

/// generated route for
/// [_i3.UnverifiedUserScreen]
class UnverifiedUserRoute extends _i17.PageRouteInfo<void> {
  const UnverifiedUserRoute()
      : super(
          UnverifiedUserRoute.name,
          path: 'unverified-user',
        );

  static const String name = 'UnverifiedUserRoute';
}

/// generated route for
/// [_i4.MediaScreen]
class MediaRoute extends _i17.PageRouteInfo<MediaRouteArgs> {
  MediaRoute({
    _i19.Key? key,
    required String id,
    required dynamic mediaType,
  }) : super(
          MediaRoute.name,
          path: ':mediaType/:id',
          args: MediaRouteArgs(
            key: key,
            id: id,
            mediaType: mediaType,
          ),
          rawPathParams: {
            'id': id,
            'mediaType': mediaType,
          },
        );

  static const String name = 'MediaRoute';

  static _i17.PageRouteInfo fromMedia(_i21.TMDBPrimaryMedia media) {
    return MediaRoute(id: media.id, mediaType: media.type);
  }
}

class MediaRouteArgs {
  const MediaRouteArgs({
    this.key,
    required this.id,
    required this.mediaType,
  });

  final _i19.Key? key;

  final String id;

  final dynamic mediaType;

  @override
  String toString() {
    return 'MediaRouteArgs{key: $key, id: $id, mediaType: $mediaType}';
  }
}

/// generated route for
/// [_i5.TVShowSeasonScreen]
class TVShowSeasonRoute extends _i17.PageRouteInfo<TVShowSeasonRouteArgs> {
  TVShowSeasonRoute({
    _i19.Key? key,
    required int seasonNumber,
    required String tvShowId,
  }) : super(
          TVShowSeasonRoute.name,
          path: 'tv/:tvShowId/:seasonNumber',
          args: TVShowSeasonRouteArgs(
            key: key,
            seasonNumber: seasonNumber,
            tvShowId: tvShowId,
          ),
          rawPathParams: {
            'seasonNumber': seasonNumber,
            'tvShowId': tvShowId,
          },
        );

  static const String name = 'TVShowSeasonRoute';
}

class TVShowSeasonRouteArgs {
  const TVShowSeasonRouteArgs({
    this.key,
    required this.seasonNumber,
    required this.tvShowId,
  });

  final _i19.Key? key;

  final int seasonNumber;

  final String tvShowId;

  @override
  String toString() {
    return 'TVShowSeasonRouteArgs{key: $key, seasonNumber: $seasonNumber, tvShowId: $tvShowId}';
  }
}

/// generated route for
/// [_i6.TVShowEpisodeScreen]
class TVShowEpisodeRoute extends _i17.PageRouteInfo<TVShowEpisodeRouteArgs> {
  TVShowEpisodeRoute({
    _i19.Key? key,
    required _i20.TMDBTVEpisode episode,
  }) : super(
          TVShowEpisodeRoute.name,
          path: 't-vshow-episode-screen',
          args: TVShowEpisodeRouteArgs(
            key: key,
            episode: episode,
          ),
        );

  static const String name = 'TVShowEpisodeRoute';
}

class TVShowEpisodeRouteArgs {
  const TVShowEpisodeRouteArgs({
    this.key,
    required this.episode,
  });

  final _i19.Key? key;

  final _i20.TMDBTVEpisode episode;

  @override
  String toString() {
    return 'TVShowEpisodeRouteArgs{key: $key, episode: $episode}';
  }
}

/// generated route for
/// [_i7.StreamMediaScreen]
class StreamMediaRoute extends _i17.PageRouteInfo<StreamMediaRouteArgs> {
  StreamMediaRoute({
    _i19.Key? key,
    required _i21.TMDBPlayableMedia playableMedia,
  }) : super(
          StreamMediaRoute.name,
          path: 'stream',
          args: StreamMediaRouteArgs(
            key: key,
            playableMedia: playableMedia,
          ),
        );

  static const String name = 'StreamMediaRoute';
}

class StreamMediaRouteArgs {
  const StreamMediaRouteArgs({
    this.key,
    required this.playableMedia,
  });

  final _i19.Key? key;

  final _i21.TMDBPlayableMedia playableMedia;

  @override
  String toString() {
    return 'StreamMediaRouteArgs{key: $key, playableMedia: $playableMedia}';
  }
}

/// generated route for
/// [_i8.AuthScreen]
class AuthRoute extends _i17.PageRouteInfo<AuthRouteArgs> {
  AuthRoute({
    _i19.Key? key,
    void Function()? onFinish,
    _i22.AuthFormMode mode = _i22.AuthFormMode.signIn,
  }) : super(
          AuthRoute.name,
          path: 'auth',
          args: AuthRouteArgs(
            key: key,
            onFinish: onFinish,
            mode: mode,
          ),
        );

  static const String name = 'AuthRoute';
}

class AuthRouteArgs {
  const AuthRouteArgs({
    this.key,
    this.onFinish,
    this.mode = _i22.AuthFormMode.signIn,
  });

  final _i19.Key? key;

  final void Function()? onFinish;

  final _i22.AuthFormMode mode;

  @override
  String toString() {
    return 'AuthRouteArgs{key: $key, onFinish: $onFinish, mode: $mode}';
  }
}

/// generated route for
/// [_i9.ForgotPasswordScreen]
class ForgotPasswordRoute extends _i17.PageRouteInfo<void> {
  const ForgotPasswordRoute()
      : super(
          ForgotPasswordRoute.name,
          path: 'forgot-password',
        );

  static const String name = 'ForgotPasswordRoute';
}

/// generated route for
/// [_i10.AdminScreen]
class AdminRoute extends _i17.PageRouteInfo<void> {
  const AdminRoute()
      : super(
          AdminRoute.name,
          path: 'admin-panel',
        );

  static const String name = 'AdminRoute';
}

/// generated route for
/// [_i11.SettingsScreen]
class SettingsRoute extends _i17.PageRouteInfo<void> {
  const SettingsRoute()
      : super(
          SettingsRoute.name,
          path: 'settings',
        );

  static const String name = 'SettingsRoute';
}

/// generated route for
/// [_i12.UploadScreen]
class UploadRoute extends _i17.PageRouteInfo<void> {
  const UploadRoute()
      : super(
          UploadRoute.name,
          path: 'upload-file',
        );

  static const String name = 'UploadRoute';
}

/// generated route for
/// [_i13.SearchScreen]
class SearchRoute extends _i17.PageRouteInfo<SearchRouteArgs> {
  SearchRoute({_i19.Key? key})
      : super(
          SearchRoute.name,
          path: 'search',
          args: SearchRouteArgs(key: key),
        );

  static const String name = 'SearchRoute';
}

class SearchRouteArgs {
  const SearchRouteArgs({this.key});

  final _i19.Key? key;

  @override
  String toString() {
    return 'SearchRouteArgs{key: $key}';
  }
}

/// generated route for
/// [_i14.ExploreScreen]
class DiscoverRoute extends _i17.PageRouteInfo<DiscoverRouteArgs> {
  DiscoverRoute({_i19.Key? key})
      : super(
          DiscoverRoute.name,
          path: 'discover',
          args: DiscoverRouteArgs(key: key),
        );

  static const String name = 'DiscoverRoute';
}

class DiscoverRouteArgs {
  const DiscoverRouteArgs({this.key});

  final _i19.Key? key;

  @override
  String toString() {
    return 'DiscoverRouteArgs{key: $key}';
  }
}

/// generated route for
/// [_i15.LibraryScreen]
class LibraryRoute extends _i17.PageRouteInfo<LibraryRouteArgs> {
  LibraryRoute({_i19.Key? key})
      : super(
          LibraryRoute.name,
          path: 'library',
          args: LibraryRouteArgs(key: key),
        );

  static const String name = 'LibraryRoute';
}

class LibraryRouteArgs {
  const LibraryRouteArgs({this.key});

  final _i19.Key? key;

  @override
  String toString() {
    return 'LibraryRouteArgs{key: $key}';
  }
}

/// generated route for
/// [_i16.MyAccountScreen]
class MyAccountRoute extends _i17.PageRouteInfo<void> {
  const MyAccountRoute()
      : super(
          MyAccountRoute.name,
          path: 'my-account',
        );

  static const String name = 'MyAccountRoute';
}
