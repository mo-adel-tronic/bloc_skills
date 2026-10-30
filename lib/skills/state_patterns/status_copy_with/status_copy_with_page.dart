import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'product_catalog_cubit.dart';

class StatusCopyWithPage extends StatelessWidget {
  const StatusCopyWithPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductCatalogCubit(),
      child: const _StatusCopyWithView(),
    );
  }
}

class _StatusCopyWithView extends StatelessWidget {
  const _StatusCopyWithView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('State Design — copyWith + Enum'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Concept Card
            Card(
              color: Colors.indigo.shade50,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.indigo.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.copy_all, color: Colors.indigo.shade900),
                        const SizedBox(width: 8),
                        Text(
                          'The Status + copyWith Pattern',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Recommended for forms, shopping carts, and screens with multiple interdependent fields.\n'
                      '• Uses a single state class with a `status` enum (`initial`, `loading`, `success`, `failure`).\n'
                      '• `copyWith()` produces a new immutable state instance modifying only target properties while preserving others.',
                      style: TextStyle(fontSize: 13.5, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Category Filter Bar (Only active when success)
            BlocBuilder<ProductCatalogCubit, ProductCatalogState>(
              buildWhen: (prev, curr) =>
                  prev.status != curr.status ||
                  prev.selectedCategory != curr.selectedCategory,
              builder: (context, state) {
                final isLoaded = state.status == CatalogStatus.success;
                final categories = ['All', 'Tech', 'Books'];

                return Row(
                  children: [
                    const Text('Filter: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    ...categories.map((cat) {
                      final isSelected = state.selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(cat),
                          selected: isSelected && isLoaded,
                          onSelected: isLoaded
                              ? (_) => context.read<ProductCatalogCubit>().filterByCategory(cat)
                              : null,
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // Live State Card
            BlocBuilder<ProductCatalogCubit, ProductCatalogState>(
              builder: (context, state) {
                switch (state.status) {
                  case CatalogStatus.initial:
                    return Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        children: const [
                          Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Catalog not loaded yet.', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );

                  case CatalogStatus.loading:
                    return Container(
                      padding: const EdgeInsets.all(36),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        children: const [
                          CircularProgressIndicator(),
                          SizedBox(height: 12),
                          Text('Loading catalog with copyWith...', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );

                  case CatalogStatus.failure:
                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red.shade300),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 44),
                          const SizedBox(height: 8),
                          Text(
                            state.errorMessage ?? 'An error occurred',
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );

                  case CatalogStatus.success:
                    final products = state.filteredProducts;
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Showing ${products.length} Products (Filter: ${state.selectedCategory})',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 12),
                          ...products.map((p) => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.indigo.shade50.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(p.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        Text(p.category, style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                                      ],
                                    ),
                                    Text('\$${p.price.toInt()}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo.shade900)),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    );
                }
              },
            ),
            const SizedBox(height: 20),

            // Controls
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () => context.read<ProductCatalogCubit>().loadProducts(),
                  icon: const Icon(Icons.cloud_download),
                  label: const Text('Load Products'),
                  style: FilledButton.styleFrom(backgroundColor: Colors.indigo),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.read<ProductCatalogCubit>().loadProducts(simulateError: true),
                  icon: const Icon(Icons.error_outline),
                  label: const Text('Simulate Error'),
                ),
                IconButton.filledTonal(
                  onPressed: () => context.read<ProductCatalogCubit>().reset(),
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Reset',
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Code Display
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(12),
              ),
              width: double.infinity,
              child: const Text(
                '// Immutable update using copyWith:\n'
                'void filterByCategory(String cat) {\n'
                '  emit(state.copyWith(\n'
                '    selectedCategory: cat,\n'
                '    // Other fields (products, status) remain intact!\n'
                '  ));\n'
                '}',
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.indigoAccent,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

