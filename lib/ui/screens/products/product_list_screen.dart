import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../state/product_provider.dart';
import 'widgets/floating_product_card.dart';
import 'widgets/product_filter_sheet.dart';
import '../home/widgets/search_and_filter_bar.dart';

class ProductListScreen extends StatefulWidget {
  final String? initialCategoryId;

  const ProductListScreen({
    super.key,
    this.initialCategoryId,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialCategoryId != null) {
        context.read<ProductProvider>().selectCategory(widget.initialCategoryId!);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ProductFilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<ProductProvider>();
    final products = provider.filteredProducts;
    final categories = provider.categories;

    final hasActiveFilters = provider.selectedCategoryId != 'cat_all' ||
        provider.minPrice != null ||
        provider.maxPrice != null ||
        provider.sortBy != 'Popularity';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text('Explore Collection', style: AppTypography.headingMedium),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded),
            tooltip: _isGridView ? 'Switch to List' : 'Switch to Grid',
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1360),
          child: Column(
            children: [
              const SizedBox(height: 8),
          // Search & Filter Bar
          SearchAndFilterBar(
            controller: _searchController,
            onChanged: (val) => provider.setSearchQuery(val),
            onFilterTap: _openFilterModal,
            onClear: () {
              _searchController.clear();
              provider.setSearchQuery('');
            },
            hasActiveFilters: hasActiveFilters,
          ),
          const SizedBox(height: 12),

          // Categories Horizontal Chips
          SizedBox(
            height: 38,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = provider.selectedCategoryId == cat.id;

                return ChoiceChip(
                  label: Text(cat.name),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: isDark ? AppColors.darkCard : const Color(0xFFF1F5F9),
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
                      provider.selectCategory(cat.id);
                    }
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Result Count & Active Filter Indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${products.length} Products Found',
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (hasActiveFilters)
                  InkWell(
                    onTap: () {
                      _searchController.clear();
                      provider.resetFilters();
                    },
                    child: Text(
                      'Clear Filters',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.accentRose,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Products View
          Expanded(
            child: products.isEmpty
                ? _buildEmptyState(isDark, provider)
                : _isGridView
                    ? _buildGridView(products)
                    : _buildListView(products),
          ),
        ],
      ),
    ),
  ),
);
}

  Widget _buildGridView(List products) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 4
            : constraints.maxWidth > 600
                ? 3
                : 2;

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.62,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            return FloatingProductCard(
              product: products[index],
              width: double.infinity,
            );
          },
        );
      },
    );
  }

  Widget _buildListView(List products) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: products.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        return FloatingProductCard(
          product: products[index],
          width: double.infinity,
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark, ProductProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(isDark ? 30 : 15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 54,
                color: AppColors.primaryLight,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Products Found',
              style: AppTypography.headingMedium.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We couldn\'t find any items matching your search or filters. Try adjusting your preferences.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                provider.resetFilters();
              },
              child: const Text('Reset All Filters'),
            ),
          ],
        ),
      ),
    );
  }
}
