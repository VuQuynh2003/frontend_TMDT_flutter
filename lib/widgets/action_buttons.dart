import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final bool isSelectionMode;
  final VoidCallback onDeleteSelected;
  final VoidCallback onAdd;
  final VoidCallback onToggleSelection;
  final String rightBtnTag;
  final String leftBtnTag;

  const ActionButtons({
    super.key,
    required this.isSelectionMode,
    required this.onDeleteSelected,
    required this.onAdd,
    required this.onToggleSelection,
    required this.rightBtnTag,
    required this.leftBtnTag,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Nút thêm mới hoặc xóa đã chọn (bên phải)
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            heroTag: rightBtnTag,
            onPressed: isSelectionMode ? onDeleteSelected : onAdd,
            backgroundColor:
                isSelectionMode
                    ? Colors.red
                    : const Color.fromARGB(255, 14, 19, 29),
            child: Icon(
              isSelectionMode ? Icons.delete : Icons.add,
              color: Colors.white,
            ),
            tooltip: isSelectionMode ? 'Delete Selected' : 'Add New',
          ),
        ),
        // Nút xóa hoặc hủy chọn (bên trái)
        Positioned(
          bottom: 16,
          left: 16,
          child: FloatingActionButton(
            heroTag: leftBtnTag,
            onPressed: onToggleSelection,
            backgroundColor:
                isSelectionMode
                    ? Colors.grey
                    : const Color.fromARGB(255, 14, 19, 29),
            child: Icon(
              isSelectionMode ? Icons.close : Icons.delete,
              color: Colors.white,
            ),
            tooltip: isSelectionMode ? 'Cancel Selection' : 'Delete Items',
          ),
        ),
      ],
    );
  }
}
