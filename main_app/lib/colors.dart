import 'package:flutter/material.dart';

MaterialColor griiColors = MaterialColor(
  0xffb91c1c,
  <int, Color>{
    50: Color.fromARGB(255, 254, 242, 242),
    100: Color.fromARGB(255, 254, 226, 226),
    200: Color.fromARGB(255, 254, 202, 202),
    300: Color.fromARGB(255, 252, 165, 165),
    400: Color.fromARGB(255, 248, 113, 113),
    500: Color.fromARGB(255, 239, 68, 68),
    600: Color.fromARGB(255, 220, 38, 38),
    700: Color.fromARGB(255, 185, 28, 28),
    800: Color.fromARGB(255, 153, 27, 27),
    900: Color.fromARGB(255, 127, 29, 29),
  },
);

ThemeData griiThemeLight = ThemeData.light().copyWith(
  primaryColor: griiColors,
);

ThemeData griiThemeDark = ThemeData.dark().copyWith(
  primaryColor: griiColors,
);
