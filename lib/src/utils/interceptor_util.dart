import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';

final class InterceptorUtil {
  static BeanT create<BeanT extends Object>(
    ScopeFactory<BeanT> factory,
    BeanT applicationClazz,
  ) {
    if (factory.interceptors case final inter? when inter.isNotEmpty) {
      for (final interceptor in inter) {
        final instance =
            ddi.get(qualifier: interceptor) as DDIInterceptor<BeanT>;

        applicationClazz = instance.onCreate(applicationClazz) as BeanT;
      }
    }

    return applicationClazz;
  }

  static FutureOr<BeanT> createAsync<BeanT extends Object>(
    ScopeFactory<BeanT> factory,
    BeanT applicationClazz,
  ) async {
    if (factory.interceptors case final inter? when inter.isNotEmpty) {
      for (final interceptor in inter) {
        final instance =
            (await ddi.getAsync(qualifier: interceptor)) as DDIInterceptor;

        final exec = instance.onCreate(applicationClazz);

        applicationClazz = (exec is Future ? await exec : exec) as BeanT;
      }
    }

    return applicationClazz;
  }

  static BeanT get<BeanT extends Object>(
    ScopeFactory<BeanT> factory,
    BeanT applicationClazz,
  ) {
    if (factory.interceptors case final inter? when inter.isNotEmpty) {
      for (final interceptor in inter) {
        final instance = ddi.get(qualifier: interceptor) as DDIInterceptor;

        applicationClazz = instance.onGet(applicationClazz) as BeanT;
      }
    }

    return applicationClazz;
  }

  static FutureOr<BeanT> getAsync<BeanT extends Object>(
    ScopeFactory<BeanT> factory,
    BeanT applicationClazz,
  ) async {
    if (factory.interceptors case final inter? when inter.isNotEmpty) {
      for (final interceptor in inter) {
        final instance =
            (await ddi.getAsync(qualifier: interceptor)) as DDIInterceptor;

        final exec = instance.onGet(applicationClazz);

        applicationClazz = (exec is Future ? await exec : exec) as BeanT;
      }
    }

    return applicationClazz;
  }

  static FutureOr<void> disposeAsync<BeanT extends Object>(
    ScopeFactory<BeanT> factory,
    BeanT? applicationClazz,
  ) async {
    if (factory.interceptors case final inter? when inter.isNotEmpty) {
      for (final interceptor in inter) {
        final instance =
            (await ddi.getAsync(qualifier: interceptor)) as DDIInterceptor;

        final exec = instance.onDispose(applicationClazz);
        if (exec is Future) {
          await exec;
        }
      }
    }
  }
}
