import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 가격 직접 입력 다이얼로그
class PriceInputDialog extends StatefulWidget {
  final int? initialMin;
  final int? initialMax;

  const PriceInputDialog({
    super.key,
    this.initialMin,
    this.initialMax,
  });

  @override
  State<PriceInputDialog> createState() => _PriceInputDialogState();
}

class _PriceInputDialogState extends State<PriceInputDialog> {
  late TextEditingController _minController;
  late TextEditingController _maxController;

  @override
  void initState() {
    super.initState();
    _minController = TextEditingController(
      text: widget.initialMin != null ? '${widget.initialMin! ~/ 10000}' : '',
    );
    _maxController = TextEditingController(
      text: widget.initialMax != null ? '${widget.initialMax! ~/ 10000}' : '',
    );
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('가격 직접 입력'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _minController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: '최소 가격 (만원)',
              hintText: '예: 5',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _maxController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: '최대 가격 (만원)',
              hintText: '예: 10',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: () {
            final minText = _minController.text.trim();
            final maxText = _maxController.text.trim();

            if (minText.isEmpty && maxText.isEmpty) {
              Navigator.pop(context);
              return;
            }

            final min = minText.isNotEmpty ? int.tryParse(minText) : null;
            final max = maxText.isNotEmpty ? int.tryParse(maxText) : null;

            if (min != null && max != null && min > max) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('최소 가격이 최대 가격보다 클 수 없습니다')),
              );
              return;
            }

            Navigator.pop(context, {
              'min': min != null ? min * 10000 : null,
              'max': max != null ? max * 10000 : null,
            });
          },
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF476A62),
          ),
          child: const Text('확인'),
        ),
      ],
    );
  }
}




