import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Cart Models & Events
class CartItem extends Equatable {
  final String name;
  final double price;

  const CartItem(this.name, this.price);

  @override
  List<Object?> get props => [name, price];
}

sealed class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object?> get props => [];
}

class AddCartItem extends CartEvent {
  final CartItem item;
  const AddCartItem(this.item);

  @override
  List<Object?> get props => [item];
}

class RemoveCartItem extends CartEvent {
  final String itemName;
  const RemoveCartItem(this.itemName);

  @override
  List<Object?> get props => [itemName];
}

class ClearCart extends CartEvent {}

// Cart States
sealed class CartState extends Equatable {
  const CartState();
  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoaded extends CartState {
  final List<CartItem> items;
  final double totalPrice;

  const CartLoaded(this.items, this.totalPrice);

  @override
  List<Object?> get props => [items, totalPrice];
}

class CartError extends CartState {
  final String message;
  const CartError(this.message);

  @override
  List<Object?> get props => [message];
}

// CartBloc
class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartInitial()) {
    on<AddCartItem>(_onAddItem);
    on<RemoveCartItem>(_onRemoveItem);
    on<ClearCart>(_onClearCart);
  }

  void _onAddItem(AddCartItem event, Emitter<CartState> emit) {
    final currentItems = state is CartLoaded ? (state as CartLoaded).items : <CartItem>[];
    final updatedList = List<CartItem>.from(currentItems)..add(event.item);
    final total = updatedList.fold<double>(0, (sum, item) => sum + item.price);
    emit(CartLoaded(updatedList, total));
  }

  void _onRemoveItem(RemoveCartItem event, Emitter<CartState> emit) {
    if (state is! CartLoaded) {
      emit(const CartError('Cannot remove items from an empty cart.'));
      return;
    }

    final currentItems = (state as CartLoaded).items;
    final index = currentItems.indexWhere((i) => i.name == event.itemName);

    if (index == -1) {
      emit(CartError('Item "${event.itemName}" not found in cart.'));
      return;
    }

    final updatedList = List<CartItem>.from(currentItems)..removeAt(index);
    if (updatedList.isEmpty) {
      emit(CartInitial());
    } else {
      final total = updatedList.fold<double>(0, (sum, item) => sum + item.price);
      emit(CartLoaded(updatedList, total));
    }
  }

  void _onClearCart(ClearCart event, Emitter<CartState> emit) {
    emit(CartInitial());
  }
}

