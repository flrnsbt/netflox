import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/data/models/exception.dart';
import 'package:netflox/data/models/tmdb/media.dart';
import 'package:netflox/ui/widgets/custom_awesome_dialog.dart';
import 'package:netflox/ui/widgets/tmdb/tmdb_media_card.dart';

import '../../../data/blocs/account/auth/auth_cubit.dart';
import '../../router/router.gr.dart';
import '../../widgets/netflox_loading_indicator.dart';
import '../../widgets/profile_image.dart';

class MyAccountScreen extends StatelessWidget {
  const MyAccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(listener: (context, state) {
      if (state.hasError()) {
        final exception = NetfloxException.from(state.message!);
        ErrorDialog.fromException(exception, context);
      }
    }, builder: (context, state) {
      if (state.isLoading()) {
        return const Center(
          child: NetfloxLoadingIndicator(),
        );
      }
      if (state.isUnauthenticated()) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "not-logged-in",
              textAlign: TextAlign.center,
            ).tr(),
            const SizedBox(
              height: 15,
            ),
            TextButton(
                onPressed: () => context.router.push(AuthRoute()),
                child: const Text("sign-in").tr())
          ],
        );
      }
      final user = state.user!;
      return SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 15),
        child: CustomScrollView(
          clipBehavior: Clip.none,
          shrinkWrap: true,
          slivers: [
            const SliverPadding(padding: EdgeInsets.symmetric(vertical: 15)),
            SliverAppBar(
                backgroundColor: Colors.transparent,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      user.displayName,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    if (user.email != null)
                      Text(
                        user.email!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 12),
                      ),
                  ],
                ),
                actions: [
                  IconButton(
                      onPressed: () {
                        context.pushRoute(const SettingsRoute());
                      },
                      icon: Icon(
                        Icons.settings,
                        color: Theme.of(context).colorScheme.onSurface,
                      ))
                ],
                centerTitle: false,
                leading: ProfileImage(
                  imgUrl: user.imgURL,
                )),
            SliverList(
                delegate: SliverChildListDelegate([
              const SizedBox(
                height: 25,
              ),
              const SizedBox(
                height: 30,
              ),
            ])),
          ],
        ),
      );
    });
  }

  Widget _buildFavoriteCard() => Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Row(children: [
                  const Text(
                    "favorite-media",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ).tr(),
                  const Spacer(),
                  TextButton(
                      onPressed: () {}, child: const Text("see-all").tr())
                ]),
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: AspectRatio(
                          aspectRatio: 1,
                          child: TMDBMediaCard(media: TMDBMediaEmpty())),
                    );
                  },
                  itemCount: 15,
                ),
              )
            ],
          ),
        ),
      );
}
