import 'package:aegis/data/repositories/events_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:aegis/data/local/database/app_database.dart';

void main() {
  late AppDatabase db;
  late EventsRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = EventsRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('EventsRepository', () {
    test('insert Event y getAllEvents funcionan correctamente', () async {
      await repository.addEvent('Test Evento', true, DateTime.now(), null);

      final events = await repository.getAllEvents();

      expect(events, isNotEmpty);
      expect(events.length, 1);
      expect(events.first.title, 'Test Evento');
    });

    test('updateEvent modifica los datos de la base de datos', () async {
      await repository.addEvent('Test Evento', true, DateTime.now(), null);
      var events = await repository.getAllEvents();
      final originalEvent = events.first;
      final updatedEvent =
          originalEvent.copyWith(title: 'Test Evento Actualizado');

      await repository.updateEvent(updatedEvent);

      events = await repository.getAllEvents();
      final updatedEventBD = events.first;
      expect(events, isNotEmpty);
      expect(events.length, 1);
      expect(updatedEventBD.id, originalEvent.id);
      expect(events.first.title, 'Test Evento Actualizado');
    });

    test('deleteEvent elimina el evento de la base de datos', () async {
      await repository.addEvent('Test Evento', true, DateTime.now(), null);
      var events = await repository.getAllEvents();
      await repository.deleteEvent(events.first.id);

      events = await repository.getAllEvents();
      expect(events, isEmpty);
    });

    test('watchAllEvents devuelve el Stream correctamente', () async {
      await repository.addEvent('Test Evento 1', true, DateTime.now(), null);
      await repository.addEvent('Test Evento 2', true, DateTime.now(), null);
      await repository.addEvent('Test Evento 3', true, DateTime.now(), null);
      await repository.addEvent('Test Evento 4', true, DateTime.now(), null);

      final eventsStream = repository.watchAllEvents();
      var events = await eventsStream.first;

      expect(events, isNotEmpty);
      expect(events.length, 4);

      await repository.updateEvent(
          events.first.copyWith(title: 'Test Evento 1 Actualizado'));
      events = await eventsStream.first;
      expect(events.first.title, 'Test Evento 1 Actualizado');
    });
  });
}
