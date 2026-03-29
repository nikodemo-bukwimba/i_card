// lib/features/portfolio/presentation/pages/portfolio_edit_page.dart
import 'package:flutter/material.dart';
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

  void _addItem() async {
    final result = await showDialog<PortfolioItem>(
      context: context,
      builder: (_) => const _AddItemDialog(),
    );
    if (result == null) return;
    setState(() => _items.add(result));
    _save();
  }

  void _removeItem(String id) {
    setState(() => _items.removeWhere((e) => e.id == id));
    _save();
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
        title: const Text('Portfolio',
            style: TextStyle(color: AppColors.textLight, fontSize: 16)),
        actions: [
          TextButton.icon(
            onPressed: _addItem,
            icon: const Icon(Icons.add, color: AppColors.purpleMid, size: 18),
            label: const Text('Ongeza',
                style: TextStyle(
                    color: AppColors.purpleMid, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: _items.isEmpty
          ? _EmptyState(onAdd: _addItem)
          : ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = _items.removeAt(oldIndex);
                  _items.insert(newIndex, item);
                });
                _save();
              },
              itemBuilder: (_, i) {
                final item = _items[i];
                return _EditRow(
                    key: ValueKey(item.id),
                    item: item,
                    onDelete: () => _removeItem(item.id));
              },
            ),
    );
  }
}

class _EditRow extends StatelessWidget {
  final PortfolioItem item;
  final VoidCallback onDelete;
  const _EditRow({required Key key, required this.item, required this.onDelete})
      : super(key: key);

  static const _typeBg = {
    PortfolioItemType.video:    Color(0xFFEEEDFE),
    PortfolioItemType.document: Color(0xFFE1F5EE),
    PortfolioItemType.website:  Color(0xFFFAEEDA),
    PortfolioItemType.image:    Color(0xFFFAECE7),
  };
  static const _typeColor = {
    PortfolioItemType.video:    Color(0xFF3C3489),
    PortfolioItemType.document: Color(0xFF085041),
    PortfolioItemType.website:  Color(0xFF633806),
    PortfolioItemType.image:    Color(0xFF712B13),
  };
  static const _typeShort = {
    PortfolioItemType.video:    'VID',
    PortfolioItemType.document: 'DOC',
    PortfolioItemType.website:  'WEB',
    PortfolioItemType.image:    'IMG',
  };

  @override
  Widget build(BuildContext context) {
    final bg    = _typeBg[item.type]!;
    final color = _typeColor[item.type]!;
    final short = _typeShort[item.type]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkSurface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.purpleMid.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          // Drag handle
          const Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(Icons.drag_handle,
                color: AppColors.textMuted, size: 18),
          ),
          // Type badge
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: bg.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(short,
                style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(item.url,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 11),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Delete
          GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('Futa',
                  style: TextStyle(color: Colors.redAccent, fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddItemDialog extends StatefulWidget {
  const _AddItemDialog();
  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  final _titleCtrl = TextEditingController();
  final _urlCtrl   = TextEditingController();
  final _descCtrl  = TextEditingController();
  PortfolioItemType _type = PortfolioItemType.website;

  @override
  void dispose() {
    _titleCtrl.dispose(); _urlCtrl.dispose(); _descCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_titleCtrl.text.trim().isEmpty || _urlCtrl.text.trim().isEmpty) return;
    Navigator.pop(
      context,
      PortfolioItem(
        id:          const Uuid().v4(),
        type:        _type,
        title:       _titleCtrl.text.trim(),
        url:         _urlCtrl.text.trim(),
        description: _descCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.darkSurface2,
      title: const Text('Ongeza kipande',
          style: TextStyle(color: AppColors.textLight, fontSize: 16)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Type selector
            SegmentedButton<PortfolioItemType>(
              segments: const [
                ButtonSegment(
                    value: PortfolioItemType.video,
                    label: Text('Video')),
                ButtonSegment(
                    value: PortfolioItemType.document,
                    label: Text('Doc')),
                ButtonSegment(
                    value: PortfolioItemType.website,
                    label: Text('Web')),
                ButtonSegment(
                    value: PortfolioItemType.image,
                    label: Text('Picha')),
              ],
              selected: {_type},
              onSelectionChanged: (s) =>
                  setState(() => _type = s.first),
              style: ButtonStyle(
                textStyle: MaterialStateProperty.all(
                    const TextStyle(fontSize: 12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleCtrl,
              style: const TextStyle(color: AppColors.textLight),
              decoration: const InputDecoration(
                labelText: 'Jina / Title',
                labelStyle: TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.darkSurface,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _urlCtrl,
              keyboardType: TextInputType.url,
              style: const TextStyle(color: AppColors.textLight),
              decoration: const InputDecoration(
                labelText: 'URL (https://...)',
                labelStyle: TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.darkSurface,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descCtrl,
              style: const TextStyle(color: AppColors.textLight),
              decoration: const InputDecoration(
                labelText: 'Maelezo (hiari)',
                labelStyle: TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.darkSurface,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Ghairi',
              style: TextStyle(color: AppColors.textMuted)),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.purpleMid,
            foregroundColor: Colors.white,
          ),
          child: const Text('Hifadhi'),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.folder_open_outlined,
              color: AppColors.textMuted, size: 48),
          const SizedBox(height: 12),
          const Text('Bado hujaweka portfolio',
              style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Ongeza kwanza'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purpleMid,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}