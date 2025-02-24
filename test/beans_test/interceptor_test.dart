import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:test/test.dart';

import '../clazz_samples/d.dart';
import '../clazz_samples/e.dart';
import '../clazz_samples/f.dart';
import '../clazz_samples/g.dart';
import '../clazz_samples/h.dart';
import '../clazz_samples/i.dart';
import '../clazz_samples/j.dart';
import '../clazz_samples/k.dart';

/*extension PI0<B extends Object, InterceptorT extends DDIInterceptor<B>> on DDIInterceptor Function<B extends Object>() {
  List<Type> get parameters => [];
  Type get returnType => InterceptorT;
  CustomBuilder<InterceptorT> get builder => CustomBuilder<InterceptorT>(
        producer: this,
        parametersType: parameters,
        returnType: returnType,
        isFuture: this is Future<Object> Function(),
      );
}*/

void interceptor() {
  group('DDI Interceptor Tests', () {
    test('ADD Interceptor to a Singleton bean', () {
      ddi.register(
        factory: ScopeFactory.singleton(
          builder: const CustomBuilder<J>(
            producer: J.new,
            parametersType: [],
            returnType: J,
            isFuture: false,
          ),
        ),
      );

      ///Where is Singleton, should the register in the correct order
      DDI.instance.registerSingleton<G>(() => H(), interceptors: {J});

      final G instance = DDI.instance.get<G>();

      expect(instance.area(), 20);
      expect(instance is I, true);

      DDI.instance.destroy<G>();
      ddi.destroy<J>();

      expect(
          () => DDI.instance.get<G>(), throwsA(isA<BeanNotFoundException>()));
      expect(DDI.instance.isRegistered<J>(), false);
    });

    test('ADD Interceptor to a Application bean', () {
      ddi.register<J<G>>(
        factory: ScopeFactory.application(
          builder: J<G>.new.builder,
        ),
      );
      DDI.instance.registerApplication<G>(() => H(), interceptors: {J<G>});

      final G instance = DDI.instance.get<G>();

      expect(instance.area(), 20);
      expect(instance is I, true);

      DDI.instance.destroy<G>();
      ddi.destroy<J>();

      expect(
          () => DDI.instance.get<G>(), throwsA(isA<BeanNotFoundException>()));
      expect(DDI.instance.isRegistered<J>(), false);
    });

    test('ADD Interceptor to a Application bean with qualifier', () {
      ddi.register<J>(
        factory: ScopeFactory.application(
          builder: J<G>.new.builder,
        ),
      );
      DDI.instance.registerApplication<G>(() => H(),
          qualifier: 'qualifier', interceptors: {J});

      final G instance = DDI.instance.get<G>(qualifier: 'qualifier');

      expect(instance.area(), 20);
      expect(instance is I, true);

      DDI.instance.destroy<G>(qualifier: 'qualifier');
      ddi.destroy<J>();

      expect(() => DDI.instance.get<G>(qualifier: 'qualifier'),
          throwsA(isA<BeanNotFoundException>()));
      expect(DDI.instance.isRegistered<J>(), false);
    });

    test('ADD Interceptor to a Dependent bean', () {
      ddi.register<J>(
        factory: ScopeFactory.dependent(
          builder: J<G>.new.builder,
        ),
      );
      DDI.instance.registerDependent<G>(() => H(), interceptors: {J});

      final G instance = DDI.instance.get<G>();

      expect(instance.area(), 20);
      expect(instance is I, true);

      DDI.instance.destroy<G>();
      ddi.destroy<J>();

      expect(
          () => DDI.instance.get<G>(), throwsA(isA<BeanNotFoundException>()));
      expect(DDI.instance.isRegistered<J>(), false);
    });

    test('ADD Interceptor to a Session bean', () {
      ddi.register<J>(
        factory: ScopeFactory.session(
          builder: J<G>.new.builder,
        ),
      );
      DDI.instance.registerSession<G>(() => H(), interceptors: {J});

      final G instance = DDI.instance.get<G>();

      expect(instance.area(), 20);
      expect(instance is I, true);

      DDI.instance.destroy<G>();
      ddi.destroy<J>();

      expect(
          () => DDI.instance.get<G>(), throwsA(isA<BeanNotFoundException>()));
      expect(DDI.instance.isRegistered<J>(), false);
    });

    test('ADD Interceptor after registered a Application bean', () {
      ddi.register<J>(
        factory: ScopeFactory.application(
          builder: J<G>.new.builder,
        ),
      );
      DDI.instance.registerApplication<G>(() => H());

      final G instance = DDI.instance.get<G>();

      expect(instance.area(), 10);
      expect(instance is H, true);

      DDI.instance.dispose<G>();

      DDI.instance.addInterceptor<G>({J});

      final G instance2 = DDI.instance.get<G>();

      expect(instance2 is I, true);
      expect(instance2.area(), 20);

      DDI.instance.destroy<G>();
      ddi.destroy<J>();

      expect(
          () => DDI.instance.get<G>(), throwsA(isA<BeanNotFoundException>()));
      expect(DDI.instance.isRegistered<J>(), false);
    });

    test('ADD Decorators and Interceptor to a Singleton bean', () {
      ddi.register<K>(
        factory: ScopeFactory.singleton(
          builder: K.new.builder,
        ),
      );

      ///Where is Singleton, should the register in the correct order
      DDI.instance.registerSingleton(
        () => D(),
        decorators: [
          (D instance) => E(instance),
          (D instance) => F(instance),
        ],
        interceptors: {K},
      );

      final instance1 = DDI.instance.get<D>();

      expect(instance1.value, 'bcconsdfghiGET');

      DDI.instance.addDecorator<D>([
        (instance) => E(instance),
      ]);

      final instance2 = DDI.instance.get<D>();

      // Be aware about this behavior. Being apply the `get` everytime
      expect(instance2.value, 'bcconsdfghGETdefGET');
      expect(identical(instance1, instance2), false);

      DDI.instance.destroy<D>();
      ddi.destroy<K>();

      expect(DDI.instance.isRegistered<D>(), false);
      expect(DDI.instance.isRegistered<J>(), false);
    });

    test('ADD Interceptor to a Bean not registered', () {
      expect(() => ddi.addInterceptor<D>({}),
          throwsA(isA<BeanNotFoundException>()));
    });
  });
}
