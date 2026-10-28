class PaginationModel<T> {
  final bool status;
  final String? message;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final List<T> data;

  PaginationModel({
    required this.status,
    this.message,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.data,
  });

  /// Accepts either:
  /// A) { status, message, data: { current_page, last_page, per_page, total, data: [...] } }
  /// B) { current_page, last_page, per_page, total, data: [...] }  (Laravel paginator)
  factory PaginationModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    // Decide which shape we're dealing with
    Map<String, dynamic> paginator;
    bool hasWrapper = json.containsKey('data') &&
        json['data'] is Map &&
        (json['data'] as Map).containsKey('data');

    if (json.containsKey('current_page')) {
      // Shape B: pure Laravel paginator
      paginator = json;
    } else if (hasWrapper) {
      // Shape A: wrapper with data -> { current_page, ..., data: [...] }
      paginator = (json['data'] as Map).cast<String, dynamic>();
    } else {
      throw ArgumentError('Unsupported pagination JSON shape: $json');
    }

    final list = (paginator['data'] as List? ?? [])
        .map((e) => fromJsonT((e as Map).cast<String, dynamic>()))
        .toList();

    return PaginationModel<T>(
      status: (json['status'] is bool)
          ? json['status'] as bool
          : true, // default true for Laravel shape
      message: json['message'] as String?,
      currentPage: (paginator['current_page'] ?? 1) as int,
      lastPage: (paginator['last_page'] ?? 1) as int,
      perPage: (paginator['per_page'] ?? list.length) as int,
      total: (paginator['total'] ?? list.length) as int,
      data: list,
    );
  }

  Map<String, dynamic> toJson(
    Map<String, dynamic> Function(T value) toJsonT,
  ) {
    return {
      "status": status,
      "message": message,
      "data": {
        "current_page": currentPage,
        "last_page": lastPage,
        "per_page": perPage,
        "total": total,
        "data": data.map((e) => toJsonT(e)).toList(),
      }
    };
  }

  bool get canLoadMore => currentPage < lastPage;
}
