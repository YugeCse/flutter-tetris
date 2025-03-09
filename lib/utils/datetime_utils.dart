/// 时间相关工具类
class DatetimeUtils {
  DatetimeUtils._();

  /// 获取当前时间
  static String get todayTimeText {
    var dt = DateTime.now();
    var year = dt.year;
    var month = dt.month;
    var day = dt.day;
    var hours = dt.hour;
    var minutes = dt.minute;
    var seconds = dt.second;
    return '$year年${month > 9 ? month : '0$month'}月${day > 9 ? day : '0$day'}日 ${hours > 9 ? hours : '0$hours'}:${minutes > 9 ? minutes : '0$minutes'}:${seconds > 9 ? seconds : '0$seconds'}';
  }
}
