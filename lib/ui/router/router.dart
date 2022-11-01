import 'package:auto_route/auto_route.dart';
import 'package:netflox/main.dart';
import 'package:netflox/ui/screens/admin_screen.dart';
import 'package:netflox/ui/screens/auths/auth_screen.dart';
import 'package:netflox/ui/screens/auths/forgot_password_screen.dart';
import 'package:netflox/ui/screens/main/my_account_screen.dart';
import 'package:netflox/ui/screens/auths/unverified_user_screen.dart';
import 'package:netflox/ui/screens/error_screen.dart';
import 'package:netflox/ui/screens/main/explore_screen.dart';
import 'package:netflox/ui/screens/download_screen.dart';
import 'package:netflox/ui/screens/main/search_screen.dart';
import 'package:netflox/ui/screens/main/library_screen.dart';
import 'package:netflox/ui/screens/settings_screen.dart';
import 'package:netflox/ui/screens/tmdb/tv_show_episode_screen.dart';
import 'package:netflox/ui/screens/upload_screen.dart';

import '../screens/main/tab_home_screen.dart';
import '../screens/sftp_media_screen.dart';
import '../screens/tmdb/media_screen.dart';
import '../screens/tmdb/tv_show_season_screen.dart';

@AdaptiveAutoRouter(
  replaceInRouteName: 'Screen,Route',
  routes: <AutoRoute>[
    AutoRoute(page: StackScreen, initial: true, path: "", children: [
      AutoRoute(
          path: "dashboard",
          initial: true,
          page: TabHomeScreen,
          children: [
            AutoRoute(
              page: SearchScreen,
              path: "search",
              initial: true,
            ),
            AutoRoute(
              page: ExploreScreen,
              path: "discover",
            ),
            AutoRoute(
              page: LibraryScreen,
              path: "library",
            ),
            AutoRoute(page: MyAccountScreen, path: 'my-account'),
          ]),
      AutoRoute(page: UnverifiedUserScreen, path: "unverified-user"),
      AutoRoute(page: TMDBMovieScreen, path: "movie/:id"),
      AutoRoute(page: TMDBPeopleScreen, path: "people/:id"),
      AutoRoute(page: TMDBTvScreen, path: "tv/:id"),
      AutoRoute(
          page: TMDBTVShowSeasonScreen, path: 'tv/:id/seasons/:seasonNumber'),
      AutoRoute(
          path: 'tv/:id/seasons/:seasonNumber/episodes/:episodeNumber',
          page: TVShowEpisodeScreen),
      AutoRoute(
        path: 'stream',
        fullscreenDialog: true,
        page: StreamSFTPMediaScreen,
      ),
      AutoRoute(
        path: 'download',
        fullscreenDialog: true,
        page: DownloadScreen,
      ),
      AutoRoute<bool>(page: AuthScreen, path: 'auth', children: [
        AutoRoute(
          page: ForgotPasswordScreen,
          path: "forgot-password",
        ),
      ]),
      AutoRoute(
        path: 'admin-panel',
        page: AdminScreen,
      ),
      AutoRoute(
        path: 'settings',
        page: SettingsScreen,
      ),
      AutoRoute(
        path: 'upload',
        page: UploadScreen,
      ),
      AutoRoute(
        page: WrappedBuilderScreen,
      ),
    ]),
    AutoRoute(
      path: 'error/:error',
      page: ErrorScreen,
    ),
    RedirectRoute(path: '*', redirectTo: 'error/404-not-found'),
  ],
)
class $NetfloxRouter {}
