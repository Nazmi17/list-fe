class ApiError {
  final String error;
  final List<dynamic>? details;

  ApiError({required this.error, this.details});

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(error: json['error'], details: json['details']);
  }

  @override
  String toString() {
    if (details != null && details!.isNotEmpty) {
      return '$error: ${details!.join(", ")}';
    }
    return error;
  }
}
