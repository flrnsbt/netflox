import 'package:flutter/material.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';

class SeeMoreWidget extends StatefulWidget {
  final Widget child;
  final double maxHeight;
  const SeeMoreWidget({super.key, required this.child, this.maxHeight = 150});

  @override
  State<SeeMoreWidget> createState() => _SeeMoreWidgetState();
}

class _SeeMoreWidgetState extends State<SeeMoreWidget> {
  double _limitHeight = double.infinity;
  bool _clipped = true;

  @override
  void initState() {
    super.initState();
    _limitHeight = widget.maxHeight;
  }

  Size _getLimitSize() =>
      Size.fromHeight(_clipped ? _limitHeight : double.infinity);

  Widget _buildLayout() {
    if (_clipped) {
      return LayoutBuilder(
        builder: (context, constraints) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            final height = context.size?.height ?? double.infinity;
            if (_limitHeight > height) {
              setState(() {
                _clipped = false;
              });
            }
          });
          return widget.child;
        },
      );
    } else {
      return widget.child;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRect(
          child: ConstrainedBox(
            constraints: BoxConstraints.loose(_getLimitSize()),
            child: _buildLayout(),
          ),
        ),
        if (_clipped)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: () {
                    setState(() {
                      _clipped = false;
                    });
                  },
                  child: Text(
                    "see-more".tr(context),
                    style: TextStyle(
                        fontSize: 12, color: Theme.of(context).disabledColor),
                  ))
            ],
          )
      ],
    );
  }
}
