import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_destroyed.dart';
import 'package:dart_ddi/src/typedef/typedef.dart';
import 'package:dart_ddi/src/utils/interceptor_util.dart';

final class DartDDIUtils {
  static BeanT executarDecorators<BeanT extends Object>(
    BeanT clazz,
    ListDecorator<BeanT>? decorators,
  ) {
    if (decorators != null) {
      for (final decorator in decorators) {
        clazz = decorator(clazz);
      }
    }

    return clazz;
  }

  static Future<void> runFutureOrPostConstruct(
      Future<PostConstruct> register) async {
    final PostConstruct clazz = await register;

    return clazz.onPostConstruct();
  }

  static BeanT getSingleton<BeanT extends Object>({
    required ScopeFactory<BeanT> factory,
    required Object effectiveQualifierName,
  }) {
    if (factory.instanceHolder case final clazz?) {
      return InterceptorUtil.get<BeanT>(factory, clazz);
    }

    throw BeanDestroyedException(effectiveQualifierName.toString());
  }

  static FutureOr<BeanT> getSingletonAsync<BeanT extends Object>({
    required ScopeFactory<BeanT> factory,
    required Object effectiveQualifierName,
  }) async {
    if (factory.instanceHolder case final clazz?) {
      final exec = InterceptorUtil.getAsync<BeanT>(factory, clazz);

      return exec is Future ? await exec : exec;
    }

    throw BeanDestroyedException(effectiveQualifierName.toString());
  }
}
