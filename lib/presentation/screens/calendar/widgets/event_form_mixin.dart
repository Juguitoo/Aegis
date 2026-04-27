import 'package:aegis/core/providers/repository_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:aegis/data/local/database/app_database.dart';

mixin EventFormMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  Event? get initialEvent;

  final titleController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool isAllDay = false;
  DateTime? selectedNotificationDate;

  @override
  void initState() {
    super.initState();
    _initForm();
  }

  void _initForm() {
    if (initialEvent != null) {
      titleController.text = initialEvent!.title;
      isAllDay = initialEvent!.isAllDay;
      selectedDate = initialEvent!.date;
      selectedTime = TimeOfDay.fromDateTime(initialEvent!.date);
      selectedNotificationDate = initialEvent!.notificationAt;
    } else {
      selectedDate = DateTime.now();
      selectedTime = TimeOfDay.now();
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? const Color(0xFFDC2626) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null && mounted) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  Future<void> pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (time != null && mounted) {
      setState(() {
        selectedTime = time;
      });
    }
  }

  Future<void> pickNotificationDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedNotificationDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime:
            TimeOfDay.fromDateTime(selectedNotificationDate ?? DateTime.now()),
      );
      if (time != null && mounted) {
        setState(() {
          selectedNotificationDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void toggleAllDay(bool value) {
    setState(() {
      isAllDay = value;
    });
  }

  void clearNotificationDate() {
    setState(() {
      selectedNotificationDate = null;
    });
  }

  Future<void> saveEvent() async {
    if (titleController.text.trim().isEmpty) {
      _showSnackBar('El título no puede estar vacío', isError: true);
      return;
    }
    if (selectedDate == null) {
      _showSnackBar('Debes seleccionar una fecha', isError: true);
      return;
    }

    DateTime finalDate = selectedDate!;
    if (!isAllDay && selectedTime != null) {
      finalDate = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );
    } else if (isAllDay) {
      finalDate = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
      );
    }

    try {
      final repo = ref.read(eventsRepositoryProvider);

      if (initialEvent != null) {
        final updated = initialEvent!.copyWith(
          title: titleController.text.trim(),
          isAllDay: isAllDay,
          date: finalDate,
          notificationAt: drift.Value(selectedNotificationDate),
        );
        await repo.updateEvent(updated);
        if (mounted) {
          Navigator.pop(context);
          _showSnackBar('Evento actualizado');
        }
      } else {
        await repo.addEvent(
          titleController.text.trim(),
          isAllDay,
          finalDate,
          selectedNotificationDate,
        );
        if (mounted) {
          Navigator.pop(context);
          _showSnackBar('Evento creado');
        }
      }
    } catch (e) {
      _showSnackBar('Error al guardar el evento', isError: true);
    }
  }

  Future<void> deleteEvent() async {
    if (initialEvent == null) return;
    try {
      await ref.read(eventsRepositoryProvider).deleteEvent(initialEvent!.id);
      if (mounted) {
        Navigator.pop(context);
        _showSnackBar('Evento eliminado');
      }
    } catch (e) {
      _showSnackBar('Error al eliminar', isError: true);
    }
  }
}
