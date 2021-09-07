import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chopper/chopper.dart';
import 'package:flutter/foundation.dart';
import 'package:grii_resmi/flavors.dart';
import 'package:grii_resmi/installation_id.dart';
import 'package:http/io_client.dart' as http;
import 'package:http/http.dart' as http0;
import 'package:package_info/package_info.dart';

import 'pillar_models.dart';

part 'pillar_api.chopper.dart';

final _chopperJsonToTypeMap = {
  ArticleBriefsResponse: (json) => ArticleBriefsResponse.fromJson(json),
  String: (json) => json.toString(),
};

class JsonToTypeConverter extends JsonConverter {
  final Map<Type, Function> typeToJsonFactoryMap;

  JsonToTypeConverter(this.typeToJsonFactoryMap);

  @override
  Response<BodyType> convertResponse<BodyType, InnerType>(Response response) {
    return response.copyWith(
      body: fromJsonData<BodyType, InnerType>(response.body, typeToJsonFactoryMap[InnerType]!),
    );
  }

  T? fromJsonData<T, InnerType>(String jsonData, Function jsonParser) {
    final jsonMap = json.decode(jsonData);

    if (jsonMap is List) {
      return jsonMap.map((item) => jsonParser(item as Map<String, dynamic>) as InnerType).toList() as T;
    }

    return jsonParser(jsonMap);
  }
}

ChopperClient createChopperClient(String baseUrl) {
  return ChopperClient(
    baseUrl: baseUrl,
    client: kIsWeb ? null : http.IOClient(HttpClient()..connectionTimeout = Duration(seconds: 30)),
    services: [PillarApiService.create()],
    converter: JsonToTypeConverter(_chopperJsonToTypeMap),
    interceptors: [
      HttpLoggingInterceptor(),
    ],
  );
}

@ChopperApi()
abstract class PillarApiService extends ChopperService {
  static PillarApiService create([ChopperClient? client]) => _$PillarApiService(client);

  @Get(path: '?method=listArticlesForCategory&category_id=2')
  Future<Response<ArticleBriefsResponse>> listArticles();

  @Get(path: '?method=listAllIssues')
  Future<Response<IssuesResponse>> listAllIssues();
}

PillarApiService pillarApiService = createChopperClient(Flavor.current.pillarApiUrl).getService<PillarApiService>();

String _encodeParams(Map<String, dynamic> params) {
  return params.entries
      .map((e) => Uri.encodeQueryComponent(e.key) + '=' + Uri.encodeQueryComponent(e.value.toString()))
      .join('&');
}

Future<Map<String, dynamic>> _commonParams() async {
  final pi = await PackageInfo.fromPlatform();
  final params = {
    'source_platform': 'grii_resmi',
    'source_installation_id': getInstallationId(),
    'source_app_packageName': 'yuku.grii',
    'source_app_versionCode': pi.buildNumber,
    'source_app_debug': Flavor.current.name,
  };
  return params;
}

void getArticle(int articleId, StreamController<ArticleFull> controller) async {
  final params = await _commonParams();
  params['method'] = 'getArticle';
  params['article_id'] = '$articleId';

  final client = http0.Client();

  try {
    final resp = await client.get(Uri.parse(Flavor.current.pillarApiUrl + '?' + _encodeParams(params)));
    if (resp.statusCode == 200) {
      final root = json.decode(resp.body);
      final dynamic item = root['article'];
      var a = ArticleFull();
      a.name = item['name'];
      a.title = item['title'];
      a.body = item['body'];
      controller.add(a);
      controller.close();
    } else {
      throw Exception("bad status code ${resp.statusCode}");
    }
  } catch (e) {
    controller.addError(e);
  }
}
