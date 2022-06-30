import 'package:flutter/material.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/data/models/tmdb/filter.dart';

class CustomDrawer extends Drawer {
  final void Function(TMDBFilter filter) onSelected;
  const CustomDrawer({
    super.key,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    Widget buildTile<T extends TMDBFilter>(T element) {
      return ListTile(
        minLeadingWidth: 0,
        contentPadding: const EdgeInsets.symmetric(horizontal: 25),
        leading: Image.asset(
          "assets/icons/${element.name}.png",
          height: 24.0,
        ),
        title: Text(
          element.name.tr,
          style: const TextStyle(fontSize: 13),
        ),
        onTap: () {
          onSelected(element);
          Navigator.pop(context);
        },
      );
    }

    Widget buildCategory(String title, List<Widget> children) {
      var opened = ValueNotifier(false);
      return ValueListenableBuilder(
        builder: (BuildContext context, value, Widget? child) {
          return Column(
            children: [
              ListTile(
                trailing:
                    Icon(value ? Icons.arrow_drop_up : Icons.arrow_drop_down),
                onTap: () {
                  opened.value = !opened.value;
                },
                title: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (opened.value) ...children
            ],
          );
        },
        valueListenable: opened,
      );
    }

    return SizedBox(
      width: 250,
      child: Material(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(
              height: 15,
            ),
            const ListTile(
              title: Text(
                "Movie Filters",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const Divider(),
            buildCategory(
                "Media Types", TMDBMediaType.values.map(buildTile).toList()),
            buildCategory("Genres", TMDBGenre.values.map(buildTile).toList()),
            buildCategory(
                "Language", TMDBLanguage.values.map(buildTile).toList()),
          ],
        ),
      ),
    );
  }
}
