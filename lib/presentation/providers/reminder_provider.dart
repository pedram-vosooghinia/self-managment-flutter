import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/reminder_model.dart';
import '../../data/repositories/reminder_repository.dart';

class ReminderProvider extends ChangeNotifier {
  final ReminderRepository _reminderRepository;

  ReminderProvider({required ReminderRepository reminderRepository})
      : _reminderRepository = reminderRepository;

  List<ReminderModel> _reminders = [];
  bool _isLoading = false;

  List<ReminderModel> get reminders => _reminders;
  bool get isLoading => _isLoading;

  List<ReminderModel> get activeReminders =>
      _reminderRepository.getActiveReminders();
  List<ReminderModel> get upcomingReminders =>
      _reminderRepository.getUpcomingReminders();

  void loadReminders() {
    _isLoading = true;
    notifyListeners();

    _reminders = _reminderRepository.getAllReminders();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addReminder({
    required String itemId,
    required ReminderType type,
    required DateTime scheduledDateTime,
    required String title,
    String? body,
    String? alarmSoundPath,
  }) async {
    final reminder = ReminderModel(
      id: const Uuid().v4(),
      itemId: itemId,
      type: type,
      scheduledDateTime: scheduledDateTime,
      notificationId: DateTime.now().millisecondsSinceEpoch % 100000,
      title: title,
      body: body,
      alarmSoundPath: alarmSoundPath,
    );

    await _reminderRepository.addReminder(reminder);
    loadReminders();
  }

  Future<void> updateReminder(ReminderModel reminder) async {
    await _reminderRepository.updateReminder(reminder);
    loadReminders();
  }

  Future<void> toggleReminderActive(String id) async {
    await _reminderRepository.toggleReminderActive(id);
    loadReminders();
  }

  Future<void> deleteReminder(String id) async {
    await _reminderRepository.deleteReminder(id);
    loadReminders();
  }

  List<ReminderModel> getRemindersByItemId(String itemId) {
    return _reminderRepository.getRemindersByItemId(itemId);
  }
}

