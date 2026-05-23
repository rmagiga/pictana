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

class $FavoriteFoldersTable extends FavoriteFolders
    with TableInfo<$FavoriteFoldersTable, FavoriteFolder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoriteFoldersTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
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
  static const VerificationMeta _registeredAtMeta = const VerificationMeta(
    'registeredAt',
  );
  @override
  late final GeneratedColumn<DateTime> registeredAt = GeneratedColumn<DateTime>(
    'registered_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, uri, name, registeredAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorite_folders';
  @override
  VerificationContext validateIntegrity(
    Insertable<FavoriteFolder> instance, {
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
    if (data.containsKey('registered_at')) {
      context.handle(
        _registeredAtMeta,
        registeredAt.isAcceptableOrUnknown(
          data['registered_at']!,
          _registeredAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_registeredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FavoriteFolder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteFolder(
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
      registeredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}registered_at'],
      )!,
    );
  }

  @override
  $FavoriteFoldersTable createAlias(String alias) {
    return $FavoriteFoldersTable(attachedDatabase, alias);
  }
}

class FavoriteFolder extends DataClass implements Insertable<FavoriteFolder> {
  /// 主キー（自動インクリメント）
  final int id;

  /// フォルダ URI（ユニーク制約）
  final String uri;

  /// フォルダ表示名
  final String name;

  /// お気に入り登録日時
  final DateTime registeredAt;
  const FavoriteFolder({
    required this.id,
    required this.uri,
    required this.name,
    required this.registeredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uri'] = Variable<String>(uri);
    map['name'] = Variable<String>(name);
    map['registered_at'] = Variable<DateTime>(registeredAt);
    return map;
  }

  FavoriteFoldersCompanion toCompanion(bool nullToAbsent) {
    return FavoriteFoldersCompanion(
      id: Value(id),
      uri: Value(uri),
      name: Value(name),
      registeredAt: Value(registeredAt),
    );
  }

  factory FavoriteFolder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteFolder(
      id: serializer.fromJson<int>(json['id']),
      uri: serializer.fromJson<String>(json['uri']),
      name: serializer.fromJson<String>(json['name']),
      registeredAt: serializer.fromJson<DateTime>(json['registeredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uri': serializer.toJson<String>(uri),
      'name': serializer.toJson<String>(name),
      'registeredAt': serializer.toJson<DateTime>(registeredAt),
    };
  }

  FavoriteFolder copyWith({
    int? id,
    String? uri,
    String? name,
    DateTime? registeredAt,
  }) => FavoriteFolder(
    id: id ?? this.id,
    uri: uri ?? this.uri,
    name: name ?? this.name,
    registeredAt: registeredAt ?? this.registeredAt,
  );
  FavoriteFolder copyWithCompanion(FavoriteFoldersCompanion data) {
    return FavoriteFolder(
      id: data.id.present ? data.id.value : this.id,
      uri: data.uri.present ? data.uri.value : this.uri,
      name: data.name.present ? data.name.value : this.name,
      registeredAt: data.registeredAt.present
          ? data.registeredAt.value
          : this.registeredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteFolder(')
          ..write('id: $id, ')
          ..write('uri: $uri, ')
          ..write('name: $name, ')
          ..write('registeredAt: $registeredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, uri, name, registeredAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteFolder &&
          other.id == this.id &&
          other.uri == this.uri &&
          other.name == this.name &&
          other.registeredAt == this.registeredAt);
}

class FavoriteFoldersCompanion extends UpdateCompanion<FavoriteFolder> {
  final Value<int> id;
  final Value<String> uri;
  final Value<String> name;
  final Value<DateTime> registeredAt;
  const FavoriteFoldersCompanion({
    this.id = const Value.absent(),
    this.uri = const Value.absent(),
    this.name = const Value.absent(),
    this.registeredAt = const Value.absent(),
  });
  FavoriteFoldersCompanion.insert({
    this.id = const Value.absent(),
    required String uri,
    required String name,
    required DateTime registeredAt,
  }) : uri = Value(uri),
       name = Value(name),
       registeredAt = Value(registeredAt);
  static Insertable<FavoriteFolder> custom({
    Expression<int>? id,
    Expression<String>? uri,
    Expression<String>? name,
    Expression<DateTime>? registeredAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uri != null) 'uri': uri,
      if (name != null) 'name': name,
      if (registeredAt != null) 'registered_at': registeredAt,
    });
  }

  FavoriteFoldersCompanion copyWith({
    Value<int>? id,
    Value<String>? uri,
    Value<String>? name,
    Value<DateTime>? registeredAt,
  }) {
    return FavoriteFoldersCompanion(
      id: id ?? this.id,
      uri: uri ?? this.uri,
      name: name ?? this.name,
      registeredAt: registeredAt ?? this.registeredAt,
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
    if (registeredAt.present) {
      map['registered_at'] = Variable<DateTime>(registeredAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteFoldersCompanion(')
          ..write('id: $id, ')
          ..write('uri: $uri, ')
          ..write('name: $name, ')
          ..write('registeredAt: $registeredAt')
          ..write(')'))
        .toString();
  }
}

class $ImagesTable extends Images with TableInfo<$ImagesTable, ImageTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  @override
  late final GeneratedColumn<String> entryId = GeneratedColumn<String>(
    'entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _folderUriMeta = const VerificationMeta(
    'folderUri',
  );
  @override
  late final GeneratedColumn<String> folderUri = GeneratedColumn<String>(
    'folder_uri',
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
  static const VerificationMeta _extensionMeta = const VerificationMeta(
    'extension',
  );
  @override
  late final GeneratedColumn<String> extension = GeneratedColumn<String>(
    'extension',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modifiedMeta = const VerificationMeta(
    'modified',
  );
  @override
  late final GeneratedColumn<int> modified = GeneratedColumn<int>(
    'modified',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<int> size = GeneratedColumn<int>(
    'size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
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
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _indexedAtMeta = const VerificationMeta(
    'indexedAt',
  );
  @override
  late final GeneratedColumn<DateTime> indexedAt = GeneratedColumn<DateTime>(
    'indexed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    entryId,
    uri,
    folderUri,
    name,
    extension,
    modified,
    size,
    mimeType,
    width,
    height,
    indexedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'images';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImageTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('uri')) {
      context.handle(
        _uriMeta,
        uri.isAcceptableOrUnknown(data['uri']!, _uriMeta),
      );
    } else if (isInserting) {
      context.missing(_uriMeta);
    }
    if (data.containsKey('folder_uri')) {
      context.handle(
        _folderUriMeta,
        folderUri.isAcceptableOrUnknown(data['folder_uri']!, _folderUriMeta),
      );
    } else if (isInserting) {
      context.missing(_folderUriMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('extension')) {
      context.handle(
        _extensionMeta,
        extension.isAcceptableOrUnknown(data['extension']!, _extensionMeta),
      );
    } else if (isInserting) {
      context.missing(_extensionMeta);
    }
    if (data.containsKey('modified')) {
      context.handle(
        _modifiedMeta,
        modified.isAcceptableOrUnknown(data['modified']!, _modifiedMeta),
      );
    } else if (isInserting) {
      context.missing(_modifiedMeta);
    }
    if (data.containsKey('size')) {
      context.handle(
        _sizeMeta,
        size.isAcceptableOrUnknown(data['size']!, _sizeMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('indexed_at')) {
      context.handle(
        _indexedAtMeta,
        indexedAt.isAcceptableOrUnknown(data['indexed_at']!, _indexedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_indexedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entryId};
  @override
  ImageTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImageTableData(
      entryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_id'],
      )!,
      uri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uri'],
      )!,
      folderUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folder_uri'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      extension: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extension'],
      )!,
      modified: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}modified'],
      )!,
      size: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      ),
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      ),
      indexedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}indexed_at'],
      )!,
    );
  }

  @override
  $ImagesTable createAlias(String alias) {
    return $ImagesTable(attachedDatabase, alias);
  }
}

class ImageTableData extends DataClass implements Insertable<ImageTableData> {
  /// 画像の識別子 (EntryId)
  final String entryId;

  /// アクセス用 URI 文字列
  final String uri;

  /// 所属フォルダの URI
  final String folderUri;

  /// ファイル名
  final String name;

  /// 拡張子 (小文字、ドットなし)
  final String extension;

  /// 最終更新時刻 (エポックミリ秒)
  final int modified;

  /// ファイルサイズ (バイト)
  final int size;

  /// MIMEタイプ
  final String mimeType;

  /// 画像の幅 (px, null許容)
  final int? width;

  /// 画像の高さ (px, null許容)
  final int? height;

  /// インデックス作成/更新日時
  final DateTime indexedAt;
  const ImageTableData({
    required this.entryId,
    required this.uri,
    required this.folderUri,
    required this.name,
    required this.extension,
    required this.modified,
    required this.size,
    required this.mimeType,
    this.width,
    this.height,
    required this.indexedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entry_id'] = Variable<String>(entryId);
    map['uri'] = Variable<String>(uri);
    map['folder_uri'] = Variable<String>(folderUri);
    map['name'] = Variable<String>(name);
    map['extension'] = Variable<String>(extension);
    map['modified'] = Variable<int>(modified);
    map['size'] = Variable<int>(size);
    map['mime_type'] = Variable<String>(mimeType);
    if (!nullToAbsent || width != null) {
      map['width'] = Variable<int>(width);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<int>(height);
    }
    map['indexed_at'] = Variable<DateTime>(indexedAt);
    return map;
  }

  ImagesCompanion toCompanion(bool nullToAbsent) {
    return ImagesCompanion(
      entryId: Value(entryId),
      uri: Value(uri),
      folderUri: Value(folderUri),
      name: Value(name),
      extension: Value(extension),
      modified: Value(modified),
      size: Value(size),
      mimeType: Value(mimeType),
      width: width == null && nullToAbsent
          ? const Value.absent()
          : Value(width),
      height: height == null && nullToAbsent
          ? const Value.absent()
          : Value(height),
      indexedAt: Value(indexedAt),
    );
  }

  factory ImageTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImageTableData(
      entryId: serializer.fromJson<String>(json['entryId']),
      uri: serializer.fromJson<String>(json['uri']),
      folderUri: serializer.fromJson<String>(json['folderUri']),
      name: serializer.fromJson<String>(json['name']),
      extension: serializer.fromJson<String>(json['extension']),
      modified: serializer.fromJson<int>(json['modified']),
      size: serializer.fromJson<int>(json['size']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      width: serializer.fromJson<int?>(json['width']),
      height: serializer.fromJson<int?>(json['height']),
      indexedAt: serializer.fromJson<DateTime>(json['indexedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entryId': serializer.toJson<String>(entryId),
      'uri': serializer.toJson<String>(uri),
      'folderUri': serializer.toJson<String>(folderUri),
      'name': serializer.toJson<String>(name),
      'extension': serializer.toJson<String>(extension),
      'modified': serializer.toJson<int>(modified),
      'size': serializer.toJson<int>(size),
      'mimeType': serializer.toJson<String>(mimeType),
      'width': serializer.toJson<int?>(width),
      'height': serializer.toJson<int?>(height),
      'indexedAt': serializer.toJson<DateTime>(indexedAt),
    };
  }

  ImageTableData copyWith({
    String? entryId,
    String? uri,
    String? folderUri,
    String? name,
    String? extension,
    int? modified,
    int? size,
    String? mimeType,
    Value<int?> width = const Value.absent(),
    Value<int?> height = const Value.absent(),
    DateTime? indexedAt,
  }) => ImageTableData(
    entryId: entryId ?? this.entryId,
    uri: uri ?? this.uri,
    folderUri: folderUri ?? this.folderUri,
    name: name ?? this.name,
    extension: extension ?? this.extension,
    modified: modified ?? this.modified,
    size: size ?? this.size,
    mimeType: mimeType ?? this.mimeType,
    width: width.present ? width.value : this.width,
    height: height.present ? height.value : this.height,
    indexedAt: indexedAt ?? this.indexedAt,
  );
  ImageTableData copyWithCompanion(ImagesCompanion data) {
    return ImageTableData(
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      uri: data.uri.present ? data.uri.value : this.uri,
      folderUri: data.folderUri.present ? data.folderUri.value : this.folderUri,
      name: data.name.present ? data.name.value : this.name,
      extension: data.extension.present ? data.extension.value : this.extension,
      modified: data.modified.present ? data.modified.value : this.modified,
      size: data.size.present ? data.size.value : this.size,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      indexedAt: data.indexedAt.present ? data.indexedAt.value : this.indexedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImageTableData(')
          ..write('entryId: $entryId, ')
          ..write('uri: $uri, ')
          ..write('folderUri: $folderUri, ')
          ..write('name: $name, ')
          ..write('extension: $extension, ')
          ..write('modified: $modified, ')
          ..write('size: $size, ')
          ..write('mimeType: $mimeType, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('indexedAt: $indexedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    entryId,
    uri,
    folderUri,
    name,
    extension,
    modified,
    size,
    mimeType,
    width,
    height,
    indexedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImageTableData &&
          other.entryId == this.entryId &&
          other.uri == this.uri &&
          other.folderUri == this.folderUri &&
          other.name == this.name &&
          other.extension == this.extension &&
          other.modified == this.modified &&
          other.size == this.size &&
          other.mimeType == this.mimeType &&
          other.width == this.width &&
          other.height == this.height &&
          other.indexedAt == this.indexedAt);
}

class ImagesCompanion extends UpdateCompanion<ImageTableData> {
  final Value<String> entryId;
  final Value<String> uri;
  final Value<String> folderUri;
  final Value<String> name;
  final Value<String> extension;
  final Value<int> modified;
  final Value<int> size;
  final Value<String> mimeType;
  final Value<int?> width;
  final Value<int?> height;
  final Value<DateTime> indexedAt;
  final Value<int> rowid;
  const ImagesCompanion({
    this.entryId = const Value.absent(),
    this.uri = const Value.absent(),
    this.folderUri = const Value.absent(),
    this.name = const Value.absent(),
    this.extension = const Value.absent(),
    this.modified = const Value.absent(),
    this.size = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.indexedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImagesCompanion.insert({
    required String entryId,
    required String uri,
    required String folderUri,
    required String name,
    required String extension,
    required int modified,
    required int size,
    required String mimeType,
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    required DateTime indexedAt,
    this.rowid = const Value.absent(),
  }) : entryId = Value(entryId),
       uri = Value(uri),
       folderUri = Value(folderUri),
       name = Value(name),
       extension = Value(extension),
       modified = Value(modified),
       size = Value(size),
       mimeType = Value(mimeType),
       indexedAt = Value(indexedAt);
  static Insertable<ImageTableData> custom({
    Expression<String>? entryId,
    Expression<String>? uri,
    Expression<String>? folderUri,
    Expression<String>? name,
    Expression<String>? extension,
    Expression<int>? modified,
    Expression<int>? size,
    Expression<String>? mimeType,
    Expression<int>? width,
    Expression<int>? height,
    Expression<DateTime>? indexedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entryId != null) 'entry_id': entryId,
      if (uri != null) 'uri': uri,
      if (folderUri != null) 'folder_uri': folderUri,
      if (name != null) 'name': name,
      if (extension != null) 'extension': extension,
      if (modified != null) 'modified': modified,
      if (size != null) 'size': size,
      if (mimeType != null) 'mime_type': mimeType,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (indexedAt != null) 'indexed_at': indexedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImagesCompanion copyWith({
    Value<String>? entryId,
    Value<String>? uri,
    Value<String>? folderUri,
    Value<String>? name,
    Value<String>? extension,
    Value<int>? modified,
    Value<int>? size,
    Value<String>? mimeType,
    Value<int?>? width,
    Value<int?>? height,
    Value<DateTime>? indexedAt,
    Value<int>? rowid,
  }) {
    return ImagesCompanion(
      entryId: entryId ?? this.entryId,
      uri: uri ?? this.uri,
      folderUri: folderUri ?? this.folderUri,
      name: name ?? this.name,
      extension: extension ?? this.extension,
      modified: modified ?? this.modified,
      size: size ?? this.size,
      mimeType: mimeType ?? this.mimeType,
      width: width ?? this.width,
      height: height ?? this.height,
      indexedAt: indexedAt ?? this.indexedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entryId.present) {
      map['entry_id'] = Variable<String>(entryId.value);
    }
    if (uri.present) {
      map['uri'] = Variable<String>(uri.value);
    }
    if (folderUri.present) {
      map['folder_uri'] = Variable<String>(folderUri.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (extension.present) {
      map['extension'] = Variable<String>(extension.value);
    }
    if (modified.present) {
      map['modified'] = Variable<int>(modified.value);
    }
    if (size.present) {
      map['size'] = Variable<int>(size.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (indexedAt.present) {
      map['indexed_at'] = Variable<DateTime>(indexedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImagesCompanion(')
          ..write('entryId: $entryId, ')
          ..write('uri: $uri, ')
          ..write('folderUri: $folderUri, ')
          ..write('name: $name, ')
          ..write('extension: $extension, ')
          ..write('modified: $modified, ')
          ..write('size: $size, ')
          ..write('mimeType: $mimeType, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('indexedAt: $indexedAt, ')
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
  late final $FavoriteFoldersTable favoriteFolders = $FavoriteFoldersTable(
    this,
  );
  late final $ImagesTable images = $ImagesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    recentFolders,
    thumbnailCaches,
    appSettings,
    favoriteFolders,
    images,
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
typedef $$FavoriteFoldersTableCreateCompanionBuilder =
    FavoriteFoldersCompanion Function({
      Value<int> id,
      required String uri,
      required String name,
      required DateTime registeredAt,
    });
typedef $$FavoriteFoldersTableUpdateCompanionBuilder =
    FavoriteFoldersCompanion Function({
      Value<int> id,
      Value<String> uri,
      Value<String> name,
      Value<DateTime> registeredAt,
    });

class $$FavoriteFoldersTableFilterComposer
    extends Composer<_$AppDatabase, $FavoriteFoldersTable> {
  $$FavoriteFoldersTableFilterComposer({
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

  ColumnFilters<DateTime> get registeredAt => $composableBuilder(
    column: $table.registeredAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FavoriteFoldersTableOrderingComposer
    extends Composer<_$AppDatabase, $FavoriteFoldersTable> {
  $$FavoriteFoldersTableOrderingComposer({
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

  ColumnOrderings<DateTime> get registeredAt => $composableBuilder(
    column: $table.registeredAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FavoriteFoldersTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavoriteFoldersTable> {
  $$FavoriteFoldersTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get registeredAt => $composableBuilder(
    column: $table.registeredAt,
    builder: (column) => column,
  );
}

class $$FavoriteFoldersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FavoriteFoldersTable,
          FavoriteFolder,
          $$FavoriteFoldersTableFilterComposer,
          $$FavoriteFoldersTableOrderingComposer,
          $$FavoriteFoldersTableAnnotationComposer,
          $$FavoriteFoldersTableCreateCompanionBuilder,
          $$FavoriteFoldersTableUpdateCompanionBuilder,
          (
            FavoriteFolder,
            BaseReferences<
              _$AppDatabase,
              $FavoriteFoldersTable,
              FavoriteFolder
            >,
          ),
          FavoriteFolder,
          PrefetchHooks Function()
        > {
  $$FavoriteFoldersTableTableManager(
    _$AppDatabase db,
    $FavoriteFoldersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoriteFoldersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoriteFoldersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoriteFoldersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uri = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> registeredAt = const Value.absent(),
              }) => FavoriteFoldersCompanion(
                id: id,
                uri: uri,
                name: name,
                registeredAt: registeredAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uri,
                required String name,
                required DateTime registeredAt,
              }) => FavoriteFoldersCompanion.insert(
                id: id,
                uri: uri,
                name: name,
                registeredAt: registeredAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavoriteFoldersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FavoriteFoldersTable,
      FavoriteFolder,
      $$FavoriteFoldersTableFilterComposer,
      $$FavoriteFoldersTableOrderingComposer,
      $$FavoriteFoldersTableAnnotationComposer,
      $$FavoriteFoldersTableCreateCompanionBuilder,
      $$FavoriteFoldersTableUpdateCompanionBuilder,
      (
        FavoriteFolder,
        BaseReferences<_$AppDatabase, $FavoriteFoldersTable, FavoriteFolder>,
      ),
      FavoriteFolder,
      PrefetchHooks Function()
    >;
typedef $$ImagesTableCreateCompanionBuilder =
    ImagesCompanion Function({
      required String entryId,
      required String uri,
      required String folderUri,
      required String name,
      required String extension,
      required int modified,
      required int size,
      required String mimeType,
      Value<int?> width,
      Value<int?> height,
      required DateTime indexedAt,
      Value<int> rowid,
    });
typedef $$ImagesTableUpdateCompanionBuilder =
    ImagesCompanion Function({
      Value<String> entryId,
      Value<String> uri,
      Value<String> folderUri,
      Value<String> name,
      Value<String> extension,
      Value<int> modified,
      Value<int> size,
      Value<String> mimeType,
      Value<int?> width,
      Value<int?> height,
      Value<DateTime> indexedAt,
      Value<int> rowid,
    });

class $$ImagesTableFilterComposer
    extends Composer<_$AppDatabase, $ImagesTable> {
  $$ImagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entryId => $composableBuilder(
    column: $table.entryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uri => $composableBuilder(
    column: $table.uri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get folderUri => $composableBuilder(
    column: $table.folderUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extension => $composableBuilder(
    column: $table.extension,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get modified => $composableBuilder(
    column: $table.modified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
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

  ColumnFilters<DateTime> get indexedAt => $composableBuilder(
    column: $table.indexedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ImagesTableOrderingComposer
    extends Composer<_$AppDatabase, $ImagesTable> {
  $$ImagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entryId => $composableBuilder(
    column: $table.entryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uri => $composableBuilder(
    column: $table.uri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get folderUri => $composableBuilder(
    column: $table.folderUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extension => $composableBuilder(
    column: $table.extension,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get modified => $composableBuilder(
    column: $table.modified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
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

  ColumnOrderings<DateTime> get indexedAt => $composableBuilder(
    column: $table.indexedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ImagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImagesTable> {
  $$ImagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entryId =>
      $composableBuilder(column: $table.entryId, builder: (column) => column);

  GeneratedColumn<String> get uri =>
      $composableBuilder(column: $table.uri, builder: (column) => column);

  GeneratedColumn<String> get folderUri =>
      $composableBuilder(column: $table.folderUri, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get extension =>
      $composableBuilder(column: $table.extension, builder: (column) => column);

  GeneratedColumn<int> get modified =>
      $composableBuilder(column: $table.modified, builder: (column) => column);

  GeneratedColumn<int> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<DateTime> get indexedAt =>
      $composableBuilder(column: $table.indexedAt, builder: (column) => column);
}

class $$ImagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ImagesTable,
          ImageTableData,
          $$ImagesTableFilterComposer,
          $$ImagesTableOrderingComposer,
          $$ImagesTableAnnotationComposer,
          $$ImagesTableCreateCompanionBuilder,
          $$ImagesTableUpdateCompanionBuilder,
          (
            ImageTableData,
            BaseReferences<_$AppDatabase, $ImagesTable, ImageTableData>,
          ),
          ImageTableData,
          PrefetchHooks Function()
        > {
  $$ImagesTableTableManager(_$AppDatabase db, $ImagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entryId = const Value.absent(),
                Value<String> uri = const Value.absent(),
                Value<String> folderUri = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> extension = const Value.absent(),
                Value<int> modified = const Value.absent(),
                Value<int> size = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<DateTime> indexedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImagesCompanion(
                entryId: entryId,
                uri: uri,
                folderUri: folderUri,
                name: name,
                extension: extension,
                modified: modified,
                size: size,
                mimeType: mimeType,
                width: width,
                height: height,
                indexedAt: indexedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entryId,
                required String uri,
                required String folderUri,
                required String name,
                required String extension,
                required int modified,
                required int size,
                required String mimeType,
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                required DateTime indexedAt,
                Value<int> rowid = const Value.absent(),
              }) => ImagesCompanion.insert(
                entryId: entryId,
                uri: uri,
                folderUri: folderUri,
                name: name,
                extension: extension,
                modified: modified,
                size: size,
                mimeType: mimeType,
                width: width,
                height: height,
                indexedAt: indexedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ImagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ImagesTable,
      ImageTableData,
      $$ImagesTableFilterComposer,
      $$ImagesTableOrderingComposer,
      $$ImagesTableAnnotationComposer,
      $$ImagesTableCreateCompanionBuilder,
      $$ImagesTableUpdateCompanionBuilder,
      (
        ImageTableData,
        BaseReferences<_$AppDatabase, $ImagesTable, ImageTableData>,
      ),
      ImageTableData,
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
  $$FavoriteFoldersTableTableManager get favoriteFolders =>
      $$FavoriteFoldersTableTableManager(_db, _db.favoriteFolders);
  $$ImagesTableTableManager get images =>
      $$ImagesTableTableManager(_db, _db.images);
}
