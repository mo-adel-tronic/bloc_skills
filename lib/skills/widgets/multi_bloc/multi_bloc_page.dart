import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'multi_bloc_cubits.dart';

class MultiBlocPage extends StatelessWidget {
  const MultiBlocPage({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiBlocProvider merges multiple providers into a flat list
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CartCubit()),
        BlocProvider(create: (_) => NotificationCubit()),
      ],
      child: const _MultiBlocView(),
    );
  }
}

class _MultiBlocView extends StatelessWidget {
  const _MultiBlocView();

  @override
  Widget build(BuildContext context) {
    // MultiBlocListener merges multiple listeners into a flat list
    return MultiBlocListener(
      listeners: [
        BlocListener<NotificationCubit, String?>(
          listener: (context, notification) {
            if (notification != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(notification),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        ),
        BlocListener<CartCubit, CartState>(
          listenWhen: (prev, curr) => prev.itemCount > 0 && curr.itemCount == 0,
          listener: (context, state) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
                title: const Text('Checkout Complete!'),
                content: const Text(
                  'Cart was cleared and purchase confirmed.\n'
                  'Detected by BlocListener<CartCubit> inside MultiBlocListener.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('MultiBlocProvider & MultiBlocListener'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Concept Card
              Card(
                color: Colors.teal.shade50,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.teal.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.layers_outlined, color: Colors.teal.shade800),
                          const SizedBox(width: 8),
                          Text(
                            'MultiBloc Widgets',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• Avoid nested "pyramid of doom" provider/listener widgets.\n'
                        '• `MultiBlocProvider`: injects N BLoCs at once.\n'
                        '• `MultiBlocListener`: attaches N listeners to the widget tree.\n'
                        '• Clean, readable, and standard practice for production apps.',
                        style: TextStyle(fontSize: 13.5, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Cart Summary Card
              BlocBuilder<CartCubit, CartState>(
                builder: (context, cart) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.teal.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('Items in Cart', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(
                              '${cart.itemCount}',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal.shade900,
                              ),
                            ),
                          ],
                        ),
                        Container(height: 40, width: 1, color: Colors.teal.shade200),
                        Column(
                          children: [
                            const Text('Total Value', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(
                              '\$${cart.totalPrice}',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal.shade900,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Interactive Action Buttons
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: () {
                      context.read<CartCubit>().addItem(price: 25);
                      context.read<NotificationCubit>().notify('🛒 Added Flutter Book (\$25) to Cart');
                    },
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Add Book (+\$25)'),
                  ),
                  FilledButton.icon(
                    onPressed: () {
                      context.read<CartCubit>().addItem(price: 50);
                      context.read<NotificationCubit>().notify('💻 Added Dev Course (\$50) to Cart');
                    },
                    icon: const Icon(Icons.laptop_mac),
                    label: const Text('Add Course (+\$50)'),
                    style: FilledButton.styleFrom(backgroundColor: Colors.indigo),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      context.read<CartCubit>().clearCart();
                    },
                    icon: const Icon(Icons.shopping_bag_outlined),
                    label: const Text('Checkout Cart'),
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
                  'MultiBlocProvider(\n'
                  '  providers: [\n'
                  '    BlocProvider(create: (_) => CartCubit()),\n'
                  '    BlocProvider(create: (_) => NotificationCubit()),\n'
                  '  ],\n'
                  '  child: MultiBlocListener(\n'
                  '    listeners: [\n'
                  '      BlocListener<NotificationCubit, String?>(...),\n'
                  '      BlocListener<CartCubit, CartState>(...),\n'
                  '    ],\n'
                  '    child: MyView(),\n'
                  '  ),\n'
                  ');',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: Colors.tealAccent,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
