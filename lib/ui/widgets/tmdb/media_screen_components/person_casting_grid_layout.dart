import 'package:auto_route/auto_route.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/ui/widgets/netflox_loading_indicator.dart';
import '../../../../data/blocs/data_fetcher/basic_server_fetch_state.dart';
import '../../../../data/models/tmdb/filter_parameter.dart';
import '../../../../data/blocs/data_fetcher/tmdb/element_cubit.dart';
import '../../../../data/models/tmdb/media.dart';
import '../../../router/router.gr.dart';
import '../../custom_awesome_dialog.dart';
import '../../default_sliver_grid.dart';
import '../../filters/filter_menu_dialog.dart';
import '../tmdb_media_card.dart';
import 'components.dart';

class PersonCastingGridLayout extends StatefulWidget {
  const PersonCastingGridLayout({super.key});

  @override
  State<PersonCastingGridLayout> createState() =>
      _PersonCastingGridLayoutState();
}

class _PersonCastingGridLayoutState extends State<PersonCastingGridLayout> {
  void showFilterMenuDialog(BuildContext context) {
    CustomAwesomeDialog(
            dialogType: DialogType.noHeader,
            bodyHeaderDistance: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            body: FilterMenuDialog<SimpleMultimediaFilterParameter>(
                onParameterSubmitted: (newParameter) {
                  setState(() {
                    _parameter = newParameter;
                  });
                },
                currentParameters: _parameter),
            context: context)
        .show();
  }

  var _parameter = const SimpleMultimediaFilterParameter();

  final _media = <TMDBMultiMedia>[];
  @override
  Widget build(BuildContext context) {
    return MediaScreenComponent(
      titleSpacing: 5,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
      name: "known-for".tr(context),
      action: IconButton(
          onPressed: () {
            showFilterMenuDialog(context);
          },
          icon: const Icon(Icons.filter_list)),
      child: BlocConsumer<TMDBFetchPeopleCasting,
          BasicServerFetchState<List<TMDBMultiMedia>>>(
        listener: (context, state) {
          if (state.success() && state.hasData()) {
            _media.addAll(state.result!);
          }
        },
        builder: (context, state) {
          if (state.success() && _media.isNotEmpty) {
            final sortParameter = SortParameter(
                criterion: _parameter.sortCriterion, order: _parameter.order);
            final data = _media
                .where((element) => _parameter.types.contains(element.type))
                .toList();
            data.sort(sortParameter.comparator);
            return GridView.custom(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                childrenDelegate: SliverChildBuilderDelegate(
                  (context, index) => TMDBMediaCard(
                    showBottomTitle: true,
                    media: data.elementAt(index),
                    onTap: (media) =>
                        context.pushRoute(MediaRoute.fromMedia(media)),
                  ),
                  childCount: data.length,
                ),
                gridDelegate: DefaultSliverGrid.defaultGridDelegate);
          }
          return Center(
              child: state.isLoading()
                  ? const NetfloxLoadingIndicator()
                  : Text("Nothing found".tr(context)));
        },
      ),
    );
  }
}
