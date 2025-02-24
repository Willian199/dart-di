import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';

import 'g.dart';

class WithDestroyInterceptor extends DDIInterceptor<G> {
  @override
  Future<G> onGet(G instance) async {
    await ddi.destroy<G>();
    return super.onGet(instance);
  }
}
