import 'package:coding_dorado/features/exchange/domain/entities/rate_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pestaña activa. Es un Cubit porque es estado simple, sin concurrencia.
class HomeCubit extends Cubit<RateProvider> {
  HomeCubit() : super(RateProvider.values.first);

  void select(RateProvider provider) {
    if (provider != state) emit(provider);
  }
}
