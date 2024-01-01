import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../services/firebase/projects_firestore.dart';

class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({
    super.key,
    required this.project,
  });
  final ProjectsFirestore project;

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final navigator = Navigator.of(context);
    String? taskName;
    String? assignedTo;
    DateTime? deadLine;

    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'addTask',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ).tr(),
      content: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              onChanged: (newValue) {
                taskName = newValue;
              },
              decoration: InputDecoration(
                labelText: 'taskName'.tr(),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(8),
                ),
                disabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              onChanged: (newValue) {
                assignedTo = newValue;
              },
              decoration: InputDecoration(
                labelText: 'assignedTo'.tr(),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(8),
                ),
                disabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    deadLine = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(
                        const Duration(days: 365),
                      ),
                    );
                    setState(() {
                      deadLine;
                    });
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: const Text(
                    'selectDeadline',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ).tr(),
                ),
                Text(
                  deadLine != null ? DateFormat.yMd().format(deadLine!) : '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'cancel',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.red,
            ),
          ).tr(),
        ),
        ElevatedButton(
          onPressed: () async {
            formKey.currentState?.save();
            Map<dynamic, dynamic> task = {
              'taskName': taskName ?? '',
              'assignedTo': assignedTo ?? '',
              'deadLine': DateFormat.yMd().format(deadLine ?? DateTime.now()),
            };
            widget.project.projectData?.tasks?.add(task);
            await widget.project.updateProjectData(
              projectID: widget.project.projectData?.projectID,
              tasks: widget.project.projectData?.tasks,
            );
            await widget.project.loadProjectData(
                projectID: widget.project.projectData?.projectID);
            navigator.pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[700],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'add',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ).tr(),
        ),
      ],
    );
  }
}
