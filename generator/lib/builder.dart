/// build_runner entry point; apps never import this.
library;

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:skeleton_faker/skeleton_faker.dart';
import 'package:source_gen/source_gen.dart';

Builder skeletonFakeBuilder(BuilderOptions options) =>
    SharedPartBuilder([SkeletonFakeGenerator()], 'skeleton_fake');

/// Nested models deeper than this stop recursing, which also breaks cycles.
const _maxDepth = 3;

const _jsonCtors = {'fromJson', 'fromMap'};

class SkeletonFakeGenerator extends GeneratorForAnnotation<SkeletonFake> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! InterfaceElement) {
      throw InvalidGenerationSourceError(
        '@skeletonFake can only be used on classes.',
        element: element,
      );
    }
    final name = element.name!;
    final params = element.typeParameters.map((t) => t.name!).toList();
    final generics = params.isEmpty ? '' : '<${params.join(', ')}>';
    final body = _Faker(element.library).build(element.thisType, 0);
    return '$name$generics \$fake$name$generics(Fake f) => $body;';
  }
}

/// Writes one Dart expression per type, using `f` (a Fake) for values.
class _Faker {
  _Faker(this.library);

  /// The annotated class's library: its private members are reachable from
  /// the generated part file.
  final LibraryElement library;

  String build(DartType type, int depth, [String field = '']) {
    final nullable = type.nullabilitySuffix == NullabilitySuffix.question;
    if (type is DynamicType || type.isDartCoreObject) return 'f.name';
    if (type.isDartCoreString) return _string(field);
    if (type.isDartCoreInt) return 'f.integer()';
    if (type.isDartCoreDouble || type.isDartCoreNum) return 'f.decimal()';
    if (type.isDartCoreBool) return 'f.boolean';
    if (type is TypeParameterType) return 'f.get<${type.element.name}>()';
    if (type is RecordType) return _record(type, depth);
    if (type is FunctionType) return _function(type, depth);
    if (type is InterfaceType) {
      final known = _interface(type, depth, field);
      if (known != null) return known;
    }
    if (nullable) return 'null';
    return 'f.get<${_name(type)}>()';
  }

  String? _interface(InterfaceType type, int depth, String field) {
    final el = type.element;
    final lib = el.library.uri.toString();
    String arg([int i = 0]) => type.typeArguments.length > i
        ? build(type.typeArguments[i], depth, field)
        : 'f.name';

    if (lib == 'dart:core') {
      switch (el.name) {
        case 'DateTime':
          return 'f.date';
        case 'Duration':
          return 'f.duration';
        case 'Uri':
          return 'f.uri';
        case 'BigInt':
          return 'BigInt.zero';
        case 'List' || 'Iterable':
          return _cycle(type, depth) ? '[]' : 'f.list(3, (f) => ${arg()})';
        case 'Set':
          return _cycle(type, depth) ? '{}' : '{${arg()}}';
        case 'Map':
          return _cycle(type, depth) ? '{}' : '{${arg()}: ${arg(1)}}';
      }
    }
    if (lib == 'dart:async') {
      switch (el.name) {
        case 'Future' || 'FutureOr':
          return _isVoid(type.typeArguments.first)
              ? 'Future.value()'
              : 'Future.value(${arg()})';
        case 'Stream':
          return 'Stream.value(${arg()})';
      }
    }
    if (lib == 'dart:ui' && el.name == 'Color') {
      return 'const Color(0xFFE0E0E0)';
    }
    if (el is EnumElement) return '${_name(type)}.values.first';
    if (el is ClassElement && depth < _maxDepth) return _class(el, type, depth);
    return null;
  }

  String? _class(ClassElement cls, InterfaceType type, int depth) {
    final ctors = cls.constructors
        .where((c) =>
            _visible(c, c.name ?? '') && (!cls.isAbstract || c.isFactory))
        .toList();
    // Prefer the plain constructor, then named ones, then fromJson.
    ConstructorElement? pick(bool Function(ConstructorElement) test) =>
        ctors.where(test).firstOrNull;
    final ctor = pick((c) => c.name == null || c.name == 'new') ??
        pick((c) => !_jsonCtors.contains(c.name)) ??
        pick((c) => true);

    if (ctor == null) return _subclass(cls, depth);
    if (!_visible(cls, cls.name!)) return null;

    final owner = cls.name;
    final named =
        ctor.name == null || ctor.name == 'new' ? '' : '.${ctor.name}';
    if (_jsonCtors.contains(ctor.name)) {
      return '$owner$named(${_json(cls, depth + 1)})';
    }
    final args = <String>[];
    for (final p in ctor.formalParameters) {
      final value = build(p.type, depth + 1, p.name!);
      // Optional params we cannot fake are left to their defaults.
      if (!p.isRequired && value.startsWith('f.get<')) continue;
      args.add(p.isNamed ? '${p.name}: $value' : value);
    }
    return '$owner$named(${args.join(', ')})';
  }

  /// Sealed/abstract class with no usable constructor: fake a subclass.
  String? _subclass(ClassElement cls, int depth) {
    for (final sub in cls.library.classes) {
      if (sub == cls || sub.isAbstract) continue;
      if (sub.allSupertypes.any((t) => t.element == cls)) {
        final value = _class(sub, sub.thisType, depth);
        if (value != null) return value;
      }
    }
    return null;
  }

  /// A JSON map built from the class's fields, for fromJson-only models.
  // shortcut: keys are field names, ignoring @JsonKey(name:) renames.
  String _json(ClassElement cls, int depth) {
    final entries = cls.fields
        .where((e) => !e.isStatic)
        .map((e) => "'${e.name}': ${_jsonValue(e.type, depth, e.name!)}");
    return '<String, dynamic>{${entries.join(', ')}}';
  }

  String _jsonValue(DartType type, int depth, String field) {
    if (type.isDartCoreString) return _string(field);
    if (type.isDartCoreInt) return 'f.integer()';
    if (type.isDartCoreDouble || type.isDartCoreNum) return 'f.decimal()';
    if (type.isDartCoreBool) return 'f.boolean';
    if (type is InterfaceType) {
      final el = type.element;
      if (el.name == 'DateTime') return 'f.date.toIso8601String()';
      if (el is EnumElement) return '${_name(type)}.values.first.name';
      if ((type.isDartCoreList || type.isDartCoreIterable) &&
          type.typeArguments.isNotEmpty) {
        return '[${_jsonValue(type.typeArguments.first, depth, field)}]';
      }
      if (el is ClassElement && !el.library.isInSdk && depth < _maxDepth) {
        return _json(el, depth + 1);
      }
    }
    return 'null';
  }

  String _record(RecordType type, int depth) {
    final values = [
      for (final p in type.positionalFields) build(p.type, depth),
      for (final n in type.namedFields)
        '${n.name}: ${build(n.type, depth, n.name)}',
    ];
    // A one-field positional record needs a trailing comma.
    final trailing =
        type.positionalFields.length == 1 && type.namedFields.isEmpty;
    return '(${values.join(', ')}${trailing ? ',' : ''})';
  }

  String _function(FunctionType type, int depth) {
    final required = <String>[];
    final optional = <String>[];
    final named = <String>[];
    var i = 0;
    for (final p in type.formalParameters) {
      if (p.isNamed) {
        named.add(p.isRequired ? 'required ${p.name}' : p.name!);
      } else {
        (p.isOptional ? optional : required).add('p${i++}');
      }
    }
    final params = [
      ...required,
      if (optional.isNotEmpty) '[${optional.join(', ')}]',
      if (named.isNotEmpty) '{${named.join(', ')}}',
    ].join(', ');
    final ret = type.returnType;
    return _isVoid(ret) ? '($params) {}' : '($params) => ${build(ret, depth)}';
  }

  /// Collection of a model we stopped recursing into: leave it empty
  /// rather than throw at runtime.
  bool _cycle(InterfaceType type, int depth) =>
      depth >= _maxDepth &&
      type.typeArguments
          .any((t) => t is InterfaceType && t.element is ClassElement);

  bool _isVoid(DartType type) => type is VoidType || type.isDartCoreNull;

  bool _visible(Element owner, String name) =>
      !name.startsWith('_') || owner.library == library;

  String _name(DartType type) =>
      type.getDisplayString().replaceAll(RegExp(r'\?$'), '');

  // Field-name hints so bones get a realistic length.
  static const _hints = {
    'f.image()': [
      'image',
      'logo',
      'avatar',
      'photo',
      'picture',
      'thumbnail',
      'url'
    ],
    'f.email': ['email'],
    'f.phone': ['phone', 'mobile'],
    'f.paragraph': [
      'description',
      'body',
      'content',
      'bio',
      'about',
      'summary'
    ],
    'f.title': ['title', 'subtitle', 'address'],
    'f.code()': ['code', 'iata', 'icao', 'currency'],
  };

  String _string(String field) {
    if (field == 'id' || field.endsWith('Id')) return 'f.code(8)';
    final lower = field.toLowerCase();
    for (final MapEntry(:key, :value) in _hints.entries) {
      if (value.any(lower.contains)) return key;
    }
    return 'f.name';
  }
}
