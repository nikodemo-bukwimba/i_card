// lib/features/portfolio/presentation/pages/portfolio_edit_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../config/theme/app_colors.dart';
import '../../domain/entities/portfolio_item.dart';
import '../bloc/portfolio_bloc.dart';
import '../bloc/portfolio_event.dart';
import '../bloc/portfolio_state.dart';

class PortfolioEditPage extends StatefulWidget {
  const PortfolioEditPage({super.key});
  @override
  State<PortfolioEditPage> createState() => _PortfolioEditPageState();
}

class _PortfolioEditPageState extends State<PortfolioEditPage> {
  List<PortfolioItem> _items = [];

  @override
  void initState() {
    super.initState();
    final state = context.read<PortfolioBloc>().state;
    if (state is PortfolioLoaded) _items = List.from(state.items);
  }

  void _addOrEditItem([PortfolioItem? existing]) async {
    final result = await showModalBottomSheet<PortfolioItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ItemFormSheet(existing: existing),
    );
    if (result == null) return;

    setState(() {
      if (existing != null) {
        final idx = _items.indexWhere((e) => e.id == existing.id);
        if (idx != -1) _items[idx] = result;
      } else {
        _items.add(result);
      }
    });
    _save();
  }

  void _removeItem(String id) {
    final item = _items.firstWhere((e) => e.id == id);
    setState(() => _items.removeWhere((e) => e.id == id));
    _save();

    // Show undo snackbar
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${item.title}" imeondolewa'),
        action: SnackBarAction(
          label: 'Rudisha',
          textColor: AppColors.purpleMid,
          onPressed: () {
            setState(() => _items.add(item));
            _save();
          },
        ),
        backgroundColor: AppColors.darkSurface2,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _save() {
    context.read<PortfolioBloc>().add(PortfolioSaveRequested(_items));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkSurface,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.textLight,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const Text(
              'Portfolio',
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_items.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.purpleMid.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_items.length}',
                  style: const TextStyle(
                    color: AppColors.purpleMid,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _addOrEditItem(),
            icon: const Icon(
              Icons.add_rounded,
              color: AppColors.purpleMid,
              size: 20,
            ),
            label: const Text(
              'Ongeza',
              style: TextStyle(
                color: AppColors.purpleMid,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body:
          _items.isEmpty
              ? _EmptyState(onAdd: () => _addOrEditItem())
              : ReorderableListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                itemCount: _items.length,
                proxyDecorator: (child, index, animation) {
                  return AnimatedBuilder(
                    animation: animation,
                    builder:
                        (context, child) => Material(
                          color: Colors.transparent,
                          elevation: 4,
                          shadowColor: AppColors.purpleMid.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(14),
                          child: child,
                        ),
                    child: child,
                  );
                },
                onReorder: (oldIndex, newIndex) {
                  HapticFeedback.lightImpact();
                  setState(() {
                    if (newIndex > oldIndex) newIndex--;
                    final item = _items.removeAt(oldIndex);
                    _items.insert(newIndex, item);
                  });
                  _save();
                },
                itemBuilder: (_, i) {
                  final item = _items[i];
                  return _EditCard(
                    key: ValueKey(item.id),
                    item: item,
                    index: i,
                    onEdit: () => _addOrEditItem(item),
                    onDelete: () => _removeItem(item.id),
                  );
                },
              ),
    );
  }
}

// ── Visual config per type ──────────────────────────────────────────────────
class _TypeConfig {
  final IconData icon;
  final Color bg;
  final Color fg;
  final String label;
  final String labelSw; // Swahili label
  const _TypeConfig(this.icon, this.bg, this.fg, this.label, this.labelSw);
}

const _typeConfigs = <PortfolioItemType, _TypeConfig>{
  PortfolioItemType.video: _TypeConfig(
    Icons.play_circle_rounded,
    Color(0xFF2D1F5E),
    Color(0xFFB4A0FF),
    'Video',
    'Video',
  ),
  PortfolioItemType.document: _TypeConfig(
    Icons.description_rounded,
    Color(0xFF0D3D2E),
    Color(0xFF6EDBB5),
    'Document',
    'Hati',
  ),
  PortfolioItemType.website: _TypeConfig(
    Icons.language_rounded,
    Color(0xFF3D2A0B),
    Color(0xFFE8C064),
    'Website',
    'Tovuti',
  ),
  PortfolioItemType.image: _TypeConfig(
    Icons.image_rounded,
    Color(0xFF3D1510),
    Color(0xFFE88B74),
    'Image',
    'Picha',
  ),
  PortfolioItemType.social: _TypeConfig(
    Icons.people_rounded,
    Color(0xFF0D2A3D),
    Color(0xFF6DB8E8),
    'Social',
    'Mtandao',
  ),
};

// ── Edit Card (list item) ───────────────────────────────────────────────────
class _EditCard extends StatelessWidget {
  final PortfolioItem item;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EditCard({
    required Key key,
    required this.item,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cfg = _typeConfigs[item.type]!;
    final platformLabel = item.displayPlatform;

    return Dismissible(
      key: ValueKey('dismiss_${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
            SizedBox(height: 2),
            Text(
              'Futa',
              style: TextStyle(color: Colors.redAccent, fontSize: 10),
            ),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        HapticFeedback.mediumImpact();
        return true;
      },
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onEdit,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.darkSurface2,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cfg.fg.withOpacity(0.12)),
          ),
          child: Row(
            children: [
              // Drag handle
              const Padding(
                padding: EdgeInsets.only(right: 10),
                child: Icon(
                  Icons.drag_handle_rounded,
                  color: AppColors.textMuted,
                  size: 18,
                ),
              ),
              // Type icon
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: cfg.bg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(cfg.icon, color: cfg.fg, size: 20),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        // Type badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: cfg.fg.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            cfg.label.toUpperCase(),
                            style: TextStyle(
                              color: cfg.fg,
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        if (platformLabel.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Text(
                            platformLabel,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (item.description.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        item.description,
                        style: TextStyle(
                          color: AppColors.textMuted.withOpacity(0.7),
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Edit indicator
              Icon(
                Icons.edit_outlined,
                color: AppColors.textMuted.withOpacity(0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Item Form Bottom Sheet ──────────────────────────────────────────────────
class _ItemFormSheet extends StatefulWidget {
  final PortfolioItem? existing;
  const _ItemFormSheet({this.existing});
  @override
  State<_ItemFormSheet> createState() => _ItemFormSheetState();
}

class _ItemFormSheetState extends State<_ItemFormSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _urlCtrl;
  late final TextEditingController _descCtrl;
  late PortfolioItemType _type;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.existing != null;
    _type = widget.existing?.type ?? PortfolioItemType.website;
    _titleCtrl = TextEditingController(text: widget.existing?.title ?? '');
    _urlCtrl = TextEditingController(text: widget.existing?.url ?? '');
    _descCtrl = TextEditingController(text: widget.existing?.description ?? '');

    _urlCtrl.addListener(_onUrlChanged);
  }

  @override
  void dispose() {
    _urlCtrl.removeListener(_onUrlChanged);
    _titleCtrl.dispose();
    _urlCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  /// Auto-detect type from URL if user hasn't manually changed it.
  void _onUrlChanged() {
    final url = _urlCtrl.text.toLowerCase();
    if (url.isEmpty) return;

    PortfolioItemType? detected;
    if (url.contains('youtube.com') ||
        url.contains('youtu.be') ||
        url.contains('vimeo.com') ||
        url.contains('loom.com')) {
      detected = PortfolioItemType.video;
    } else if (url.contains('github.com') ||
        url.contains('instagram.com') ||
        url.contains('twitter.com') ||
        url.contains('x.com') ||
        url.contains('linkedin.com') ||
        url.contains('behance.net') ||
        url.contains('dribbble.com')) {
      detected = PortfolioItemType.social;
    } else if (url.contains('.pdf') ||
        url.contains('docs.google') ||
        url.contains('notion.so') ||
        url.contains('drive.google')) {
      detected = PortfolioItemType.document;
    } else if (url.contains('figma.com') ||
        url.contains('unsplash.com') ||
        url.contains('.png') ||
        url.contains('.jpg') ||
        url.contains('.jpeg')) {
      detected = PortfolioItemType.image;
    }

    if (detected != null && detected != _type) {
      setState(() => _type = detected!);
    }
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    final url = _urlCtrl.text.trim();
    if (title.isEmpty || url.isEmpty) return;

    Navigator.pop(
      context,
      PortfolioItem(
        id: widget.existing?.id ?? const Uuid().v4(),
        type: _type,
        title: title,
        url: url,
        description: _descCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              _isEditing ? 'Hariri kipande' : 'Ongeza kipande kipya',
              style: const TextStyle(
                color: AppColors.textLight,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _isEditing
                  ? 'Badilisha taarifa za kipande hiki'
                  : 'Kipande hiki kitaonekana kwenye QR yako',
              style: TextStyle(
                color: AppColors.textMuted.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),

            // Type selector — horizontal chips
            const Text(
              'Aina / Type',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 10,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 72,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children:
                    PortfolioItemType.values.map((t) {
                      final cfg = _typeConfigs[t]!;
                      final selected = t == _type;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () => setState(() => _type = t),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 70,
                            decoration: BoxDecoration(
                              color: selected ? cfg.bg : AppColors.darkSurface2,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    selected
                                        ? cfg.fg.withOpacity(0.5)
                                        : AppColors.textMuted.withOpacity(0.15),
                                width: selected ? 1.5 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  cfg.icon,
                                  color:
                                      selected
                                          ? cfg.fg
                                          : AppColors.textMuted.withOpacity(
                                            0.5,
                                          ),
                                  size: 22,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  cfg.labelSw,
                                  style: TextStyle(
                                    color:
                                        selected
                                            ? cfg.fg
                                            : AppColors.textMuted.withOpacity(
                                              0.6,
                                            ),
                                    fontSize: 10,
                                    fontWeight:
                                        selected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Title field
            _FormField(
              controller: _titleCtrl,
              label: 'Jina / Title',
              icon: Icons.title_rounded,
              hint: 'e.g. My Portfolio Website',
            ),
            const SizedBox(height: 12),

            // URL field
            _FormField(
              controller: _urlCtrl,
              label: 'URL',
              icon: Icons.link_rounded,
              hint: 'https://...',
              keyboard: TextInputType.url,
            ),
            const SizedBox(height: 12),

            // Description field
            _FormField(
              controller: _descCtrl,
              label: 'Maelezo mafupi / Description (hiari)',
              icon: Icons.notes_rounded,
              hint: 'Short description...',
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textMuted,
                      side: BorderSide(
                        color: AppColors.textMuted.withOpacity(0.3),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Ghairi'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _submit,
                    icon: Icon(
                      _isEditing ? Icons.check_rounded : Icons.add_rounded,
                      size: 18,
                    ),
                    label: Text(_isEditing ? 'Hifadhi' : 'Ongeza'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purpleMid,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Styled form field ───────────────────────────────────────────────────────
class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hint;
  final TextInputType? keyboard;
  final int maxLines;

  const _FormField({
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.keyboard,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: keyboard,
    maxLines: maxLines,
    style: const TextStyle(color: AppColors.textLight, fontSize: 14),
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
      hintStyle: TextStyle(
        color: AppColors.textMuted.withOpacity(0.4),
        fontSize: 13,
      ),
      prefixIcon: Icon(icon, color: AppColors.purpleMid, size: 18),
      filled: true,
      fillColor: AppColors.darkSurface2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.purpleMid.withOpacity(0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.purpleMid.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.purpleMid, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
    ),
  );
}

// ── Empty state ─────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Visual icon cluster
            SizedBox(
              height: 64,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 0,
                    child: _MiniIcon(
                      Icons.play_circle_outline,
                      const Color(0xFF2D1F5E),
                      const Color(0xFFB4A0FF),
                    ),
                  ),
                  Positioned(
                    left: 36,
                    top: 8,
                    child: _MiniIcon(
                      Icons.description_outlined,
                      const Color(0xFF0D3D2E),
                      const Color(0xFF6EDBB5),
                    ),
                  ),
                  Positioned(
                    left: 72,
                    child: _MiniIcon(
                      Icons.language_outlined,
                      const Color(0xFF3D2A0B),
                      const Color(0xFFE8C064),
                    ),
                  ),
                  Positioned(
                    left: 108,
                    top: 8,
                    child: _MiniIcon(
                      Icons.people_outlined,
                      const Color(0xFF0D2A3D),
                      const Color(0xFF6DB8E8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Bado hujaweka portfolio',
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Ongeza video, hati, tovuti au mitandao\nya kijamii kwenye kadi yako',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted.withOpacity(0.7),
                fontSize: 12,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Ongeza kipande cha kwanza'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purpleMid,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniIcon extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final Color fg;
  const _MiniIcon(this.icon, this.bg, this.fg);

  @override
  Widget build(BuildContext context) => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: fg.withOpacity(0.2)),
    ),
    child: Icon(icon, color: fg, size: 18),
  );
}
