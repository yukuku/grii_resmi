import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

import 'flavors.dart';

int _todayDayNumber() {
  return (DateTime.now().millisecondsSinceEpoch / Duration.millisecondsPerDay).floor();
}

String _dayNumberToDisplayDate(int dayNumber) {
  final d = DateTime.fromMillisecondsSinceEpoch(dayNumber * Duration.millisecondsPerDay).toLocal();
  return ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'][d.weekday - 1] + ', ' + DateFormat('yyyy-MM-dd').format(d);
}

String _dayNumberToDate(int dayNumber) {
  final d = DateTime.fromMillisecondsSinceEpoch(dayNumber * Duration.millisecondsPerDay).toLocal();
  return DateFormat('yyyy-MM-dd').format(d);
}

String _dayNumberToTzhm(int dayNumber) {
  final d = DateTime.fromMillisecondsSinceEpoch(dayNumber * Duration.millisecondsPerDay).toLocal();
  final tz = d.timeZoneOffset;
  final sign = tz >= Duration.zero ? '+' : '-';
  final min = tz.inMinutes.abs();
  return sign + (min ~/ 60).toString().padLeft(2, '0') + ':' + (min % 60).toString().padLeft(2, '0');
}

class CalendarHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CalendarHomeState();
}

class CalendarHomeState extends State<CalendarHome> {
  final _controller = PageController(
    initialPage: _todayDayNumber(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jadwal'),
      ),
      body: PageView.builder(
        controller: _controller,
        itemBuilder: (BuildContext context, int index) {
          return DayPage(dayNumber: index);
        },
      ),
    );
  }
}

class DayPage extends StatefulWidget {
  final int dayNumber;

  DayPage({this.dayNumber});

  @override
  State<StatefulWidget> createState() => _DayPageState();
}

class _DayPageState extends State<DayPage> {
  final StreamController<List> _controller = StreamController();

  Future fetchCalendar() async {
    final date = _dayNumberToDate(widget.dayNumber);
    final tzhm = _dayNumberToTzhm(widget.dayNumber);

    final response = await Client().get('${Flavor.current.functionsPrefix}/calendar/v0/listDayEvents?local_date=$date&local_tzhm=${Uri.encodeQueryComponent(tzhm)}');

    if (response.statusCode == 200) {
      _controller.add(json.decode(response.body));
      _controller.close();
    } else {
      _controller.addError('Failed to load post: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    fetchCalendar();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            _dayNumberToDisplayDate(widget.dayNumber),
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        Expanded(
          flex: 1,
          child: StreamBuilder(
            stream: _controller.stream,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.error != null) {
                return Center(child: Text('Error ${snapshot.error}'));
              }
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final List<dynamic> events = snapshot.data;
              final widgets = events.map((e) {
                double ms = (e['startTime'] * 1000.0);
                final startTime = DateTime.fromMillisecondsSinceEpoch(ms.toInt());

                return Column(children: <Widget>[
                  Text(startTime.toString()),
                  Text(
                    e['title'] + "${widget.dayNumber}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (e['speaker'] != null) Text(e['speaker']),
                  if (e['linkText'] != null) Text(e['linkText']),
                  if (e['description'] != null)
                    Text(
                      e['description'],
                      style: TextStyle(fontSize: 12.0),
                    ),
                ]);
              }).toList();
              return ListView(children: widgets);
            },
          ),
        ),
      ],
    );
  }
}
