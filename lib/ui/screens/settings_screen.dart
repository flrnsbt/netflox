import 'package:auto_route/auto_route.dart';
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
import 'package:netflox/ui/widgets/constrained_large_screen_widget.dart';
import 'package:netflox/ui/widgets/error_widget.dart';
import 'package:netflox/ui/widgets/profile_image.dart';
import 'package:netflox/utils/reponsive_size_helper.dart';
import '../../data/blocs/account/auth/auth_cubit.dart';
import '../router/router.gr.dart';
import '../widgets/custom_awesome_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  Widget _buildLanguagePicker(BuildContext context) {
    final locales = <Locale, Widget>{};
    for (var locale in AppLocalization.supportedLocales) {
      final widget = Text(
        "language-${locale.languageCode}".tr(context),
        style: TextStyle(fontSize: 5.sp(context)),
      );
      locales.putIfAbsent(locale, () => widget);
    }
    return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        return BlocBuilder<AppLocalization, AppLocalizationState>(
          builder: (context, state) {
            return CupertinoSlidingSegmentedControl<Locale>(
              thumbColor: Theme.of(context).primaryColor,
              children: locales,
              onValueChanged: (value) {
                if (value != null) {
                  CustomAwesomeDialog(
                          btnOkOnPress: () {
                            context.read<AppLocalization>().updateLocale(value);
                            context.popRoute();
                          },
                          onDismissCallback: (type) {
                            if (type.aborted()) {
                              setState.call(() {});
                            }
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
              groupValue: state.currentLocale,
            );
          },
        );
      },
    );
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
    final themes = <ThemeMode, Widget>{};
    for (var theme in ThemeMode.values) {
      final widget = Text(
        theme.name,
        style: TextStyle(fontSize: 5.sp(context)),
      ).tr();
      themes.putIfAbsent(theme, () => widget);
    }
    return BlocBuilder<ThemeDataCubit, ThemeDataState>(
      builder: (context, state) {
        return CupertinoSlidingSegmentedControl<ThemeMode>(
          children: themes,
          thumbColor: Theme.of(context).primaryColor,
          onValueChanged: (value) {
            if (value != null) {
              context.read<ThemeDataCubit>().changeMode(value);
            }
          },
          groupValue: state.mode,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedLargeScreenWidget(
        child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              title: const Text(
                "settings",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ).tr(),
              backgroundColor: Colors.transparent,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
            ),
            body: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              children: [
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    if (state.isAuthenticated()) {
                      final user = state.user!;
                      return _AccountDetailEditor(user);
                    } else {
                      return CustomErrorWidget.from(
                        error: "not-authenticated",
                      );
                    }
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                _buildAppSettings(context),
                const SizedBox(
                  height: 20,
                ),
              ],
            )));
  }
}

class _AccountDetailEditor extends StatefulWidget {
  final NetfloxUser user;
  const _AccountDetailEditor(this.user);

  @override
  State<_AccountDetailEditor> createState() => _AccountDetailEditorState();
}

const _kDefaultPassword = "...............";

class _AccountDetailEditorState extends State<_AccountDetailEditor> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final key = GlobalKey<FormState>();

  bool _passwordEdited = false;
  bool _emailEdited = false;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  void _reset() {
    emailController.text = widget.user.email ?? "";
    passwordController.text = _kDefaultPassword;
    _passwordEdited = false;
    _emailEdited = false;
  }

  Future<bool> _onWillPop() async {
    if (_edited()) {
      bool result = false;
      await CustomAwesomeDialog(
              dialogType: DialogType.warning,
              title: "warning",
              desc: "unsaved-changes",
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

  @override
  Widget build(BuildContext context) {
    return SettingCard(
        title: "account-settings".tr(context),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SizedBox(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProfileImage(imgUrl: widget.user.imgURL),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      widget.user.displayName,
                      maxLines: 1,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        if (widget.user.verified)
                          const Padding(
                            padding: EdgeInsets.only(right: 5),
                            child: Icon(Icons.verified),
                          ),
                        Text(
                          widget.user.verified ? 'verified' : 'unverified',
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
                          widget.user.userType.tr(context),
                          style: const TextStyle(fontSize: 12),
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.user.isAdmin())
                ElevatedButton(
                    style: const ButtonStyle(
                        fixedSize:
                            MaterialStatePropertyAll(Size.fromHeight(40))),
                    onPressed: () => context.router.push(const AdminRoute()),
                    child: AutoSizeText(
                      "admin-panel".tr(context),
                      maxLines: 2,
                      wrapWords: false,
                      textAlign: TextAlign.center,
                      minFontSize: 10,
                    )),
              ElevatedButton(
                style: const ButtonStyle(
                    fixedSize: MaterialStatePropertyAll(Size.fromHeight(40))),
                child: AutoSizeText(
                  "sign-out".tr(context),
                  maxLines: 1,
                  wrapWords: false,
                  textAlign: TextAlign.center,
                  minFontSize: 10,
                ),
                onPressed: () => context.read<AuthCubit>().signOut(),
              ),
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(
                        Theme.of(context).disabledColor),
                    fixedSize:
                        const MaterialStatePropertyAll(Size.fromHeight(40))),
                child: AutoSizeText(
                  "delete-account".tr(context),
                  maxLines: 2,
                  wrapWords: false,
                  textAlign: TextAlign.center,
                  minFontSize: 8,
                ),
                onPressed: () {
                  context.read<AuthCubit>().deleteAccount();
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
          ),
          const SizedBox(
            height: 45,
          ),
          Form(
            onWillPop: _onWillPop,
            key: key,
            child: Column(
              children: [
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
                    name: (_passwordEdited ? 'new-password' : 'password')
                        .tr(context),
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
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
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
          )
        ]));
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
                  backgroundColor: MaterialStatePropertyAll(
                      Theme.of(context).disabledColor)),
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
      children: [
        Expanded(
          child: AutoSizeText(
            name,
            minFontSize: 10,
            maxLines: 2,
            wrapWords: false,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(flex: 3, child: child),
      ],
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: Column(
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
