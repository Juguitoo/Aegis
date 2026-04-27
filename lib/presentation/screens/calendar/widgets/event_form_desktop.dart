import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'event_form_mixin.dart';

class EventFormDesktop extends ConsumerStatefulWidget {
  final Event? event;

  const EventFormDesktop({super.key, this.event});

  @override
  ConsumerState<EventFormDesktop> createState() => _EventFormDesktopState();
}

class _EventFormDesktopState extends ConsumerState<EventFormDesktop>
    with EventFormMixin {
  @override
  Event? get initialEvent => widget.event;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
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
                    fontSize: 24,
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
            const SizedBox(height: 24),
            TextField(
              controller: titleController,
              autofocus: initialEvent == null,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Título',
                hintText: 'Ej. Reunión de TFG',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF6366F1), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),
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
            const SizedBox(height: 24),
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
                  const SizedBox(width: 16),
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
            const SizedBox(height: 24),
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
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (initialEvent != null)
                  TextButton(
                    onPressed: deleteEvent,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                    ),
                    child: const Text(
                      'Eliminar Evento',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: saveEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    initialEvent == null ? 'Guardar' : 'Actualizar',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
