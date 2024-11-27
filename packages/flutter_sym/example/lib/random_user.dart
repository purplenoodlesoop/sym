// ignore_for_file: body_might_complete_normally_nullable

import 'package:sym/sym.dart';

import 'requests.dart';

enum Gender {
  female,
  male,
}

final randomUser = Module(($) {
  final requests$ = $.use(requests);
  final control = (
    fetch: $.trigger<()>(),
    keepUpdated: $.signal(($) => true),
    gender: $.signal(($) => Gender.female),
  );
  final isLoading = $.signal(($) => false);
  final (get: getUser, set: setUser) = $.signal(($) => 'No user yet');
  final error = $.trigger<String>();
  final lastFetchedGender$ = $.store<Gender?>(($) {
    $.on(
      getUser,
      (current) => $.use(control.gender.get),
    );
  });
  $
    ..on($.self.init, ($, _) {
      control.fetch($);
    })
    ..on(control.gender.get, ($, _) {
      if ($.use(control.keepUpdated.get)) control.fetch($);
    })
    ..on(control.keepUpdated.get, ($, keepUpdated) {
      final dirty = $.use(control.gender.get) != $.use(lastFetchedGender$);
      if (keepUpdated && dirty) control.fetch($);
    })
    ..on(control.fetch, ($, event) async {
      isLoading.set($, true);
      try {
        final response = await $.use(requests$).get(
              Uri.https(
                'randomuser.me',
                '/api',
                {'gender': $.use(control.gender.get).name},
              ),
            );
        setUser($, response['results'][0]['name']['first']! as String);
      } on Object catch (e) {
        error($, e.toString());
      } finally {
        isLoading.set($, false);
      }
    });

  return (
    control: control,
    isLoading: isLoading.get,
    user: getUser,
    error: error,
  );
});
