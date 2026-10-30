import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Weather Info Model
class WeatherData extends Equatable {
  final String city;
  final int tempCelsius;
  final String condition;
  final String icon;

  const WeatherData({
    required this.city,
    required this.tempCelsius,
    required this.condition,
    required this.icon,
  });

  @override
  List<Object?> get props => [city, tempCelsius, condition, icon];
}

// Sealed Event Hierarchy
sealed class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object?> get props => [];
}

class FetchWeather extends WeatherEvent {
  final String city;
  const FetchWeather(this.city);

  @override
  List<Object?> get props => [city];
}

class ResetWeather extends WeatherEvent {
  const ResetWeather();
}

// Sealed State Hierarchy (Dart 3 Pattern Matching)
sealed class WeatherState extends Equatable {
  const WeatherState();

  @override
  List<Object?> get props => [];
}

class WeatherInitial extends WeatherState {
  const WeatherInitial();
}

class WeatherLoading extends WeatherState {
  const WeatherLoading();
}

class WeatherSuccess extends WeatherState {
  final WeatherData data;
  const WeatherSuccess(this.data);

  @override
  List<Object?> get props => [data];
}

class WeatherError extends WeatherState {
  final String message;
  const WeatherError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC Implementation
class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  WeatherBloc() : super(const WeatherInitial()) {
    on<FetchWeather>(_onFetchWeather);
    on<ResetWeather>(_onResetWeather);
  }

  Future<void> _onFetchWeather(
    FetchWeather event,
    Emitter<WeatherState> emit,
  ) async {
    emit(const WeatherLoading());

    await Future.delayed(const Duration(milliseconds: 700));

    switch (event.city.toLowerCase()) {
      case 'tokyo':
        emit(const WeatherSuccess(WeatherData(
          city: 'Tokyo, Japan',
          tempCelsius: 22,
          condition: 'Sunny & Clear',
          icon: '☀️',
        )));
        break;
      case 'london':
        emit(const WeatherSuccess(WeatherData(
          city: 'London, UK',
          tempCelsius: 14,
          condition: 'Light Showers',
          icon: '🌧️',
        )));
        break;
      case 'cairo':
        emit(const WeatherSuccess(WeatherData(
          city: 'Cairo, Egypt',
          tempCelsius: 31,
          condition: 'Warm & Dry',
          icon: '🌤️',
        )));
        break;
      default:
        emit(WeatherError('City "${event.city}" not found in weather registry.'));
    }
  }

  void _onResetWeather(
    ResetWeather event,
    Emitter<WeatherState> emit,
  ) {
    emit(const WeatherInitial());
  }
}

