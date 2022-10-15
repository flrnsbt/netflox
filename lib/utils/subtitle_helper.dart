import 'dart:convert';

import 'package:chewie/chewie.dart';

enum SubtitleType {
  webvtt,
  srt;
}

Subtitles getSubtitlesData(
  String subtitlesContent,
  SubtitleType subtitleType,
) {
  RegExp regExp;
  if (subtitleType == SubtitleType.webvtt) {
    regExp = RegExp(
      r'((\d{2}):(\d{2}):(\d{2})\.(\d+)) +--> +((\d{2}):(\d{2}):(\d{2})\.(\d{3})).*[\r\n]+\s*((?:(?!\r?\n\r?).)*(\r\n|\r|\n)(?:.*))',
      caseSensitive: false,
      multiLine: true,
    );
  } else if (subtitleType == SubtitleType.srt) {
    regExp = RegExp(
      r'((\d{2}):(\d{2}):(\d{2})\,(\d+)) +--> +((\d{2}):(\d{2}):(\d{2})\,(\d{3})).*[\r\n]+\s*((?:(?!\r?\n\r?).)*(\r\n|\r|\n)(?:.*))',
      caseSensitive: false,
      multiLine: true,
    );
  } else {
    throw 'Incorrect subtitle type';
  }

  final matches = regExp.allMatches(subtitlesContent).toList();
  final List<Subtitle> subtitleList = [];
  for (int i = 0; i < matches.length; i++) {
    final regExpMatch = matches[i];
    final startTimeHours = int.parse(regExpMatch.group(2)!);
    final startTimeMinutes = int.parse(regExpMatch.group(3)!);
    final startTimeSeconds = int.parse(regExpMatch.group(4)!);
    final startTimeMilliseconds = int.parse(regExpMatch.group(5)!);

    final endTimeHours = int.parse(regExpMatch.group(7)!);
    final endTimeMinutes = int.parse(regExpMatch.group(8)!);
    final endTimeSeconds = int.parse(regExpMatch.group(9)!);
    final endTimeMilliseconds = int.parse(regExpMatch.group(10)!);
    final text = removeAllHtmlTags(regExpMatch.group(11)!);

    final startTime = Duration(
      hours: startTimeHours,
      minutes: startTimeMinutes,
      seconds: startTimeSeconds,
      milliseconds: startTimeMilliseconds,
    );
    final endTime = Duration(
      hours: endTimeHours,
      minutes: endTimeMinutes,
      seconds: endTimeSeconds,
      milliseconds: endTimeMilliseconds,
    );

    subtitleList.add(
      Subtitle(start: startTime, end: endTime, text: text.trim(), index: i),
    );
  }

  return Subtitles(subtitleList);
}

String removeAllHtmlTags(String htmlText) {
  final exp = RegExp(
    '(<[^>]*>)',
    multiLine: true,
  );
  var newHtmlText = htmlText;
  exp.allMatches(htmlText).toList().forEach(
    (RegExpMatch regExpMatch) {
      newHtmlText = regExpMatch.group(0) == '<br>'
          ? newHtmlText.replaceAll(regExpMatch.group(0)!, '\n')
          : newHtmlText.replaceAll(regExpMatch.group(0)!, '');
    },
  );

  return newHtmlText;
}
