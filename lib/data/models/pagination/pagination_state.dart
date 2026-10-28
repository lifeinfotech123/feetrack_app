class PaginationState<T> {
  int page;
  int lastPage;
  final int pageSize;
  bool isInitialLoading;
  bool isMoreLoading;
  final List<T> items;
  final Set<dynamic> dedupeIds; // optional: prevent duplicates by id

  PaginationState({
    this.page = 1,
    this.lastPage = 1,
    this.pageSize = 10,
    this.isInitialLoading = false,
    this.isMoreLoading = false,
    List<T>? initialItems,
  })  : items = initialItems ?? <T>[],
        dedupeIds = <dynamic>{};

  bool get canLoadMore => page < lastPage;

  void reset() {
    page = 1;
    lastPage = 1;
    isInitialLoading = false;
    isMoreLoading = false;
    items.clear();
    dedupeIds.clear();
  }
}
