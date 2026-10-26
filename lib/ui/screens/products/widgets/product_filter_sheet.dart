import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../state/product_provider.dart';

class ProductFilterSheet extends StatefulWidget {
  const ProductFilterSheet({super.key});

  @override
  State<ProductFilterSheet> createState() => _ProductFilterSheetState();
}

class _ProductFilterSheetState extends State<ProductFilterSheet> {
  late String _selectedCategory;
  late String _selectedSort;
  late RangeValues _priceRange;

  final List<String> _sortOptions = [
    'Popularity',
    'Price: Low to High',
    'Price: High to Low',
    'Top Rated',
  ];

  @override
  void initState() {
    super.initState();
    final provider = context.read<ProductProvider>();
    _selectedCategory = provider.selectedCategoryId;
    _selectedSort = provider.sortBy;
    _priceRange = RangeValues(
      provider.minPrice ?? 0,
      provider.maxPrice ?? 2500,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<ProductProvider>();
    final categories = provider.categories;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header: Title & Reset Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter & Sort',
                  style: AppTypography.headingMedium.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = 'cat_all';
                      _selectedSort = 'Popularity';
                      _priceRange = const RangeValues(0, 2500);
                    });
                  },
                  child: Text(
                    'Reset',
                    style: AppTypography.buttonText.copyWith(
                      color: AppColors.accentRose,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Categories Filter
            Text(
              'CATEGORIES',
              style: AppTypography.badgeText.copyWith(
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((cat) {
                final isSelected = _selectedCategory == cat.id;
                return ChoiceChip(
                  label: Text(cat.name),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                  labelStyle: AppTypography.bodySmall.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primaryLight
                        : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedCategory = cat.id);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Sort By Options
            Text(
              'SORT BY',
              style: AppTypography.badgeText.copyWith(
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _sortOptions.map((sort) {
                final isSelected = _selectedSort == sort;
                return ChoiceChip(
                  label: Text(sort),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                  labelStyle: AppTypography.bodySmall.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primaryLight
                        : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedSort = sort);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Price Range Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PRICE RANGE',
                  style: AppTypography.badgeText.copyWith(
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  '${Formatters.currency(_priceRange.start)} - ${Formatters.currency(_priceRange.end)}',
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryLight,
                  ),
                ),
              ],
            ),
            RangeSlider(
              values: _priceRange,
              min: 0,
              max: 2500,
              divisions: 50,
              activeColor: AppColors.primary,
              inactiveColor: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
              onChanged: (values) {
                setState(() => _priceRange = values);
              },
            ),
            const SizedBox(height: 24),

            // Apply Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  final provider = context.read<ProductProvider>();
                  provider.selectCategory(_selectedCategory);
                  provider.setSortBy(_selectedSort);
                  provider.setPriceFilter(_priceRange.start, _priceRange.end);
                  Navigator.pop(context);
                },
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
