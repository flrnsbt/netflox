import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';

class CustomModalBottomSheetItem extends StatelessWidget {
  final void Function()? onTap;
  final Widget child;
  const CustomModalBottomSheetItem(
      {super.key, this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.hardEdge,
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: child,
      ),
    );
  }
}

class CustomModalBottomSheet<T> {
  final void Function(T? value)? onSelected;
  final List<CustomModalBottomSheetItem> _children;
  final Color? color;

  const CustomModalBottomSheet._(
      {this.onSelected,
      required List<CustomModalBottomSheetItem> children,
      this.color})
      : _children = children;

  factory CustomModalBottomSheet(
      {void Function(T? value)? onSelected,
      required T? defaultValue,
      required Iterable<T> values,
      Color? color}) {
    final v = [...values, null];
    final children = v.map<CustomModalBottomSheetItem>((e) {
      final isSelected = e == defaultValue;
      return CustomModalBottomSheetItem(
          onTap: () {
            onSelected?.call(e);
          },
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Row(
                children: [
                  SizedBox(width: isSelected ? 8 : 16),
                  Visibility(
                      visible: isSelected,
                      child: Icon(
                        Icons.check_outlined,
                        color: color,
                      )),
                  const SizedBox(width: 16),
                  Text(
                    e?.toString() ?? 'none',
                    style: _getOverflowMenuElementTextStyle(isSelected, color),
                  ).tr(),
                ],
              )));
    }).toList();

    return CustomModalBottomSheet._(
        children: children, color: color, onSelected: onSelected);
  }

  void show(BuildContext context) {
    Platform.isAndroid
        ? _showMaterialBottomSheet(context)
        : _showCupertinoModalBottomSheet(context);
  }

  static TextStyle _getOverflowMenuElementTextStyle(bool isSelected,
      [Color? color]) {
    return TextStyle(
      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      color: color?.withOpacity(isSelected ? 1 : 0.7),
    );
  }

  void _showCupertinoModalBottomSheet(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      useRootNavigator: true,
      builder: (context) {
        return SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: color ?? Theme.of(context).backgroundColor,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24.0),
                    topRight: Radius.circular(24.0)),
              ),
              child: Column(
                children: _children,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showMaterialBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      builder: (context) {
        return SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: color ?? Theme.of(context).backgroundColor,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24.0),
                    topRight: Radius.circular(24.0)),
              ),
              child: Column(
                children: _children,
              ),
            ),
          ),
        );
      },
    );
  }
}
