import 'dart:async';
import 'dart:io';

import 'package:chopper/chopper.dart';
import 'package:flutter/foundation.dart';
import 'package:grii_resmi/flavors.dart';
import 'package:grii_resmi/kita_models.dart';
import 'package:http/io_client.dart' as http;

import 'json_to_type_converter.dart';

part 'kita_api.chopper.dart';

final _chopperJsonToTypeMap = {
  ListEdisiResponse: (json) => ListEdisiResponse.fromJson(json),
  EdisiResponse: (json) => EdisiResponse.fromJson(json),
  String: (json) => json.toString(),
};

ChopperClient createChopperClient(String baseUrl) {
  return ChopperClient(
    baseUrl: baseUrl,
    client: kIsWeb ? null : http.IOClient(HttpClient()..connectionTimeout = Duration(seconds: 30)),
    services: [KitaApiService.create()],
    converter: JsonToTypeConverter(_chopperJsonToTypeMap),
    interceptors: [
      HttpLoggingInterceptor(),
    ],
  );
}

@ChopperApi()
abstract class KitaApiService extends ChopperService {
  static KitaApiService create([ChopperClient? client]) => _$KitaApiService(client);

  @Get(path: 'list_edisi')
  Future<Response<ListEdisiResponse>> listEdisis();

  @Get(path: 'edisi')
  Future<Response<EdisiResponse>> getEdisi(@Query('edisi_page_url') String edisi_page_url);
}

KitaApiService kitaApiService = createChopperClient(Flavor.current.kitaApiUrl).getService<KitaApiService>();
