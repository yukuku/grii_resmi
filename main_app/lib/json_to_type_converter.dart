import 'dart:convert';

import 'package:chopper/chopper.dart';

import 'main.dart';

class JsonToTypeConverter extends JsonConverter {
  final Map<Type, Function> typeToJsonFactoryMap;

  JsonToTypeConverter(this.typeToJsonFactoryMap);

  @override
  Response<BodyType> convertResponse<BodyType, InnerType>(Response response) {
    final factory = typeToJsonFactoryMap[InnerType];
    if (factory == null) {
      recordGenericError('factory should not be null for $InnerType');
    }
    return response.copyWith(
      body: fromJsonData<BodyType, InnerType>(response.body, factory!),
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
