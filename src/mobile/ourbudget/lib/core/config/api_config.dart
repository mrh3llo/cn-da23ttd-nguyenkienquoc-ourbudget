class ApiConfig {
  const ApiConfig({
    this.baseUrl = const String.fromEnvironment('API_BASE_URL'),
  });

  final String baseUrl;

  Uri endpoint(List<String> segments) {
    final base = Uri.tryParse(baseUrl);
    if (base == null ||
        (base.scheme != 'https' && base.scheme != 'http') ||
        base.host.isEmpty ||
        base.userInfo.isNotEmpty ||
        base.hasQuery ||
        base.hasFragment ||
        (base.path.isNotEmpty && base.path != '/')) {
      throw const FormatException('API_BASE_URL phải là địa chỉ gốc HTTP(S).');
    }
    return base.replace(pathSegments: ['api', 'v1', ...segments]);
  }
}
