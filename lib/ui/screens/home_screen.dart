import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/data/blocs/netflox_db_manager.dart/netflox_db_manager_cubit.dart';
import 'package:netflox/data/models/tmdb/movie.dart';
import 'package:netflox/ui/widgets/custom_drawer.dart';
import 'package:netflox/ui/widgets/dialogs.dart';
import 'package:netflox/ui/widgets/layouts/db_element_grid.dart';

import '../../data/models/tmdb/element.dart';
import '../../data/repositories/tmdb_repository.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<NetfloxDBManager>(context).getPopularMovies();
    return Scaffold(
      body: BlocConsumer<NetfloxDBManager, NetfloxDBState>(
        buildWhen: (previous, current) {
          return current is NetfloxDBStateSuccess;
        },
        builder: _buildLayout,
        listenWhen: (previous, current) {
          return previous.runtimeType != current.runtimeType;
        },
        listener: (context, state) {
          if (state is NetfloxDBStateLoading) {
            showDialog(
              context: context,
              builder: (context) => loadingDialog(),
            );
          } else {
            Navigator.maybePop(context);
            if (state is NetfloxDBStateFail) {
              showDialog(
                context: context,
                builder: (context) => customDialog(
                    child: Text(
                        state.exception.message?.tr ?? "unknown-message".tr),
                    title: state.exception.code.tr),
              );
            }
          }
        },
      ),
      drawer: CustomDrawer(
        onSelected: (filter) {},
      ),
    );
  }

  Widget _buildLayout(BuildContext context, NetfloxDBState state) {
    if (state is NetfloxDBStateSuccess) {
      final result = state.result;
      return DbLazyGridLayout(
        result: result as TMDBQueryResult<List<TMDBElement>>,
      );
    }
    return Container();
  }
}
