import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:intl/intl.dart';
import '../../providers/alarm_sound_provider.dart';
import '../../../data/models/alarm_sound_model.dart';

class AlarmSoundsScreen extends StatefulWidget {
  const AlarmSoundsScreen({super.key});

  @override
  State<AlarmSoundsScreen> createState() => _AlarmSoundsScreenState();
}

class _AlarmSoundsScreenState extends State<AlarmSoundsScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlayingId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AlarmSoundProvider>().loadAlarmSounds();
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('صداهای آلارم')),
      body: Consumer<AlarmSoundProvider>(
        builder: (context, provider, child) {
          if (provider.alarmSounds.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.music_off, size: 64, color: Colors.blue),
                  const SizedBox(height: 16),
                  Text(
                    'هیچ صدای آلارمی ندارید',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('اولین صدای آلارم خود را اضافه کنید'),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _showAddSoundDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('اضافه کردن صدای آلارم'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.alarmSounds.length,
            itemBuilder: (context, index) {
              final sound = provider.alarmSounds[index];
              final isPlaying = _currentlyPlayingId == sound.id;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(
                      sound.isSystemSound
                          ? Icons.notifications_active
                          : Icons.music_note,
                    ),
                  ),
                  title: Text(sound.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sound.isSystemSound ? 'صدای سیستم' : 'صدای سفارشی',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        'اضافه شده ${DateFormat('MMM dd, yyyy').format(sound.createdAt)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
                        onPressed: () => _togglePlaySound(sound),
                      ),
                      PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 8),
                                Text('ویرایش'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete),
                                SizedBox(width: 8),
                                Text('حذف'),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditSoundDialog(sound);
                          } else if (value == 'delete') {
                            _showDeleteDialog(sound);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSoundDialog,
        icon: const Icon(Icons.add),
        label: const Text('اضافه کردن صدای آلارم'),
      ),
    );
  }

  Future<void> _togglePlaySound(AlarmSoundModel sound) async {
    if (_currentlyPlayingId == sound.id) {
      // Stop playing
      await _audioPlayer.stop();
      setState(() {
        _currentlyPlayingId = null;
      });
    } else {
      // Play sound
      await _audioPlayer.stop();

      if (sound.filePath == 'default' || sound.isSystemSound) {
        // For system sounds, we can't preview them easily
        // Show a message instead
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('صداهای سیستم زمانی که آلارم فعال شود پخش می‌شوند'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Play custom sound from file
        try {
          await _audioPlayer.play(DeviceFileSource(sound.filePath));
          setState(() {
            _currentlyPlayingId = sound.id;
          });

          // Auto-stop after playing
          _audioPlayer.onPlayerComplete.listen((_) {
            if (mounted) {
              setState(() {
                _currentlyPlayingId = null;
              });
            }
          });
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error playing sound: $e')));
          }
        }
      }
    }
  }

  void _showAddSoundDialog() {
    final nameController = TextEditingController();
    bool isSystemSound = false;
    String? selectedFilePath;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('اضافه کردن صدای آلارم'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'نام صدای آلارم',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.label),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  value: isSystemSound,
                  onChanged: (value) {
                    setState(() {
                      isSystemSound = value ?? false;
                      if (isSystemSound) {
                        selectedFilePath = 'default';
                      } else {
                        selectedFilePath = null;
                      }
                    });
                  },
                  title: const Text('استفاده از صدای سیستم'),
                  subtitle: const Text('استفاده از صدای سیستم دستگاه'),
                ),
                if (!isSystemSound) ...[
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.audio,
                        allowMultiple: false,
                      );

                      if (result != null && result.files.single.path != null) {
                        setState(() {
                          selectedFilePath = result.files.single.path;
                        });
                      }
                    },
                    icon: const Icon(Icons.file_upload),
                    label: Text(
                      selectedFilePath != null
                          ? 'فایل انتخاب شده'
                          : 'انتخاب فایل صوتی',
                    ),
                  ),
                  if (selectedFilePath != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      selectedFilePath!.split('/').last,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('انصراف'),
            ),
            FilledButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('لطفا نامی وارد کنید')),
                  );
                  return;
                }

                if (!isSystemSound && selectedFilePath == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'لطفا یک فایل صوتی انتخاب کنید یا از صدای سیستم استفاده کنید',
                      ),
                    ),
                  );
                  return;
                }

                context.read<AlarmSoundProvider>().addAlarmSound(
                  name: nameController.text.trim(),
                  filePath: selectedFilePath ?? 'default',
                  isSystemSound: isSystemSound,
                );

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('صدای آلارم اضافه شد')),
                );
              },
              child: const Text('اضافه کردن'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSoundDialog(AlarmSoundModel sound) {
    final nameController = TextEditingController(text: sound.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ویرایش صدای آلارم'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'نام صدای آلارم',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.label),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('انصراف'),
          ),
          FilledButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a name')),
                );
                return;
              }

              final updatedSound = sound.copyWith(
                name: nameController.text.trim(),
              );

              context.read<AlarmSoundProvider>().updateAlarmSound(updatedSound);

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Alarm sound updated')),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(AlarmSoundModel sound) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Alarm Sound'),
        content: Text('Are you sure you want to delete "${sound.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<AlarmSoundProvider>().deleteAlarmSound(sound.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Alarm sound deleted')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
