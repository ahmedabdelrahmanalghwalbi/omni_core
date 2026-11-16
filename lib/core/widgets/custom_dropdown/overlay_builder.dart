part of 'custom_dropdown.dart';

class _OverlayBuilder extends StatefulWidget {
  final Widget Function(Size, VoidCallback) overlay;
  final Widget Function(VoidCallback) child;

  const _OverlayBuilder({required this.overlay, required this.child});

  @override
  _OverlayBuilderState createState() => _OverlayBuilderState();
}

class _OverlayBuilderState extends State<_OverlayBuilder> {
  OverlayEntry? overlayEntry;

  bool get isShowingOverlay => overlayEntry != null;

  void showOverlay() {
    overlayEntry = OverlayEntry(
      builder: (_) {
        if (mounted) {
          final renderBox = context.findRenderObject() as RenderBox;
          final size = renderBox.size;
          return widget.overlay(size, hideOverlay);
        }
        return const SizedBox();
      },
    );
    addToOverlay(overlayEntry!);
  }

  void addToOverlay(OverlayEntry entry) => Overlay.of(context).insert(entry);

  void hideOverlay() {
    final entry = overlayEntry;
    if (entry == null) return;
    overlayEntry = null;
    // Detached from the state right away, so the entry is still taken down
    // when this widget is unmounted before the delay elapses.
    Future.delayed(const Duration(milliseconds: 100), () {
      log('Overlay is being hidden');
      _removeAndDispose(entry);
    });
  }

  /// An entry must leave the overlay before it may be disposed.
  void _removeAndDispose(OverlayEntry entry) {
    if (entry.mounted) entry.remove();
    entry.dispose();
  }

  @override
  void dispose() {
    final entry = overlayEntry;
    overlayEntry = null;
    if (entry != null) _removeAndDispose(entry);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child(showOverlay);
}
