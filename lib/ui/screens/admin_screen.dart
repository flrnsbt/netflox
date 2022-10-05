import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/ui/screens/error_screen.dart';
import 'package:netflox/ui/widgets/buttons/back_button.dart';

import '../../data/blocs/account/auth/auth_cubit.dart';
import '../router/router.gr.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state.user?.isAdmin() ?? true) {
            return const ErrorScreen(
              error: 'permission-denied',
            );
          }
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                leading: const NetfloxBackButton(),
                foregroundColor: Colors.white,
                backgroundColor: Colors.transparent,
                title: const Text("Admin Panel"),
                actions: [
                  IconButton(
                      onPressed: () => context.router.push(const UploadRoute()),
                      icon: Icon(Icons.upload,
                          color: Theme.of(context).primaryColor))
                ],
              ),
              SliverPadding(
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(
                      height: 25,
                    ),
                    const Text(
                      "Requests",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    // GridView.builder(gridDelegate: , itemBuilder: ,)
                  ]),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 25),
              )
            ],
          );
        },
      ),
    );
  }
}
