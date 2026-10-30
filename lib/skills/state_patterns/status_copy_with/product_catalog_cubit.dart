import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum CatalogStatus { initial, loading, success, failure }

class ProductItem extends Equatable {
  final String id;
  final String title;
  final String category;
  final double price;

  const ProductItem({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
  });

  @override
  List<Object?> get props => [id, title, category, price];
}

class ProductCatalogState extends Equatable {
  final CatalogStatus status;
  final List<ProductItem> allProducts;
  final String selectedCategory;
  final String? errorMessage;

  const ProductCatalogState({
    this.status = CatalogStatus.initial,
    this.allProducts = const [],
    this.selectedCategory = 'All',
    this.errorMessage,
  });

  // Getter for filtered products based on current selectedCategory
  List<ProductItem> get filteredProducts {
    if (selectedCategory == 'All') return allProducts;
    return allProducts.where((p) => p.category == selectedCategory).toList();
  }

  // copyWith allows immutable partial updates
  ProductCatalogState copyWith({
    CatalogStatus? status,
    List<ProductItem>? allProducts,
    String? selectedCategory,
    String? errorMessage,
  }) {
    return ProductCatalogState(
      status: status ?? this.status,
      allProducts: allProducts ?? this.allProducts,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        allProducts,
        selectedCategory,
        errorMessage,
      ];
}

class ProductCatalogCubit extends Cubit<ProductCatalogState> {
  ProductCatalogCubit() : super(const ProductCatalogState());

  final _mockProducts = const [
    ProductItem(id: '1', title: 'MacBook Pro M3', category: 'Tech', price: 1999.0),
    ProductItem(id: '2', title: 'Clean Architecture in Dart', category: 'Books', price: 45.0),
    ProductItem(id: '3', title: 'Sony WH-1000XM5', category: 'Tech', price: 399.0),
    ProductItem(id: '4', title: 'Flutter Apprentice', category: 'Books', price: 55.0),
  ];

  Future<void> loadProducts({bool simulateError = false}) async {
    emit(state.copyWith(status: CatalogStatus.loading, errorMessage: null));

    await Future.delayed(const Duration(milliseconds: 900));

    if (simulateError) {
      emit(state.copyWith(
        status: CatalogStatus.failure,
        errorMessage: 'Failed to fetch catalog: Server 503 Service Unavailable',
      ));
      return;
    }

    emit(state.copyWith(
      status: CatalogStatus.success,
      allProducts: _mockProducts,
    ));
  }

  void filterByCategory(String category) {
    emit(state.copyWith(selectedCategory: category));
  }

  void reset() {
    emit(const ProductCatalogState());
  }
}

