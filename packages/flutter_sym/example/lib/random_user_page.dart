import 'random_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sym/flutter_sym.dart';

class RandomUserPage extends StatelessWidget {
  const RandomUserPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final $ = context.$;
    final m = $.use(randomUser);
    final control = m.control;
    final user = $.use(m.user);
    final isLoading = $.use(m.isLoading);

    return Center(
      child: Column(
        children: [
          Row(
            children: [
              Column(
                children: [
                  const Text('Keep updated'),
                  Checkbox(
                    value: $.use(control.keepUpdated.get),
                    onChanged: isLoading
                        ? null
                        : (value) => control.keepUpdated.set($, value!),
                  ),
                ],
              ),
              SegmentedButton<Gender>(
                segments: Gender.values
                    .map((gender) =>
                        ButtonSegment(value: gender, label: Text(gender.name)))
                    .toList(),
                selected: {
                  $.use(control.gender.get),
                },
                onSelectionChanged: isLoading
                    ? null
                    : (genders) => control.gender.set($, genders.first),
              ),
            ],
          ),
          if (isLoading) ...[
            const SizedBox.square(
              dimension: 32,
              child: CircularProgressIndicator(),
            ),
          ] else ...[
            Text('User: $user'),
          ],
          ElevatedButton(
            onPressed: isLoading ? null : () => control.fetch($),
            child: const Text('Fetch user'),
          ),
        ],
      ),
    );
  }
}
