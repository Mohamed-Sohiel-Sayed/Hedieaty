// lib/views/gift_list/widgets/gift_list_widgets.dart
import 'package:flutter/material.dart';
import '../../../models/gift.dart';

Color getGiftStatusColor(String status) {
  switch (status) {
    case 'pledged':
      return Colors.green;
    case 'purchased':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

Widget buildGiftItem(Gift gift) {
  return ListTile(
    title: Text(gift.name),
    subtitle: Text(gift.description),
    tileColor: getGiftStatusColor(gift.status),
  );
}