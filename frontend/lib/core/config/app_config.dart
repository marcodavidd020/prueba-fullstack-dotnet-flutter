class AppConfig {
  const AppConfig();

  String get apiBaseUrl => const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5151',
  );

  String get apiKey => const String.fromEnvironment('API_KEY');

  Duration get connectTimeout => const Duration(seconds: 10);

  Duration get receiveTimeout => const Duration(seconds: 15);

  Duration get searchDebounce => const Duration(milliseconds: 300);

  int get pageSize => 20;
}
