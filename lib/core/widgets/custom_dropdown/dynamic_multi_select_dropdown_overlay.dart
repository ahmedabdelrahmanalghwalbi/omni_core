part of 'custom_dropdown.dart';

/// Overlay for [DynamicCustomMultiDropdown]. Visually identical to the static
/// [_MultiSelectDropdownOverlay], with paged async loading, debounced
/// server-side search and an error/retry state.
///
/// [selectedItems] is the live selection owned by the dropdown state: toggling
/// an item mutates that list through [onItemSelected], so both the overlay and
/// the field render the same selection.
class _DynamicMultiSelectDropdownOverlay extends StatefulWidget {
  final DynamicDropdownItemsLoader itemsLoader;
  final List<Map<String, dynamic>> selectedItems;
  final String nameKey;
  final String? subNameKey;
  final String primaryIdKey;
  final Size size;
  final LayerLink layerLink;
  final VoidCallback hideOverlay;
  final String hintText;
  final TextStyle? headerStyle;
  final bool canCloseOutsideBounds;
  final bool enableSearch;
  final Color selectColor;
  final int? maxSelectedItems;
  final ValueSetter<Map<String, dynamic>> onItemSelected;
  final double? customOverRelayWidth;
  final String? searchHintText;
  final BorderRadius? borderRadius;
  final String noResultsText;
  final String loadFailedText;
  final String retryText;
  final int pageSize;
  final Duration searchDebounce;

  const _DynamicMultiSelectDropdownOverlay({
    required this.itemsLoader,
    required this.selectedItems,
    required this.nameKey,
    required this.primaryIdKey,
    required this.size,
    required this.layerLink,
    required this.hideOverlay,
    required this.hintText,
    required this.canCloseOutsideBounds,
    required this.enableSearch,
    required this.selectColor,
    required this.noResultsText,
    required this.loadFailedText,
    required this.retryText,
    required this.pageSize,
    required this.searchDebounce,
    required this.onItemSelected,
    this.subNameKey,
    this.maxSelectedItems,
    this.headerStyle,
    this.customOverRelayWidth,
    this.searchHintText,
    this.borderRadius,
  });

  @override
  _DynamicMultiSelectDropdownOverlayState createState() =>
      _DynamicMultiSelectDropdownOverlayState();
}

class _DynamicMultiSelectDropdownOverlayState
    extends State<_DynamicMultiSelectDropdownOverlay> {
  bool displayOverly = true;
  bool displayOverlayBottom = true;
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
      log('DynamicCustomMultiDropdown failed to load items: $e');
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

  /// Unlike a single-selection dropdown the overlay stays open while items are
  /// toggled; it is dismissed by tapping outside it.
  void _onItemSelect(Map<String, dynamic> item) {
    widget.onItemSelected(item);
    setState(() {});
  }

  String get _headerText {
    final selectedItems = widget.selectedItems;
    if (selectedItems.isEmpty) return widget.hintText;
    if (selectedItems.length == 1) {
      return selectedItems.first[widget.nameKey]?.toString() ?? widget.hintText;
    }
    return '${selectedItems.length} items selected';
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
              child: Text(
                widget.retryText,
                style: const TextStyle(fontSize: 16),
              ),
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
    return _DynamicMultiSelectItemsList(
      scrollController: scrollController,
      items: _items,
      selectedItems: widget.selectedItems,
      nameKey: widget.nameKey,
      subNameKey: widget.subNameKey,
      primaryIdKey: widget.primaryIdKey,
      selectColor: widget.selectColor,
      maxSelectedItems: widget.maxSelectedItems,
      padding: widget.enableSearch
          ? const EdgeInsets.only(top: 8)
          : EdgeInsets.zero,
      showBottomLoader: _hasMore,
      onItemSelect: _onItemSelect,
    );
  }

  @override
  Widget build(BuildContext context) {
    final overlayIcon = Icon(
      displayOverlayBottom
          ? Icons.keyboard_arrow_up_rounded
          : Icons.keyboard_arrow_down_rounded,
      color: Colors.black,
      size: 20,
    );

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
                        child:
                            NotificationListener<
                              OverscrollIndicatorNotification
                            >(
                              onNotification: (notification) {
                                notification.disallowIndicator();
                                return true;
                              },
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  scrollbarTheme: ScrollbarThemeData(
                                    thumbVisibility: WidgetStateProperty.all(
                                      true,
                                    ),
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
                                              _headerText,
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

/// Items list for the dynamic multi-select overlay. Same checkbox rows as the
/// static [_MultiSelectItemsList], with an optional bottom loader row for
/// pagination.
class _DynamicMultiSelectItemsList extends StatelessWidget {
  final ScrollController scrollController;
  final List<Map<String, dynamic>> items;
  final List<Map<String, dynamic>> selectedItems;
  final String nameKey;
  final String? subNameKey;
  final String primaryIdKey;
  final Color selectColor;
  final int? maxSelectedItems;
  final ValueSetter<Map<String, dynamic>> onItemSelect;
  final EdgeInsets padding;
  final bool showBottomLoader;

  const _DynamicMultiSelectItemsList({
    required this.scrollController,
    required this.items,
    required this.selectedItems,
    required this.nameKey,
    required this.primaryIdKey,
    required this.selectColor,
    required this.onItemSelect,
    required this.padding,
    required this.showBottomLoader,
    this.subNameKey,
    this.maxSelectedItems,
  });

  @override
  Widget build(BuildContext context) {
    // Same fixed item style as the static [_MultiSelectItemsList], so both
    // multi-selects render identically.
    final listItemStyle = const TextStyle(
      fontSize: 14.0,
      color: Colors.black87,
    );
    final selectedItemIds = selectedItems
        .map((item) => item[primaryIdKey].toString())
        .toSet();

    return ListView.builder(
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
        final item = items[index];
        final displayText = item[nameKey]?.toString() ?? '';
        final subDisplayText = subNameKey == null
            ? null
            : item[subNameKey]?.toString();
        final isSelected = selectedItemIds.contains(
          item[primaryIdKey].toString(),
        );
        final isDisabled =
            maxSelectedItems != null &&
            selectedItems.length >= maxSelectedItems! &&
            !isSelected;

        return InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.grey[200],
          onTap: isDisabled ? null : () => onItemSelect(item),
          child: Container(
            color: Colors.transparent,
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 12.0,
            ),
            child: Row(
              spacing: 8.0,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                isSelected
                    ? Icon(
                        Icons.check_box_rounded,
                        size: 16.0,
                        color: selectColor,
                      )
                    : Icon(
                        Icons.check_box_outline_blank,
                        color: isDisabled
                            ? Colors.grey[400]
                            : listItemStyle.color,
                        size: 16.0,
                      ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        displayText,
                        style: listItemStyle.copyWith(
                          color: isDisabled
                              ? Colors.grey[400]
                              : listItemStyle.color,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subDisplayText != null && subDisplayText.isNotEmpty)
                        Text(
                          subDisplayText,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12.0,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
