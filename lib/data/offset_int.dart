class OffsetInt {
  int dx;

  int dy;

  OffsetInt({required this.dx, required this.dy});

  OffsetInt operator +(OffsetInt other) {
    return OffsetInt(dx: dx + other.dx, dy: dy + other.dy);
  }

  OffsetInt operator -(OffsetInt other) {
    return OffsetInt(dx: dx - other.dx, dy: dy - other.dy);
  }

  OffsetInt operator *(int factor) {
    return OffsetInt(dx: dx * factor, dy: dy * factor);
  }

  OffsetInt operator /(int factor) {
    return OffsetInt(dx: dx ~/ factor, dy: dy ~/ factor);
  }

  @override
  String toString() {
    return 'OffsetInt(dx: $dx, dy: $dy)';
  }
}
