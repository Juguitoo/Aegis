import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/presentation/viewmodels/calendar_viewmodel.dart';

mixin EventFormMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  Event? get initialEvent;

  final titleController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final notificationController = TextEditingController();

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
    dateController.dispose();
    timeController.dispose();
    notificationController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;

    final sideMargin =
        screenSize.width > 600 ? (screenSize.width - 400) / 2 : 16.0;
    final bottomMargin = (screenSize.height - 120).clamp(16.0, 4000.0);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle_outline,
                color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        backgroundColor: isError ? colorScheme.error : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: bottomMargin,
          left: sideMargin,
          right: sideMargin,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 6,
        dismissDirection: DismissDirection.up,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('es', 'ES'),
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
      builder: (context, child) {
        return Localizations.override(
          context: context,
          locale: const Locale('es', 'ES'),
          child: child!,
        );
      },
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
      initialEntryMode: TimePickerEntryMode.dialOnly,
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: Localizations.override(
            context: context,
            locale: const Locale('es', 'ES'),
            child: child!,
          ),
        );
      },
    );
    if (time != null && mounted) {
      setState(() {
        selectedTime = time;
      });
    }
  }

  Future<void> pickNotificationDate() async {
    final now = DateTime.now();
    final initial = selectedNotificationDate ?? now;
    final first = initial.isBefore(now) ? initial : now;

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: DateTime(2100),
      locale: const Locale('es', 'ES'),
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
      builder: (context, child) {
        return Localizations.override(
          context: context,
          locale: const Locale('es', 'ES'),
          child: child!,
        );
      },
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initial),
        initialEntryMode: TimePickerEntryMode.dialOnly,
        cancelText: 'Cancelar',
        confirmText: 'Aceptar',
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: Localizations.override(
              context: context,
              locale: const Locale('es', 'ES'),
              child: child!,
            ),
          );
        },
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
      final viewModel = ref.read(calendarViewModelProvider.notifier);

      if (initialEvent != null) {
        final updated = initialEvent!.copyWith(
          title: titleController.text.trim(),
          isAllDay: isAllDay,
          date: finalDate,
          notificationAt: drift.Value(selectedNotificationDate),
        );
        await viewModel.updateEvent(updated);

        if (mounted) {
          Navigator.pop(context);
          _showSnackBar('Evento actualizado');
        }
      } else {
        await viewModel.addEvent(
          title: titleController.text.trim(),
          isAllDay: isAllDay,
          date: finalDate,
          notificationAt: selectedNotificationDate,
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
      await ref
          .read(calendarViewModelProvider.notifier)
          .deleteEvent(initialEvent!.id);
      if (mounted) {
        Navigator.pop(context);
        _showSnackBar('Evento eliminado');
      }
    } catch (e) {
      _showSnackBar('Error al eliminar', isError: true);
    }
  }

  void clearEvent() {
    setState(() {
      titleController.clear();
      isAllDay = false;
      selectedDate = null;
      selectedTime = null;
      selectedNotificationDate = null;
    });
  }
}
