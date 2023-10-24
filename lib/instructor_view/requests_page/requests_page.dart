import 'package:flutter/material.dart';

class RequestsPage extends StatelessWidget {
  const RequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (BuildContext context, index) {
        return Column(
          children: [
            ListTile(
              leading: const Icon(Icons.groups),
              title: Text('Team ${index + 1}'),
            ),
            const Divider(
              thickness: 0.8,
            )
          ],
        );
      },
    );
  }
}
