import 'dart:async';

import 'package:dart_ddi/src/data/scope_factory.dart';
import 'package:dart_ddi/src/enum/scopes.dart';
import 'package:dart_ddi/src/exception/concurrent_creation.dart';
import 'package:dart_ddi/src/utils/application_util.dart';
import 'package:dart_ddi/src/utils/dart_ddi_utils.dart';
import 'package:dart_ddi/src/utils/dependent_utils.dart';

final class ScopeUtils {
  static const _resolutionKey = #_resolutionKey;

  static final Set<Object> _resolutionMap =
      Zone.current[_resolutionKey] as Set<Object>? ?? {};
  static BeanT _getScoped<BeanT extends Object, ParameterT extends Object>({
    required ScopeFactory<BeanT> factory,
    required Object effectiveQualifierName,
    ParameterT? parameter,
  }) {
    if (_resolutionMap.contains(effectiveQualifierName)) {
      throw ConcurrentCreationException(effectiveQualifierName.toString());
    }

    _resolutionMap.add(effectiveQualifierName);

    try {
      return switch (factory.scopeType) {
        Scopes.singleton || Scopes.object => DartDDIUtils.getSingleton<BeanT>(
            factory: factory,
            effectiveQualifierName: effectiveQualifierName,
          ),
        Scopes.dependent => DependentUtils.getDependent<BeanT, ParameterT>(
            factory: factory,
            effectiveQualifierName: effectiveQualifierName,
            parameter: parameter,
          ),
        Scopes.application ||
        Scopes.session =>
          ApplicationUtils.getAplication<BeanT, ParameterT>(
            factory: factory,
            effectiveQualifierName: effectiveQualifierName,
            parameter: parameter,
          )
      };
    } finally {
      _resolutionMap.remove(effectiveQualifierName);
    }
  }

  static Future<BeanT>
      _getScopedAsync<BeanT extends Object, ParameterT extends Object>({
    required ScopeFactory<BeanT> factory,
    required Object effectiveQualifierName,
    ParameterT? parameter,
  }) async {
    if (_resolutionMap.contains(effectiveQualifierName)) {
      throw ConcurrentCreationException(effectiveQualifierName.toString());
    }

    _resolutionMap.add(effectiveQualifierName);

    try {
      return switch (factory.scopeType) {
        Scopes.singleton ||
        Scopes.object =>
          await DartDDIUtils.getSingletonAsync<BeanT>(
            factory: factory,
            effectiveQualifierName: effectiveQualifierName,
          ),
        Scopes.dependent =>
          await DependentUtils.getDependentAsync<BeanT, ParameterT>(
            factory: factory,
            effectiveQualifierName: effectiveQualifierName,
            parameter: parameter,
          ),
        Scopes.application ||
        Scopes.session =>
          await ApplicationUtils.getAplicationAsync<BeanT, ParameterT>(
            factory: factory,
            effectiveQualifierName: effectiveQualifierName,
            parameter: parameter,
          )
      };
    } finally {
      _resolutionMap.remove(effectiveQualifierName);
    }
  }

  static BeanT executar<BeanT extends Object, ParameterT extends Object>({
    required ScopeFactory<BeanT> factory,
    required Object effectiveQualifierName,
    ParameterT? parameter,
  }) {
    return runZoned(
      () {
        return _getScoped<BeanT, ParameterT>(
          factory: factory,
          effectiveQualifierName: effectiveQualifierName,
          parameter: parameter,
        );
      },
      zoneValues: {_resolutionKey: <Object>{}},
    );
  }

  static Future<BeanT>
      executarAsync<BeanT extends Object, ParameterT extends Object>({
    required ScopeFactory<BeanT> factory,
    required Object effectiveQualifierName,
    ParameterT? parameter,
  }) {
    return runZoned(
      () {
        return _getScopedAsync<BeanT, ParameterT>(
          factory: factory,
          effectiveQualifierName: effectiveQualifierName,
          parameter: parameter,
        );
      },
      zoneValues: {_resolutionKey: <Object>{}},
    );
  }
}
