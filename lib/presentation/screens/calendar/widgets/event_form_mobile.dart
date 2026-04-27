import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'event_form_mixin.dart';

class EventFormMobile extends ConsumerStatefulWidget {
  final Event? event;

  const EventFormMobile({super.key, this.event});

  @override
  ConsumerState<EventFormMobile> createState() => _EventFormMobileState();
}

class _EventFormMobileState extends ConsumerState<EventFormMobile>
    with EventFormMixin {
  @override
  Event? get initialEvent => widget.event;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
            20, 24, 20, safeBottom > 0 ? safeBottom + 16 : 32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    initialEvent == null ? 'Nuevo Evento' : 'Editar Evento',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                autofocus: initialEvent == null,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
                decoration: const InputDecoration(
                  hintText: 'Título del evento',
                  hintStyle: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.normal,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFF1F5F9)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Todo el día',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF334155),
                    ),
                  ),
                  Switch(
                    value: isAllDay,
                    onChanged: toggleAllDay,
                    activeThumbColor: const Color(0xFF6366F1),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: pickDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 20, color: Color(0xFF64748B)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                selectedDate != null
                                    ? DateFormat('dd MMM yyyy', 'es')
                                        .format(selectedDate!)
                                    : 'Fecha',
                                style: const TextStyle(
                                    color: Color(0xFF1E293B), fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (!isAllDay) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: pickTime,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time,
                                  size: 20, color: Color(0xFF64748B)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  selectedTime != null
                                      ? selectedTime!.format(context)
                                      : 'Hora',
                                  style: const TextStyle(
                                      color: Color(0xFF1E293B), fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: pickNotificationDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: selectedNotificationDate != null
                        ? const Color(0xFFEEF2FF)
                        : Colors.transparent,
                    border: Border.all(
                      color: selectedNotificationDate != null
                          ? const Color(0xFF6366F1)
                          : const Color(0xFFE2E8F0),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.notifications_active_outlined,
                          size: 20,
                          color: selectedNotificationDate != null
                              ? const Color(0xFF6366F1)
                              : const Color(0xFF64748B)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          selectedNotificationDate != null
                              ? DateFormat('dd MMM HH:mm', 'es')
                                  .format(selectedNotificationDate!)
                              : 'Añadir Recordatorio',
                          style: TextStyle(
                            color: selectedNotificationDate != null
                                ? const Color(0xFF6366F1)
                                : const Color(0xFF475569),
                            fontWeight: selectedNotificationDate != null
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (selectedNotificationDate != null)
                        GestureDetector(
                          onTap: clearNotificationDate,
                          child: const Icon(Icons.close,
                              size: 20, color: Color(0xFF6366F1)),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  if (initialEvent != null) ...[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: deleteEvent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFEE2E2),
                          foregroundColor: const Color(0xFFDC2626),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Eliminar',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: saveEvent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        initialEvent == null ? 'Crear Evento' : 'Actualizar',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
