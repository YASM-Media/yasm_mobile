import 'package:flutter/material.dart';

void showBottomSheet(BuildContext context, Widget body) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return body;
    });
