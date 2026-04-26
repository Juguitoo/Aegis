import 'package:aegis/data/local/database/app_database.dart';
import 'package:drift/drift.dart';

class EventsRepository {
  final AppDatabase _db;

  EventsRepository(this._db);

  Stream<List<Event>> watchAllEvents() {
    return _db.select(_db.events).watch();
  }

  Future<List<Event>> getAllEvents() {
    return _db.select(_db.events).get();
  }

  Future<int> addEvent(
    String title,
    bool isAllDay,
    DateTime date,
    DateTime? notificationAt,
  ) {
    return _db.into(_db.events).insert(EventsCompanion(
        title: Value(title),
        isAllDay: Value(isAllDay),
        date: Value(date),
        notificationAt: Value(notificationAt),
        createdAt: Value(DateTime.now())));
  }

  Future<bool> updateEvent(Event updatedEvent) {
    return _db.update(_db.events).replace(updatedEvent);
  }

  Future<int> deleteEvent(int id) {
    return (_db.delete(_db.events)..where((e) => e.id.equals(id))).go();
  }
}
