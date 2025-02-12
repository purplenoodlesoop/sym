import 'random_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sym/flutter_sym.dart';

class RandomUserPage extends SymWidget {
  const RandomUserPage({
    super.key,
  });

  @override
  Widget build(SymBuildContext context) {
    final m = context.use(randomUser);
    final control = m.control;
    final user = context.use(m.user);
    final isLoading = context.use(m.isLoading);

    return Center(
      child: Column(
        children: [
          Row(
            children: [
              Column(
                children: [
                  const Text('Keep updated'),
                  Checkbox(
                    value: context.use(control.keepUpdated.get),
                    onChanged: isLoading
                        ? null
                        : (value) => control.keepUpdated.set(context, value!),
                  ),
                ],
              ),
              SegmentedButton<Gender>(
                segments: Gender.values
                    .map((gender) =>
                        ButtonSegment(value: gender, label: Text(gender.name)))
                    .toList(),
                selected: {
                  context.use(control.gender.get),
                },
                onSelectionChanged: isLoading
                    ? null
                    : (genders) => control.gender.set(context, genders.first),
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
            onPressed: isLoading ? null : () => control.fetch(context),
            child: const Text('Fetch user'),
          ),
        ],
      ),
    );
  }
}
