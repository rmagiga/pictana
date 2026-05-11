// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $RecentFoldersTable extends RecentFolders
    with TableInfo<$RecentFoldersTable, RecentFolder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecentFoldersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _uriMeta = const VerificationMeta('uri');
  @override
  late final GeneratedColumn<String> uri = GeneratedColumn<String>(
    'uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _platformTypeMeta = const VerificationMeta(
    'platformType',
  );
  @override
  late final GeneratedColumn<String> platformType = GeneratedColumn<String>(
    'platform_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastOpenedAtMeta = const VerificationMeta(
    'lastOpenedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastOpenedAt = GeneratedColumn<DateTime>(
    'last_opened_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uri,
    name,
    platformType,
    lastOpenedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recent_folders';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecentFolder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uri')) {
      context.handle(
        _uriMeta,
        uri.isAcceptableOrUnknown(data['uri']!, _uriMeta),
      );
    } else if (isInserting) {
      context.missing(_uriMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('platform_type')) {
      context.handle(
        _platformTypeMeta,
        platformType.isAcceptableOrUnknown(
          data['platform_type']!,
          _platformTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_platformTypeMeta);
    }
    if (data.containsKey('last_opened_at')) {
      context.handle(
        _lastOpenedAtMeta,
        lastOpenedAt.isAcceptableOrUnknown(
          data['last_opened_at']!,
          _lastOpenedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastOpenedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecentFolder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecentFolder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uri'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      platformType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}platform_type'],
      )!,
      lastOpenedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_opened_at'],
      )!,
    );
  }

  @override
  $RecentFoldersTable createAlias(String alias) {
    return $RecentFoldersTable(attachedDatabase, alias);
  }
}

class RecentFolder extends DataClass implements Insertable<RecentFolder> {
  /// 主キー（自動インクリメント）
  final int id;

  /// フォルダ URI
  final String uri;

  /// フォルダ表示名
  final String name;

  /// プラットフォーム種別 ("android" / "windows")
  final String platformType;

  /// 最終アクセス日時
  final DateTime lastOpenedAt;
  const RecentFolder({
    required this.id,
    required this.uri,
    required this.name,
    required this.platformType,
    required this.lastOpenedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uri'] = Variable<String>(uri);
    map['name'] = Variable<String>(name);
    map['platform_type'] = Variable<String>(platformType);
    map['last_opened_at'] = Variable<DateTime>(lastOpenedAt);
    return map;
  }

  RecentFoldersCompanion toCompanion(bool nullToAbsent) {
    return RecentFoldersCompanion(
      id: Value(id),
      uri: Value(uri),
      name: Value(name),
      platformType: Value(platformType),
      lastOpenedAt: Value(lastOpenedAt),
    );
  }

  factory RecentFolder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecentFolder(
      id: serializer.fromJson<int>(json['id']),
      uri: serializer.fromJson<String>(json['uri']),
      name: serializer.fromJson<String>(json['name']),
      platformType: serializer.fromJson<String>(json['platformType']),
      lastOpenedAt: serializer.fromJson<DateTime>(json['lastOpenedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uri': serializer.toJson<String>(uri),
      'name': serializer.toJson<String>(name),
      'platformType': serializer.toJson<String>(platformType),
      'lastOpenedAt': serializer.toJson<DateTime>(lastOpenedAt),
    };
  }

  RecentFolder copyWith({
    int? id,
    String? uri,
    String? name,
    String? platformType,
    DateTime? lastOpenedAt,
  }) => RecentFolder(
    id: id ?? this.id,
    uri: uri ?? this.uri,
    name: name ?? this.name,
    platformType: platformType ?? this.platformType,
    lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
  );
  RecentFolder copyWithCompanion(RecentFoldersCompanion data) {
    return RecentFolder(
      id: data.id.present ? data.id.value : this.id,
      uri: data.uri.present ? data.uri.value : this.uri,
      name: data.name.present ? data.name.value : this.name,
      platformType: data.platformType.present
          ? data.platformType.value
          : this.platformType,
      lastOpenedAt: data.lastOpenedAt.present
          ? data.lastOpenedAt.value
          : this.lastOpenedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecentFolder(')
          ..write('id: $id, ')
          ..write('uri: $uri, ')
          ..write('name: $name, ')
          ..write('platformType: $platformType, ')
          ..write('lastOpenedAt: $lastOpenedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, uri, name, platformType, lastOpenedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecentFolder &&
          other.id == this.id &&
          other.uri == this.uri &&
          other.name == this.name &&
          other.platformType == this.platformType &&
          other.lastOpenedAt == this.lastOpenedAt);
}

class RecentFoldersCompanion extends UpdateCompanion<RecentFolder> {
  final Value<int> id;
  final Value<String> uri;
  final Value<String> name;
  final Value<String> platformType;
  final Value<DateTime> lastOpenedAt;
  const RecentFoldersCompanion({
    this.id = const Value.absent(),
    this.uri = const Value.absent(),
    this.name = const Value.absent(),
    this.platformType = const Value.absent(),
    this.lastOpenedAt = const Value.absent(),
  });
  RecentFoldersCompanion.insert({
    this.id = const Value.absent(),
    required String uri,
    required String name,
    required String platformType,
    required DateTime lastOpenedAt,
  }) : uri = Value(uri),
       name = Value(name),
       platformType = Value(platformType),
       lastOpenedAt = Value(lastOpenedAt);
  static Insertable<RecentFolder> custom({
    Expression<int>? id,
    Expression<String>? uri,
    Expression<String>? name,
    Expression<String>? platformType,
    Expression<DateTime>? lastOpenedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uri != null) 'uri': uri,
      if (name != null) 'name': name,
      if (platformType != null) 'platform_type': platformType,
      if (lastOpenedAt != null) 'last_opened_at': lastOpenedAt,
    });
  }

  RecentFoldersCompanion copyWith({
    Value<int>? id,
    Value<String>? uri,
    Value<String>? name,
    Value<String>? platformType,
    Value<DateTime>? lastOpenedAt,
  }) {
    return RecentFoldersCompanion(
      id: id ?? this.id,
      uri: uri ?? this.uri,
      name: name ?? this.name,
      platformType: platformType ?? this.platformType,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uri.present) {
      map['uri'] = Variable<String>(uri.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (platformType.present) {
      map['platform_type'] = Variable<String>(platformType.value);
    }
    if (lastOpenedAt.present) {
      map['last_opened_at'] = Variable<DateTime>(lastOpenedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecentFoldersCompanion(')
          ..write('id: $id, ')
          ..write('uri: $uri, ')
          ..write('name: $name, ')
          ..write('platformType: $platformType, ')
          ..write('lastOpenedAt: $lastOpenedAt')
          ..write(')'))
        .toString();
  }
}

class $ThumbnailCachesTable extends ThumbnailCaches
    with TableInfo<$ThumbnailCachesTable, ThumbnailCache> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ThumbnailCachesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _imageUriMeta = const VerificationMeta(
    'imageUri',
  );
  @override
  late final GeneratedColumn<String> imageUri = GeneratedColumn<String>(
    'image_uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _cachePathMeta = const VerificationMeta(
    'cachePath',
  );
  @override
  late final GeneratedColumn<String> cachePath = GeneratedColumn<String>(
    'cache_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    imageUri,
    cachePath,
    width,
    height,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'thumbnail_caches';
  @override
  VerificationContext validateIntegrity(
    Insertable<ThumbnailCache> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('image_uri')) {
      context.handle(
        _imageUriMeta,
        imageUri.isAcceptableOrUnknown(data['image_uri']!, _imageUriMeta),
      );
    } else if (isInserting) {
      context.missing(_imageUriMeta);
    }
    if (data.containsKey('cache_path')) {
      context.handle(
        _cachePathMeta,
        cachePath.isAcceptableOrUnknown(data['cache_path']!, _cachePathMeta),
      );
    } else if (isInserting) {
      context.missing(_cachePathMeta);
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    } else if (isInserting) {
      context.missing(_widthMeta);
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    } else if (isInserting) {
      context.missing(_heightMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ThumbnailCache map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ThumbnailCache(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      imageUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_uri'],
      )!,
      cachePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cache_path'],
      )!,
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      )!,
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ThumbnailCachesTable createAlias(String alias) {
    return $ThumbnailCachesTable(attachedDatabase, alias);
  }
}

class ThumbnailCache extends DataClass implements Insertable<ThumbnailCache> {
  /// 主キー（自動インクリメント）
  final int id;

  /// 元画像 URI
  final String imageUri;

  /// ディスクキャッシュのファイルパス
  final String cachePath;

  /// サムネイル幅 (px)
  final int width;

  /// サムネイル高さ (px)
  final int height;

  /// キャッシュ更新日時
  final DateTime updatedAt;
  const ThumbnailCache({
    required this.id,
    required this.imageUri,
    required this.cachePath,
    required this.width,
    required this.height,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['image_uri'] = Variable<String>(imageUri);
    map['cache_path'] = Variable<String>(cachePath);
    map['width'] = Variable<int>(width);
    map['height'] = Variable<int>(height);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ThumbnailCachesCompanion toCompanion(bool nullToAbsent) {
    return ThumbnailCachesCompanion(
      id: Value(id),
      imageUri: Value(imageUri),
      cachePath: Value(cachePath),
      width: Value(width),
      height: Value(height),
      updatedAt: Value(updatedAt),
    );
  }

  factory ThumbnailCache.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ThumbnailCache(
      id: serializer.fromJson<int>(json['id']),
      imageUri: serializer.fromJson<String>(json['imageUri']),
      cachePath: serializer.fromJson<String>(json['cachePath']),
      width: serializer.fromJson<int>(json['width']),
      height: serializer.fromJson<int>(json['height']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'imageUri': serializer.toJson<String>(imageUri),
      'cachePath': serializer.toJson<String>(cachePath),
      'width': serializer.toJson<int>(width),
      'height': serializer.toJson<int>(height),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ThumbnailCache copyWith({
    int? id,
    String? imageUri,
    String? cachePath,
    int? width,
    int? height,
    DateTime? updatedAt,
  }) => ThumbnailCache(
    id: id ?? this.id,
    imageUri: imageUri ?? this.imageUri,
    cachePath: cachePath ?? this.cachePath,
    width: width ?? this.width,
    height: height ?? this.height,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ThumbnailCache copyWithCompanion(ThumbnailCachesCompanion data) {
    return ThumbnailCache(
      id: data.id.present ? data.id.value : this.id,
      imageUri: data.imageUri.present ? data.imageUri.value : this.imageUri,
      cachePath: data.cachePath.present ? data.cachePath.value : this.cachePath,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ThumbnailCache(')
          ..write('id: $id, ')
          ..write('imageUri: $imageUri, ')
          ..write('cachePath: $cachePath, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, imageUri, cachePath, width, height, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ThumbnailCache &&
          other.id == this.id &&
          other.imageUri == this.imageUri &&
          other.cachePath == this.cachePath &&
          other.width == this.width &&
          other.height == this.height &&
          other.updatedAt == this.updatedAt);
}

class ThumbnailCachesCompanion extends UpdateCompanion<ThumbnailCache> {
  final Value<int> id;
  final Value<String> imageUri;
  final Value<String> cachePath;
  final Value<int> width;
  final Value<int> height;
  final Value<DateTime> updatedAt;
  const ThumbnailCachesCompanion({
    this.id = const Value.absent(),
    this.imageUri = const Value.absent(),
    this.cachePath = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ThumbnailCachesCompanion.insert({
    this.id = const Value.absent(),
    required String imageUri,
    required String cachePath,
    required int width,
    required int height,
    required DateTime updatedAt,
  }) : imageUri = Value(imageUri),
       cachePath = Value(cachePath),
       width = Value(width),
       height = Value(height),
       updatedAt = Value(updatedAt);
  static Insertable<ThumbnailCache> custom({
    Expression<int>? id,
    Expression<String>? imageUri,
    Expression<String>? cachePath,
    Expression<int>? width,
    Expression<int>? height,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (imageUri != null) 'image_uri': imageUri,
      if (cachePath != null) 'cache_path': cachePath,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ThumbnailCachesCompanion copyWith({
    Value<int>? id,
    Value<String>? imageUri,
    Value<String>? cachePath,
    Value<int>? width,
    Value<int>? height,
    Value<DateTime>? updatedAt,
  }) {
    return ThumbnailCachesCompanion(
      id: id ?? this.id,
      imageUri: imageUri ?? this.imageUri,
      cachePath: cachePath ?? this.cachePath,
      width: width ?? this.width,
      height: height ?? this.height,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (imageUri.present) {
      map['image_uri'] = Variable<String>(imageUri.value);
    }
    if (cachePath.present) {
      map['cache_path'] = Variable<String>(cachePath.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ThumbnailCachesCompanion(')
          ..write('id: $id, ')
          ..write('imageUri: $imageUri, ')
          ..write('cachePath: $cachePath, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  /// 設定キー（主キー）
  final String key;

  /// 設定値（JSON文字列）
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RecentFoldersTable recentFolders = $RecentFoldersTable(this);
  late final $ThumbnailCachesTable thumbnailCaches = $ThumbnailCachesTable(
    this,
  );
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    recentFolders,
    thumbnailCaches,
    appSettings,
  ];
}

typedef $$RecentFoldersTableCreateCompanionBuilder =
    RecentFoldersCompanion Function({
      Value<int> id,
      required String uri,
      required String name,
      required String platformType,
      required DateTime lastOpenedAt,
    });
typedef $$RecentFoldersTableUpdateCompanionBuilder =
    RecentFoldersCompanion Function({
      Value<int> id,
      Value<String> uri,
      Value<String> name,
      Value<String> platformType,
      Value<DateTime> lastOpenedAt,
    });

class $$RecentFoldersTableFilterComposer
    extends Composer<_$AppDatabase, $RecentFoldersTable> {
  $$RecentFoldersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uri => $composableBuilder(
    column: $table.uri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get platformType => $composableBuilder(
    column: $table.platformType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecentFoldersTableOrderingComposer
    extends Composer<_$AppDatabase, $RecentFoldersTable> {
  $$RecentFoldersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uri => $composableBuilder(
    column: $table.uri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get platformType => $composableBuilder(
    column: $table.platformType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecentFoldersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecentFoldersTable> {
  $$RecentFoldersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uri =>
      $composableBuilder(column: $table.uri, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get platformType => $composableBuilder(
    column: $table.platformType,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => column,
  );
}

class $$RecentFoldersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecentFoldersTable,
          RecentFolder,
          $$RecentFoldersTableFilterComposer,
          $$RecentFoldersTableOrderingComposer,
          $$RecentFoldersTableAnnotationComposer,
          $$RecentFoldersTableCreateCompanionBuilder,
          $$RecentFoldersTableUpdateCompanionBuilder,
          (
            RecentFolder,
            BaseReferences<_$AppDatabase, $RecentFoldersTable, RecentFolder>,
          ),
          RecentFolder,
          PrefetchHooks Function()
        > {
  $$RecentFoldersTableTableManager(_$AppDatabase db, $RecentFoldersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecentFoldersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecentFoldersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecentFoldersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uri = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> platformType = const Value.absent(),
                Value<DateTime> lastOpenedAt = const Value.absent(),
              }) => RecentFoldersCompanion(
                id: id,
                uri: uri,
                name: name,
                platformType: platformType,
                lastOpenedAt: lastOpenedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uri,
                required String name,
                required String platformType,
                required DateTime lastOpenedAt,
              }) => RecentFoldersCompanion.insert(
                id: id,
                uri: uri,
                name: name,
                platformType: platformType,
                lastOpenedAt: lastOpenedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecentFoldersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecentFoldersTable,
      RecentFolder,
      $$RecentFoldersTableFilterComposer,
      $$RecentFoldersTableOrderingComposer,
      $$RecentFoldersTableAnnotationComposer,
      $$RecentFoldersTableCreateCompanionBuilder,
      $$RecentFoldersTableUpdateCompanionBuilder,
      (
        RecentFolder,
        BaseReferences<_$AppDatabase, $RecentFoldersTable, RecentFolder>,
      ),
      RecentFolder,
      PrefetchHooks Function()
    >;
typedef $$ThumbnailCachesTableCreateCompanionBuilder =
    ThumbnailCachesCompanion Function({
      Value<int> id,
      required String imageUri,
      required String cachePath,
      required int width,
      required int height,
      required DateTime updatedAt,
    });
typedef $$ThumbnailCachesTableUpdateCompanionBuilder =
    ThumbnailCachesCompanion Function({
      Value<int> id,
      Value<String> imageUri,
      Value<String> cachePath,
      Value<int> width,
      Value<int> height,
      Value<DateTime> updatedAt,
    });

class $$ThumbnailCachesTableFilterComposer
    extends Composer<_$AppDatabase, $ThumbnailCachesTable> {
  $$ThumbnailCachesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUri => $composableBuilder(
    column: $table.imageUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cachePath => $composableBuilder(
    column: $table.cachePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ThumbnailCachesTableOrderingComposer
    extends Composer<_$AppDatabase, $ThumbnailCachesTable> {
  $$ThumbnailCachesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUri => $composableBuilder(
    column: $table.imageUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cachePath => $composableBuilder(
    column: $table.cachePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ThumbnailCachesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ThumbnailCachesTable> {
  $$ThumbnailCachesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get imageUri =>
      $composableBuilder(column: $table.imageUri, builder: (column) => column);

  GeneratedColumn<String> get cachePath =>
      $composableBuilder(column: $table.cachePath, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ThumbnailCachesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ThumbnailCachesTable,
          ThumbnailCache,
          $$ThumbnailCachesTableFilterComposer,
          $$ThumbnailCachesTableOrderingComposer,
          $$ThumbnailCachesTableAnnotationComposer,
          $$ThumbnailCachesTableCreateCompanionBuilder,
          $$ThumbnailCachesTableUpdateCompanionBuilder,
          (
            ThumbnailCache,
            BaseReferences<
              _$AppDatabase,
              $ThumbnailCachesTable,
              ThumbnailCache
            >,
          ),
          ThumbnailCache,
          PrefetchHooks Function()
        > {
  $$ThumbnailCachesTableTableManager(
    _$AppDatabase db,
    $ThumbnailCachesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ThumbnailCachesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ThumbnailCachesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ThumbnailCachesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> imageUri = const Value.absent(),
                Value<String> cachePath = const Value.absent(),
                Value<int> width = const Value.absent(),
                Value<int> height = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ThumbnailCachesCompanion(
                id: id,
                imageUri: imageUri,
                cachePath: cachePath,
                width: width,
                height: height,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String imageUri,
                required String cachePath,
                required int width,
                required int height,
                required DateTime updatedAt,
              }) => ThumbnailCachesCompanion.insert(
                id: id,
                imageUri: imageUri,
                cachePath: cachePath,
                width: width,
                height: height,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ThumbnailCachesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ThumbnailCachesTable,
      ThumbnailCache,
      $$ThumbnailCachesTableFilterComposer,
      $$ThumbnailCachesTableOrderingComposer,
      $$ThumbnailCachesTableAnnotationComposer,
      $$ThumbnailCachesTableCreateCompanionBuilder,
      $$ThumbnailCachesTableUpdateCompanionBuilder,
      (
        ThumbnailCache,
        BaseReferences<_$AppDatabase, $ThumbnailCachesTable, ThumbnailCache>,
      ),
      ThumbnailCache,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RecentFoldersTableTableManager get recentFolders =>
      $$RecentFoldersTableTableManager(_db, _db.recentFolders);
  $$ThumbnailCachesTableTableManager get thumbnailCaches =>
      $$ThumbnailCachesTableTableManager(_db, _db.thumbnailCaches);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
