import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../origami/origami_detail_screen.dart';

class ExploreTab extends StatelessWidget {
  const ExploreTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Category Filters
        Container(
          color: AppTheme.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('Tất cả', true),
                _buildFilterChip('Động vật', false),
                _buildFilterChip('Hoa cỏ', false),
                _buildFilterChip('Đồ vật', false),
                _buildFilterChip('Kiến trúc', false),
              ],
            ),
          ),
        ),
        
        // Grid View
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: 8,
            itemBuilder: (context, index) {
              return _buildOrigamiCard(context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.indigo : AppTheme.bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? AppTheme.indigo : AppTheme.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppTheme.text,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildOrigamiCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const OrigamiDetailScreen()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppTheme.bg,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: const Center(
                  child: Text('🌺', style: TextStyle(fontSize: 48)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Hoa Hồng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text('⭐⭐⭐', style: TextStyle(fontSize: 10)),
                      const Spacer(),
                      const Icon(Icons.favorite, color: AppTheme.red, size: 12),
                      const SizedBox(width: 4),
                      const Text('1.2k', style: TextStyle(fontSize: 10, color: AppTheme.muted)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
