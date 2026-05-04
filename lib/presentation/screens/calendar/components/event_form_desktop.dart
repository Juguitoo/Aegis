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
              color: colorScheme.onSurface.withValues(alpha: 0.1),
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
                  icon: Icon(Icons.close, color: colorScheme.outline),
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
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Switch(
                  value: isAllDay,
                  onChanged: toggleAllDay,
                  activeThumbColor: colorScheme.onPrimary,
                  activeTrackColor: colorScheme.primary,
                  inactiveThumbColor: colorScheme.outline,
                  inactiveTrackColor: colorScheme.surface,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: AegisTextField(
                    hintText: selectedDate != null
                        ? DateFormat('dd MMM yyyy', 'es').format(selectedDate!)
                        : 'Fecha',
                    prefixIcon: Icons.calendar_today,
                    readOnly: true,
                    onTap: pickDate,
                  ),
                ),
                if (!isAllDay) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: AegisTextField(
                      hintText: selectedTime != null
                          ? selectedTime!.format(context)
                          : 'Hora',
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
              hintText: selectedNotificationDate != null
                  ? DateFormat('dd MMM HH:mm', 'es')
                      .format(selectedNotificationDate!)
                  : 'Añadir Recordatorio',
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
