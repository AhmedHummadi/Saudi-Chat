import 'package:intl/intl.dart';

class Message {
  late String? message;
  late String? userName;
  late String? businessName;
  late String? documentId;

  Message({this.message, this.userName, this.businessName, this.documentId});

  // ignore: empty_constructor_bodies
  String get time {
    return DateFormat.jm().format(DateTime.now());
  }
}
