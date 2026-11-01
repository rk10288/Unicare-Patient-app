class DayOption {
  final String title;
  final int days;
  final bool isCustom;

  DayOption({
    required this.title,
    required this.days,
    this.isCustom = false,
  });

  factory DayOption.fromJson(Map<String, dynamic> json) {
    return DayOption(
      title: json['title'] ?? '',
      days: json['days'] ?? 0,
      // Check both camelCase (from Vue) and snake_case keys
      isCustom: json['isCustom'] ?? json['is_custom'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'days': days,
      'isCustom': isCustom,
    };
  }
}

class HourOption {
  final String title;
  final int hours;
  final bool isCustom;

  HourOption({
    required this.title,
    required this.hours,
    this.isCustom = false,
  });

  factory HourOption.fromJson(Map<String, dynamic> json) {
    return HourOption(
      title: json['title'] ?? '',
      hours: json['hours'] ?? 0,
      // Check both camelCase (from Vue) and snake_case keys
      isCustom: json['isCustom'] ?? json['is_custom'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'hours': hours,
      'isCustom': isCustom,
    };
  }
}
