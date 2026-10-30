import 'package:flutter_bloc/flutter_bloc.dart';

class WalletState {
  final int balance;
  final String lastAction;

  const WalletState({required this.balance, required this.lastAction});
}

/// ListenerCubit manages a balance state.
/// Used to demonstrate how BlocListener catches state changes to show
/// dialogs and SnackBars without rebuilding the widget tree.
class ListenerCubit extends Cubit<WalletState> {
  ListenerCubit()
      : super(const WalletState(balance: 50, lastAction: 'Initial deposit: \$50'));

  void deposit(int amount) {
    final next = state.balance + amount;
    emit(WalletState(balance: next, lastAction: 'Deposited +\$$amount'));
  }

  void withdraw(int amount) {
    final next = state.balance - amount;
    emit(WalletState(balance: next, lastAction: 'Withdrew -\$$amount'));
  }

  void reset() {
    emit(const WalletState(balance: 50, lastAction: 'Reset to \$50'));
  }
}
