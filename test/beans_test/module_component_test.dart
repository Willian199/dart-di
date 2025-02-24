import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:dart_ddi/src/exception/module_not_found.dart';
import 'package:test/test.dart';

import '../clazz_samples/child_module.dart';
import '../clazz_samples/component.dart';
import '../clazz_samples/parent_module.dart';

void moduleComponentTest() {
  group('DDI Modules Component Basic Tests', () {
    test('Register a Component Module', () {
      DDI.instance.registerSingleton(ParentModule.new);

      final Component parent = DDI.instance.getComponent(module: ParentModule);
      expect(parent.value, same('parent'));

      expect(() => DDI.instance.getComponent(module: ChildModule),
          throwsA(isA<ModuleNotFoundException>()));

      // Load the subModule
      DDI.instance.get<ChildModule>();

      final Component child = DDI.instance.getComponent(module: ChildModule);

      expect(false, identical(parent, child));
      expect(child.value, same('child'));
      expect(false, identical(parent.value, child.value));

      expect(child,
          same(DDI.instance.getComponent<Component>(module: ChildModule)));

      DDI.instance.destroy<ParentModule>();

      expect(() => DDI.instance.getComponent<Component>(module: ChildModule),
          throwsA(isA<ModuleNotFoundException>()));
      expect(() => DDI.instance.getComponent<Component>(module: ParentModule),
          throwsA(isA<ModuleNotFoundException>()));
      expect(() => DDI.instance.get<ChildModule>(),
          throwsA(isA<BeanNotFoundException>()));
      expect(() => DDI.instance.get<ParentModule>(),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Register a Component Module with Qualifier', () {
      DDI.instance.registerSingleton(ParentModule.new, qualifier: 'first');

      final Component parent = DDI.instance.getComponent(module: 'first');
      expect(parent.value, same('parent'));

      expect(() => DDI.instance.getComponent(module: ChildModule),
          throwsA(isA<ModuleNotFoundException>()));

      // Load the subModule
      DDI.instance.get<ChildModule>();

      final Component child = DDI.instance.getComponent(module: ChildModule);

      expect(false, identical(parent, child));
      expect(child.value, same('child'));
      expect(false, identical(parent.value, child.value));

      expect(child,
          same(DDI.instance.getComponent<Component>(module: ChildModule)));

      DDI.instance.destroy(qualifier: 'first');

      expect(() => DDI.instance.getComponent<Component>(module: ChildModule),
          throwsA(isA<ModuleNotFoundException>()));
      expect(() => DDI.instance.getComponent<Component>(module: 'first'),
          throwsA(isA<ModuleNotFoundException>()));
      expect(() => DDI.instance.get<ChildModule>(),
          throwsA(isA<BeanNotFoundException>()));
      expect(() => DDI.instance.get(qualifier: 'first'),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Try to register a Component without Module', () {
      expect(
          () => ddi.registerComponent(
                clazzRegister: () => const Component('parent'),
                moduleQualifier: ParentModule,
              ),
          throwsA(isA<ModuleNotFoundException>()));
    });
  });
}
