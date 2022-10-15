import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/ui/widgets/filters/filter_widget.dart';
import '../../../data/models/tmdb/filter_parameter.dart';
import 'filter_menu_builder.dart';

class FilterMenuDialog<P extends FilterParameter> extends StatelessWidget {
  final P _filterParameter;
  final void Function(P newParameter)? onParameterSubmitted;
  const FilterMenuDialog({
    super.key,
    required P currentParameters,
    this.onParameterSubmitted,
  }) : _filterParameter = currentParameters;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FilterMenuBuilder.from<P>(_filterParameter),
      child: BlocBuilder<FilterMenuBuilder<P>, List<FilterWidget>>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text(
                    "filters",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ).tr(),
                  const Spacer(),
                  const CloseButton()
                ],
              ),
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shrinkWrap: true,
                itemCount: state.length,
                itemBuilder: (context, index) => state[index],
                separatorBuilder: (context, index) => const Divider(
                  height: 30,
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    final parameters =
                        context.read<FilterMenuBuilder<P>>().save();
                    onParameterSubmitted?.call(parameters);
                    FocusManager.instance.primaryFocus?.unfocus();
                    Navigator.maybePop(context);
                  },
                  child: const Text("filter").tr())
            ],
          );
        },
      ),
    );
  }
}
