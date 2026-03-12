// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_settings.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetNotificationSettingsCollection on Isar {
  IsarCollection<NotificationSettings> get notificationSettings =>
      this.collection();
}

const NotificationSettingsSchema = CollectionSchema(
  name: r'NotificationSettings',
  id: 4766171496376314778,
  properties: {
    r'achievementAlerts': PropertySchema(
      id: 0,
      name: r'achievementAlerts',
      type: IsarType.bool,
    ),
    r'habitReminderTimeHour': PropertySchema(
      id: 1,
      name: r'habitReminderTimeHour',
      type: IsarType.long,
    ),
    r'habitReminderTimeMinute': PropertySchema(
      id: 2,
      name: r'habitReminderTimeMinute',
      type: IsarType.long,
    ),
    r'habitReminders': PropertySchema(
      id: 3,
      name: r'habitReminders',
      type: IsarType.bool,
    ),
    r'pendingTasksReminder': PropertySchema(
      id: 4,
      name: r'pendingTasksReminder',
      type: IsarType.bool,
    ),
    r'pomodoroCompleted': PropertySchema(
      id: 5,
      name: r'pomodoroCompleted',
      type: IsarType.bool,
    ),
    r'taskReminderTimeHour': PropertySchema(
      id: 6,
      name: r'taskReminderTimeHour',
      type: IsarType.long,
    ),
    r'taskReminderTimeMinute': PropertySchema(
      id: 7,
      name: r'taskReminderTimeMinute',
      type: IsarType.long,
    )
  },
  estimateSize: _notificationSettingsEstimateSize,
  serialize: _notificationSettingsSerialize,
  deserialize: _notificationSettingsDeserialize,
  deserializeProp: _notificationSettingsDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _notificationSettingsGetId,
  getLinks: _notificationSettingsGetLinks,
  attach: _notificationSettingsAttach,
  version: '3.1.0+1',
);

int _notificationSettingsEstimateSize(
  NotificationSettings object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _notificationSettingsSerialize(
  NotificationSettings object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.achievementAlerts);
  writer.writeLong(offsets[1], object.habitReminderTimeHour);
  writer.writeLong(offsets[2], object.habitReminderTimeMinute);
  writer.writeBool(offsets[3], object.habitReminders);
  writer.writeBool(offsets[4], object.pendingTasksReminder);
  writer.writeBool(offsets[5], object.pomodoroCompleted);
  writer.writeLong(offsets[6], object.taskReminderTimeHour);
  writer.writeLong(offsets[7], object.taskReminderTimeMinute);
}

NotificationSettings _notificationSettingsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = NotificationSettings();
  object.achievementAlerts = reader.readBool(offsets[0]);
  object.habitReminderTimeHour = reader.readLong(offsets[1]);
  object.habitReminderTimeMinute = reader.readLong(offsets[2]);
  object.habitReminders = reader.readBool(offsets[3]);
  object.id = id;
  object.pendingTasksReminder = reader.readBool(offsets[4]);
  object.pomodoroCompleted = reader.readBool(offsets[5]);
  object.taskReminderTimeHour = reader.readLong(offsets[6]);
  object.taskReminderTimeMinute = reader.readLong(offsets[7]);
  return object;
}

P _notificationSettingsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _notificationSettingsGetId(NotificationSettings object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _notificationSettingsGetLinks(
    NotificationSettings object) {
  return [];
}

void _notificationSettingsAttach(
    IsarCollection<dynamic> col, Id id, NotificationSettings object) {
  object.id = id;
}

extension NotificationSettingsQueryWhereSort
    on QueryBuilder<NotificationSettings, NotificationSettings, QWhere> {
  QueryBuilder<NotificationSettings, NotificationSettings, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension NotificationSettingsQueryWhere
    on QueryBuilder<NotificationSettings, NotificationSettings, QWhereClause> {
  QueryBuilder<NotificationSettings, NotificationSettings, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension NotificationSettingsQueryFilter on QueryBuilder<NotificationSettings,
    NotificationSettings, QFilterCondition> {
  QueryBuilder<NotificationSettings, NotificationSettings,
      QAfterFilterCondition> achievementAlertsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'achievementAlerts',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings,
      QAfterFilterCondition> habitReminderTimeHourEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'habitReminderTimeHour',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings,
      QAfterFilterCondition> habitReminderTimeHourGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'habitReminderTimeHour',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings,
      QAfterFilterCondition> habitReminderTimeHourLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'habitReminderTimeHour',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings,
      QAfterFilterCondition> habitReminderTimeHourBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'habitReminderTimeHour',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings,
      QAfterFilterCondition> habitReminderTimeMinuteEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'habitReminderTimeMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings,
      QAfterFilterCondition> habitReminderTimeMinuteGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'habitReminderTimeMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings,
      QAfterFilterCondition> habitReminderTimeMinuteLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'habitReminderTimeMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings,
      QAfterFilterCondition> habitReminderTimeMinuteBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'habitReminderTimeMinute',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings,
      QAfterFilterCondition> habitRemindersEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'habitReminders',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings,
      QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings,
      QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings,
      QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings,
      QAfterFilterCondition> pendingTasksReminderEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pendingTasksReminder',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings,
      QAfterFilterCondition> pomodoroCompletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pomodoroCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings,
      QAfterFilterCondition> taskReminderTimeHourEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'taskReminderTimeHour',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings,
      QAfterFilterCondition> taskReminderTimeHourGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'taskReminderTimeHour',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings,
      QAfterFilterCondition> taskReminderTimeHourLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'taskReminderTimeHour',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings,
      QAfterFilterCondition> taskReminderTimeHourBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'taskReminderTimeHour',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings,
      QAfterFilterCondition> taskReminderTimeMinuteEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'taskReminderTimeMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings,
      QAfterFilterCondition> taskReminderTimeMinuteGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'taskReminderTimeMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings,
      QAfterFilterCondition> taskReminderTimeMinuteLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'taskReminderTimeMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings,
      QAfterFilterCondition> taskReminderTimeMinuteBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'taskReminderTimeMinute',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension NotificationSettingsQueryObject on QueryBuilder<NotificationSettings,
    NotificationSettings, QFilterCondition> {}

extension NotificationSettingsQueryLinks on QueryBuilder<NotificationSettings,
    NotificationSettings, QFilterCondition> {}

extension NotificationSettingsQuerySortBy
    on QueryBuilder<NotificationSettings, NotificationSettings, QSortBy> {
  QueryBuilder<NotificationSettings, NotificationSettings, QAfterSortBy>
      sortByAchievementAlerts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'achievementAlerts', Sort.asc);
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings, QAfterSortBy>
      sortByAchievementAlertsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'achievementAlerts', Sort.desc);
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings, QAfterSortBy>
      sortByHabitReminderTimeHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'habitReminderTimeHour', Sort.asc);
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings, QAfterSortBy>
      sortByHabitReminderTimeHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'habitReminderTimeHour', Sort.desc);
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings, QAfterSortBy>
      sortByHabitReminderTimeMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'habitReminderTimeMinute', Sort.asc);
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings, QAfterSortBy>
      sortByHabitReminderTimeMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'habitReminderTimeMinute', Sort.desc);
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings, QAfterSortBy>
      sortByHabitReminders() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'habitReminders', Sort.asc);
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings, QAfterSortBy>
      sortByHabitRemindersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'habitReminders', Sort.desc);
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings, QAfterSortBy>
      sortByPendingTasksReminder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingTasksReminder', Sort.asc);
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings, QAfterSortBy>
      sortByPendingTasksReminderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingTasksReminder', Sort.desc);
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings, QAfterSortBy>
      sortByPomodoroCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pomodoroCompleted', Sort.asc);
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings, QAfterSortBy>
      sortByPomodoroCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pomodoroCompleted', Sort.desc);
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings, QAfterSortBy>
      sortByTaskReminderTimeHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskReminderTimeHour', Sort.asc);
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings, QAfterSortBy>
      sortByTaskReminderTimeHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskReminderTimeHour', Sort.desc);
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings, QAfterSortBy>
      sortByTaskReminderTimeMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskReminderTimeMinute', Sort.asc);
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings, QAfterSortBy>
      sortByTaskReminderTimeMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskReminderTimeMinute', Sort.desc);
    });
  }
}

extension NotificationSettingsQuerySortThenBy
    on QueryBuilder<NotificationSettings, NotificationSettings, QSortThenBy> {
  QueryBuilder<NotificationSettings, NotificationSettings, QAfterSortBy>
      thenByAchievementAlerts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'achievementAlerts', Sort.asc);
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings, QAfterSortBy>
      thenByAchievementAlertsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'achievementAlerts', Sort.desc);
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings, QAfterSortBy>
      thenByHabitReminderTimeHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'habitReminderTimeHour', Sort.asc);
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings, QAfterSortBy>
      thenByHabitReminderTimeHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'habitReminderTimeHour', Sort.desc);
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings, QAfterSortBy>
      thenByHabitReminderTimeMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'habitReminderTimeMinute', Sort.asc);
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings, QAfterSortBy>
      thenByHabitReminderTimeMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'habitReminderTimeMinute', Sort.desc);
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings, QAfterSortBy>
      thenByHabitReminders() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'habitReminders', Sort.asc);
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings, QAfterSortBy>
      thenByHabitRemindersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'habitReminders', Sort.desc);
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings, QAfterSortBy>
      thenByPendingTasksReminder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingTasksReminder', Sort.asc);
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings, QAfterSortBy>
      thenByPendingTasksReminderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingTasksReminder', Sort.desc);
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings, QAfterSortBy>
      thenByPomodoroCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pomodoroCompleted', Sort.asc);
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings, QAfterSortBy>
      thenByPomodoroCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pomodoroCompleted', Sort.desc);
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings, QAfterSortBy>
      thenByTaskReminderTimeHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskReminderTimeHour', Sort.asc);
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings, QAfterSortBy>
      thenByTaskReminderTimeHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskReminderTimeHour', Sort.desc);
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings, QAfterSortBy>
      thenByTaskReminderTimeMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskReminderTimeMinute', Sort.asc);
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings, QAfterSortBy>
      thenByTaskReminderTimeMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskReminderTimeMinute', Sort.desc);
    });
  }
}

extension NotificationSettingsQueryWhereDistinct
    on QueryBuilder<NotificationSettings, NotificationSettings, QDistinct> {
  QueryBuilder<NotificationSettings, NotificationSettings, QDistinct>
      distinctByAchievementAlerts() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'achievementAlerts');
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings, QDistinct>
      distinctByHabitReminderTimeHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'habitReminderTimeHour');
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings, QDistinct>
      distinctByHabitReminderTimeMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'habitReminderTimeMinute');
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings, QDistinct>
      distinctByHabitReminders() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'habitReminders');
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings, QDistinct>
      distinctByPendingTasksReminder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pendingTasksReminder');
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings, QDistinct>
      distinctByPomodoroCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pomodoroCompleted');
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings, QDistinct>
      distinctByTaskReminderTimeHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'taskReminderTimeHour');
    });
  }

  QueryBuilder<NotificationSettings, NotificationSettings, QDistinct>
      distinctByTaskReminderTimeMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'taskReminderTimeMinute');
    });
  }
}

extension NotificationSettingsQueryProperty on QueryBuilder<
    NotificationSettings, NotificationSettings, QQueryProperty> {
  QueryBuilder<NotificationSettings, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<NotificationSettings, bool, QQueryOperations>
      achievementAlertsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'achievementAlerts');
    });
  }

  QueryBuilder<NotificationSettings, int, QQueryOperations>
      habitReminderTimeHourProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'habitReminderTimeHour');
    });
  }

  QueryBuilder<NotificationSettings, int, QQueryOperations>
      habitReminderTimeMinuteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'habitReminderTimeMinute');
    });
  }

  QueryBuilder<NotificationSettings, bool, QQueryOperations>
      habitRemindersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'habitReminders');
    });
  }

  QueryBuilder<NotificationSettings, bool, QQueryOperations>
      pendingTasksReminderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pendingTasksReminder');
    });
  }

  QueryBuilder<NotificationSettings, bool, QQueryOperations>
      pomodoroCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pomodoroCompleted');
    });
  }

  QueryBuilder<NotificationSettings, int, QQueryOperations>
      taskReminderTimeHourProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'taskReminderTimeHour');
    });
  }

  QueryBuilder<NotificationSettings, int, QQueryOperations>
      taskReminderTimeMinuteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'taskReminderTimeMinute');
    });
  }
}
