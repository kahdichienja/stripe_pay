import 'package:flutter/material.dart';

final kHintTextStyle = TextStyle(
  color: Colors.blueGrey,
  fontFamily: 'Circular',
);

final kLabelStyle = TextStyle(
  color: Colors.black45,
  fontWeight: FontWeight.bold,
  fontFamily: 'Circular',
);

final kBoxDecorationStyle = BoxDecoration(
  color: Color(0xFFCADCED),
  borderRadius: BorderRadius.circular(10.0),
  boxShadow: [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 6.0,
      offset: Offset(0, 2),
    ),
  ],
);