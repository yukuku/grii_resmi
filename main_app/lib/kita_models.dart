import 'package:json_annotation/json_annotation.dart';

part 'kita_models.g.dart';

@JsonSerializable()
class ListEdisiResponse {
  late EdisiBriefList edisis;

  ListEdisiResponse();

  factory ListEdisiResponse.fromJson(Map<String, dynamic> json) => _$ListEdisiResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ListEdisiResponseToJson(this);
}

@JsonSerializable()
class EdisiBriefList extends _KitaList<EdisiBrief> {
  EdisiBriefList();

  factory EdisiBriefList.fromJson(Map<String, dynamic> json) => _$EdisiBriefListFromJson(json);

  Map<String, dynamic> toJson() => _$EdisiBriefListToJson(this);
}

@JsonSerializable()
class EdisiBrief {
  late String edisi_title;
  late String edisi_page_url;
  late String edisi_thumbnail;

  EdisiBrief();

  factory EdisiBrief.fromJson(Map<String, dynamic> json) => _$EdisiBriefFromJson(json);

  Map<String, dynamic> toJson() => _$EdisiBriefToJson(this);
}

@JsonSerializable()
class EdisiResponse {
  late EdisiFull edisi;

  EdisiResponse();

  factory EdisiResponse.fromJson(Map<String, dynamic> json) => _$EdisiResponseFromJson(json);

  Map<String, dynamic> toJson() => _$EdisiResponseToJson(this);
}

@JsonSerializable()
class EdisiFull {
  late String edisi_title;
  late String edisi_image;
  late List<Download> downloads;

  EdisiFull();

  factory EdisiFull.fromJson(Map<String, dynamic> json) => _$EdisiFullFromJson(json);

  Map<String, dynamic> toJson() => _$EdisiFullToJson(this);
}

@JsonSerializable()
class Download {
  late String title;
  late String url;

  Download();

  factory Download.fromJson(Map<String, dynamic> json) => _$DownloadFromJson(json);

  Map<String, dynamic> toJson() => _$DownloadToJson(this);
}

abstract class _KitaList<E> {
  late int total;
  late List<E> items;

  _KitaList();
}
