import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class NoticesHome extends StatefulWidget {
  @override
  _NoticesHomeState createState() => _NoticesHomeState();
}

class Notice {
  final DateTime createTime;
  final String body;

  Notice({required this.createTime, required this.body});
}

class _NoticesHomeState extends State<NoticesHome> {
  final notices = [
    Notice(createTime: DateTime(2020, 6, 17, 4, 35), body: """Anak Bertanya, Pak Tong Menjawab #21\n"Mengapa Manusia Berdosa?" Hallo Anak-anak! Tuhan ciptakan manusia begitu baik. Tuhan juga baik kepada manusia. Mengapa manusia berdosa? https://youtu.be/pL698u8a3eo"""),
    Notice(createTime: DateTime(2020, 6, 16, 10, 12), body: """Streaming Reformed Injili\nSelasa, 16 Juni 2020, pk 19.00 WIB\nSPIK 1993 (Sesi 2)\nRoh Kudus, Doa, dan Kebangunan"""),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengumuman'),
      ),
      body: ListView.builder(
        itemCount: 20,
        itemBuilder: (context, index) {
          final notice = notices[index % notices.length];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Linkify(text: notice.body, style: Theme.of(context).textTheme.bodyText2, onOpen: (link) => launch(link.url)),
                    Text(notice.createTime.toString(), style: Theme.of(context).textTheme.caption),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
