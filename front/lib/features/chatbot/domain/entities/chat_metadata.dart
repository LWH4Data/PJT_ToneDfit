/// 챗봇 응답 메타데이터
class ChatMetaData {
  final String? intent;
  final String? searchQuery;
  final dynamic filters;
  final String? location;
  final bool? weatherRequested;

  ChatMetaData({
    this.intent,
    this.searchQuery,
    this.filters,
    this.location,
    this.weatherRequested,
  });

  factory ChatMetaData.fromJson(Map<String, dynamic> json) {
    return ChatMetaData(
      intent: json['intent']?.toString(),
      searchQuery: json['search_query']?.toString(),
      filters: json['filters'],
      location: json['location']?.toString(),
      weatherRequested: json['weather_requested'] as bool?,
    );
  }
}
