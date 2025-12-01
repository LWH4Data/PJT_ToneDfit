import 'package:flutter/material.dart';
import 'price_input_dialog.dart';

/// 가격 범위 선택 드롭다운
class PriceRangeDropdown extends StatefulWidget {
  static const List<Map<String, dynamic>> priceRanges = [
    {'label': '1만원 이하', 'value': '0-10000', 'min': 0, 'max': 10000},
    {'label': '1만원 ~ 3만원', 'value': '10000-30000', 'min': 10000, 'max': 30000},
    {'label': '3만원 ~ 5만원', 'value': '30000-50000', 'min': 30000, 'max': 50000},
    {'label': '5만원 ~ 10만원', 'value': '50000-100000', 'min': 50000, 'max': 100000},
    {'label': '10만원 ~ 20만원', 'value': '100000-200000', 'min': 100000, 'max': 200000},
    {'label': '20만원 이상', 'value': '200000-', 'min': 200000, 'max': null},
    {'label': '직접 입력', 'value': 'custom', 'min': null, 'max': null},
  ];

  final String label;
  final String? selectedRange;
  final ValueChanged<String?>? onChanged;
  final ValueChanged<Map<String, int?>?>? onCustomPriceChanged;

  const PriceRangeDropdown({
    super.key,
    required this.label,
    this.selectedRange,
    this.onChanged,
    this.onCustomPriceChanged,
  });

  @override
  State<PriceRangeDropdown> createState() => _PriceRangeDropdownState();
}

class _PriceRangeDropdownState extends State<PriceRangeDropdown> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty) ...[
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF292D32),
          ),
        ),
        const SizedBox(height: 8),
        ],
        DropdownButtonFormField<String>(
          value: widget.selectedRange,
          decoration: InputDecoration(
            hintText: '가격 범위 선택',
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF476A62)),
            ),
          ),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('전체', style: TextStyle(fontSize: 14)),
            ),
            ...PriceRangeDropdown.priceRanges.map((range) {
              return DropdownMenuItem<String>(
                value: range['value'],
                child: Text(
                  range['label'],
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }),
          ],
          onChanged: (value) async {
            if (value == 'custom') {
              // 직접 입력 다이얼로그 표시
              final result = await showDialog<Map<String, int?>>(
                context: context,
                builder: (context) => const PriceInputDialog(),
              );

              if (result != null) {
                widget.onChanged?.call('custom');
                widget.onCustomPriceChanged?.call(result);
              }
            } else {
              widget.onChanged?.call(value);
              
              // 선택된 범위의 min/max 값 전달
              if (value != null) {
                final range = PriceRangeDropdown.priceRanges.firstWhere(
                  (r) => r['value'] == value,
                  orElse: () => PriceRangeDropdown.priceRanges[0],
                );
                widget.onCustomPriceChanged?.call({
                  'min': range['min'],
                  'max': range['max'],
                });
              } else {
                widget.onCustomPriceChanged?.call(null);
              }
            }
          },
          isExpanded: true,
        ),
      ],
    );
  }
}



