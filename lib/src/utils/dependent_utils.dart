import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/utils/dart_ddi_utils.dart';
import 'package:dart_ddi/src/utils/instance_factory_util.dart';
import 'package:dart_ddi/src/utils/interceptor_util.dart';

final class DependentUtils {
  static BeanT getDependent<BeanT extends Object, ParameterT extends Object>({
    required ScopeFactory<BeanT> factory,
    required Object effectiveQualifierName,
    ParameterT? parameter,
  }) {
    BeanT dependentClazz = InstanceFactoryUtil.create<BeanT, ParameterT>(
      builder: factory.builder!,
      parameter: parameter,
    );

    dependentClazz = InterceptorUtil.create<BeanT>(factory, dependentClazz);

    dependentClazz = _applyDependent<BeanT>(factory, dependentClazz);

    if (dependentClazz is DDIModule) {
      dependentClazz.moduleQualifier = effectiveQualifierName;
    }

    if (dependentClazz is PostConstruct) {
      dependentClazz.onPostConstruct();
    } else if (dependentClazz is Future<PostConstruct>) {
      DartDDIUtils.runFutureOrPostConstruct(dependentClazz);
    }

    return InterceptorUtil.get<BeanT>(factory, dependentClazz);
  }

  static Future<BeanT>
      getDependentAsync<BeanT extends Object, ParameterT extends Object>({
    required ScopeFactory<BeanT> factory,
    required Object effectiveQualifierName,
    ParameterT? parameter,
  }) async {
    BeanT dependentClazz =
        await InstanceFactoryUtil.createAsync<BeanT, ParameterT>(
      builder: factory.builder!,
      parameter: parameter,
    );

    dependentClazz =
        await InterceptorUtil.createAsync<BeanT>(factory, dependentClazz);

    dependentClazz = _applyDependent<BeanT>(factory, dependentClazz);

    if (dependentClazz is DDIModule) {
      dependentClazz.moduleQualifier = effectiveQualifierName;
    }

    if (dependentClazz is PostConstruct) {
      await dependentClazz.onPostConstruct();
    } else if (dependentClazz is Future<PostConstruct>) {
      await DartDDIUtils.runFutureOrPostConstruct(dependentClazz);
    }

    return InterceptorUtil.getAsync<BeanT>(factory, dependentClazz);
  }

  static BeanT _applyDependent<BeanT extends Object>(
    ScopeFactory<BeanT> factory,
    BeanT dependentClazz,
  ) {
    assert(
        dependentClazz is! PreDispose || dependentClazz is! Future<PreDispose>,
        'Dependent instances dont support PreDispose. Use Interceptors instead.');
    assert(
        dependentClazz is! PreDestroy || dependentClazz is! Future<PreDestroy>,
        'Dependent instances dont support PreDestroy. Use Interceptors instead.');

    dependentClazz = DartDDIUtils.executarDecorators<BeanT>(
        dependentClazz, factory.decorators);

    factory.postConstruct?.call();

    return dependentClazz;
  }
}
