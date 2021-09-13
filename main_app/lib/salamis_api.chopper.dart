// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'salamis_api.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations
class _$SalamisApiService extends SalamisApiService {
  _$SalamisApiService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = SalamisApiService;

  @override
  Future<Response<ListEdisiResponse>> listEdisis() {
    final $url = 'kita/list_edisi';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<ListEdisiResponse, ListEdisiResponse>($request);
  }

  @override
  Future<Response<EdisiResponse>> getEdisi(String edisi_page_url) {
    final $url = 'kita/edisi';
    final $params = <String, dynamic>{'edisi_page_url': edisi_page_url};
    final $request = Request('GET', $url, client.baseUrl, parameters: $params);
    return client.send<EdisiResponse, EdisiResponse>($request);
  }

  @override
  Future<Response<ListCabangResponse>> listCabangs() {
    final $url = 'cabang/list_cabang';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<ListCabangResponse, ListCabangResponse>($request);
  }
}
