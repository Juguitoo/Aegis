class NotificationIdManager {
  static const int taskPrefix = 100000;
  static const int eventPrefix = 200000;

  static int getTaskId(int taskId) {
    return taskPrefix + taskId;
  }

  static int getEventId(int eventId) {
    return eventPrefix + eventId;
  }
}
