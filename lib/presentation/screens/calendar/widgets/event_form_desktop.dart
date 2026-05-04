import 'package:aegis/core/theme/app_theme.dart';
import 'package:aegis/presentation/widgets/aegis_buttons.dart';
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
          color: AppTheme.pureWhite,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.ebony.withValues(alpha: 0.1),
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
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppTheme.gullGray),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: titleController,
              autofocus: initialEvent == null,
              textCapitalization: TextCapitalization.sentences,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                labelText: 'Título',
                labelStyle: Theme.of(context).textTheme.bodyMedium,
                hintText: 'Ej. Reunión de TFG',
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.gullGray,
                    ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.gullGray),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppTheme.royalBlue, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Todo el día',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Switch(
                  value: isAllDay,
                  onChanged: toggleAllDay,
                  activeThumbColor: AppTheme.pureWhite,
                  activeTrackColor: AppTheme.royalBlue,
                  inactiveThumbColor: AppTheme.gullGray,
                  inactiveTrackColor: AppTheme.whiteZyrcon,
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
                        border: Border.all(
                            color: AppTheme.gullGray.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 20, color: AppTheme.fiord),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              selectedDate != null
                                  ? DateFormat('dd MMM yyyy', 'es')
                                      .format(selectedDate!)
                                  : 'Fecha',
                              style: Theme.of(context).textTheme.bodyLarge,
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
                          border: Border.all(
                              color: AppTheme.gullGray.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time,
                                size: 20, color: AppTheme.fiord),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                selectedTime != null
                                    ? selectedTime!.format(context)
                                    : 'Hora',
                                style: Theme.of(context).textTheme.bodyLarge,
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
                      ? AppTheme.royalBlue10
                      : Colors.transparent,
                  border: Border.all(
                    color: selectedNotificationDate != null
                        ? AppTheme.royalBlue
                        : AppTheme.gullGray.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications_active_outlined,
                      size: 20,
                      color: selectedNotificationDate != null
                          ? AppTheme.royalBlue
                          : AppTheme.fiord,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selectedNotificationDate != null
                            ? DateFormat('dd MMM HH:mm', 'es')
                                .format(selectedNotificationDate!)
                            : 'Añadir Recordatorio',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: selectedNotificationDate != null
                                  ? AppTheme.royalBlue
                                  : AppTheme.fiord,
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
                            size: 20, color: AppTheme.royalBlue),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 160,
                  child: AegisButton(
                    text: initialEvent == null ? 'Limpiar' : 'Eliminar',
                    type: initialEvent == null
                        ? ButtonType.secondary
                        : ButtonType.destructive,
                    onPressed: initialEvent == null ? clearEvent : deleteEvent,
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 160,
                  child: AegisButton(
                    text: initialEvent == null ? 'Guardar' : 'Actualizar',
                    type: ButtonType.primary,
                    onPressed: saveEvent,
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
