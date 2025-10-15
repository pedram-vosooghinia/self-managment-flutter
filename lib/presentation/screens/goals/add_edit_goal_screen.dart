// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
// import '../../../data/models/goal_model.dart';
// import '../../providers/goal_provider.dart';
// import '../../providers/reminder_provider.dart';
// import '../../providers/alarm_sound_provider.dart';
// import '../../../data/models/reminder_model.dart';
// import '../alarm_sounds/alarm_sounds_screen.dart';

// class AddEditGoalScreen extends StatefulWidget {
//   final GoalModel? goal;

//   const AddEditGoalScreen({super.key, this.goal});

//   @override
//   State<AddEditGoalScreen> createState() => _AddEditGoalScreenState();
// }

// class _AddEditGoalScreenState extends State<AddEditGoalScreen> {
//   late TextEditingController _titleController;
//   late TextEditingController _descriptionController;

//   GoalType _goalType = GoalType.shortTerm;
//   DateTime? _targetDate;
//   DateTime? _reminderDateTime;
//   String? _alarmSoundId;

//   @override
//   void initState() {
//     super.initState();
//     _titleController = TextEditingController(text: widget.goal?.title ?? '');
//     _descriptionController = TextEditingController(
//       text: widget.goal?.description ?? '',
//     );

//     if (widget.goal != null) {
//       _goalType = widget.goal!.type;
//       _targetDate = widget.goal!.targetDate;
//       _reminderDateTime = widget.goal!.reminderDateTime;
//       _alarmSoundId = widget.goal!.alarmSoundId;
//     }
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isEditing = widget.goal != null;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(isEditing ? 'ویرایش هدف' : 'اضافه کردن هدف'),
//         actions: [
//           if (isEditing)
//             IconButton(
//               icon: const Icon(Icons.delete),
//               onPressed: () {
//                 _showDeleteDialog(context);
//               },
//             ),
//         ],
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           TextField(
//             controller: _titleController,
//             decoration: const InputDecoration(
//               labelText: 'عنوان',
//               border: OutlineInputBorder(),
//               prefixIcon: Icon(Icons.flag),
//             ),
//             textCapitalization: TextCapitalization.sentences,
//           ),
//           const SizedBox(height: 16),
//           TextField(
//             controller: _descriptionController,
//             decoration: const InputDecoration(
//               labelText: 'توضیحات (اختیاری)',
//               border: OutlineInputBorder(),
//               prefixIcon: Icon(Icons.description),
//             ),
//             maxLines: 2,
//             textCapitalization: TextCapitalization.sentences,
//           ),
//           const SizedBox(height: 16),
//           Card(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'نوع هدف',
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   SegmentedButton<GoalType>(
//                     segments: const [
//                       ButtonSegment(
//                         value: GoalType.shortTerm,
//                         label: Text('کوتاه مدت'),
//                         icon: Icon(Icons.calendar_today),
//                       ),
//                       ButtonSegment(
//                         value: GoalType.longTerm,
//                         label: Text('بلند مدت'),
//                         icon: Icon(Icons.calendar_month),
//                       ),
//                     ],
//                     selected: {_goalType},
//                     onSelectionChanged: (Set<GoalType> selected) {
//                       setState(() {
//                         _goalType = selected.first;
//                       });
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Card(
//             child: Column(
//               children: [
//                 ListTile(
//                   leading: const Icon(Icons.calendar_today),
//                   title: const Text('تاریخ مقصد'),
//                   subtitle: _targetDate != null
//                       ? Text(DateFormat('MMM dd, yyyy').format(_targetDate!))
//                       : const Text('تاریخ مقصد ندارد'),
//                   trailing: _targetDate != null
//                       ? IconButton(
//                           icon: const Icon(Icons.clear),
//                           onPressed: () {
//                             setState(() {
//                               _targetDate = null;
//                             });
//                           },
//                         )
//                       : null,
//                   onTap: _pickTargetDate,
//                 ),
//                 const Divider(height: 1),
//                 ListTile(
//                   leading: const Icon(Icons.access_time),
//                   title: const Text('یادآوری'),
//                   subtitle: _reminderDateTime != null
//                       ? Text(
//                           DateFormat(
//                             'MMM dd, yyyy - HH:mm',
//                           ).format(_reminderDateTime!),
//                         )
//                       : const Text('یادآوری ندارد'),
//                   trailing: _reminderDateTime != null
//                       ? IconButton(
//                           icon: const Icon(Icons.clear),
//                           onPressed: () {
//                             setState(() {
//                               _reminderDateTime = null;
//                               _alarmSoundId = null;
//                             });
//                           },
//                         )
//                       : null,
//                   onTap: _pickReminderDateTime,
//                 ),
//                 if (_reminderDateTime != null) ...[
//                   const Divider(height: 1),
//                   Consumer<AlarmSoundProvider>(
//                     builder: (context, alarmSoundProvider, child) {
//                       final selectedSound = _alarmSoundId != null
//                           ? alarmSoundProvider.getAlarmSoundById(_alarmSoundId!)
//                           : null;
//                       final soundName =
//                           selectedSound?.name ?? 'Select alarm sound';

//                       return ListTile(
//                         leading: const Icon(Icons.music_note),
//                         title: const Text('صدای آلارم'),
//                         subtitle: Text(soundName),
//                         trailing: const Icon(Icons.chevron_right),
//                         onTap: _selectAlarmSound,
//                       );
//                     },
//                   ),
//                 ],
//               ],
//             ),
//           ),
//           const SizedBox(height: 24),
//           FilledButton.icon(
//             onPressed: _saveGoal,
//             icon: const Icon(Icons.save),
//             label: Text(isEditing ? 'آپدیت' : 'اضافه کردن هدف'),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _pickTargetDate() async {
//     final date = await showDatePicker(
//       context: context,
//       initialDate: _targetDate ?? DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
//     );

//     if (date != null) {
//       setState(() {
//         _targetDate = date;
//       });
//     }
//   }

//   Future<void> _pickReminderDateTime() async {
//     final date = await showDatePicker(
//       context: context,
//       initialDate: _reminderDateTime ?? _targetDate ?? DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
//     );

//     if (date != null && mounted) {
//       final time = await showTimePicker(
//         context: context,
//         initialTime: TimeOfDay.fromDateTime(
//           _reminderDateTime ?? DateTime.now(),
//         ),
//       );

//       if (time != null) {
//         setState(() {
//           _reminderDateTime = DateTime(
//             date.year,
//             date.month,
//             date.day,
//             time.hour,
//             time.minute,
//           );
//         });
//       }
//     }
//   }

//   Future<void> _selectAlarmSound() async {
//     final alarmSoundProvider = context.read<AlarmSoundProvider>();
//     final alarmSounds = alarmSoundProvider.alarmSounds;

//     if (alarmSounds.isEmpty) {
//       // No alarm sounds available, navigate to alarm sounds screen
//       final result = await showDialog<bool>(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text('صدای آلارم ندارد'),
//           content: const Text(
//             'شما هیچ صدای آلارمی ندارید. آیا می‌خواهید یکی اضافه کنید؟',
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context, false),
//               child: const Text('انصراف'),
//             ),
//             FilledButton(
//               onPressed: () => Navigator.pop(context, true),
//               child: const Text('اضافه کردن صدای آلارم'),
//             ),
//           ],
//         ),
//       );

//       if (result == true) {
//         if (!mounted) return;
//         await Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => const AlarmSoundsScreen()),
//         );
//         if (!mounted) return;
//         // Reload alarm sounds after returning
//         alarmSoundProvider.loadAlarmSounds();
//       }
//       return;
//     }

//     // Show alarm sound picker
//     String? tempSelectedSound = _alarmSoundId;
//     final selectedSound = await showDialog<String>(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setState) => AlertDialog(
//           title: const Text('انتخاب صدای آلارم'),
//           content: SizedBox(
//             width: double.maxFinite,
//             child: ListView.builder(
//               shrinkWrap: true,
//               itemCount: alarmSounds.length,
//               itemBuilder: (context, index) {
//                 final sound = alarmSounds[index];

//                 final isSelected = sound.id == tempSelectedSound;
//                 return ListTile(
//                   leading: Icon(
//                     sound.isSystemSound
//                         ? Icons.notifications_active
//                         : Icons.music_note,
//                   ),
//                   title: Text(sound.name),
//                   subtitle: Text(
//                     sound.isSystemSound ? 'صدای سیستم' : 'صدای سفارشی',
//                   ),
//                   trailing: isSelected ? const Icon(Icons.check) : null,
//                   onTap: () {
//                     Navigator.pop(context, sound.id);
//                   },
//                 );
//               },
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('انصراف'),
//             ),
//             TextButton(
//               onPressed: () async {
//                 // Navigate to add alarm sound
//                 Navigator.pop(context);
//                 if (!context.mounted) return;
//                 await Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const AlarmSoundsScreen(),
//                   ),
//                 );
//               },
//               child: const Text('مدیریت صداهای آلارم'),
//             ),
//           ],
//         ),
//       ),
//     );

//     if (selectedSound != null) {
//       setState(() {
//         _alarmSoundId = selectedSound;
//       });
//     }
//   }

//   Future<void> _saveGoal() async {
//     if (_titleController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('لطفا عنوانی وارد کنید')));
//       return;
//     }

//     final goalProvider = context.read<GoalProvider>();
//     final reminderProvider = context.read<ReminderProvider>();

//     if (widget.goal != null) {
//       // Update existing goal
//       final updatedGoal = widget.goal!.copyWith(
//         title: _titleController.text.trim(),
//         description: _descriptionController.text.trim().isEmpty
//             ? null
//             : _descriptionController.text.trim(),
//         type: _goalType,
//         targetDate: _targetDate,
//         reminderDateTime: _reminderDateTime,
//         alarmSoundId: _alarmSoundId,
//       );
//       goalProvider.updateGoal(updatedGoal);

//       // حذف یادآورهای قبلی
//       final oldReminders = reminderProvider.getRemindersByItemId(
//         updatedGoal.id,
//       );
//       for (var reminder in oldReminders) {
//         if (!reminder.isRecurring) {
//           await reminderProvider.deleteReminder(reminder.id);
//         }
//       }

//       // اضافه کردن یادآور جدید در صورت نیاز
//       if (_reminderDateTime != null && mounted) {
//         // Get the alarm sound file path from the ID
//         final alarmSoundProvider = context.read<AlarmSoundProvider>();
//         final alarmSoundPath = _alarmSoundId != null
//             ? alarmSoundProvider.getAlarmSoundById(_alarmSoundId!)?.filePath
//             : null;

//         await reminderProvider.addReminder(
//           itemId: updatedGoal.id,
//           type: ReminderType.goal,
//           scheduledDateTime: _reminderDateTime!,
//           title: 'یادآوری هدف: ${updatedGoal.title}',
//           body: updatedGoal.description,
//           alarmSoundPath: alarmSoundPath,
//         );
//       }
//     } else {
//       // Create new goal
//       await goalProvider.addGoal(
//         title: _titleController.text.trim(),
//         description: _descriptionController.text.trim().isEmpty
//             ? null
//             : _descriptionController.text.trim(),
//         type: _goalType,
//         targetDate: _targetDate,
//         reminderDateTime: _reminderDateTime,
//         alarmSoundId: _alarmSoundId,
//       );

//       // اضافه کردن یادآور برای هدف جدید
//       if (_reminderDateTime != null && mounted) {
//         // Get the alarm sound file path from the ID
//         final alarmSoundProvider = context.read<AlarmSoundProvider>();
//         final alarmSoundPath = _alarmSoundId != null
//             ? alarmSoundProvider.getAlarmSoundById(_alarmSoundId!)?.filePath
//             : null;

//         // پیدا کردن goal که الان اضافه شده
//         goalProvider.loadGoals();
//         final goals = goalProvider.goals;
//         final newGoal = goals.firstWhere(
//           (g) => g.title == _titleController.text.trim(),
//           orElse: () => goals.last,
//         );

//         await reminderProvider.addReminder(
//           itemId: newGoal.id,
//           type: ReminderType.goal,
//           scheduledDateTime: _reminderDateTime!,
//           title: 'یادآوری هدف: ${newGoal.title}',
//           body: newGoal.description,
//           alarmSoundPath: alarmSoundPath,
//         );
//       }
//     }

//     if (mounted) Navigator.pop(context);
//   }

//   void _showDeleteDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('حذف هدف'),
//         content: const Text(
//           'آیا مطمئن هستید که می‌خواهید این هدف را حذف کنید؟',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('انصراف'),
//           ),
//           FilledButton(
//             onPressed: () {
//               context.read<GoalProvider>().deleteGoal(widget.goal!.id);
//               Navigator.pop(context); // Close dialog
//               Navigator.pop(context); // Close screen
//             },
//             child: const Text('حذف'),
//           ),
//         ],
//       ),
//     );
//   }
// }
