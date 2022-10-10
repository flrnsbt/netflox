import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';

import '../../router/router.gr.dart';

class TabHomeScreen extends StatelessWidget {
  const TabHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AutoTabsScaffold(
      routes: [
        SearchRoute(),
        LibraryRoute(),
        DiscoverRoute(),
        const MyAccountRoute()
      ],
      animationCurve: Curves.ease,
      animationDuration: const Duration(milliseconds: 800),
      homeIndex: 0,
      bottomNavigationBuilder: (_, tabsRouter) {
        return BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: const Icon(CupertinoIcons.search),
                label: 'search'.tr(context),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.video_library),
                label: context.tr('library'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.explore),
                label: 'explore'.tr(context),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.account_box),
                label: 'my-account'.tr(context),
              ),
            ],
            currentIndex: tabsRouter.activeIndex,
            onTap: tabsRouter.setActiveIndex);
      },
    );
  }
}
