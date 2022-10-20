import 'package:flutter/material.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';

class NetfloxSearchBar extends StatefulWidget {
  final void Function(String query)? onQueryChange;
  final Widget? suffixWidget;
  final TextEditingController? controller;

  const NetfloxSearchBar(
      {Key? key, this.onQueryChange, this.controller, this.suffixWidget})
      : super(key: key);

  @override
  State<NetfloxSearchBar> createState() => _NetfloxSearchBarState();
}

class _NetfloxSearchBarState extends State<NetfloxSearchBar> {
  TextEditingController? _controller;
  Widget? _suffixWidget;
  bool _showEraseButton = false;

  @override
  void initState() {
    super.initState();
    _suffixWidget = widget.suffixWidget;
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller?.addListener(_controllerListener);
  }

  void _controllerListener() {
    setState(() {
      _showEraseButton = _controller!.text.isNotEmpty;
      widget.onQueryChange?.call(_controller!.text);
    });
  }

  @override
  void dispose() {
    _controller?.removeListener(_controllerListener);
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      style: const TextStyle(fontSize: 15, fontFamily: "Verdana"),
      minLines: 1,
      maxLines: 1,
      maxLength: 100,
      textInputAction: TextInputAction.search,
      keyboardType: TextInputType.text,
      cursorColor: Colors.black,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 5),
        prefixIconConstraints: const BoxConstraints(minWidth: 60),
        prefixIcon: const Icon(
          Icons.search,
        ),
        suffixIconConstraints: const BoxConstraints(minWidth: 60),
        suffixIcon: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_showEraseButton)
              MaterialButton(
                  onPressed: () {
                    _controller?.clear();
                  },
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  minWidth: 0,
                  padding: EdgeInsets.zero,
                  shape: const CircleBorder(),
                  child: const Icon(
                    Icons.close,
                  )),
            if (_suffixWidget != null) _suffixWidget!,
            const SizedBox(
              width: 10,
            )
          ],
        ),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none),
        counterText: "",
        hintText: "search-bar-hint".tr(context),
        fillColor: Theme.of(context).cardColor,
        filled: true,
      ),
    );
  }
}
