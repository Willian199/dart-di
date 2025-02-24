import 'beans_test/add_decoratos_factory_test.dart';
import 'beans_test/add_decoratos_test.dart';
import 'beans_test/application_factory_future_test.dart';
import 'beans_test/application_factory_test.dart';
import 'beans_test/application_future_test.dart';
import 'beans_test/application_test.dart';
import 'beans_test/circular_injection_test.dart';
import 'beans_test/dependent_factory_future_test.dart';
import 'beans_test/dependent_factory_test.dart';
import 'beans_test/dependent_future_test.dart';
import 'beans_test/dependent_test.dart';
import 'beans_test/dispose_destroy_all_session_test.dart';
import 'beans_test/factory_circular_injection_test.dart';
import 'beans_test/factory_interceptor_test.dart';
import 'beans_test/future_add_decoratos_test.dart';
import 'beans_test/future_circular_injection_test.dart';
import 'beans_test/future_post_construct_pre_destroy_test.dart';
import 'beans_test/get_by_future_type_test.dart';
import 'beans_test/get_by_type_test.dart';
import 'beans_test/interceptor_cases_test.dart';
import 'beans_test/interceptor_feature_test.dart';
import 'beans_test/interceptor_test.dart';
import 'beans_test/module_application_test.dart';
import 'beans_test/module_component_test.dart';
import 'beans_test/module_dependent_test.dart';
import 'beans_test/module_factory_test.dart';
import 'beans_test/module_object_test.dart';
import 'beans_test/module_session_test.dart';
import 'beans_test/module_singleton_test.dart';
import 'beans_test/object_future_test.dart';
import 'beans_test/object_test.dart';
import 'beans_test/post_construct_pre_destroy_test.dart';
import 'beans_test/register_if_test.dart';
import 'beans_test/session_future_test.dart';
import 'beans_test/session_test.dart';
import 'beans_test/singleton_factory_future_test.dart';
import 'beans_test/singleton_factory_test.dart';
import 'beans_test/singleton_future_test.dart';
import 'beans_test/singleton_test.dart';

void main() {
  //Basic Tests, with consists in register, get, dispose, remove
  singleton();
  application();
  session();
  dependent();
  object();

  //Factories
  singletonFactory();
  singletonFactoryFuture();
  applicationFactory();
  applicationFactoryFuture();
  dependentFactory();
  dependentFactoryFuture();

  runByType();
  disposeDestroyAllSession();
  canRegister();
  postConstructPreDestroyTest();

  //Futures
  applicationFuture();
  singletonFuture();
  sessionFuture();
  dependentFuture();
  objectFuture();

  runByFutureType();
  canRegister();
  futurePostConstructPreDestroyTest();

  //Decorators
  addDecorator();
  futureAddDecorator();
  addDecoratorFactory();

  //Interceptor
  interceptor();
  factoryInterceptor();
  interceptorFeatures();
  intecertorCases();

  //CircularDetection
  circularDetection();
  futureCircularDetection();
  factoryCircularDetection();

  //Modules
  moduleSingletonTest();
  moduleApplicationTest();
  moduleDependentTest();
  moduleObjectTest();
  moduleSessionTest();
  moduleComponentTest();
  moduleFactoryApplicationTest();
}
