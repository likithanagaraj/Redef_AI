// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDeepworkSessionCollection on Isar {
  IsarCollection<DeepworkSession> get deepworkSessions => this.collection();
}

const DeepworkSessionSchema = CollectionSchema(
  name: r'DeepworkSession',
  id: 1723590468105174510,
  properties: {
    r'durationInMinutes': PropertySchema(
      id: 0,
      name: r'durationInMinutes',
      type: IsarType.long,
    ),
    r'durationInSeconds': PropertySchema(
      id: 1,
      name: r'durationInSeconds',
      type: IsarType.long,
    ),
    r'endTime': PropertySchema(
      id: 2,
      name: r'endTime',
      type: IsarType.dateTime,
    ),
    r'isManualEntry': PropertySchema(
      id: 3,
      name: r'isManualEntry',
      type: IsarType.bool,
    ),
    r'startTime': PropertySchema(
      id: 4,
      name: r'startTime',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _deepworkSessionEstimateSize,
  serialize: _deepworkSessionSerialize,
  deserialize: _deepworkSessionDeserialize,
  deserializeProp: _deepworkSessionDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'project': LinkSchema(
      id: 8974048199264455029,
      name: r'project',
      target: r'Project',
      single: true,
    )
  },
  embeddedSchemas: {},
  getId: _deepworkSessionGetId,
  getLinks: _deepworkSessionGetLinks,
  attach: _deepworkSessionAttach,
  version: '3.1.0+1',
);

int _deepworkSessionEstimateSize(
  DeepworkSession object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _deepworkSessionSerialize(
  DeepworkSession object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.durationInMinutes);
  writer.writeLong(offsets[1], object.durationInSeconds);
  writer.writeDateTime(offsets[2], object.endTime);
  writer.writeBool(offsets[3], object.isManualEntry);
  writer.writeDateTime(offsets[4], object.startTime);
}

DeepworkSession _deepworkSessionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DeepworkSession();
  object.durationInMinutes = reader.readLong(offsets[0]);
  object.durationInSeconds = reader.readLong(offsets[1]);
  object.endTime = reader.readDateTime(offsets[2]);
  object.id = id;
  object.isManualEntry = reader.readBool(offsets[3]);
  object.startTime = reader.readDateTime(offsets[4]);
  return object;
}

P _deepworkSessionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _deepworkSessionGetId(DeepworkSession object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _deepworkSessionGetLinks(DeepworkSession object) {
  return [object.project];
}

void _deepworkSessionAttach(
    IsarCollection<dynamic> col, Id id, DeepworkSession object) {
  object.id = id;
  object.project.attach(col, col.isar.collection<Project>(), r'project', id);
}

extension DeepworkSessionQueryWhereSort
    on QueryBuilder<DeepworkSession, DeepworkSession, QWhere> {
  QueryBuilder<DeepworkSession, DeepworkSession, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DeepworkSessionQueryWhere
    on QueryBuilder<DeepworkSession, DeepworkSession, QWhereClause> {
  QueryBuilder<DeepworkSession, DeepworkSession, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DeepworkSession, DeepworkSession, QAfterWhereClause>
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

  QueryBuilder<DeepworkSession, DeepworkSession, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DeepworkSession, DeepworkSession, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DeepworkSession, DeepworkSession, QAfterWhereClause> idBetween(
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

extension DeepworkSessionQueryFilter
    on QueryBuilder<DeepworkSession, DeepworkSession, QFilterCondition> {
  QueryBuilder<DeepworkSession, DeepworkSession, QAfterFilterCondition>
      durationInMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'durationInMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<DeepworkSession, DeepworkSession, QAfterFilterCondition>
      durationInMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'durationInMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<DeepworkSession, DeepworkSession, QAfterFilterCondition>
      durationInMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'durationInMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<DeepworkSession, DeepworkSession, QAfterFilterCondition>
      durationInMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'durationInMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DeepworkSession, DeepworkSession, QAfterFilterCondition>
      durationInSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'durationInSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<DeepworkSession, DeepworkSession, QAfterFilterCondition>
      durationInSecondsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'durationInSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<DeepworkSession, DeepworkSession, QAfterFilterCondition>
      durationInSecondsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'durationInSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<DeepworkSession, DeepworkSession, QAfterFilterCondition>
      durationInSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'durationInSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DeepworkSession, DeepworkSession, QAfterFilterCondition>
      endTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endTime',
        value: value,
      ));
    });
  }

  QueryBuilder<DeepworkSession, DeepworkSession, QAfterFilterCondition>
      endTimeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endTime',
        value: value,
      ));
    });
  }

  QueryBuilder<DeepworkSession, DeepworkSession, QAfterFilterCondition>
      endTimeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endTime',
        value: value,
      ));
    });
  }

  QueryBuilder<DeepworkSession, DeepworkSession, QAfterFilterCondition>
      endTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DeepworkSession, DeepworkSession, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DeepworkSession, DeepworkSession, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<DeepworkSession, DeepworkSession, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<DeepworkSession, DeepworkSession, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<DeepworkSession, DeepworkSession, QAfterFilterCondition>
      isManualEntryEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isManualEntry',
        value: value,
      ));
    });
  }

  QueryBuilder<DeepworkSession, DeepworkSession, QAfterFilterCondition>
      startTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<DeepworkSession, DeepworkSession, QAfterFilterCondition>
      startTimeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<DeepworkSession, DeepworkSession, QAfterFilterCondition>
      startTimeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<DeepworkSession, DeepworkSession, QAfterFilterCondition>
      startTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DeepworkSessionQueryObject
    on QueryBuilder<DeepworkSession, DeepworkSession, QFilterCondition> {}

extension DeepworkSessionQueryLinks
    on QueryBuilder<DeepworkSession, DeepworkSession, QFilterCondition> {
  QueryBuilder<DeepworkSession, DeepworkSession, QAfterFilterCondition> project(
      FilterQuery<Project> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'project');
    });
  }

  QueryBuilder<DeepworkSession, DeepworkSession, QAfterFilterCondition>
      projectIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'project', 0, true, 0, true);
    });
  }
}

extension DeepworkSessionQuerySortBy
    on QueryBuilder<DeepworkSession, DeepworkSession, QSortBy> {
  QueryBuilder<DeepworkSession, DeepworkSession, QAfterSortBy>
      sortByDurationInMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationInMinutes', Sort.asc);
    });
  }

  QueryBuilder<DeepworkSession, DeepworkSession, QAfterSortBy>
      sortByDurationInMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationInMinutes', Sort.desc);
    });
  }

  QueryBuilder<DeepworkSession, DeepworkSession, QAfterSortBy>
      sortByDurationInSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationInSeconds', Sort.asc);
    });
  }

  QueryBuilder<DeepworkSession, DeepworkSession, QAfterSortBy>
      sortByDurationInSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationInSeconds', Sort.desc);
    });
  }

  QueryBuilder<DeepworkSession, DeepworkSession, QAfterSortBy> sortByEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.asc);
    });
  }

  QueryBuilder<DeepworkSession, DeepworkSession, QAfterSortBy>
      sortByEndTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.desc);
    });
  }

  QueryBuilder<DeepworkSession, DeepworkSession, QAfterSortBy>
      sortByIsManualEntry() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isManualEntry', Sort.asc);
    });
  }

  QueryBuilder<DeepworkSession, DeepworkSession, QAfterSortBy>
      sortByIsManualEntryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isManualEntry', Sort.desc);
    });
  }

  QueryBuilder<DeepworkSession, DeepworkSession, QAfterSortBy>
      sortByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.asc);
    });
  }

  QueryBuilder<DeepworkSession, DeepworkSession, QAfterSortBy>
      sortByStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.desc);
    });
  }
}

extension DeepworkSessionQuerySortThenBy
    on QueryBuilder<DeepworkSession, DeepworkSession, QSortThenBy> {
  QueryBuilder<DeepworkSession, DeepworkSession, QAfterSortBy>
      thenByDurationInMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationInMinutes', Sort.asc);
    });
  }

  QueryBuilder<DeepworkSession, DeepworkSession, QAfterSortBy>
      thenByDurationInMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationInMinutes', Sort.desc);
    });
  }

  QueryBuilder<DeepworkSession, DeepworkSession, QAfterSortBy>
      thenByDurationInSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationInSeconds', Sort.asc);
    });
  }

  QueryBuilder<DeepworkSession, DeepworkSession, QAfterSortBy>
      thenByDurationInSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationInSeconds', Sort.desc);
    });
  }

  QueryBuilder<DeepworkSession, DeepworkSession, QAfterSortBy> thenByEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.asc);
    });
  }

  QueryBuilder<DeepworkSession, DeepworkSession, QAfterSortBy>
      thenByEndTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.desc);
    });
  }

  QueryBuilder<DeepworkSession, DeepworkSession, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DeepworkSession, DeepworkSession, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DeepworkSession, DeepworkSession, QAfterSortBy>
      thenByIsManualEntry() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isManualEntry', Sort.asc);
    });
  }

  QueryBuilder<DeepworkSession, DeepworkSession, QAfterSortBy>
      thenByIsManualEntryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isManualEntry', Sort.desc);
    });
  }

  QueryBuilder<DeepworkSession, DeepworkSession, QAfterSortBy>
      thenByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.asc);
    });
  }

  QueryBuilder<DeepworkSession, DeepworkSession, QAfterSortBy>
      thenByStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.desc);
    });
  }
}

extension DeepworkSessionQueryWhereDistinct
    on QueryBuilder<DeepworkSession, DeepworkSession, QDistinct> {
  QueryBuilder<DeepworkSession, DeepworkSession, QDistinct>
      distinctByDurationInMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'durationInMinutes');
    });
  }

  QueryBuilder<DeepworkSession, DeepworkSession, QDistinct>
      distinctByDurationInSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'durationInSeconds');
    });
  }

  QueryBuilder<DeepworkSession, DeepworkSession, QDistinct>
      distinctByEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endTime');
    });
  }

  QueryBuilder<DeepworkSession, DeepworkSession, QDistinct>
      distinctByIsManualEntry() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isManualEntry');
    });
  }

  QueryBuilder<DeepworkSession, DeepworkSession, QDistinct>
      distinctByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startTime');
    });
  }
}

extension DeepworkSessionQueryProperty
    on QueryBuilder<DeepworkSession, DeepworkSession, QQueryProperty> {
  QueryBuilder<DeepworkSession, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DeepworkSession, int, QQueryOperations>
      durationInMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'durationInMinutes');
    });
  }

  QueryBuilder<DeepworkSession, int, QQueryOperations>
      durationInSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'durationInSeconds');
    });
  }

  QueryBuilder<DeepworkSession, DateTime, QQueryOperations> endTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endTime');
    });
  }

  QueryBuilder<DeepworkSession, bool, QQueryOperations>
      isManualEntryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isManualEntry');
    });
  }

  QueryBuilder<DeepworkSession, DateTime, QQueryOperations>
      startTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startTime');
    });
  }
}
