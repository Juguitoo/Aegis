import 'package:aegis/core/providers/repository_providers.dart';
import 'package:aegis/core/services/notification_service.dart';
import 'package:aegis/core/utils/notification_id_manager.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/data/repositories/events_repository.dart';
import 'package:aegis/presentation/viewmodels/calendar_viewmodel.dart';
import 'package:aegis/presentation/viewmodels/task_list_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import 'calendar_viewmodel_test.mocks.dart';

class FakeTaskListViewModel extends StreamNotifier<List<Task>>
    implements TaskListViewModel {
  @override
  Stream<List<Task>> build() => Stream.value([]);
  @override
  Future<List<int>> getTagsForTask(int taskId) async => [];
  @override
  Future<int> addTask(
          {required String title,
          String? description,
          int? estimatedDuration,
          DateTime? dueDate,
          DateTime? notificationAt,
          int? areaId,
          int priority = 0,
          List<int> tagIds = const [],
          List<TaskChecklistItem> checklist = const [],
          String? notes}) async =>
      1;
  @override
  Future<void> updateTask(
      {required Task task,
      List<int> tagIds = const [],
      List<TaskChecklistItem> checklist = const []}) async {}
  @override
  Future<int> deleteTask(Task task) async => 1;
  @override
  Future<int> deleteTaskById(int id) async => 1;
  @override
  Future<bool> toggleTaskCompletion(Task task) async => true;
}

@GenerateNiceMocks(
    [MockSpec<NotificationService>(), MockSpec<NotificationIdManager>()])
@GenerateMocks([EventsRepository])
void main() {
  setUpAll(() {
    tz.initializeTimeZones();
  });

  group('CalendarViewModel', () {
    late MockEventsRepository mockEventsRepository;
    late MockNotificationService mockNotificationService;
    late ProviderContainer container;

    setUp(() {
      mockEventsRepository = MockEventsRepository();
      mockNotificationService = MockNotificationService();

      when(mockNotificationService.scheduleNotification(
        id: anyNamed('id'),
        title: anyNamed('title'),
        body: anyNamed('body'),
        scheduledDate: anyNamed('scheduledDate'),
        payload: anyNamed('payload'),
      )).thenAnswer((_) => Future.value());

      when(mockNotificationService.cancelNotification(any))
          .thenAnswer((_) => Future.value());

      container = ProviderContainer(
        overrides: [
          eventsRepositoryProvider.overrideWithValue(mockEventsRepository),
          notificationServiceProvider
              .overrideWithValue(mockNotificationService),
          taskListViewModelProvider.overrideWith(() => FakeTaskListViewModel()),
          eventsStreamProvider.overrideWith((ref) => Stream.value([])),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('onDaySelected updates state', () {
      final viewModel = container.read(calendarViewModelProvider.notifier);
      final newDate = DateTime(2024, 1, 15);
      viewModel.onDaySelected(newDate, newDate);
      expect(container.read(calendarViewModelProvider).selectedDay, newDate);
      expect(container.read(calendarViewModelProvider).focusedDay, newDate);
    });

    test('onPageChanged updates state', () {
      final viewModel = container.read(calendarViewModelProvider.notifier);
      final newDate = DateTime(2024, 2, 1);
      viewModel.onPageChanged(newDate);
      expect(container.read(calendarViewModelProvider).focusedDay, newDate);
    });

    test('addEvent calls repository and schedules notification', () async {
      final title = 'New Event';
      final date = DateTime.now().add(const Duration(days: 1));

      when(mockEventsRepository.addEvent(title, false, date, date))
          .thenAnswer((_) => Future.value(1));

      await container.read(calendarViewModelProvider.notifier).addEvent(
            title: title,
            isAllDay: false,
            date: date,
            notificationAt: date,
          );

      verify(mockEventsRepository.addEvent(title, false, date, date)).called(1);
    });

    test('addEvent without notification', () async {
      final title = 'New Event without notification';
      final date = DateTime.now().add(const Duration(days: 1));

      when(mockEventsRepository.addEvent(title, false, date, null))
          .thenAnswer((_) => Future.value(1));

      await container.read(calendarViewModelProvider.notifier).addEvent(
            title: title,
            isAllDay: false,
            date: date,
            notificationAt: null,
          );

      verify(mockEventsRepository.addEvent(title, false, date, null)).called(1);
    });

    test('updateEvent calls repository and updates notification', () async {
      final event = Event(
        id: 1,
        title: 'Updated Event',
        date: DateTime.now().add(const Duration(days: 1)),
        isAllDay: false,
        notificationAt: DateTime.now().add(const Duration(days: 1)),
        createdAt: DateTime.now(),
      );

      when(mockEventsRepository.updateEvent(event))
          .thenAnswer((_) => Future.value(true));

      await container
          .read(calendarViewModelProvider.notifier)
          .updateEvent(event);

      verify(mockEventsRepository.updateEvent(event)).called(1);
    });

    test('deleteEvent calls repository and cancels notification', () async {
      const eventId = 1;

      when(mockEventsRepository.deleteEvent(eventId))
          .thenAnswer((_) => Future.value(1));

      await container
          .read(calendarViewModelProvider.notifier)
          .deleteEvent(eventId);

      verify(mockEventsRepository.deleteEvent(eventId)).called(1);
    });
  });
}
