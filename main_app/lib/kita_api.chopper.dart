// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kita_api.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations
class _$KitaApiService extends KitaApiService {
  _$KitaApiService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = KitaApiService;

  @override
  Future<Response<IssuesResponse>> listEdisis() {
    final $url = 'list_edisi';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<IssuesResponse, IssuesResponse>($request);
  }

  @override
  Future<Response<LastIssueResponse>> getEdisi(String edisi_page_url) {
    final $url = 'edisi';
    final $params = <String, dynamic>{'edisi_page_url': edisi_page_url};
    final $request = Request('GET', $url, client.baseUrl, parameters: $params);
    return client.send<LastIssueResponse, LastIssueResponse>($request);
  }
}
