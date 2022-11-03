import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/app_localization/app_localization_cubit.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/data/blocs/theme/theme_cubit_cubit.dart';
import 'package:netflox/data/models/user/user.dart';
import 'package:netflox/ui/router/idle_timed_auto_push_route.dart';
import 'package:netflox/ui/widgets/constrained_large_screen_widget.dart';
import 'package:netflox/ui/widgets/error_widget.dart';
import 'package:netflox/ui/widgets/profile_image.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../data/blocs/account/auth/auth_cubit.dart';
import '../router/router.gr.dart';
import '../widgets/custom_awesome_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  Widget _buildLanguagePicker(BuildContext context) {
    return BlocBuilder<AppLocalization, AppLocalizationState>(
        builder: (context, state) => CupertinoSelector<Locale>(
              currentValue: state.currentLocale,
              builder: (context, value, selected) {
                return Text(
                  "language-${value.languageCode}".tr(context),
                  maxLines: 1,
                  style: TextStyle(
                      fontSize: 14, color: selected ? Colors.white : null),
                );
              },
              values: AppLocalization.supportedLocales,
              onValueChanged: (value) {
                if (value != null) {
                  CustomAwesomeDialog(
                          btnOkOnPress: () {
                            context.read<AppLocalization>().updateLocale(value);
                            context.router.pop();
                          },
                          onDismissCallback: (type) {
                            if (type.aborted()) {}
                          },
                          btnCancelOnPress: () {},
                          context: context,
                          dialogType: DialogType.info,
                          title: "reload-app",
                          desc: "reload-required-desc")
                      .tr()
                      .show();
                }
              },
            ));
  }

  Widget _buildAppSettings(BuildContext context) {
    return SettingCard(
        title: "app-settings".tr(context),
        child: Column(
          children: [
            SettingItem(
              name: 'language'.tr(context),
              child: _buildLanguagePicker(context),
            ),
            const SizedBox(
              height: 20,
            ),
            SettingItem(
              name: 'theme'.tr(context),
              child: _buildThemePicker(context),
            ),
          ],
        ));
  }

  Widget _buildThemePicker(BuildContext context) {
    return BlocBuilder<ThemeDataCubit, ThemeDataState>(
      builder: (context, state) {
        return CupertinoSelector<Brightness>(
          values: Brightness.values,
          thumbColor: Theme.of(context).primaryColor,
          builder: (context, value, selected) => Text(
            value.name,
            maxLines: 1,
            style:
                TextStyle(fontSize: 14, color: selected ? Colors.white : null),
          ).tr(),
          onValueChanged: (value) {
            if (value != null) {
              context.read<ThemeDataCubit>().change(value);
            }
          },
          currentValue: state.brightness,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: SingleChildScrollView(
            child: ResponsiveRowColumn(
              rowCrossAxisAlignment: CrossAxisAlignment.start,
              layout: ResponsiveWrapper.of(context).isLargerThan(TABLET)
                  ? ResponsiveRowColumnType.ROW
                  : ResponsiveRowColumnType.COLUMN,
              children: [
                const ResponsiveRowColumnItem(
                  rowFit: FlexFit.loose,
                  rowFlex: 2,
                  child: _AccountInfoCard(),
                ),
                ResponsiveRowColumnItem(
                  rowFit: FlexFit.loose,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildAppSettings(context),
                      SettingCard(
                          title: 'others'.tr(context),
                          child: Column(
                            children: [
                              SettingItem(
                                  name: 'credits'.tr(context),
                                  child: TextButton(
                                      onPressed: () {},
                                      child: const Text('view-credits').tr())),
                              const SizedBox(
                                height: 15,
                              ),
                              SettingItem(
                                  name: 'conditions'.tr(context),
                                  child: TextButton(
                                      onPressed: () {},
                                      child:
                                          const Text('view-conditions').tr()))
                            ],
                          ))
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }
}

class _AccountInfoCard extends StatelessWidget {
  const _AccountInfoCard();

  Widget _buildAccountInfoCard(BuildContext context, NetfloxUser user) =>
      SizedBox(
        height: 100,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProfileImage(imgUrl: user.imgURL),
            const SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  user.displayName,
                  maxLines: 1,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    if (user.verified)
                      const Padding(
                        padding: EdgeInsets.only(right: 5),
                        child: Icon(Icons.verified),
                      ),
                    Text(
                      user.verified ? 'verified' : 'unverified',
                      style: const TextStyle(fontSize: 12),
                    ).tr(),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.account_circle),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      user.userType.tr(context),
                      style: const TextStyle(fontSize: 12),
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
      );

  Widget _buildAccountControlButtons(BuildContext context, NetfloxUser user) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (user.isAdmin())
            ElevatedButton(
                style: ButtonStyle(
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100))),
                    elevation: const MaterialStatePropertyAll(0),
                    fixedSize:
                        const MaterialStatePropertyAll(Size.fromHeight(40))),
                onPressed: () => context.router.push(const AdminRoute()),
                child: AutoSizeText(
                  "admin-panel".tr(context),
                  maxLines: 2,
                  wrapWords: false,
                  textAlign: TextAlign.center,
                  minFontSize: 7,
                )),
          ElevatedButton(
            style: ButtonStyle(
                shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100))),
                elevation: const MaterialStatePropertyAll(0),
                fixedSize: const MaterialStatePropertyAll(Size.fromHeight(40))),
            child: AutoSizeText(
              "sign-out".tr(context),
              maxLines: 1,
              wrapWords: false,
              textAlign: TextAlign.center,
              minFontSize: 7,
            ),
            onPressed: () => context.read<AuthCubit>().signOut(),
          ),
          ElevatedButton(
            style: ButtonStyle(
                shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100))),
                elevation: const MaterialStatePropertyAll(0),
                fixedSize: const MaterialStatePropertyAll(Size.fromHeight(40))),
            child: AutoSizeText(
              "delete-account".tr(context),
              maxLines: 2,
              wrapWords: false,
              textAlign: TextAlign.center,
              minFontSize: 7,
            ),
            onPressed: () {
              if (!user.isTestAccount()) {
                context.read<AuthCubit>().deleteAccount();
              } else {
                CustomAwesomeDialog(
                        context: context,
                        title: 'test-account-limit',
                        desc: "test-account-limit-desc")
                    .tr()
                    .show();
              }
            },
          ),
        ]
            .map((e) => Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: e,
                  ),
                ))
            .toList(),
      );

  bool largerThanMobile(BuildContext context) =>
      ResponsiveWrapper.of(context).isLargerThan(MOBILE);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state.isAuthenticated()) {
          final user = state.user!;
          return SettingCard(
              title: "account-settings".tr(context),
              child: ResponsiveRowColumn(
                rowSpacing: 25,
                columnSpacing: 25,
                layout: largerThanMobile(context)
                    ? ResponsiveRowColumnType.ROW
                    : ResponsiveRowColumnType.COLUMN,
                children: [
                  ResponsiveRowColumnItem(
                    rowFit: FlexFit.loose,
                    rowFlex: 2,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildAccountInfoCard(context, user),
                          const SizedBox(
                            height: 25,
                          ),
                          _buildAccountControlButtons(context, user),
                        ]),
                  ),
                  if (largerThanMobile(context))
                    ResponsiveRowColumnItem(
                      child: Container(
                        width: 0.5,
                        height: 150,
                        color: Theme.of(context).highlightColor,
                      ),
                    ),
                  const ResponsiveRowColumnItem(
                      rowFlex: 3,
                      rowFit: FlexFit.loose,
                      child: _AccountDetailsEditor()),
                ],
              ));
        } else {
          return CustomErrorWidget.from(
            error: "not-authenticated",
          );
        }
      },
    );
  }
}

class _AccountDetailsEditor extends StatefulWidget {
  const _AccountDetailsEditor({Key? key}) : super(key: key);

  @override
  State<_AccountDetailsEditor> createState() => __AccountDetailsEditorState();
}

class __AccountDetailsEditorState extends State<_AccountDetailsEditor> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final key = GlobalKey<FormState>();
  static const _kDefaultPassword = "...............";

  bool _passwordEdited = false;
  bool _emailEdited = false;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  void _reset() {
    emailController.text = user.email ?? "";
    passwordController.text = _kDefaultPassword;
    _passwordEdited = false;
    _emailEdited = false;
  }

  Future<bool> _onWillPop() async {
    if (_edited()) {
      bool result = false;
      await CustomAwesomeDialog(
              dialogType: DialogType.warning,
              title: "unsaved-changes",
              desc: "unsaved-changes-desc",
              btnOkOnPress: () {
                result = true;
              },
              btnCancelOnPress: () {},
              context: context)
          .tr()
          .show();
      return result;
    }
    return true;
  }

  bool _edited() => _passwordEdited || _emailEdited;

  NetfloxUser get user => context.read<AuthCubit>().state.user!;

  Widget _buildBlockingOverlay() {
    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).dialogBackgroundColor,
            borderRadius: BorderRadius.circular(15)),
        constraints: const BoxConstraints(maxHeight: 200, maxWidth: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(
              height: 5,
            ),
            const Text(
              'test-account-limit',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ).tr(),
            const SizedBox(
              height: 5,
            ),
            const Text(
              'test-account-limit-desc',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13),
            ).tr()
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildForm(),
        if (user.isTestAccount())
          Positioned.fill(child: _buildBlockingOverlay())
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      onWillPop: _onWillPop,
      key: key,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
        child: Column(
          children: [
            const Text(
              'account-details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ).tr(),
            const SizedBox(height: 20),
            SettingItem(
                name: 'email'.tr(context),
                child: TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    if (!_emailEdited) {
                      setState(() {
                        emailController.clear();
                        _emailEdited = true;
                      });
                    }
                  },
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return "fill-out-this-field".tr(context);
                    } else if (!EmailValidator.validate(value!)) {
                      return "use-valid-email".tr(context);
                    }
                    return null;
                  },
                  style: const TextStyle(fontSize: 15),
                  decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email),
                      hintText: "email-address-hint".tr(context),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      fillColor: const Color.fromARGB(21, 0, 0, 0),
                      filled: true,
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10))),
                )),
            const SizedBox(height: 10),
            SettingItem(
                name:
                    (_passwordEdited ? 'new-password' : 'password').tr(context),
                child: TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  onChanged: (value) {
                    if (!_passwordEdited) {
                      setState(() {
                        passwordController.clear();
                        _passwordEdited = true;
                      });
                    }
                  },
                  style: const TextStyle(fontSize: 15),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return "fill-out-this-field".tr(context);
                    }
                    if ((value?.length ?? 0) <= 7) {
                      return "password-too-short".tr(context);
                    }
                    return null;
                  },
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock),
                    hintText: "password-hint".tr(context),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    fillColor: const Color.fromARGB(21, 0, 0, 0),
                    filled: true,
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10)),
                  ),
                )),
            if (_passwordEdited) _buildConfirmPasswordField(),
            if (_edited()) _buildControlButtons()
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    final confirmController = TextEditingController();
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: SettingItem(
          name: 'confirm-password-hint'.tr(context),
          child: TextFormField(
            controller: confirmController,
            obscureText: true,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return "fill-out-this-field".tr(context);
              }
              if (value != passwordController.text) {
                return "passwords-not-matching".tr(context);
              }
              return null;
            },
            style: const TextStyle(fontSize: 15),
            keyboardType: TextInputType.visiblePassword,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline),
              hintText: "confirm-password-hint".tr(context),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              fillColor: const Color.fromARGB(21, 0, 0, 0),
              filled: true,
              border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10)),
            ),
          )),
    );
  }

  Widget _buildControlButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: ElevatedButton(
              onPressed: () {
                if (key.currentState!.validate()) {
                  final newEmail = _emailEdited ? emailController.text : null;
                  final newPassword =
                      _passwordEdited ? passwordController.text : null;
                  context.read<AuthCubit>().updateAccountDetails(
                      newEmail: newEmail, newPassword: newPassword);
                }
              },
              child: const Text("save").tr(),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            flex: 1,
            child: ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStatePropertyAll(Theme.of(context).hintColor)),
              onPressed: () {
                setState(() {
                  _reset();
                });
              },
              child: AutoSizeText(
                "reset".tr(context),
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingItem extends StatelessWidget {
  final String name;
  final Widget child;

  const SettingItem({super.key, required this.name, required this.child});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
            child: AutoSizeText(
          name,
          minFontSize: 10,
          maxLines: 2,
          wrapWords: false,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        )),
        Flexible(flex: 3, child: child),
      ],
    );
  }
}

class CupertinoSelector<T> extends StatelessWidget {
  final List<T> values;
  final Color? thumbColor;
  final T? currentValue;
  final Widget Function(BuildContext context, T value, bool selected)? builder;
  final void Function(T?) onValueChanged;
  const CupertinoSelector(
      {super.key,
      required this.values,
      this.currentValue,
      this.builder,
      required this.onValueChanged,
      this.thumbColor});

  Widget _builder(BuildContext context, T value, bool selected) {
    return builder?.call(context, value, selected) ??
        Text(
          value.toString(),
          maxLines: 1,
          style: const TextStyle(fontSize: 14, color: Colors.white),
        );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoSlidingSegmentedControl<T>(
      thumbColor: thumbColor ?? Theme.of(context).primaryColor,
      groupValue: currentValue,
      children: values.asMap().map((key, value) => MapEntry(
          value,
          FittedBox(
              fit: BoxFit.scaleDown,
              child: _builder(context, value, value == currentValue)))),
      onValueChanged: (value) {
        if (value != null) {
          onValueChanged(value);
        }
      },
    );
  }
}

class SettingCard extends StatelessWidget {
  final String title;
  final Widget child;
  const SettingCard({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: Column(
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 35,
              ),
              child
            ],
          )),
    );
  }
}
