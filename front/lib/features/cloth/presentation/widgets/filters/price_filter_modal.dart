import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../price_range_dropdown.dart';
import 'filter_modal_wrapper.dart';

/// 가격 필터 모달
class PriceFilterModal extends StatefulWidget {
  final String? selectedPriceRange;
  final Function(String?) onPriceRangeChanged;
  final Function(Map<String, int?>?) onCustomPriceChanged;
  final VoidCallback onApply;
  final VoidCallback onCancel;
  final List<FilterTagData> filterTags;
  final Function(String)? onRemoveTag;

  const PriceFilterModal({
    super.key,
    required this.selectedPriceRange,
    required this.onPriceRangeChanged,
    required this.onCustomPriceChanged,
    required this.onApply,
    required this.onCancel,
    this.filterTags = const [],
    this.onRemoveTag,
  });

  @override
  State<PriceFilterModal> createState() => _PriceFilterModalState();
}

class _PriceFilterModalState extends State<PriceFilterModal> {
  final TextEditingController _minController = TextEditingController();
  final TextEditingController _maxController = TextEditingController();

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  void _onCustomPriceChanged() {
    final minText = _minController.text;
    final maxText = _maxController.text;
    
    if (minText.isEmpty && maxText.isEmpty) {
      widget.onCustomPriceChanged(null);
      return;
    }
    
    final min = minText.isNotEmpty ? int.tryParse(minText) : null;
    final max = maxText.isNotEmpty ? int.tryParse(maxText) : null;
    
    widget.onCustomPriceChanged({'min': min, 'max': max});
  }

  @override
  Widget build(BuildContext context) {
    return FilterModalWrapper(
      title: '가격',
      onApply: widget.onApply,
      onCancel: widget.onCancel,
      filterTags: widget.filterTags,
      onRemoveTag: widget.onRemoveTag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 전체 옵션 (단독)
          _buildCheckboxTile(
            label: '전체',
            value: null,
            isSelected: widget.selectedPriceRange == null,
            onChanged: () {
              widget.onPriceRangeChanged(null);
              widget.onCustomPriceChanged(null);
              _minController.clear();
              _maxController.clear();
            },
          ),
          // 가격 옵션 (2열 그리드)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 3.5,
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
            children: [
              // 일반 가격 범위
              ...PriceRangeDropdown.priceRanges
                  .where((range) => range['value'] != 'custom')
                  .map((range) {
                final value = range['value'] as String;
                return _buildCheckboxTile(
                  label: range['label'] as String,
                  value: value,
                  isSelected: widget.selectedPriceRange == value,
                  onChanged: () {
                    widget.onPriceRangeChanged(value);
                    // 선택된 범위의 min/max 값 전달
                    widget.onCustomPriceChanged({
                      'min': range['min'] as int?,
                      'max': range['max'] as int?,
                    });
                    _minController.clear();
                    _maxController.clear();
                  },
                );
              }),
              // 직접 입력을 그리드에 포함
              _buildCheckboxTile(
                label: '직접 입력',
                value: 'custom',
                isSelected: widget.selectedPriceRange == 'custom',
                onChanged: () {
                  widget.onPriceRangeChanged('custom');
                },
              ),
              // 빈 공간 (체크박스 옆)
              const SizedBox(),
              // 직접 입력이 선택된 경우 입력창을 그리드 셀로 표시
              if (widget.selectedPriceRange == 'custom') ...[
                // 최소 금액 입력창 (그리드 셀)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: TextField(
                    controller: _minController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      labelText: '최소',
                      labelStyle: const TextStyle(fontSize: 12),
                      suffixText: '원',
                      suffixStyle: const TextStyle(fontSize: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      isDense: true,
                    ),
                    onChanged: (_) => _onCustomPriceChanged(),
                  ),
                ),
                // 최대 금액 입력창 (그리드 셀)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: TextField(
                    controller: _maxController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      labelText: '최대',
                      labelStyle: const TextStyle(fontSize: 12),
                      suffixText: '원',
                      suffixStyle: const TextStyle(fontSize: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      isDense: true,
                    ),
                    onChanged: (_) => _onCustomPriceChanged(),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildCheckboxTile({
    required String label,
    required String? value,
    required bool isSelected,
    required VoidCallback onChanged,
  }) {
    return InkWell(
      onTap: onChanged,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (_) => onChanged(),
              activeColor: const Color(0xFF476A62),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? const Color(0xFF476A62) : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
