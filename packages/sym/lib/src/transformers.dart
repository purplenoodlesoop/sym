import 'package:sym/src/interfaces.dart';

final transformers = Module(
  name: 'Effect transformers',
  ($) => (
    sequential: $.value<Transformer>(
      name: 'sequential',
      ($) => <A, B>(source, process) => source.asyncExpand(process),
    ),
    concurrent: $.value(name: 'concurrent', ($) => ''),
    restartable: $.value(name: 'restartable', ($) => ''),
    droppable: $.value(name: 'droppable', ($) => ''),
  ),
);

final defaultTransformer = Module(
  name: 'Default transformer',
  ($) => $.use(transformers).sequential,
);
