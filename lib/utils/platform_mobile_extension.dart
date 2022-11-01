import 'dart:io';

platformIsMobile() => Platform.isIOS || Platform.isAndroid;

platformIsCupertino() => Platform.isIOS || Platform.isMacOS;
