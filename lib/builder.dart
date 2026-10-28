/// build_runner entry point; apps never import this.
library;

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'skeleton_faker.dart';

Builder skeletonFakeBuilder(BuilderOptions options) =>
    SharedPartBuilder([SkeletonFakeGenerator()], 'skeleton_fake');

/// Nested models deeper than this get null (if nullable) to stop cycles.
const _maxDepth = 3;

class SkeletonFakeGenerator extends GeneratorForAnnotation<SkeletonFake> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '@skeletonFake can only be used on classes.',
        element: element,
      );
    }
    final name = element.name!;
    return '$name \$fake$name(Fake f) => ${_construct(element, 0)};';
  }

  String _construct(InterfaceElement cls, int depth) {
    final ctor = cls.unnamedConstructor;
    if (ctor == null) {
      throw InvalidGenerationSourceError(
        '${cls.name} needs an unnamed constructor to be faked.',
        element: cls,
      );
    }
    final args = ctor.formalParameters.map((p) {
      final value = _value(p.type, p.name!, depth);
      return p.isNamed ? '${p.name}: $value' : value;
    });
    return '${cls.name}(${args.join(', ')})';
  }

  String _value(DartType type, String field, int depth) {
    final nullable = type.nullabilitySuffix == NullabilitySuffix.question;
    if (type.isDartCoreString) return _string(field);
    if (type.isDartCoreInt) return 'f.integer()';
    if (type.isDartCoreDouble || type.isDartCoreNum) return 'f.decimal()';
    if (type.isDartCoreBool) return 'f.boolean';
    if (type is InterfaceType) {
      final el = type.element;
      if (el.name == 'DateTime' && el.library.isDartCore) return 'f.date';
      if (type.isDartCoreList || type.isDartCoreSet) {
        final item = _value(type.typeArguments.first, field, depth);
        return 'f.list(3, (f) => $item)${type.isDartCoreSet ? '.toSet()' : ''}';
      }
      if (type.isDartCoreMap) return 'const {}';
      if (el is EnumElement) return '${el.name}.values.first';
      if (depth < _maxDepth && el is ClassElement && !el.isAbstract) {
        return _construct(el, depth + 1);
      }
    }
    if (nullable) return 'null';
    throw InvalidGenerationSourceError(
      'Cannot fake `$field` of type ${type.getDisplayString()}; '
      'make it nullable or give it a constructor.',
    );
  }

  // Field-name hints so bones get a realistic length.
  static const _hints = {
    'f.image()': [
      'image',
      'logo',
      'avatar',
      'photo',
      'picture',
      'thumbnail',
      'url',
    ],
    'f.email': ['email'],
    'f.phone': ['phone', 'mobile'],
    'f.paragraph': [
      'description',
      'body',
      'content',
      'bio',
      'about',
      'summary',
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
