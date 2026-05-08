import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/presentation/widgets/aegis_buttons.dart';
import 'package:aegis/presentation/widgets/aegis_inputs.dart';
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    dateController.text = selectedDate != null
        ? DateFormat('dd MMM yyyy', 'es').format(selectedDate!)
        : '';
    timeController.text =
        selectedTime != null ? selectedTime!.format(context) : '';
    notificationController.text = selectedNotificationDate != null
        ? DateFormat('dd MMM HH:mm', 'es').format(selectedNotificationDate!)
        : '';

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.1),
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
                  style: textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: colorScheme.onSurfaceVariant),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AegisTextField(
              controller: titleController,
              labelText: 'Título',
              hintText: 'Ej. Reunión de TFG',
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Todo el día',
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                Switch(
                  value: isAllDay,
                  onChanged: toggleAllDay,
                  activeThumbColor: colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: AegisTextField(
                    controller: dateController,
                    hintText: 'Fecha',
                    prefixIcon: Icons.calendar_today,
                    readOnly: true,
                    onTap: pickDate,
                  ),
                ),
                if (!isAllDay) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: AegisTextField(
                      controller: timeController,
                      hintText: 'Hora',
                      prefixIcon: Icons.access_time,
                      readOnly: true,
                      onTap: pickTime,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
            AegisTextField(
              controller: notificationController,
              hintText: 'Añadir Recordatorio',
              prefixIcon: Icons.notifications_active_outlined,
              suffixIcon: selectedNotificationDate != null
                  ? IconButton(
                      icon: Icon(Icons.close, color: colorScheme.primary),
                      onPressed: clearNotificationDate,
                    )
                  : null,
              readOnly: true,
              onTap: pickNotificationDate,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: AegisButton(
                    text: initialEvent == null ? 'Limpiar' : 'Eliminar',
                    type: initialEvent == null
                        ? ButtonType.secondary
                        : ButtonType.destructive,
                    onPressed: initialEvent == null ? clearEvent : deleteEvent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
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
