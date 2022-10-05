class TMDBApiConfig {
  final String apiKey;
  const TMDBApiConfig(this.apiKey, this.url, this.imgDatabaseUrl);

  final String url;
  final String imgDatabaseUrl;

  factory TMDBApiConfig.fromMap(Map<String, dynamic> map) {
    return TMDBApiConfig(map['api_key'], map['url'], map['img_db_url']);
  }

  @override
  String toString() => 'TMDBApiConfig(apiKey: $apiKey)';
}
