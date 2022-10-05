import 'dart:convert';

import 'package:flutter/services.dart';

const kJsonAssetBasePath = "assets/jsons";

class JsonFileReader {
  static Future<Map<String, dynamic>> read(String filename) async {
    final string = await rootBundle.loadString("$kJsonAssetBasePath/$filename");
    final json = jsonDecode(string);
    return json;
  }
}
