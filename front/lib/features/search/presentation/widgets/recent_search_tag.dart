import 'package:flutter/material.dart';

class RecentSearchTag extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const RecentSearchTag({
    super.key,
    required this.label,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    const double horizontalPadding = 18.0;
    const double verticalPadding = 2.0;
    const double fontSize = 12.0;
    const double borderRadius = 20.0;
    const double tagHeight = 24.0;
    const Color borderColor = Color(0xFF9AA6B2);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: tagHeight,
        padding: const EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: borderColor),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: fontSize,
                fontFamily: 'S-Core Dream',
                fontWeight: FontWeight.w500,
                height: 1.66,
                letterSpacing: 0.40,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(width: 6),
            if (onDelete != null)
              GestureDetector(
                onTap: onDelete,
                behavior: HitTestBehavior.opaque,
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.black45,
                ),
              ),
          ],
        ),
      ),
    );
  }
}








