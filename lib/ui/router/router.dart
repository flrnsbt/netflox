import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:netflox/ui/screens/auths/my_account_screen.dart';
import 'package:netflox/ui/screens/auths/sign_in_screen.dart';
import 'package:netflox/ui/screens/auths/sign_up_screen.dart';
import 'package:netflox/ui/screens/home_screen.dart';
import 'package:netflox/ui/screens/library_screen.dart';

import '../../main.dart';

part 'router.gr.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Screen',
  routes: <AutoRoute>[
    AutoRoute(page: AppGenerator, path: "", initial: true, children: [
      AutoRoute(page: HomeScreen, path: "dashboard", initial: true),
      AutoRoute(page: LibraryScreen),
      AutoRoute(page: MyAccountScreen),
      AutoRoute(page: SignInScreen),
      AutoRoute(page: SignUpScreen),
    ]),
  ],
)
class NetfloxRouter extends _$NetfloxRouter {}
