# 📘 BLoC Skills — Course Book

> A progressive, commit-based learning reference for Flutter students.
> A progressive, skill-based learning reference for Flutter students.
> Every skill builds from fundamental concepts to production-grade architecture.
> **1 Commit = 1 Complete Skill**: Each Git commit in this repository delivers a full skill along with its interactive live examples and state demonstrations.
>
> 🔒 **Why are some skills locked in the app?**
> The app displays a lock icon 🔒 for skills that are planned in future commits or not yet checked out. When you checkout an earlier commit or explore milestones, you see the exact state of the project at that step. Moving forward in commits unlocks each skill with all its interactive live examples!

---

## 📑 Table of Contents

- [What is BLoC?](#-what-is-bloc)
- [Skill 1: Cubit — The Simplified BLoC](#skill-1-cubit--the-simplified-bloc)
- [Skill 2: BLoC — Events & States](#skill-2-bloc--events--states)
- [Skill 3: BLoC Builder, Listener & Consumer](#skill-3-bloc-builder-listener--consumer)
- [Skill 4: BLoC Access & Dependency Injection](#skill-4-bloc-access--dependency-injection)
- [Skill 5: State Design Patterns](#skill-5-state-design-patterns)
- [Skill 6: Advanced BLoC Patterns](#skill-6-advanced-bloc-patterns)
- [Commits Reference](#-commits-reference)

---

## 🧠 What is BLoC?

**BLoC** (Business Logic Component) is a design pattern for Flutter that separates **business logic** from the **UI**. It uses **streams** under the hood to manage state reactively.

### Why BLoC?

| Problem | BLoC Solution |
|---|---|
| `setState` mixes UI + logic | BLoC lives outside widgets |
| Hard to test UI logic | BLoC is pure Dart — easy to unit test |
| State shared across screens is messy | `BlocProvider` injects state anywhere |
| Unpredictable rebuilds | `BlocBuilder` rebuilds only when state changes |

### The BLoC Mental Model

```
UI (Widget)
  │
  │  dispatches Events  ──►  BLoC / Cubit
  │                               │
  │  reacts to States   ◄──  emits States
  │
  ▼
New UI (rebuilt)
```

### Cubit vs BLoC

| | Cubit | BLoC |
|---|---|---|
| Input | Method calls | Events (classes) |
| Output | States | States |
| Complexity | ⭐ Simple | ⭐⭐⭐ Powerful |
| Use when | Simple counters, toggles | Complex flows, async, logging |

### Core Packages

```yaml
dependencies:
  flutter_bloc: ^9.x.x   # BLoC + Cubit widgets
  bloc: ^9.x.x            # Core BLoC logic (pure Dart)
  equatable: ^2.x.x       # Value equality for states
```

---

# Skill 1: Cubit — The Simplified BLoC

## 1.1 What is a Cubit?

A **Cubit** is the simplest form of BLoC. Instead of events, you call **methods directly** on the Cubit to trigger state changes.

```
Widget calls method  ──►  Cubit.method()
                               │
                          emit(newState)
                               │
Widget rebuilds      ◄──  BlocBuilder reacts
```

**When to use Cubit:** Toggles, counters, simple async fetches, anything with a small number of inputs.

## 1.2 Your First Cubit — Counter

### Step 1: Create the Cubit

```dart
// counter_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';

class CounterCubit extends Cubit<int> {
  // Initial state = 0
  CounterCubit() : super(0);

  // Methods that change state
  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
  void reset() => emit(0);
}
```

### Step 2: Provide the Cubit

```dart
// Wrap the widget tree where you want the Cubit available
BlocProvider(
  create: (context) => CounterCubit(),
  child: const CounterPage(),
)
```

### Step 3: Read & React with BlocBuilder

```dart
class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter — Cubit')),
      body: Center(
        child: BlocBuilder<CounterCubit, int>(
          builder: (context, count) {
            return Text(
              '$count',
              style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
            );
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'inc',
            onPressed: () => context.read<CounterCubit>().increment(),
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'dec',
            onPressed: () => context.read<CounterCubit>().decrement(),
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}
```

> **Key insight:** `context.read<CounterCubit>()` finds the Cubit provided above in the widget tree. It does NOT trigger rebuilds — use it only in callbacks (onTap, onPressed), never in `build()`.

## 1.3 Cubit with Complex State

Cubit is not limited to `int`. Your state can be any Dart object:

```dart
// theme_cubit.dart — a ThemeMode state
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light);

  void toggleTheme() => emit(
    state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light,
  );
}
```

## 1.4 Cubit Lifecycle

```dart
class MyCubit extends Cubit<MyState> {
  MyCubit() : super(MyInitialState());

  @override
  void onChange(Change<MyState> change) {
    super.onChange(change);
    // Called every time state changes
    // change.currentState → old state
    // change.nextState   → new state
    print('State changed: $change');
  }

  @override
  Future<void> close() {
    // Called when Cubit is disposed
    // Clean up resources here (controllers, streams, timers)
    return super.close();
  }
}
```

> **Rule:** Always clean up subscriptions and controllers in `close()`. `BlocProvider` calls `close()` automatically when the widget is removed from the tree.

## 1.5 Quick Reference — Cubit

| What | How |
|---|---|
| Create | `class MyCubit extends Cubit<StateType>` |
| Initial state | `MyCubit() : super(initialValue)` |
| Emit new state | `emit(newState)` |
| Provide | `BlocProvider(create: (_) => MyCubit())` |
| Read (in callback) | `context.read<MyCubit>().method()` |
| Watch (in build) | `context.watch<MyCubit>().state` |
| React to changes | `BlocBuilder<MyCubit, StateType>` |

---

# Skill 2: BLoC — Events & States

## 2.1 Why Events?

BLoC adds a layer of **named events** between the UI and logic. Instead of calling methods, widgets **dispatch events** (plain Dart objects). BLoC **handles** each event and emits a new state.

```
Widget                BLoC
  │  add(LoginPressed)  │
  │ ──────────────────► │
  │                     │ on<LoginPressed>() runs
  │                     │ → emit(LoginLoading)
  │  ◄── LoginLoading ──│
  │                     │ await api.login()
  │                     │ → emit(LoginSuccess)
  │  ◄── LoginSuccess ──│
```

**Benefits of events:**
- You can log every event (analytics, debugging)
- You can replay events
- You can add middleware (transformers, debounce)
- Clear separation: UI only knows about events, not logic

## 2.2 Defining Events

```dart
// auth_event.dart

// Base class — all events extend this
sealed class AuthEvent {}

// Each event is its own class
class LoginPressed extends AuthEvent {
  final String email;
  final String password;
  const LoginPressed({required this.email, required this.password});
}

class LogoutPressed extends AuthEvent {}

class TokenRefreshRequested extends AuthEvent {
  final String refreshToken;
  const TokenRefreshRequested(this.refreshToken);
}
```

> **Why `sealed`?** A `sealed` class forces exhaustive handling in `switch` statements — the compiler warns you if you forget to handle an event type.

## 2.3 Defining States

```dart
// auth_state.dart
sealed class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String username;
  const AuthSuccess(this.username);
}

class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);
}
```

## 2.4 Creating the BLoC

```dart
// auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    // Register a handler for each event type
    on<LoginPressed>(_onLoginPressed);
    on<LogoutPressed>(_onLogoutPressed);
  }

  Future<void> _onLoginPressed(
    LoginPressed event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading()); // Show a spinner

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (event.email == 'test@test.com' && event.password == '123456') {
        emit(AuthSuccess('Test User'));
      } else {
        emit(AuthFailure('Invalid credentials'));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  void _onLogoutPressed(
    LogoutPressed event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthInitial());
  }
}
```

## 2.5 Dispatching Events from UI

```dart
// Add an event — equivalent to calling a method on a Cubit
context.read<AuthBloc>().add(LoginPressed(
  email: _emailController.text,
  password: _passwordController.text,
));
```

## 2.6 BLoC Lifecycle & Observer

```dart
// bloc_observer.dart — intercept ALL blocs globally
class AppBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    print('[${bloc.runtimeType}] Event: $event');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('[${bloc.runtimeType}] Change: $change');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('[${bloc.runtimeType}] Error: $error');
    super.onError(bloc, error, stackTrace);
  }
}

// main.dart — register the observer
void main() {
  Bloc.observer = AppBlocObserver();
  runApp(const MyApp());
}
```

## 2.7 Quick Reference — BLoC

| What | How |
|---|---|
| Create | `class MyBloc extends Bloc<MyEvent, MyState>` |
| Register handler | `on<MyEvent>(_handler)` in constructor |
| Handler signature | `void _handler(MyEvent event, Emitter<MyState> emit)` |
| Async handler | `Future<void> _handler(...)` |
| Dispatch event | `context.read<MyBloc>().add(MyEvent())` |
| Emit state | `emit(MyNewState())` |
| Observe globally | `Bloc.observer = AppBlocObserver()` |

---

# Skill 3: BLoC Builder, Listener & Consumer

## 3.1 BlocBuilder — Rebuild UI on State Change

`BlocBuilder` rebuilds its child whenever state changes.

```dart
BlocBuilder<CounterCubit, int>(
  // Optional: only rebuild when this condition is true
  buildWhen: (previous, current) => current != previous,

  builder: (context, state) {
    return Text('Count: $state');
  },
)
```

> **`buildWhen`**: A performance optimization. Use it to skip unnecessary rebuilds — e.g., skip rebuilding a button row when only a text value changes.

## 3.2 BlocListener — React to State Without Rebuilding

`BlocListener` does NOT rebuild UI. It runs a callback as a **side effect** — navigation, dialogs, snack bars.

```dart
BlocListener<AuthBloc, AuthState>(
  listenWhen: (previous, current) => current is AuthSuccess || current is AuthFailure,

  listener: (context, state) {
    if (state is AuthSuccess) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else if (state is AuthFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },

  child: const LoginForm(), // This widget NEVER rebuilds due to the listener
)
```

## 3.3 BlocConsumer — Builder + Listener Combined

When you need both UI rebuilds AND side effects:

```dart
BlocConsumer<AuthBloc, AuthState>(
  listenWhen: (previous, current) => current is AuthSuccess,
  listener: (context, state) {
    Navigator.pushReplacementNamed(context, '/home');
  },

  buildWhen: (previous, current) => current is! AuthSuccess,
  builder: (context, state) {
    return switch (state) {
      AuthInitial() => const LoginForm(),
      AuthLoading() => const CircularProgressIndicator(),
      AuthFailure(:final message) => ErrorWidget(message: message),
      AuthSuccess() => const SizedBox.shrink(),
    };
  },
)
```

## 3.4 MultiBlocListener & MultiBlocProvider

When you need multiple BLoCs:

```dart
// Provide multiple BLoCs at once
MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => AuthBloc()),
    BlocProvider(create: (_) => CartBloc()),
    BlocProvider(create: (_) => ThemeCubit()),
  ],
  child: const MyApp(),
)

// Listen to multiple BLoCs
MultiBlocListener(
  listeners: [
    BlocListener<AuthBloc, AuthState>(
      listener: (context, state) { /* ... */ },
    ),
    BlocListener<CartBloc, CartState>(
      listener: (context, state) { /* ... */ },
    ),
  ],
  child: const HomeScreen(),
)
```

## 3.5 Quick Reference — Widgets

| Widget | Rebuilds? | Side Effects? | Use When |
|---|---|---|---|
| `BlocBuilder` | ✅ | ❌ | Update UI based on state |
| `BlocListener` | ❌ | ✅ | Navigate, show dialogs/snackbars |
| `BlocConsumer` | ✅ | ✅ | Both at once |
| `MultiBlocProvider` | — | — | Provide multiple BLoCs |
| `MultiBlocListener` | — | — | Listen to multiple BLoCs |

---

# Skill 4: BLoC Access & Dependency Injection

## 4.1 Three Ways to Access a BLoC

```dart
// 1. context.read — one-time read (use in callbacks, NOT in build)
ElevatedButton(
  onPressed: () => context.read<CounterCubit>().increment(),
  child: const Text('Add'),
)

// 2. context.watch — watch and rebuild when state changes (use in build)
final count = context.watch<CounterCubit>().state;
Text('$count')

// 3. context.select — watch only a piece of state (fine-grained rebuilds)
final isLoggedIn = context.select<AuthBloc, bool>(
  (bloc) => bloc.state is AuthSuccess,
);
```

> **Rule of thumb:**
> - `read` → callbacks/events (won't rebuild)
> - `watch` → `build()` when you need the full state
> - `select` → `build()` when you only need a specific field (performance win)

## 4.2 BlocProvider Positioning

Where you place `BlocProvider` defines **which widgets can access the BLoC**:

```dart
// App-wide — place at MaterialApp level
BlocProvider(
  create: (_) => AuthBloc(),
  child: MaterialApp(/* ... */),
)

// Feature-scoped — provide only to a specific route
BlocProvider(
  create: (_) => CartBloc(),
  child: const CheckoutPage(),
)

// Pass an existing BLoC to a new route (value constructor)
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => BlocProvider.value(
      value: context.read<CartBloc>(), // Reuse existing instance
      child: const CartDetailPage(),
    ),
  ),
);
```

> **`BlocProvider` vs `BlocProvider.value`:**
> - `BlocProvider(create:...)` → creates AND closes the BLoC automatically
> - `BlocProvider.value(value:...)` → provides an EXISTING BLoC, does NOT close it

## 4.3 RepositoryProvider — Injecting Services

For non-BLoC dependencies (API clients, databases, repositories):

```dart
// Provide a repository
RepositoryProvider(
  create: (_) => UserRepository(),
  child: BlocProvider(
    create: (context) => UserBloc(
      userRepo: context.read<UserRepository>(),
    ),
    child: const UserPage(),
  ),
)

// Access in BLoC constructor
class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _userRepo;
  UserBloc({required UserRepository userRepo})
      : _userRepo = userRepo,
        super(UserInitial()) {
    on<FetchUser>(_onFetchUser);
  }
}
```

## 4.4 Quick Reference — Access Patterns

| Method | Triggers Rebuild | Use In |
|---|---|---|
| `context.read<B>()` | ❌ | Callbacks, `initState` |
| `context.watch<B>()` | ✅ | `build()` method |
| `context.select<B, T>()` | ✅ (partial) | `build()` for performance |
| `BlocProvider.of<B>(context)` | ❌ | Same as `read` |

---

# Skill 5: State Design Patterns

## 5.1 The Status Pattern — copyWith + Enum

The most common real-world pattern: one state class with a `status` enum:

```dart
// product_state.dart
enum FetchStatus { initial, loading, success, failure }

class ProductState {
  final FetchStatus status;
  final List<Product> products;
  final String? errorMessage;

  const ProductState({
    this.status = FetchStatus.initial,
    this.products = const [],
    this.errorMessage,
  });

  // copyWith for immutable updates
  ProductState copyWith({
    FetchStatus? status,
    List<Product>? products,
    String? errorMessage,
  }) {
    return ProductState(
      status: status ?? this.status,
      products: products ?? this.products,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
```

```dart
// In BLoC — emit partial updates cleanly
Future<void> _onFetchProducts(
  FetchProducts event,
  Emitter<ProductState> emit,
) async {
  emit(state.copyWith(status: FetchStatus.loading));
  try {
    final products = await _repo.getProducts();
    emit(state.copyWith(status: FetchStatus.success, products: products));
  } catch (e) {
    emit(state.copyWith(status: FetchStatus.failure, errorMessage: e.toString()));
  }
}
```

## 5.2 Equatable — Preventing Unnecessary Rebuilds

By default, BLoC compares states with `==`. Without Equatable, two identical state objects are considered different (different instances), causing unnecessary rebuilds.

```dart
import 'package:equatable/equatable.dart';

// Without Equatable — emitting same values still triggers rebuild
class CounterState {
  final int count;
  const CounterState(this.count);
}

// With Equatable — BLoC skips rebuild if props are equal
class CounterState extends Equatable {
  final int count;
  const CounterState(this.count);

  @override
  List<Object?> get props => [count]; // Fields to compare
}
```

> **Rule:** Use `Equatable` for all your state classes. Skip it only for states that should ALWAYS trigger a rebuild (e.g., a one-shot "show dialog" state).

## 5.3 Sealed Classes Pattern (Dart 3+)

Dart 3 `sealed` classes provide exhaustive matching — ideal for states:

```dart
// weather_state.dart
sealed class WeatherState {}
class WeatherInitial extends WeatherState {}
class WeatherLoading extends WeatherState {}
class WeatherLoaded extends WeatherState {
  final String city;
  final double temperature;
  const WeatherLoaded({required this.city, required this.temperature});
}
class WeatherError extends WeatherState {
  final String message;
  const WeatherError(this.message);
}
```

```dart
// In BlocBuilder — exhaustive switch (compiler warns on missing cases)
builder: (context, state) {
  return switch (state) {
    WeatherInitial() => const SearchPrompt(),
    WeatherLoading() => const LoadingSpinner(),
    WeatherLoaded(:final city, :final temperature) => WeatherCard(
        city: city,
        temperature: temperature,
      ),
    WeatherError(:final message) => ErrorView(message: message),
  };
},
```

## 5.4 Quick Reference — State Patterns

| Pattern | Best For | Key Feature |
|---|---|---|
| Multiple state classes | Clear, simple states | `sealed` + exhaustive switch |
| Single class + `copyWith` | Complex state with many fields | Immutable partial updates |
| Freezed package | Large projects, code gen | `@freezed` annotation |
| Equatable | All patterns | Skip redundant rebuilds |

---

# Skill 6: Advanced BLoC Patterns

## 6.1 BLoC-to-BLoC Communication

BLoCs should not directly reference each other. Instead, use **stream subscriptions**:

```dart
class CartBloc extends Bloc<CartEvent, CartState> {
  late final StreamSubscription<AuthState> _authSubscription;

  CartBloc({required AuthBloc authBloc}) : super(CartInitial()) {
    // Listen to AuthBloc's stream
    _authSubscription = authBloc.stream.listen((authState) {
      if (authState is AuthInitial) {
        add(CartCleared()); // Clear cart when user logs out
      }
    });

    on<CartCleared>(_onCartCleared);
  }

  @override
  Future<void> close() {
    _authSubscription.cancel(); // Always cancel!
    return super.close();
  }
}
```

## 6.2 Event Transformers — Debounce & Throttle

Control how rapidly events are processed using `package:bloc_concurrency`:

```dart
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:stream_transform/stream_transform.dart';

// Custom debounce transformer
EventTransformer<T> debounceTransformer<T>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

// In BLoC:
on<SearchQueryChanged>(
  _onSearchQueryChanged,
  transformer: debounceTransformer(const Duration(milliseconds: 300)),
);

// Built-in transformers from bloc_concurrency:
on<FetchNextPage>(
  _onFetchNextPage,
  transformer: droppable(), // Drop new events while one is in progress
);

on<IncrementPressed>(
  _onIncrement,
  transformer: sequential(), // Queue events — process one at a time
);

on<RefreshPressed>(
  _onRefresh,
  transformer: restartable(), // Cancel ongoing, start new
);
```

## 6.3 Hydrated BLoC — Persisting State

`hydrated_bloc` persists BLoC state across app restarts automatically:

```dart
// pubspec.yaml: hydrated_bloc, path_provider

// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );
  HydratedBloc.storage = storage;
  runApp(const MyApp());
}

// settings_cubit.dart
class SettingsCubit extends HydratedCubit<SettingsState> {
  SettingsCubit() : super(const SettingsState());

  void toggleDarkMode() =>
      emit(state.copyWith(darkMode: !state.darkMode));

  // Serialize state to/from JSON
  @override
  SettingsState? fromJson(Map<String, dynamic> json) =>
      SettingsState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(SettingsState state) => state.toJson();
}
```

## 6.4 Testing BLoC

BLoC is pure Dart — test logic without any widgets:

```dart
// counter_cubit_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:test/test.dart';

void main() {
  group('CounterCubit', () {
    late CounterCubit cubit;

    setUp(() => cubit = CounterCubit());
    tearDown(() => cubit.close());

    test('initial state is 0', () {
      expect(cubit.state, equals(0));
    });

    blocTest<CounterCubit, int>(
      'emits [1] when increment is called',
      build: () => CounterCubit(),
      act: (cubit) => cubit.increment(),
      expect: () => [1],
    );

    blocTest<CounterCubit, int>(
      'emits [1, 2, 1] when increment, increment, decrement called',
      build: () => CounterCubit(),
      act: (cubit) {
        cubit.increment();
        cubit.increment();
        cubit.decrement();
      },
      expect: () => [1, 2, 1],
    );
  });
}
```

## 6.5 BLoC with Repository Pattern

Real apps separate data access into **Repositories**:

```dart
// Layer architecture:
// UI (Widgets) → BLoC → Repository → Data Source (API / DB)

// repository/user_repository.dart
class UserRepository {
  final ApiClient _api;
  UserRepository(this._api);

  Future<User> getUser(String id) async {
    final json = await _api.get('/users/$id');
    return User.fromJson(json);
  }
}

// bloc/user_bloc.dart
class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _repo;
  UserBloc({required UserRepository repo})
      : _repo = repo,
        super(UserInitial()) {
    on<FetchUser>(_onFetchUser);
  }

  Future<void> _onFetchUser(
    FetchUser event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final user = await _repo.getUser(event.id);
      emit(UserLoaded(user));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}

// main.dart — wire everything together
RepositoryProvider(
  create: (_) => UserRepository(ApiClient()),
  child: BlocProvider(
    create: (ctx) => UserBloc(repo: ctx.read<UserRepository>()),
    child: const App(),
  ),
)
```

---

# 📎 Commits Reference

Use `git log --oneline` to see the skill commits. Here is the roadmap:

| # | Commit Message | Skill Unlocked | Status | Concepts & Examples |
|---|---|---|---|---|
| 1 | `init: project setup with home screen and course roadmap` | Project Foundation | ✅ Available | Clean architecture setup, Home Screen, Skill catalog with locked placeholders |
| 2 | `skill 1: cubit — the simplified BLoC` | Skill 1: Cubit | ✅ Available | Counter (`int` state), Theme Toggle (`ThemeMode` enum), Lifecycle (`onChange` & `close()`) |
| 3 | `skill 2: bloc — events & states` | Skill 2: BLoC | ✅ Available | Auth Flow (sealed events & states, async emit), `AppBlocObserver` global logger |
| 4 | `skill 3: bloc widgets — builder, listener & consumer` | Skill 3: BLoC Widgets | ✅ Available | `buildWhen`, `BlocListener` side-effects, `BlocConsumer`, `MultiBloc` |
| 5 | `skill 4: bloc access & DI — read, watch, select & providers` | Skill 4: Access & DI | ✅ Available | `context.read/watch/select`, `BlocProvider.value`, `RepositoryProvider` |
| 6 | `skill 5: state design patterns — status, equatable & sealed` | Skill 5: State Patterns | ✅ Available | `status` enum + `copyWith`, `Equatable` value equality, Sealed hierarchies |
| 7 | `skill 6: advanced bloc patterns — stream subs, transformers & hydrated` | Skill 6: Advanced | ⏳ Planned | BLoC-to-BLoC, `bloc_concurrency`, `HydratedBloc`, testing |

---

> **📘 How to use this repo:**
> 1. `git log --oneline` — view the progressive skill milestones.
> 2. `git checkout <commit-hash>` — jump to any skill milestone:
>    - `git checkout <commit-1>`: Project setup with all skills in roadmap.
>    - `git checkout <commit-2>`: Skill 1 (Cubit) unlocked with 3 live examples.
>    - `git checkout <commit-3>`: Skill 2 (BLoC) unlocked with Auth Flow and Global Observer.
>    - `git checkout <commit-4>`: Skill 3 (BLoC Widgets) unlocked with 4 live widget examples.
>    - `git checkout <commit-5>`: Skill 4 (BLoC Access & DI) unlocked with 3 live examples.
>    - `git checkout <commit-6>`: Skill 5 (State Design Patterns) unlocked with 3 live examples.
> 3. `git checkout main` — return to the latest unlocked skill.

---

**Made with ❤️ for Flutter students**
