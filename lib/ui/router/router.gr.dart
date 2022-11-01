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
import 'package:auto_route/auto_route.dart' as _i19;
import 'package:flutter/foundation.dart' as _i21;
import 'package:flutter/material.dart' as _i20;
import 'package:netflox/data/blocs/account/auth/auth_form/auth_form_bloc.dart'
    as _i23;
import 'package:netflox/data/models/tmdb/filter_parameter.dart' as _i24;
import 'package:netflox/data/models/tmdb/media.dart' as _i22;
import 'package:netflox/main.dart' as _i1;
import 'package:netflox/ui/screens/admin_screen.dart' as _i11;
import 'package:netflox/ui/screens/auths/auth_screen.dart' as _i10;
import 'package:netflox/ui/screens/auths/forgot_password_screen.dart' as _i18;
import 'package:netflox/ui/screens/main/my_account_screen.dart' as _i17;
import 'package:netflox/ui/screens/auths/unverified_user_screen.dart' as _i4;
import 'package:netflox/ui/screens/download_screen.dart' as _i9;
import 'package:netflox/ui/screens/error_screen.dart' as _i2;
import 'package:netflox/ui/screens/main/explore_screen.dart' as _i15;
import 'package:netflox/ui/screens/main/library_screen.dart' as _i16;
import 'package:netflox/ui/screens/main/search_screen.dart' as _i14;
import 'package:netflox/ui/screens/main/tab_home_screen.dart' as _i3;
import 'package:netflox/ui/screens/settings_screen.dart' as _i12;
import 'package:netflox/ui/screens/sftp_media_screen.dart' as _i8;
import 'package:netflox/ui/screens/tmdb/media_screen.dart' as _i5;
import 'package:netflox/ui/screens/tmdb/tv_show_episode_screen.dart' as _i7;
import 'package:netflox/ui/screens/tmdb/tv_show_season_screen.dart' as _i6;
import 'package:netflox/ui/screens/upload_screen.dart' as _i13;

import 'idle_timed_auto_push_route.dart';

class NetfloxRouter extends _i19.RootStackRouter with IdleTimedPushAutoRoute {
  NetfloxRouter([_i20.GlobalKey<_i20.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i19.PageFactory> pagesMap = {
    StackRoute.name: (routeData) {
      return _i19.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i1.StackScreen(),
      );
    },
    ErrorRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<ErrorRouteArgs>(
          orElse: () => ErrorRouteArgs(errorCode: pathParams.get('error')));
      return _i19.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i2.ErrorScreen(
          key: args.key,
          errorCode: args.errorCode,
          child: args.child,
        ),
      );
    },
    TabHomeRoute.name: (routeData) {
      return _i19.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i3.TabHomeScreen(),
      );
    },
    UnverifiedUserRoute.name: (routeData) {
      return _i19.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i4.UnverifiedUserScreen(),
      );
    },
    TMDBMovieRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<TMDBMovieRouteArgs>(
          orElse: () => TMDBMovieRouteArgs(id: pathParams.getString('id')));
      return _i19.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i19.WrappedRoute(
            child: _i5.TMDBMovieScreen(
          key: args.key,
          id: args.id,
        )),
      );
    },
    TMDBPeopleRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<TMDBPeopleRouteArgs>(
          orElse: () => TMDBPeopleRouteArgs(id: pathParams.getString('id')));
      return _i19.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i19.WrappedRoute(
            child: _i5.TMDBPeopleScreen(
          key: args.key,
          id: args.id,
        )),
      );
    },
    TMDBTvRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<TMDBTvRouteArgs>(
          orElse: () => TMDBTvRouteArgs(id: pathParams.getString('id')));
      return _i19.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i19.WrappedRoute(
            child: _i5.TMDBTvScreen(
          key: args.key,
          id: args.id,
        )),
      );
    },
    TMDBTVShowSeasonRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<TMDBTVShowSeasonRouteArgs>(
          orElse: () => TMDBTVShowSeasonRouteArgs(
                id: pathParams.getInt('seasonNumber'),
                showId: pathParams.getString('id'),
              ));
      return _i19.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i19.WrappedRoute(
            child: _i6.TMDBTVShowSeasonScreen(
          key: args.key,
          id: args.id,
          showId: args.showId,
        )),
      );
    },
    TVShowEpisodeRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<TVShowEpisodeRouteArgs>(
          orElse: () => TVShowEpisodeRouteArgs(
                id: pathParams.getInt('episodeNumber'),
                seasonNumber: pathParams.getInt('seasonNumber'),
                showId: pathParams.getString('id'),
              ));
      return _i19.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i19.WrappedRoute(
            child: _i7.TVShowEpisodeScreen(
          key: args.key,
          id: args.id,
          seasonNumber: args.seasonNumber,
          showId: args.showId,
        )),
      );
    },
    StreamSFTPMediaRoute.name: (routeData) {
      final args = routeData.argsAs<StreamSFTPMediaRouteArgs>();
      return _i19.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i8.StreamSFTPMediaScreen(
          key: args.key,
          playableMedia: args.playableMedia,
          startAt: args.startAt,
          onVideoClosed: args.onVideoClosed,
        ),
        fullscreenDialog: true,
      );
    },
    DownloadRoute.name: (routeData) {
      final args = routeData.argsAs<DownloadRouteArgs>();
      return _i19.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i9.DownloadScreen(
          key: args.key,
          media: args.media,
        ),
        fullscreenDialog: true,
      );
    },
    AuthRoute.name: (routeData) {
      final args =
          routeData.argsAs<AuthRouteArgs>(orElse: () => const AuthRouteArgs());
      return _i19.AdaptivePage<bool>(
        routeData: routeData,
        child: _i10.AuthScreen(
          key: args.key,
          onFinish: args.onFinish,
          mode: args.mode,
        ),
      );
    },
    AdminRoute.name: (routeData) {
      return _i19.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i11.AdminScreen(),
      );
    },
    SettingsRoute.name: (routeData) {
      return _i19.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i12.SettingsScreen(),
      );
    },
    UploadRoute.name: (routeData) {
      final args = routeData.argsAs<UploadRouteArgs>();
      return _i19.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i13.UploadScreen(
          key: args.key,
          media: args.media,
        ),
      );
    },
    WrappedBuilderRoute.name: (routeData) {
      final args = routeData.argsAs<WrappedBuilderRouteArgs>();
      return _i19.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i5.WrappedBuilderScreen(
          key: args.key,
          builder: args.builder,
        ),
      );
    },
    SearchRoute.name: (routeData) {
      final args = routeData.argsAs<SearchRouteArgs>(
          orElse: () => const SearchRouteArgs());
      return _i19.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i19.WrappedRoute(child: _i14.SearchScreen(key: args.key)),
      );
    },
    ExploreRoute.name: (routeData) {
      final args = routeData.argsAs<ExploreRouteArgs>(
          orElse: () => const ExploreRouteArgs());
      return _i19.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i19.WrappedRoute(
            child: _i15.ExploreScreen(
          key: args.key,
          parameter: args.parameter,
        )),
      );
    },
    LibraryRoute.name: (routeData) {
      return _i19.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i16.LibraryScreen(),
      );
    },
    MyAccountRoute.name: (routeData) {
      return _i19.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i17.MyAccountScreen(),
      );
    },
    ForgotPasswordRoute.name: (routeData) {
      return _i19.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i18.ForgotPasswordScreen(),
      );
    },
  };

  @override
  List<_i19.RouteConfig> get routes => [
        _i19.RouteConfig(
          '/#redirect',
          path: '/',
          redirectTo: '',
          fullMatch: true,
        ),
        _i19.RouteConfig(
          StackRoute.name,
          path: '',
          children: [
            _i19.RouteConfig(
              '#redirect',
              path: '',
              parent: StackRoute.name,
              redirectTo: 'dashboard',
              fullMatch: true,
            ),
            _i19.RouteConfig(
              TabHomeRoute.name,
              path: 'dashboard',
              parent: StackRoute.name,
              children: [
                _i19.RouteConfig(
                  '#redirect',
                  path: '',
                  parent: TabHomeRoute.name,
                  redirectTo: 'search',
                  fullMatch: true,
                ),
                _i19.RouteConfig(
                  SearchRoute.name,
                  path: 'search',
                  parent: TabHomeRoute.name,
                ),
                _i19.RouteConfig(
                  ExploreRoute.name,
                  path: 'discover',
                  parent: TabHomeRoute.name,
                ),
                _i19.RouteConfig(
                  LibraryRoute.name,
                  path: 'library',
                  parent: TabHomeRoute.name,
                ),
                _i19.RouteConfig(
                  MyAccountRoute.name,
                  path: 'my-account',
                  parent: TabHomeRoute.name,
                ),
              ],
            ),
            _i19.RouteConfig(
              UnverifiedUserRoute.name,
              path: 'unverified-user',
              parent: StackRoute.name,
            ),
            _i19.RouteConfig(
              TMDBMovieRoute.name,
              path: 'movie/:id',
              parent: StackRoute.name,
            ),
            _i19.RouteConfig(
              TMDBPeopleRoute.name,
              path: 'people/:id',
              parent: StackRoute.name,
            ),
            _i19.RouteConfig(
              TMDBTvRoute.name,
              path: 'tv/:id',
              parent: StackRoute.name,
            ),
            _i19.RouteConfig(
              TMDBTVShowSeasonRoute.name,
              path: 'tv/:id/seasons/:seasonNumber',
              parent: StackRoute.name,
            ),
            _i19.RouteConfig(
              TVShowEpisodeRoute.name,
              path: 'tv/:id/seasons/:seasonNumber/episodes/:episodeNumber',
              parent: StackRoute.name,
            ),
            _i19.RouteConfig(
              StreamSFTPMediaRoute.name,
              path: 'stream',
              parent: StackRoute.name,
            ),
            _i19.RouteConfig(
              DownloadRoute.name,
              path: 'download',
              parent: StackRoute.name,
            ),
            _i19.RouteConfig(
              AuthRoute.name,
              path: 'auth',
              parent: StackRoute.name,
              children: [
                _i19.RouteConfig(
                  ForgotPasswordRoute.name,
                  path: 'forgot-password',
                  parent: AuthRoute.name,
                )
              ],
            ),
            _i19.RouteConfig(
              AdminRoute.name,
              path: 'admin-panel',
              parent: StackRoute.name,
            ),
            _i19.RouteConfig(
              SettingsRoute.name,
              path: 'settings',
              parent: StackRoute.name,
            ),
            _i19.RouteConfig(
              UploadRoute.name,
              path: 'upload',
              parent: StackRoute.name,
            ),
            _i19.RouteConfig(
              WrappedBuilderRoute.name,
              path: 'wrapped-builder-screen',
              parent: StackRoute.name,
            ),
          ],
        ),
        _i19.RouteConfig(
          ErrorRoute.name,
          path: 'error/:error',
        ),
        _i19.RouteConfig(
          '*#redirect',
          path: '*',
          redirectTo: 'error/404-not-found',
          fullMatch: true,
        ),
      ];
}

/// generated route for
/// [_i1.StackScreen]
class StackRoute extends _i19.PageRouteInfo<void> {
  const StackRoute({List<_i19.PageRouteInfo>? children})
      : super(
          StackRoute.name,
          path: '',
          initialChildren: children,
        );

  static const String name = 'StackRoute';
}

/// generated route for
/// [_i2.ErrorScreen]
class ErrorRoute extends _i19.PageRouteInfo<ErrorRouteArgs> {
  ErrorRoute({
    _i21.Key? key,
    dynamic errorCode,
    _i20.Widget? child,
  }) : super(
          ErrorRoute.name,
          path: 'error/:error',
          args: ErrorRouteArgs(
            key: key,
            errorCode: errorCode,
            child: child,
          ),
          rawPathParams: {'error': errorCode},
        );

  static const String name = 'ErrorRoute';
}

class ErrorRouteArgs {
  const ErrorRouteArgs({
    this.key,
    this.errorCode,
    this.child,
  });

  final _i21.Key? key;

  final dynamic errorCode;

  final _i20.Widget? child;

  @override
  String toString() {
    return 'ErrorRouteArgs{key: $key, errorCode: $errorCode, child: $child}';
  }
}

/// generated route for
/// [_i3.TabHomeScreen]
class TabHomeRoute extends _i19.PageRouteInfo<void> {
  const TabHomeRoute({List<_i19.PageRouteInfo>? children})
      : super(
          TabHomeRoute.name,
          path: 'dashboard',
          initialChildren: children,
        );

  static const String name = 'TabHomeRoute';
}

/// generated route for
/// [_i4.UnverifiedUserScreen]
class UnverifiedUserRoute extends _i19.PageRouteInfo<void> {
  const UnverifiedUserRoute()
      : super(
          UnverifiedUserRoute.name,
          path: 'unverified-user',
        );

  static const String name = 'UnverifiedUserRoute';
}

/// generated route for
/// [_i5.TMDBMovieScreen]
class TMDBMovieRoute extends _i19.PageRouteInfo<TMDBMovieRouteArgs> {
  TMDBMovieRoute({
    _i21.Key? key,
    required String id,
  }) : super(
          TMDBMovieRoute.name,
          path: 'movie/:id',
          args: TMDBMovieRouteArgs(
            key: key,
            id: id,
          ),
          rawPathParams: {'id': id},
        );

  static const String name = 'TMDBMovieRoute';
}

class TMDBMovieRouteArgs {
  const TMDBMovieRouteArgs({
    this.key,
    required this.id,
  });

  final _i21.Key? key;

  final String id;

  @override
  String toString() {
    return 'TMDBMovieRouteArgs{key: $key, id: $id}';
  }
}

/// generated route for
/// [_i5.TMDBPeopleScreen]
class TMDBPeopleRoute extends _i19.PageRouteInfo<TMDBPeopleRouteArgs> {
  TMDBPeopleRoute({
    _i21.Key? key,
    required String id,
  }) : super(
          TMDBPeopleRoute.name,
          path: 'people/:id',
          args: TMDBPeopleRouteArgs(
            key: key,
            id: id,
          ),
          rawPathParams: {'id': id},
        );

  static const String name = 'TMDBPeopleRoute';
}

class TMDBPeopleRouteArgs {
  const TMDBPeopleRouteArgs({
    this.key,
    required this.id,
  });

  final _i21.Key? key;

  final String id;

  @override
  String toString() {
    return 'TMDBPeopleRouteArgs{key: $key, id: $id}';
  }
}

/// generated route for
/// [_i5.TMDBTvScreen]
class TMDBTvRoute extends _i19.PageRouteInfo<TMDBTvRouteArgs> {
  TMDBTvRoute({
    _i21.Key? key,
    required String id,
  }) : super(
          TMDBTvRoute.name,
          path: 'tv/:id',
          args: TMDBTvRouteArgs(
            key: key,
            id: id,
          ),
          rawPathParams: {'id': id},
        );

  static const String name = 'TMDBTvRoute';
}

class TMDBTvRouteArgs {
  const TMDBTvRouteArgs({
    this.key,
    required this.id,
  });

  final _i21.Key? key;

  final String id;

  @override
  String toString() {
    return 'TMDBTvRouteArgs{key: $key, id: $id}';
  }
}

/// generated route for
/// [_i6.TMDBTVShowSeasonScreen]
class TMDBTVShowSeasonRoute
    extends _i19.PageRouteInfo<TMDBTVShowSeasonRouteArgs> {
  TMDBTVShowSeasonRoute({
    _i21.Key? key,
    required int id,
    required String showId,
  }) : super(
          TMDBTVShowSeasonRoute.name,
          path: 'tv/:id/seasons/:seasonNumber',
          args: TMDBTVShowSeasonRouteArgs(
            key: key,
            id: id,
            showId: showId,
          ),
          rawPathParams: {
            'seasonNumber': id,
            'id': showId,
          },
        );

  static const String name = 'TMDBTVShowSeasonRoute';
}

class TMDBTVShowSeasonRouteArgs {
  const TMDBTVShowSeasonRouteArgs({
    this.key,
    required this.id,
    required this.showId,
  });

  final _i21.Key? key;

  final int id;

  final String showId;

  @override
  String toString() {
    return 'TMDBTVShowSeasonRouteArgs{key: $key, id: $id, showId: $showId}';
  }
}

/// generated route for
/// [_i7.TVShowEpisodeScreen]
class TVShowEpisodeRoute extends _i19.PageRouteInfo<TVShowEpisodeRouteArgs> {
  TVShowEpisodeRoute({
    _i21.Key? key,
    required int id,
    required int seasonNumber,
    required String showId,
  }) : super(
          TVShowEpisodeRoute.name,
          path: 'tv/:id/seasons/:seasonNumber/episodes/:episodeNumber',
          args: TVShowEpisodeRouteArgs(
            key: key,
            id: id,
            seasonNumber: seasonNumber,
            showId: showId,
          ),
          rawPathParams: {
            'episodeNumber': id,
            'seasonNumber': seasonNumber,
            'id': showId,
          },
        );

  static const String name = 'TVShowEpisodeRoute';
}

class TVShowEpisodeRouteArgs {
  const TVShowEpisodeRouteArgs({
    this.key,
    required this.id,
    required this.seasonNumber,
    required this.showId,
  });

  final _i21.Key? key;

  final int id;

  final int seasonNumber;

  final String showId;

  @override
  String toString() {
    return 'TVShowEpisodeRouteArgs{key: $key, id: $id, seasonNumber: $seasonNumber, showId: $showId}';
  }
}

/// generated route for
/// [_i8.StreamSFTPMediaScreen]
class StreamSFTPMediaRoute
    extends _i19.PageRouteInfo<StreamSFTPMediaRouteArgs> {
  StreamSFTPMediaRoute({
    _i21.Key? key,
    required _i22.TMDBPlayableMedia playableMedia,
    Duration? startAt,
    void Function(Duration?)? onVideoClosed,
  }) : super(
          StreamSFTPMediaRoute.name,
          path: 'stream',
          args: StreamSFTPMediaRouteArgs(
            key: key,
            playableMedia: playableMedia,
            startAt: startAt,
            onVideoClosed: onVideoClosed,
          ),
        );

  static const String name = 'StreamSFTPMediaRoute';
}

class StreamSFTPMediaRouteArgs {
  const StreamSFTPMediaRouteArgs({
    this.key,
    required this.playableMedia,
    this.startAt,
    this.onVideoClosed,
  });

  final _i21.Key? key;

  final _i22.TMDBPlayableMedia playableMedia;

  final Duration? startAt;

  final void Function(Duration?)? onVideoClosed;

  @override
  String toString() {
    return 'StreamSFTPMediaRouteArgs{key: $key, playableMedia: $playableMedia, startAt: $startAt, onVideoClosed: $onVideoClosed}';
  }
}

/// generated route for
/// [_i9.DownloadScreen]
class DownloadRoute extends _i19.PageRouteInfo<DownloadRouteArgs> {
  DownloadRoute({
    _i21.Key? key,
    required _i22.TMDBLibraryMedia media,
  }) : super(
          DownloadRoute.name,
          path: 'download',
          args: DownloadRouteArgs(
            key: key,
            media: media,
          ),
        );

  static const String name = 'DownloadRoute';
}

class DownloadRouteArgs {
  const DownloadRouteArgs({
    this.key,
    required this.media,
  });

  final _i21.Key? key;

  final _i22.TMDBLibraryMedia media;

  @override
  String toString() {
    return 'DownloadRouteArgs{key: $key, media: $media}';
  }
}

/// generated route for
/// [_i10.AuthScreen]
class AuthRoute extends _i19.PageRouteInfo<AuthRouteArgs> {
  AuthRoute({
    _i21.Key? key,
    void Function()? onFinish,
    _i23.AuthFormMode mode = _i23.AuthFormMode.signIn,
    List<_i19.PageRouteInfo>? children,
  }) : super(
          AuthRoute.name,
          path: 'auth',
          args: AuthRouteArgs(
            key: key,
            onFinish: onFinish,
            mode: mode,
          ),
          initialChildren: children,
        );

  static const String name = 'AuthRoute';
}

class AuthRouteArgs {
  const AuthRouteArgs({
    this.key,
    this.onFinish,
    this.mode = _i23.AuthFormMode.signIn,
  });

  final _i21.Key? key;

  final void Function()? onFinish;

  final _i23.AuthFormMode mode;

  @override
  String toString() {
    return 'AuthRouteArgs{key: $key, onFinish: $onFinish, mode: $mode}';
  }
}

/// generated route for
/// [_i11.AdminScreen]
class AdminRoute extends _i19.PageRouteInfo<void> {
  const AdminRoute()
      : super(
          AdminRoute.name,
          path: 'admin-panel',
        );

  static const String name = 'AdminRoute';
}

/// generated route for
/// [_i12.SettingsScreen]
class SettingsRoute extends _i19.PageRouteInfo<void> {
  const SettingsRoute()
      : super(
          SettingsRoute.name,
          path: 'settings',
        );

  static const String name = 'SettingsRoute';
}

/// generated route for
/// [_i13.UploadScreen]
class UploadRoute extends _i19.PageRouteInfo<UploadRouteArgs> {
  UploadRoute({
    _i21.Key? key,
    required _i22.TMDBLibraryMedia media,
  }) : super(
          UploadRoute.name,
          path: 'upload',
          args: UploadRouteArgs(
            key: key,
            media: media,
          ),
        );

  static const String name = 'UploadRoute';
}

class UploadRouteArgs {
  const UploadRouteArgs({
    this.key,
    required this.media,
  });

  final _i21.Key? key;

  final _i22.TMDBLibraryMedia media;

  @override
  String toString() {
    return 'UploadRouteArgs{key: $key, media: $media}';
  }
}

/// generated route for
/// [_i5.WrappedBuilderScreen]
class WrappedBuilderRoute extends _i19.PageRouteInfo<WrappedBuilderRouteArgs> {
  WrappedBuilderRoute({
    _i21.Key? key,
    required _i20.Widget Function(_i20.BuildContext) builder,
  }) : super(
          WrappedBuilderRoute.name,
          path: 'wrapped-builder-screen',
          args: WrappedBuilderRouteArgs(
            key: key,
            builder: builder,
          ),
        );

  static const String name = 'WrappedBuilderRoute';
}

class WrappedBuilderRouteArgs {
  const WrappedBuilderRouteArgs({
    this.key,
    required this.builder,
  });

  final _i21.Key? key;

  final _i20.Widget Function(_i20.BuildContext) builder;

  @override
  String toString() {
    return 'WrappedBuilderRouteArgs{key: $key, builder: $builder}';
  }
}

/// generated route for
/// [_i14.SearchScreen]
class SearchRoute extends _i19.PageRouteInfo<SearchRouteArgs> {
  SearchRoute({_i21.Key? key})
      : super(
          SearchRoute.name,
          path: 'search',
          args: SearchRouteArgs(key: key),
        );

  static const String name = 'SearchRoute';
}

class SearchRouteArgs {
  const SearchRouteArgs({this.key});

  final _i21.Key? key;

  @override
  String toString() {
    return 'SearchRouteArgs{key: $key}';
  }
}

/// generated route for
/// [_i15.ExploreScreen]
class ExploreRoute extends _i19.PageRouteInfo<ExploreRouteArgs> {
  ExploreRoute({
    _i21.Key? key,
    _i24.DiscoverFilterParameter<_i22.TMDBMultiMedia>? parameter,
  }) : super(
          ExploreRoute.name,
          path: 'discover',
          args: ExploreRouteArgs(
            key: key,
            parameter: parameter,
          ),
        );

  static const String name = 'ExploreRoute';
}

class ExploreRouteArgs {
  const ExploreRouteArgs({
    this.key,
    this.parameter,
  });

  final _i21.Key? key;

  final _i24.DiscoverFilterParameter<_i22.TMDBMultiMedia>? parameter;

  @override
  String toString() {
    return 'ExploreRouteArgs{key: $key, parameter: $parameter}';
  }
}

/// generated route for
/// [_i16.LibraryScreen]
class LibraryRoute extends _i19.PageRouteInfo<void> {
  const LibraryRoute()
      : super(
          LibraryRoute.name,
          path: 'library',
        );

  static const String name = 'LibraryRoute';
}

/// generated route for
/// [_i17.MyAccountScreen]
class MyAccountRoute extends _i19.PageRouteInfo<void> {
  const MyAccountRoute()
      : super(
          MyAccountRoute.name,
          path: 'my-account',
        );

  static const String name = 'MyAccountRoute';
}

/// generated route for
/// [_i18.ForgotPasswordScreen]
class ForgotPasswordRoute extends _i19.PageRouteInfo<void> {
  const ForgotPasswordRoute()
      : super(
          ForgotPasswordRoute.name,
          path: 'forgot-password',
        );

  static const String name = 'ForgotPasswordRoute';
}
