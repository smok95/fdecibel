import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class TickerClock extends StatefulWidget {
  final String languageCode;

  TickerClock({this.languageCode});

  @override
  _TickerClockState createState() => _TickerClockState();
}

class _TickerClockState extends State<TickerClock> {
  String _timeString;
  Timer _timer;
  String _langCode;

  @override
  void initState() {
    super.initState();

    if (widget.languageCode != null) _langCode = widget.languageCode;

    if (_langCode == null) {
      Future.delayed(Duration.zero, () {
        Locale locale = Localizations.localeOf(context);
        _langCode = locale?.languageCode ?? null;
        setState(() {});
      });
    }

    initializeDateFormatting().then((value) {});

    _timeString = _toTimeString();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _timeString = _toTimeString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(5, 1, 5, 1),
      child: Text(_timeString),
    );
  }

  @override
  void dispose() {
    if (_timer?.isActive ?? false) _timer.cancel();

    super.dispose();
  }

  String _toTimeString() {
    final now = DateTime.now();
    return DateFormat.yMEd(_langCode).add_jms().format(now);
  }
}
