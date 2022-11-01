import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DownloadProgressIndicator extends StatefulWidget {
  final Stream<int> bytesTransmitted;
  final int fileSize;
  const DownloadProgressIndicator(
      {super.key, required this.bytesTransmitted, required this.fileSize});

  @override
  State<DownloadProgressIndicator> createState() =>
      _DownloadProgressIndicatorState();
}

class _DownloadProgressIndicatorState extends State<DownloadProgressIndicator> {
  @override
  void initState() {
    super.initState();
    _fileSize = widget.fileSize / 1000000;
  }

  final double _dt = 1;

  double _fileSize = 0;
  double _bandwidth = 0;
  double _lastByteSize = 0;
  int _lastTsp = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.bytesTransmitted,
      builder: (context, snapshot) {
        final bytes = (snapshot.data ?? 0) / 1000000;
        final ratio = bytes / _fileSize;
        final tspNow = Timestamp.now().millisecondsSinceEpoch;
        if (_lastTsp < tspNow - (_dt * 1000)) {
          _bandwidth = (bytes - _lastByteSize) / _dt;
          if (_bandwidth < 0) {
            _bandwidth = 0;
          }
          _lastByteSize = bytes;
          _lastTsp = tspNow;
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(
                "${_bandwidth.toStringAsFixed(2)} MB/s",
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                "${bytes.toStringAsFixed(1)} / ${_fileSize.toStringAsFixed(1)} MB",
                style: const TextStyle(fontSize: 12),
              )
            ]),
            const SizedBox(
              height: 5,
            ),
            LinearProgressIndicator(value: ratio)
          ],
        );
      },
    );
  }
}
