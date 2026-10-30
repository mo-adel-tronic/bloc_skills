import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:bloc_skills/skills/advanced/bloc_testing/cart_bloc.dart';

void main() {
  group('CartBloc Unit Tests (bloc_test)', () {
    late CartBloc cartBloc;

    setUp(() {
      cartBloc = CartBloc();
    });

    tearDown(() {
      cartBloc.close();
    });

    test('initial state is CartInitial', () {
      expect(cartBloc.state, equals(CartInitial()));
    });

    blocTest<CartBloc, CartState>(
      'emits [CartLoaded] when AddCartItem is added to empty cart',
      build: () => CartBloc(),
      act: (bloc) => bloc.add(const AddCartItem(CartItem('Laptop', 1200))),
      expect: () => [
        const CartLoaded([CartItem('Laptop', 1200)], 1200),
      ],
    );

    blocTest<CartBloc, CartState>(
      'emits multiple [CartLoaded] states when multiple items are added',
      build: () => CartBloc(),
      act: (bloc) => bloc
        ..add(const AddCartItem(CartItem('Mouse', 30)))
        ..add(const AddCartItem(CartItem('Keyboard', 70))),
      expect: () => [
        const CartLoaded([CartItem('Mouse', 30)], 30),
        const CartLoaded([CartItem('Mouse', 30), CartItem('Keyboard', 70)], 100),
      ],
    );

    blocTest<CartBloc, CartState>(
      'emits [CartError] when removing item from empty cart',
      build: () => CartBloc(),
      act: (bloc) => bloc.add(const RemoveCartItem('NonExistent')),
      expect: () => [
        const CartError('Cannot remove items from an empty cart.'),
      ],
    );

    blocTest<CartBloc, CartState>(
      'emits [CartInitial] when ClearCart is dispatched',
      build: () => CartBloc(),
      seed: () => const CartLoaded([CartItem('Monitor', 300)], 300),
      act: (bloc) => bloc.add(ClearCart()),
      expect: () => [
        CartInitial(),
      ],
    );
  });
}

