import 'dart:async';
import 'dart:convert';

import 'package:grii_resmi/flavors.dart';
import 'package:grii_resmi/installation_id.dart';
import 'package:http/http.dart' as http;

class ArticleBrief {
  final int id;
  final String name;
  final String title;
  final String snippet;

  ArticleBrief({this.id, this.name, this.title, this.snippet});
}

class ArticleFull {
  final String name;
  final String title;
  final String body;

  ArticleFull({this.name, this.title, this.body});
}

String _encodeParams(Map<String, dynamic> params) {
  return params.entries
      .map((e) => Uri.encodeQueryComponent(e.key) + '=' + Uri.encodeQueryComponent(e.value.toString()))
      .join('&');
}

void getLatestArticles(StreamController<List<ArticleBrief>> controller) async {
  final params = {
    'method': 'listArticlesForCategory',
    'category_id': '2',
    'source_platform': 'grii_resmi',
    'source_installation_id': getInstallationId(),
    'source_app_packageName': 'yuku.grii',
    'source_app_versionCode': '0',
    'source_app_debug': '0',
  };

  final client = http.Client();

  try {
    final resp = await client.get(Uri.parse(Flavor.current.pillarApiUrl + '?' + _encodeParams(params)));
    if (resp.statusCode == 200) {
      final root = json.decode(resp.body);
      final List<dynamic> items = root['articles']['items'];
      final list = items
          .map((item) =>
              ArticleBrief(id: item['_id'], name: item['name'], title: item['title'], snippet: item['snippet']))
          .toList();
      controller.add(list);
      controller.close();
    } else {
      throw Exception("bad status code ${resp.statusCode}");
    }
  } catch (e) {
    controller.addError(e);
  }
}

void getArticle(int articleId, StreamController<ArticleFull> controller) async {
  final params = {
    'method': 'getArticle',
    'article_id': '$articleId',
    'source_platform': 'grii_resmi',
    'source_installation_id': getInstallationId(),
    'source_app_packageName': 'yuku.grii',
    'source_app_versionCode': '0',
    'source_app_debug': '0',
  };

  final client = http.Client();

  try {
    final resp = await client.get(Uri.parse(Flavor.current.pillarApiUrl + '?' + _encodeParams(params)));
    if (resp.statusCode == 200) {
      final root = json.decode(resp.body);
      final dynamic item = root['article'];
      controller.add(ArticleFull(name: item['name'], title: item['title'], body: item['body']));
      controller.close();
    } else {
      throw Exception("bad status code ${resp.statusCode}");
    }
  } catch (e) {
    controller.addError(e);
  }
}
