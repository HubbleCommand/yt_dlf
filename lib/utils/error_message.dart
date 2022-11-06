
import 'package:flutter/material.dart';

enum Level {
  INFO,
  WARNING,
  ERROR,
}

extension LevelExtension on Level {
  Color get color {
    switch (this) {
      case Level.INFO:
        return Colors.grey;
      case Level.WARNING:
        return Colors.orange;
      case Level.ERROR:
        return Colors.red;
      default:
        return Colors.black;
    }
  }
}

class ErrorMessage {
  String message;
  Level level;
  Color get color {
    return level.color;
  }

  ErrorMessage({required this.message, required this.level});
}