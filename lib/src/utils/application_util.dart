import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/utils/dart_ddi_utils.dart';
import 'package:dart_ddi/src/utils/instance_factory_util.dart';
import 'package:dart_ddi/src/utils/interceptor_util.dart';

final class ApplicationUtils {
  static Future<BeanT>
      getAplicationAsync<BeanT extends Object, ParameterT extends Object>({
    required ScopeFactory<BeanT> factory,
    required Object effectiveQualifierName,
    ParameterT? parameter,
  }) async {
    late BeanT applicationClazz;

    if (factory.instanceHolder == null) {
      final execInstance = InstanceFactoryUtil.createAsync<BeanT, ParameterT>(
        builder: factory.builder!,
        parameter: parameter,
      );

      applicationClazz =
          execInstance is Future ? await execInstance : execInstance;

      applicationClazz =
          await InterceptorUtil.createAsync<BeanT>(factory, applicationClazz);

      applicationClazz = _applyApplication<BeanT>(factory, applicationClazz);

      if (applicationClazz is DDIModule) {
        applicationClazz.moduleQualifier = effectiveQualifierName;
      }

      if (applicationClazz is PostConstruct) {
        await applicationClazz.onPostConstruct();
      } else if (applicationClazz is Future<PostConstruct>) {
        await DartDDIUtils.runFutureOrPostConstruct(applicationClazz);
      }
    } else {
      applicationClazz = factory.instanceHolder!;
    }

    final exec = InterceptorUtil.getAsync<BeanT>(factory, applicationClazz);

    return exec is Future ? await exec : exec;
  }

  static BeanT getAplication<BeanT extends Object, ParameterT extends Object>({
    required ScopeFactory<BeanT> factory,
    required Object effectiveQualifierName,
    ParameterT? parameter,
  }) {
    late BeanT applicationClazz;

    if (factory.instanceHolder == null) {
      applicationClazz = InstanceFactoryUtil.create<BeanT, ParameterT>(
        builder: factory.builder!,
        parameter: parameter,
      );

      applicationClazz =
          InterceptorUtil.create<BeanT>(factory, applicationClazz);

      applicationClazz = _applyApplication<BeanT>(factory, applicationClazz);

      if (applicationClazz is DDIModule) {
        applicationClazz.moduleQualifier = effectiveQualifierName;
      }

      if (applicationClazz is PostConstruct) {
        applicationClazz.onPostConstruct();
      } else if (applicationClazz is Future<PostConstruct>) {
        DartDDIUtils.runFutureOrPostConstruct(applicationClazz);
      }
    } else {
      applicationClazz = factory.instanceHolder!;
    }

    return InterceptorUtil.get<BeanT>(factory, applicationClazz);
  }

  static BeanT _applyApplication<BeanT extends Object>(
    ScopeFactory<BeanT> factory,
    BeanT applicationClazz,
  ) {
    applicationClazz = DartDDIUtils.executarDecorators<BeanT>(
        applicationClazz, factory.decorators);

    factory.postConstruct?.call();

    factory.instanceHolder = applicationClazz;

    return applicationClazz;
  }
}
