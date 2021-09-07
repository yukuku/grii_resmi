import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:url_launcher/url_launcher.dart';

import '../flavors.dart';

int _todayDayNumber() {
  return (DateTime.now().millisecondsSinceEpoch / Duration.millisecondsPerDay).floor();
}

String _dateTimeToDisplayTime(DateTime d) {
  final t = DateFormat('H:mm').format(d);
  final tz = d.timeZoneOffset;
  if (tz == Duration(hours: 7)) {
    return t + ' WIB';
  } else if (tz == Duration(hours: 8)) {
    return t + ' SGT';
  }
  final sign = tz >= Duration.zero ? '+' : '-';
  final min = tz.inMinutes.abs();
  final add = min % 60;
  return t + ' GMT' + sign + (min ~/ 60).toString() + (add == 0 ? '' : (':' + add.toString()));
}

String _dayNumberToDisplayDate(int dayNumber) {
  final d = DateTime.fromMillisecondsSinceEpoch(dayNumber * Duration.millisecondsPerDay).toLocal();
  return ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'][d.weekday - 1] +
      ', ' +
      DateFormat('yyyy-MM-dd').format(d);
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
        title: Text('Jadwal Kegiatan'),
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

  DayPage({required this.dayNumber});

  @override
  State<StatefulWidget> createState() => _DayPageState();
}

class _DayPageState extends State<DayPage> {
  final StreamController<List> _controller = StreamController();

  Future fetchCalendar() async {
    final date = _dayNumberToDate(widget.dayNumber);
    final tzhm = _dayNumberToTzhm(widget.dayNumber);

    final response = await Client().get(Uri.parse(
        '${Flavor.current.functionsPrefix}/calendar/v0/listDayEvents?local_date=$date&local_tzhm=${Uri.encodeQueryComponent(tzhm)}'));

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

              if (snapshot.data.length == 0) {
                return Center(child: Text('Belum ada jadwal hari ini'));
              }

              final List<dynamic> events = snapshot.data;
              events.sort((a, b) {
                final int as = a['startTime'];
                final int bs = b['startTime'];
                return as.compareTo(bs);
              });

              return ListView.builder(
                itemBuilder: (context, index) {
                  final e = events[index];
                  final startTime = DateTime.fromMillisecondsSinceEpoch((e['startTime'] * 1000.0).floor());

                  final String title = e['title'];
                  final String? speaker = e['speaker'];
                  final String? linkText = e['linkText'];
                  final String description = e['description'].toString().trim();

                  final linkOpen = (LinkableElement link) async {
                    if (await canLaunch(link.url)) {
                      await launch(link.url);
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(content: Text('Ga bisa jalanin URL ${link.url}'));
                        },
                      );
                    }
                  };

                  return TimelineTile(
                    alignment: TimelineAlign.manual,
                    lineXY: 0.25,
                    startChild: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(_dateTimeToDisplayTime(startTime)),
                      ),
                    ),
                    indicatorStyle: IndicatorStyle(
                      width: 16.0,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    beforeLineStyle: LineStyle(
                      thickness: 2.0,
                      color: Theme.of(context).primaryColor,
                    ),
                    afterLineStyle: LineStyle(
                      thickness: 2.0,
                      color: Theme.of(context).primaryColor,
                    ),
                    isFirst: index == 0,
                    isLast: index == events.length - 1,
                    endChild: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            title,
                            style: Theme.of(context).textTheme.subtitle2,
                          ),
                          if (speaker != null && speaker.isNotEmpty) Text(speaker),
                          if (linkText != null && linkText.isNotEmpty)
                            Linkify(
                              text: linkText,
                              onOpen: linkOpen,
                            ),
                          if (description.isNotEmpty)
                            Linkify(
                              text: description,
                              onOpen: linkOpen,
                              style: TextStyle(fontSize: 12.0),
                            ),
                        ],
                      ),
                    ),
                  );
                },
                itemCount: events.length,
              );
            },
          ),
        ),
      ],
    );
  }
}
