import 'package:flutter/material.dart';
import 'package:saudi_chat/models/nadi.dart';

const InputDecoration textInputDecoration = InputDecoration(
    labelStyle: TextStyle(color: Colors.white), focusColor: Colors.white);

const List<String> cities = ["Sydney", "Melbourne", "Brisbane"];

List<NadiData> nadis = [
  NadiData(
      phoneNum: "+61423010463",
      nadiName: "Sydney Nadi",
      email: "gg@gmail.com",
      location: "Sydney"),
  NadiData(
      phoneNum: "+61423010463",
      nadiName: "Melbourne Nadi",
      email: "aa@gmail.com",
      location: "Melbourne"),
  NadiData(
      phoneNum: "+61423010463",
      nadiName: "Brisbane Nadi",
      email: "bb@gmail.com",
      location: "Brisbane")
];
