import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/presentation/widgets/aegis_buttons.dart';
import 'package:aegis/presentation/widgets/aegis_inputs.dart';
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

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                    style: textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon:
                        Icon(Icons.close, color: colorScheme.onSurfaceVariant),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AegisTextField(
                controller: titleController,
                labelText: 'Título del evento',
                hintText: 'Ej. Cita médica',
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 8),
              Divider(color: colorScheme.outline.withValues(alpha: 0.2)),
              const SizedBox(height: 8),
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
              const SizedBox(height: 16),
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
                    const SizedBox(width: 12),
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
              const SizedBox(height: 16),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: AegisButton(
                      text: initialEvent == null ? 'Limpiar' : 'Eliminar',
                      type: initialEvent == null
                          ? ButtonType.secondary
                          : ButtonType.destructive,
                      onPressed:
                          initialEvent == null ? clearEvent : deleteEvent,
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
      ),
    );
  }
}
