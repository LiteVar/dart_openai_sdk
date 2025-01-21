import 'dart:convert';

import 'package:ovo/ovo.dart' as ovo;

extension StringExtension on String {
  bool get canBeParsedToJson {
    try {
      final _ = jsonDecode(this);

      return true;
    } catch (e) {
      return false;
    }
  }

  String pascalCaseToSnakeCase() {
    return replaceAllMapped(
      RegExp(r'(?<!^)([A-Z])'),
      (match) => '_${match.group(1)!.toLowerCase()}',
    ).toLowerCase();
  }
}

extension ObjectSchemaExtension on ovo.Object {
  Map<String, dynamic> toJsonSchemaObject() {
    Map<String, dynamic> schema = {
      "type": "object",
      "properties": {},
      "required": properties.keys.toList(),
      "additionalProperties": false,
    };

    properties.forEach((key, value) {
      if (value is ovo.String) {
        schema["properties"][key] = {"type": "string"};
      } else if (value is ovo.Number) {
        schema["properties"][key] = {"type": "number"};
      } else if (value is ovo.Boolean) {
        schema["properties"][key] = {"type": "boolean"};
      } else if (value is ovo.Integer) {
        schema["properties"][key] = {"type": "integer"};
      } else if (value is ovo.Object) {
        schema["properties"][key] = value.toJsonSchemaObject();
      } else if (value is ovo.Array) {
        schema["properties"]
            [key] = {"type": "array", "items": value.toJsonSchemaObject()};
      }
    });

    return schema;
  }

  Map<String, dynamic> formatJsonData() {
    Map<String, dynamic> json = {
      "name": runtimeType.toString().pascalCaseToSnakeCase(),
      "schema": toJsonSchemaObject(),
      "strict": true,
    };

    Map<String, dynamic> jsonSchema = {
      "type": "json_schema",
      "json_schema": json,
    };

    return jsonSchema;
  }
}

extension ArraySchemaExtension on ovo.Array {
  Map<String, dynamic> toJsonSchemaObject() {
    Map<String, dynamic> json = {};
    if (schema is ovo.Object) {
      json = (schema as ovo.Object).toJsonSchemaObject();
    }

    return json;
  }
}
