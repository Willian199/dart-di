import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';

class InstanceFactoryUtil {
  static BeanT create<BeanT extends Object, ParameterT extends Object>({
    required CustomBuilder<FutureOr<BeanT>> builder,
    ParameterT? parameter,
  }) {
    return switch (builder.producer) {
      final BeanT Function() s => s.call(),
      final BeanT Function(ParameterT) c =>
        c.call(parameter ?? ddi.get<ParameterT>()),
      final Function f when parameter != null && parameter is List =>
        Function.apply(f, parameter) as BeanT,
      final Function f when parameter != null && parameter is Map =>
        Function.apply(f, null, parameter as Map<Symbol, dynamic>) as BeanT,
      final Function f when parameter != null =>
        Function.apply(f, [parameter]) as BeanT,
      final _ => _autoInject(builder),
    };
  }

  static BeanT _autoInject<BeanT extends Object>(
      CustomBuilder<FutureOr<BeanT>> builder) {
    final instances = [
      for (final inject in builder.parametersType) ddi.get(qualifier: inject)
    ];

    return Function.apply(builder.producer, instances) as BeanT;
  }

  static FutureOr<BeanT>
      createAsync<BeanT extends Object, ParameterT extends Object>({
    required CustomBuilder<FutureOr<BeanT>> builder,
    ParameterT? parameter,
  }) async {
    return switch (builder.producer) {
      final FutureOr<BeanT> Function() s => s.call(),
      final FutureOr<BeanT> Function(ParameterT) c =>
        c.call(parameter ?? await ddi.getAsync<ParameterT>()),
      final Function f when parameter != null && parameter is List =>
        Function.apply(f, [...parameter]) as FutureOr<BeanT>,
      final Function f when parameter != null && parameter is Map =>
        Function.apply(f, null, parameter as Map<Symbol, dynamic>) as BeanT,
      final Function f when parameter != null =>
        Function.apply(f, [parameter]) as FutureOr<BeanT>,
      final _ => _autoInjectAsync(builder),
    };
  }

  static FutureOr<BeanT> _autoInjectAsync<BeanT extends Object>(
      CustomBuilder<FutureOr<BeanT>> builder) async {
    /// Must await inject by inject
    /// If use await Future.wait([]) could create different instance for the same type.
    final instances = [
      for (final inject in builder.parametersType)
        await ddi.getAsync(qualifier: inject)
    ];

    return Function.apply(builder.producer, instances) as BeanT;
  }
}
