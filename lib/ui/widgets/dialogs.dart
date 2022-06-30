import 'package:flutter/material.dart';

Widget customDialog(
    {required Widget child,
    String? title,
    EdgeInsets? insetPadding,
    bool closeButton = false,
    void Function()? onClosePressed}) {
  return Builder(builder: (context) {
    return Center(
      child: SingleChildScrollView(
        child: Card(
          margin: const EdgeInsets.all(30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          child: Padding(
            padding: insetPadding ??
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    if (closeButton)
                      SizedBox.square(
                        dimension: 20,
                        child: TextButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.grey[200]),
                              minimumSize: MaterialStateProperty.all(Size.zero),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding: MaterialStateProperty.all(
                                EdgeInsets.zero,
                              )),
                          onPressed: onClosePressed ??
                              () {
                                Navigator.pop(context);
                              },
                          child: const Text(
                            "X",
                            style: TextStyle(
                                fontFamily: "Arial",
                                fontWeight: FontWeight.bold,
                                color: Colors.black26,
                                fontSize: 12),
                          ),
                        ),
                      ),
                    if (title != null)
                      Center(
                          child: Text(
                        title,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ))
                  ],
                ),
                if (closeButton || title != null)
                  const SizedBox(
                    height: 15,
                  ),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  });
}

loadingDialog() => customDialog(child: const CircularProgressIndicator());
