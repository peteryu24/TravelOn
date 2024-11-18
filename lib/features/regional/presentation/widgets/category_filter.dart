import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/regional_provider.dart';

class CategoryFilter extends StatelessWidget {
  const CategoryFilter({super.key});

  static const List<String> categories = ['전체', '관광지', '음식', '숙박'];

  @override
  Widget build(BuildContext context) {
    return Consumer<RegionalProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: categories.map((category) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(category),
                  selected: provider.selectedCategory == category,
                  selectedColor: Colors.blue.shade100,
                  onSelected: (bool selected) {
                    if (selected) {
                      provider.setCategory(category);
                    }
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}