import 'dart:async';
import 'dart:io';

import 'package:chopper/chopper.dart';
import 'package:flutter/foundation.dart';
import 'package:http/io_client.dart' as http;

import 'cabang_models.dart';
import 'flavors.dart';
import 'json_to_type_converter.dart';
import 'kita_models.dart';

part 'salamis_api.chopper.dart';

final _chopperJsonToTypeMap = {
  ListEdisiResponse: (json) => ListEdisiResponse.fromJson(json),
  EdisiResponse: (json) => EdisiResponse.fromJson(json),
  ListCabangResponse: (json) => ListCabangResponse.fromJson(json),
  String: (json) => json.toString(),
};

ChopperClient createChopperClient(String baseUrl) {
  return ChopperClient(
    baseUrl: baseUrl,
    client: kIsWeb ? null : http.IOClient(HttpClient()..connectionTimeout = Duration(seconds: 30)),
    services: [SalamisApiService.create()],
    converter: JsonToTypeConverter(_chopperJsonToTypeMap),
    interceptors: [
      HttpLoggingInterceptor(),
    ],
  );
}

@ChopperApi()
abstract class SalamisApiService extends ChopperService {
  static SalamisApiService create([ChopperClient? client]) => _$SalamisApiService(client);

  @Get(path: 'kita/list_edisi')
  Future<Response<ListEdisiResponse>> listEdisis();

  @Get(path: 'kita/edisi')
  Future<Response<EdisiResponse>> getEdisi(@Query('edisi_page_url') String edisi_page_url);

  @Get(path: 'cabang/list_cabang')
  Future<Response<ListCabangResponse>> listCabangs();
}

SalamisApiService salamisApiService = createChopperClient(Flavor.current.salamisApiUrl).getService<SalamisApiService>();
