import 'dart:async';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:netflox/data/models/exception.dart';
import 'package:netflox/ui/widgets/netflox_loading_indicator.dart';

extension DismissTypeExtension on DismissType {
  bool aborted() =>
      this == DismissType.btnCancel ||
      this == DismissType.modalBarrier ||
      this == DismissType.androidBackButton;
}

class CustomAwesomeDialog extends AwesomeDialog with NetfloxCustomDialog {
  CustomAwesomeDialog(
      {required super.context,
      super.dialogType,
      super.body,
      super.btnOk,
      super.btnCancel,
      super.btnOkOnPress,
      super.btnCancelOnPress,
      super.onDismissCallback,
      super.headerAnimationLoop,
      super.dismissOnTouchOutside,
      super.showCloseIcon,
      super.animType,
      super.title,
      super.desc,
      super.btnOkText = "ok",
      super.btnCancelText = 'cancel',
      super.btnOkColor,
      super.btnCancelColor,
      super.btnOkIcon,
      super.btnCancelIcon,
      super.isDense = true,
      super.useRootNavigator = true,
      super.autoHide,
      super.buttonsTextStyle,
      super.buttonsBorderRadius,
      super.alignment,
      super.padding = const EdgeInsets.symmetric(horizontal: 35, vertical: 20),
      super.autoDismiss,
      super.barrierColor,
      super.bodyHeaderDistance,
      super.borderSide,
      super.closeIcon,
      Widget? customHeader,
      super.descTextStyle,
      super.dialogBackgroundColor,
      super.dialogBorderRadius,
      super.dismissOnBackKeyPress,
      super.enableEnterKey,
      super.keyboardAware,
      super.reverseBtnOrder,
      super.titleTextStyle,
      super.transitionAnimationDuration,
      double? width})
      : super(
            width: width ??
                (MediaQuery.of(context).size.width * 0.85).clamp(100, 600));

  CustomAwesomeDialog copyWith({
    BuildContext? context,
    DialogType? dialogType,
    Widget? body,
    Widget? btnOk,
    Widget? btnCancel,
    VoidCallback? btnOkOnPress,
    VoidCallback? btnCancelOnPress,
    void Function(DismissType)? onDismissCallback,
    bool? headerAnimationLoop,
    bool? dismissOnTouchOutside,
    bool? showCloseIcon,
    AnimType? animType,
    String? title,
    String? desc,
    String? btnOkText,
    String? btnCancelText,
    Color? btnOkColor,
    Color? btnCancelColor,
    IconData? btnOkIcon,
    IconData? btnCancelIcon,
    bool? isDense,
    bool? useRootNavigator,
    Duration? autoHide,
    TextStyle? buttonsTextStyle,
    BorderRadius? buttonsBorderRadius,
    Alignment? alignment,
    EdgeInsetsGeometry? padding,
    bool? autoDismiss,
    Color? barrierColor,
    double? bodyHeaderDistance,
    BorderSide? borderSide,
    Icon? closeIcon,
    Widget? customHeader,
    TextStyle? descTextStyle,
    Color? dialogBackgroundColor,
    BorderRadius? dialogBorderRadius,
    bool? dismissOnBackKeyPress,
    bool? enableEnterKey,
    bool? keyboardAware,
    bool? reverseBtnOrder,
    TextStyle? titleTextStyle,
    Duration? transitionAnimationDuration,
    double? width,
  }) {
    return CustomAwesomeDialog(
        context: context ?? this.context,
        dialogType: dialogType ?? this.dialogType,
        body: body ?? this.body,
        btnOk: btnOk ?? this.btnOk,
        btnCancel: btnCancel ?? this.btnCancel,
        btnOkOnPress: btnOkOnPress ?? this.btnOkOnPress,
        btnCancelOnPress: btnCancelOnPress ?? this.btnCancelOnPress,
        onDismissCallback: onDismissCallback ?? this.onDismissCallback,
        headerAnimationLoop: headerAnimationLoop ?? this.headerAnimationLoop,
        dismissOnTouchOutside:
            dismissOnTouchOutside ?? this.dismissOnTouchOutside,
        showCloseIcon: showCloseIcon ?? this.showCloseIcon,
        animType: animType ?? this.animType,
        title: title ?? this.title,
        desc: desc ?? this.desc,
        btnOkText: btnOkText ?? this.btnOkText,
        btnCancelText: btnCancelText ?? this.btnCancelText,
        btnOkColor: btnOkColor ?? this.btnOkColor,
        btnCancelColor: btnCancelColor ?? this.btnCancelColor,
        btnOkIcon: btnOkIcon ?? this.btnOkIcon,
        btnCancelIcon: btnCancelIcon ?? this.btnCancelIcon,
        isDense: isDense ?? this.isDense,
        useRootNavigator: useRootNavigator ?? this.useRootNavigator,
        autoHide: autoHide ?? this.autoHide,
        buttonsTextStyle: buttonsTextStyle ?? this.buttonsTextStyle,
        buttonsBorderRadius: buttonsBorderRadius ?? this.buttonsBorderRadius,
        alignment: alignment ?? this.alignment,
        padding: padding ?? this.padding,
        autoDismiss: autoDismiss ?? this.autoDismiss,
        barrierColor: barrierColor ?? this.barrierColor,
        bodyHeaderDistance: bodyHeaderDistance ?? this.bodyHeaderDistance,
        borderSide: borderSide ?? this.borderSide,
        closeIcon: closeIcon ?? this.closeIcon,
        customHeader: customHeader ?? this.customHeader,
        descTextStyle: descTextStyle ?? this.descTextStyle,
        dialogBackgroundColor:
            dialogBackgroundColor ?? this.dialogBackgroundColor,
        dialogBorderRadius: dialogBorderRadius ?? this.dialogBorderRadius,
        dismissOnBackKeyPress:
            dismissOnBackKeyPress ?? this.dismissOnBackKeyPress,
        enableEnterKey: enableEnterKey ?? this.enableEnterKey,
        keyboardAware: keyboardAware ?? this.keyboardAware,
        reverseBtnOrder: reverseBtnOrder ?? this.reverseBtnOrder,
        titleTextStyle: titleTextStyle ?? this.titleTextStyle,
        transitionAnimationDuration:
            transitionAnimationDuration ?? this.transitionAnimationDuration);
  }
}

class ErrorDialog extends CustomAwesomeDialog {
  final String errorCode;
  final String? description;
  final void Function()? onPressed;
  ErrorDialog(this.errorCode, this.description,
      {required super.context, this.onPressed})
      : super(
            dialogType: DialogType.error,
            btnOkOnPress: onPressed?.call ?? () {},
            title: errorCode,
            desc: description);

  factory ErrorDialog.fromException(
      NetfloxException exception, BuildContext context,
      {void Function()? onPressed}) {
    return ErrorDialog(exception.errorCode, "${exception.errorCode}-desc",
        context: context, onPressed: onPressed);
  }
}

class LoadingDialog extends NetfloxCustomDialog {
  @override
  final BuildContext context;
  LoadingDialog(this.context);
  bool _isShowing = false;

  @override
  Future show() async {
    if (!_isShowing) {
      _isShowing = true;
      await showGeneralDialog(
        context: context,
        useRootNavigator: false,
        barrierDismissible: false,
        pageBuilder: (
          BuildContext buildContext,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          return Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: NetfloxLoadingIndicator(),
              ),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
        transitionBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) =>
            AnimationTransition.scale(
          animation,
          secondaryAnimation,
          child,
        ),
        barrierColor: const Color.fromARGB(208, 0, 0, 0),
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
      );
      _isShowing = false;
    }
  }

  @override
  void dismiss() {
    if (_isShowing) {
      Navigator.maybeOf(context)?.pop();
    }
  }
}

abstract class NetfloxCustomDialog {
  Future<dynamic> show();

  void dismiss();

  BuildContext get context;
}
