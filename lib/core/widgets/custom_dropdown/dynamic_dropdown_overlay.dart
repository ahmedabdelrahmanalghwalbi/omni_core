part of 'custom_dropdown.dart';

/// Overlay for [DynamicCustomDropdown]. Visually identical to the static
/// [_DropdownOverlay], with paged async loading, debounced server-side
/// search and an error/retry state.
class _DynamicDropdownOverlay extends StatefulWidget {
  final DynamicDropdownItemsLoader itemsLoader;
  final String nameKey;
  final TextEditingController controller;
  final Size size;
  final LayerLink layerLink;
  final VoidCallback hideOverlay;
  final String hintText;
  final TextStyle? headerStyle;
  final TextStyle? listItemStyle;
  final bool canCloseOutsideBounds;
  final bool enableSearch;
  final Function(Map<String, dynamic>)? onItemSelected;
  final double? customOverRelayWidth;
  final String? searchHintText;
  final BorderRadius? borderRadius;
  final String noResultsText;
  final String loadFailedText;
  final String retryText;
  final int pageSize;
  final Duration searchDebounce;

  const _DynamicDropdownOverlay({
    required this.itemsLoader,
    required this.nameKey,
    required this.controller,
    required this.size,
    required this.layerLink,
    required this.hideOverlay,
    required this.hintText,
    required this.canCloseOutsideBounds,
    required this.enableSearch,
    required this.noResultsText,
    required this.loadFailedText,
    required this.retryText,
    required this.pageSize,
    required this.searchDebounce,
    this.headerStyle,
    this.listItemStyle,
    this.customOverRelayWidth,
    this.onItemSelected,
    this.searchHintText,
    this.borderRadius,
  });

  @override
  _DynamicDropdownOverlayState createState() =>
      _DynamicDropdownOverlayState();
}

class _DynamicDropdownOverlayState extends State<_DynamicDropdownOverlay> {
  bool displayOverly = true;
  bool displayOverlayBottom = true;
  late String headerText;
  final key1 = GlobalKey(), key2 = GlobalKey();
  final scrollController = ScrollController();

  final List<Map<String, dynamic>> _items = [];
  bool _isLoading = false;
  bool _isInitialLoading = true;
  bool _hasError = false;
  bool _hasMore = true;
  String _searchQuery = '';
  Timer? _searchDebounce;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final render1 = key1.currentContext?.findRenderObject() as RenderBox;
      final render2 = key2.currentContext?.findRenderObject() as RenderBox;
      final screenHeight = MediaQuery.of(context).size.height;
      double y = render1.localToGlobal(Offset.zero).dy;
      if (screenHeight - y < render2.size.height) {
        displayOverlayBottom = false;
        setState(() {});
      }
    });

    headerText = widget.controller.text;
    scrollController.addListener(_onScroll);
    _fetch();
  }

  @override
  void dispose() {
    scrollController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 100 &&
        _hasMore &&
        !_isLoading) {
      _fetch(loadMore: true);
    }
  }

  /// Fresh fetches (initial load, search, retry) preempt any in-flight
  /// request: each fetch takes a new id and responses whose id is no longer
  /// current are discarded, so a search typed while a page is loading is
  /// never dropped and never overwritten by stale results. Only [loadMore]
  /// is deduplicated against an ongoing request.
  Future<void> _fetch({bool loadMore = false}) async {
    if (loadMore && _isLoading) return;
    final requestId = ++_requestId;

    setState(() {
      _isLoading = true;
      _hasError = false;
      if (!loadMore) {
        _items.clear();
        _isInitialLoading = true;
        _hasMore = true;
      }
    });

    try {
      final page = await widget.itemsLoader(
        loadMore ? _items.length : 0,
        widget.pageSize,
        _searchQuery.isNotEmpty ? _searchQuery : null,
      );
      if (!mounted || requestId != _requestId) return;

      setState(() {
        if (page == null) {
          _hasError = true;
          _hasMore = false;
        } else {
          _items.addAll(page.items);
          _hasMore = page.hasMore && page.items.isNotEmpty;
        }
      });
      _fetchNextPageIfNotScrollable();
    } catch (e) {
      log('DynamicCustomDropdown failed to load items: $e');
      if (mounted && requestId == _requestId) {
        setState(() {
          _hasError = true;
          _hasMore = false;
        });
      }
    } finally {
      if (mounted && requestId == _requestId) {
        setState(() {
          _isLoading = false;
          _isInitialLoading = false;
        });
      }
    }
  }

  /// Pagination is normally driven by scroll events; when a page is too
  /// short to make the list scrollable those never fire, so load the next
  /// page directly instead of leaving the bottom loader spinning forever.
  void _fetchNextPageIfNotScrollable() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_hasMore || _isLoading) return;
      if (scrollController.hasClients &&
          scrollController.position.maxScrollExtent <= 0) {
        _fetch(loadMore: true);
      }
    });
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchQuery = query.trim();
    _searchDebounce = Timer(widget.searchDebounce, () {
      if (mounted) _fetch();
    });
  }

  String _displayOf(Map<String, dynamic> item) =>
      item[widget.nameKey]?.toString() ?? '';

  Future<void> _onItemSelect(Map<String, dynamic> item) async {
    setState(() => displayOverly = false);
    await Future.delayed(const Duration(milliseconds: 300));
    final display = _displayOf(item);
    if (headerText != display) {
      widget.controller.text = display;
      widget.onItemSelected?.call(item);
    }
  }

  Widget _buildStateMessage(Widget child) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: child,
    ),
  );

  Widget _buildContent() {
    if (_isInitialLoading) {
      return _buildStateMessage(const CircularProgressIndicator.adaptive());
    }
    if (_hasError && _items.isEmpty) {
      return _buildStateMessage(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.loadFailedText, style: const TextStyle(fontSize: 16)),
            TextButton(
              onPressed: _fetch,
              child: Text(widget.retryText, style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      );
    }
    if (_items.isEmpty) {
      return _buildStateMessage(
        Text(widget.noResultsText, style: const TextStyle(fontSize: 16)),
      );
    }
    return _DynamicItemsList(
      scrollController: scrollController,
      items: _items,
      nameKey: widget.nameKey,
      headerText: headerText,
      padding: widget.enableSearch
          ? const EdgeInsets.only(top: 8)
          : EdgeInsets.zero,
      itemTextStyle: widget.listItemStyle,
      showBottomLoader: _hasMore,
      onItemSelect: _onItemSelect,
    );
  }

  @override
  Widget build(BuildContext context) {
    // overlay icon
    final overlayIcon = Icon(
      displayOverlayBottom
          ? Icons.keyboard_arrow_up_rounded
          : Icons.keyboard_arrow_down_rounded,
      color: Colors.black,
      size: 20,
    );

    // overlay offset
    final overlayOffset = Offset(-12, displayOverlayBottom ? 0 : 60);

    final content = _buildContent();
    final expandList = _items.length > 4 || (_hasMore && _items.isNotEmpty);

    final child = Stack(
      children: [
        Positioned(
          width: widget.customOverRelayWidth ?? widget.size.width + 23,
          child: CompositedTransformFollower(
            link: widget.layerLink,
            followerAnchor: displayOverlayBottom
                ? Alignment.topLeft
                : Alignment.bottomLeft,
            showWhenUnlinked: false,
            offset: overlayOffset,
            child: Container(
              key: key1,
              padding: _overlayOuterPadding,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      widget.borderRadius ?? BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 24.0,
                      color: Colors.black.withValues(alpha: .08),
                      offset: _overlayShadowOffset,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: AnimatedSection(
                    animationDismissed: widget.hideOverlay,
                    expand: displayOverly,
                    axisAlignment: displayOverlayBottom ? 1.0 : -1.0,
                    child: SizedBox(
                      key: key2,
                      height: expandList
                          ? MediaQuery.of(context).size.height / 2
                          : null,
                      child: ClipRRect(
                        borderRadius:
                            widget.borderRadius ?? BorderRadius.circular(12.0),
                        child: NotificationListener<
                          OverscrollIndicatorNotification
                        >(
                          onNotification: (notification) {
                            notification.disallowIndicator();
                            return true;
                          },
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              scrollbarTheme: ScrollbarThemeData(
                                thumbVisibility: WidgetStateProperty.all(true),
                                thickness: WidgetStateProperty.all(5),
                                radius: const Radius.circular(4),
                                thumbColor: WidgetStateProperty.all(
                                  Colors.grey[300],
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: _headerPadding,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          headerText.isNotEmpty
                                              ? headerText
                                              : widget.hintText,
                                          style: widget.headerStyle,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      overlayIcon,
                                    ],
                                  ),
                                ),
                                if (widget.enableSearch)
                                  _DynamicSearchField(
                                    searchHintText: widget.searchHintText,
                                    onSearchChanged: _onSearchChanged,
                                  ),
                                expandList
                                    ? Expanded(child: content)
                                    : content,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );

    return GestureDetector(
      onTap: () => setState(() => displayOverly = false),
      child: widget.canCloseOutsideBounds
          ? Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.transparent,
              child: child,
            )
          : child,
    );
  }
}

/// Items list for the dynamic overlay. Same item styling as the static
/// [_ItemsList], with an optional bottom loader row for pagination.
class _DynamicItemsList extends StatelessWidget {
  final ScrollController scrollController;
  final List<Map<String, dynamic>> items;
  final String nameKey;
  final String headerText;
  final ValueSetter<Map<String, dynamic>> onItemSelect;
  final EdgeInsets padding;
  final TextStyle? itemTextStyle;
  final bool showBottomLoader;

  const _DynamicItemsList({
    required this.scrollController,
    required this.items,
    required this.nameKey,
    required this.headerText,
    required this.onItemSelect,
    required this.padding,
    required this.showBottomLoader,
    this.itemTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    final listItemStyle = const TextStyle(fontSize: 16).merge(itemTextStyle);

    return Scrollbar(
      controller: scrollController,
      child: ListView.builder(
        controller: scrollController,
        shrinkWrap: true,
        padding: padding,
        itemCount: items.length + (showBottomLoader ? 1 : 0),
        itemBuilder: (_, index) {
          if (index >= items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Center(child: CircularProgressIndicator.adaptive()),
            );
          }
          final display = items[index][nameKey]?.toString() ?? '';
          final selected = headerText.isNotEmpty && headerText == display;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.grey[200],
              onTap: () => onItemSelect(items[index]),
              child: Container(
                color: selected ? Colors.grey[100] : Colors.transparent,
                padding: _listItemPadding,
                child: Text(
                  display,
                  style: listItemStyle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Search box for the dynamic overlay. Same decoration as the static
/// [_SearchField], but notifies the caller so filtering happens server-side.
class _DynamicSearchField extends StatefulWidget {
  final String? searchHintText;
  final ValueSetter<String> onSearchChanged;

  const _DynamicSearchField({
    required this.onSearchChanged,
    this.searchHintText,
  });

  @override
  State<_DynamicSearchField> createState() => _DynamicSearchFieldState();
}

class _DynamicSearchFieldState extends State<_DynamicSearchField> {
  final searchCtrl = TextEditingController();
  FocusNode? _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    _focusNode?.dispose();
    super.dispose();
  }

  void onClear() {
    if (searchCtrl.text.isNotEmpty) {
      searchCtrl.clear();
      widget.onSearchChanged('');
      _focusNode?.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextField(
        focusNode: _focusNode,
        controller: searchCtrl,
        onChanged: widget.onSearchChanged,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[50],
          constraints: const BoxConstraints.tightFor(height: 40),
          contentPadding: const EdgeInsets.all(8),
          hintText: widget.searchHintText ?? 'Search',
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 22),
          suffixIcon: GestureDetector(
            onTap: onClear,
            child: const Icon(Icons.close, color: Colors.grey, size: 20),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Colors.grey.withValues(alpha: .25),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Colors.grey.withValues(alpha: .25),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Colors.grey.withValues(alpha: .25),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}
