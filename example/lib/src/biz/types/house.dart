// Copyright (c) 2024 foxsofter.
//
// Do not edit this file.
//

import 'dart:convert';

import 'package:example/src/biz/types/people.dart';
import 'package:flutter_jsonable/flutter_jsonable.dart';

/// a struct description a house.
///
class House {
  House({
    this.address = '',
    this.owner,
  });

  factory House.fromJson(Map<String, dynamic> json) => House(
        address: getValueFromJsonOrNull<String>(json, 'address') ?? '',
        owner: getValueFromJsonOrNull<People>(json, 'owner'),
      );

  factory House.copyWith(
    House other, {
    String? address,
    People? owner,
  }) {
    final otherJson = other.toJson();
    otherJson['address'] = address ?? otherJson['address'];
    otherJson['owner'] = getJsonFromValue<People>(owner) ?? otherJson['owner'];
    return House.fromJson(otherJson);
  }

  final String address;

  final People? owner;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'address': address,
        'owner': getJsonFromValue<People>(owner),
      };

  @override
  String toString() => jsonEncode(toJson());
}