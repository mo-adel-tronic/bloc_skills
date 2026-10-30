import 'package:flutter_bloc/flutter_bloc.dart';

class CartState {
  final int itemCount;
  final int totalPrice;

  const CartState({required this.itemCount, required this.totalPrice});
}

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartState(itemCount: 0, totalPrice: 0));

  void addItem({required int price}) {
    emit(CartState(
      itemCount: state.itemCount + 1,
      totalPrice: state.totalPrice + price,
    ));
  }

  void clearCart() {
    emit(const CartState(itemCount: 0, totalPrice: 0));
  }
}

class NotificationCubit extends Cubit<String?> {
  NotificationCubit() : super(null);

  void notify(String message) {
    emit(message);
  }

  void clear() {
    emit(null);
  }
}
