import 'dart:io';
import 'package:better_player/src/controls/better_player_clickable_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';

class CustomModalBottomSheet<T> {
  final void Function(T value)? onSelected;
  final List<BetterPlayerMaterialClickableWidget> _children;
  final Color? color;

  const CustomModalBottomSheet._(
      {this.onSelected,
      required List<BetterPlayerMaterialClickableWidget> children,
      this.color})
      : _children = children;

  factory CustomModalBottomSheet(
      {void Function(T value)? onSelected,
      required T defaultValue,
      required List<T> values,
      Color? color}) {
    final children = values.map<BetterPlayerMaterialClickableWidget>((e) {
      final isSelected = e == defaultValue;
      final name = e is Enum ? e.name : e.toString();
      return BetterPlayerMaterialClickableWidget(
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
                    name,
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
      barrierColor: Colors.transparent,
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
                color: color,
                /*shape: RoundedRectangleBorder(side: Bor,borderRadius: 24,)*/
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
      backgroundColor: Colors.transparent,
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
                color: color,
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