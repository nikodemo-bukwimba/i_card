import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';

/// Live colour-swatch preview — repaints whenever any controller changes.
class ColorPreviewWidget extends StatefulWidget {
  final TextEditingController primaryCtrl;
  final TextEditingController accentCtrl;
  final TextEditingController goldCtrl;

  const ColorPreviewWidget({
    super.key,
    required this.primaryCtrl,
    required this.accentCtrl,
    required this.goldCtrl,
  });

  @override
  State<ColorPreviewWidget> createState() => _ColorPreviewWidgetState();
}

class _ColorPreviewWidgetState extends State<ColorPreviewWidget> {
  @override
  void initState() {
    super.initState();
    widget.primaryCtrl.addListener(_rebuild);
    widget.accentCtrl.addListener(_rebuild);
    widget.goldCtrl.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.primaryCtrl.removeListener(_rebuild);
    widget.accentCtrl.removeListener(_rebuild);
    widget.goldCtrl.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  Color _parse(String hex) {
    try {
      hex = hex.replaceAll('#', '');
      if (hex.length == 6) hex = 'FF$hex';
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Swatch('Primary', _parse(widget.primaryCtrl.text)),
        const SizedBox(width: 10),
        _Swatch('Accent',  _parse(widget.accentCtrl.text)),
        const SizedBox(width: 10),
        _Swatch('Title',   _parse(widget.goldCtrl.text)),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  final String label;
  final Color color;
  const _Swatch(this.label, this.color);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 10)),
          ],
        ),
      );
}