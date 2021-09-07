// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pillar_api.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations
class _$PillarApiService extends PillarApiService {
  _$PillarApiService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = PillarApiService;

  @override
  Future<Response<ArticleBriefsResponse>> getLatestArticles() {
    final $url = '?method=listArticlesForCategory&articleId=2';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<ArticleBriefsResponse, ArticleBriefsResponse>($request);
  }
}
