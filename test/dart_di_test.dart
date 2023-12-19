import 'group_test/application_test.dart';
import 'group_test/dependent_test.dart';
import 'group_test/session_test.dart';
import 'group_test/singleton_test.dart';
import 'group_test/widget_test.dart';

void main() {
  //Basic Tests, with consists in register, get, dispose, remove
  singleton();
  application();
  session();
  dependent();
  widget();
}
