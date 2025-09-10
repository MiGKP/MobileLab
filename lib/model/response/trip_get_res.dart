// To parse this JSON data, do
//
//     final tripGetRespose = tripGetResposeFromJson(jsonString);

import 'dart:convert';

List<TripGetRespose> tripGetResposeFromJson(String str) =>
    List<TripGetRespose>.from(
      json.decode(str).map((x) => TripGetRespose.fromJson(x)),
    );

String tripGetResposeToJson(List<TripGetRespose> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TripGetRespose {
  int idx;
  String name;
  String country;
  String coverimage;
  String detail;
  int price;
  int duration;
  String destinationZone;

  TripGetRespose({
    required this.idx,
    required this.name,
    required this.country,
    required this.coverimage,
    required this.detail,
    required this.price,
    required this.duration,
    required this.destinationZone,
  });

  factory TripGetRespose.fromJson(Map<String, dynamic> json) => TripGetRespose(
    idx: json["idx"],
    name: json["name"],
    country: json["country"],
    coverimage: json["coverimage"],
    detail: json["detail"],
    price: json["price"],
    duration: json["duration"],
    destinationZone: json["destination_zone"],
  );

  Map<String, dynamic> toJson() => {
    "idx": idx,
    "name": name,
    "country": country,
    "coverimage": coverimage,
    "detail": detail,
    "price": price,
    "duration": duration,
    "destination_zone": destinationZone,
  };
}
