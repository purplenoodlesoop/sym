// final auth = Module(($) {
//   final api = $.api(($) {
//     return (
//       overview: $.query(($) {/* implementation */}),
//       signUp: $.mutation(($, (String email, String password) creds) {
//         /* implementation */
//       }),
//     );
//   });
//   final form = $.form(($) {
//     final password = $.text(($, value) {
//       if (value.isEmpty) return 'Password is required';
//       if (value.length < 8) return 'Password is too short';
//     });

//     return (
//       email: $.text(($, value) {
//         if (value.isEmpty) return 'Email is required';
//         if (!value.contains('@')) return 'Email is invalid';
//       }),
//       password: password,
//       confirmPassword: $.text(($, value) {
//         if (value != $.use(password)) return 'Passwords do not match';
//       }),
//       acceptTerms: $.bool(($, value) {
//         if (!value) return 'You must accept terms';
//       }),
//     );
//   });
//   final (:overview, :signUp) = api.methods;

//   $
//     ..on($.self.init, overview.run)
//     ..on(signUp.success, overview.run)
//     ..on(
//       form.success,
//       ($) => api.signUp($, (
//         $.use(form.fields.email),
//         $.use(form.fields.password),
//       )),
//     );

//   return (
//     overview: overview.get,
//     refresh: overview.run,
//     isLoading: api.isLoading,
//     form: form,
//   );
// });
