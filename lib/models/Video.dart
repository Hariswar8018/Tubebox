/*
* Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License").
* You may not use this file except in compliance with the License.
* A copy of the License is located at
*
*  http://aws.amazon.com/apache2.0
*
* or in the "license" file accompanying this file. This file is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

// NOTE: This file is generated and may not follow lint rules defined in your app
// Generated files can be excluded from analysis in analysis_options.yaml
// For more info, see: https://dart.dev/guides/language/analysis-options#excluding-code-from-analysis

// ignore_for_file: public_member_api_docs, annotate_overrides, dead_code, dead_codepublic_member_api_docs, depend_on_referenced_packages, file_names, library_private_types_in_public_api, no_leading_underscores_for_library_prefixes, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, null_check_on_nullable_type_parameter, override_on_non_overriding_member, prefer_adjacent_string_concatenation, prefer_const_constructors, prefer_if_null_operators, prefer_interpolation_to_compose_strings, slash_for_doc_comments, sort_child_properties_last, unnecessary_const, unnecessary_constructor_name, unnecessary_late, unnecessary_new, unnecessary_null_aware_assignments, unnecessary_nullable_for_final_variable_declarations, unnecessary_string_interpolations, use_build_context_synchronously

import 'ModelProvider.dart';
import 'package:amplify_core/amplify_core.dart' as amplify_core;


/** This is an auto generated class representing the Video type in your schema. */
class Video extends amplify_core.Model {
  static const classType = const _VideoModelType();
  final String id;
  final String? _title;
  final String? _uploaderId;
  final String? _s3Key;
  final amplify_core.TemporalDateTime? _createdAt;
  final String? _pic;
  final bool? _sd;
  final bool? _hd;
  final String? _s1;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  VideoModelIdentifier get modelIdentifier {
      return VideoModelIdentifier(
        id: id
      );
  }
  
  String get title {
    try {
      return _title!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get uploaderId {
    try {
      return _uploaderId!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get s3Key {
    try {
      return _s3Key!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  String? get pic {
    return _pic;
  }
  
  bool? get sd {
    return _sd;
  }
  
  bool? get hd {
    return _hd;
  }
  
  String? get s1 {
    return _s1;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const Video._internal({required this.id, required title, required uploaderId, required s3Key, createdAt, pic, sd, hd, s1, updatedAt}): _title = title, _uploaderId = uploaderId, _s3Key = s3Key, _createdAt = createdAt, _pic = pic, _sd = sd, _hd = hd, _s1 = s1, _updatedAt = updatedAt;
  
  factory Video({String? id, required String title, required String uploaderId, required String s3Key, amplify_core.TemporalDateTime? createdAt, String? pic, bool? sd, bool? hd, String? s1}) {
    return Video._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      title: title,
      uploaderId: uploaderId,
      s3Key: s3Key,
      createdAt: createdAt,
      pic: pic,
      sd: sd,
      hd: hd,
      s1: s1);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Video &&
      id == other.id &&
      _title == other._title &&
      _uploaderId == other._uploaderId &&
      _s3Key == other._s3Key &&
      _createdAt == other._createdAt &&
      _pic == other._pic &&
      _sd == other._sd &&
      _hd == other._hd &&
      _s1 == other._s1;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Video {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("title=" + "$_title" + ", ");
    buffer.write("uploaderId=" + "$_uploaderId" + ", ");
    buffer.write("s3Key=" + "$_s3Key" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("pic=" + "$_pic" + ", ");
    buffer.write("sd=" + (_sd != null ? _sd!.toString() : "null") + ", ");
    buffer.write("hd=" + (_hd != null ? _hd!.toString() : "null") + ", ");
    buffer.write("s1=" + "$_s1" + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Video copyWith({String? title, String? uploaderId, String? s3Key, amplify_core.TemporalDateTime? createdAt, String? pic, bool? sd, bool? hd, String? s1}) {
    return Video._internal(
      id: id,
      title: title ?? this.title,
      uploaderId: uploaderId ?? this.uploaderId,
      s3Key: s3Key ?? this.s3Key,
      createdAt: createdAt ?? this.createdAt,
      pic: pic ?? this.pic,
      sd: sd ?? this.sd,
      hd: hd ?? this.hd,
      s1: s1 ?? this.s1);
  }
  
  Video copyWithModelFieldValues({
    ModelFieldValue<String>? title,
    ModelFieldValue<String>? uploaderId,
    ModelFieldValue<String>? s3Key,
    ModelFieldValue<amplify_core.TemporalDateTime?>? createdAt,
    ModelFieldValue<String?>? pic,
    ModelFieldValue<bool?>? sd,
    ModelFieldValue<bool?>? hd,
    ModelFieldValue<String?>? s1
  }) {
    return Video._internal(
      id: id,
      title: title == null ? this.title : title.value,
      uploaderId: uploaderId == null ? this.uploaderId : uploaderId.value,
      s3Key: s3Key == null ? this.s3Key : s3Key.value,
      createdAt: createdAt == null ? this.createdAt : createdAt.value,
      pic: pic == null ? this.pic : pic.value,
      sd: sd == null ? this.sd : sd.value,
      hd: hd == null ? this.hd : hd.value,
      s1: s1 == null ? this.s1 : s1.value
    );
  }
  
  Video.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _title = json['title'],
      _uploaderId = json['uploaderId'],
      _s3Key = json['s3Key'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _pic = json['pic'],
      _sd = json['sd'],
      _hd = json['hd'],
      _s1 = json['s1'],
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'title': _title, 'uploaderId': _uploaderId, 's3Key': _s3Key, 'createdAt': _createdAt?.format(), 'pic': _pic, 'sd': _sd, 'hd': _hd, 's1': _s1, 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'title': _title,
    'uploaderId': _uploaderId,
    's3Key': _s3Key,
    'createdAt': _createdAt,
    'pic': _pic,
    'sd': _sd,
    'hd': _hd,
    's1': _s1,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<VideoModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<VideoModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final TITLE = amplify_core.QueryField(fieldName: "title");
  static final UPLOADERID = amplify_core.QueryField(fieldName: "uploaderId");
  static final S3KEY = amplify_core.QueryField(fieldName: "s3Key");
  static final CREATEDAT = amplify_core.QueryField(fieldName: "createdAt");
  static final PIC = amplify_core.QueryField(fieldName: "pic");
  static final SD = amplify_core.QueryField(fieldName: "sd");
  static final HD = amplify_core.QueryField(fieldName: "hd");
  static final S1 = amplify_core.QueryField(fieldName: "s1");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Video";
    modelSchemaDefinition.pluralName = "Videos";
    
    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.OWNER,
        ownerField: "uploaderId",
        identityClaim: "email",
        provider: amplify_core.AuthRuleProvider.USERPOOLS,
        operations: const [
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.UPDATE,
          amplify_core.ModelOperation.DELETE
        ]),
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.PUBLIC,
        operations: const [
          amplify_core.ModelOperation.READ
        ])
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Video.TITLE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Video.UPLOADERID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Video.S3KEY,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Video.CREATEDAT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Video.PIC,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Video.SD,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Video.HD,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Video.S1,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.nonQueryField(
      fieldName: 'updatedAt',
      isRequired: false,
      isReadOnly: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _VideoModelType extends amplify_core.ModelType<Video> {
  const _VideoModelType();
  
  @override
  Video fromJson(Map<String, dynamic> jsonData) {
    return Video.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Video';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Video] in your schema.
 */
class VideoModelIdentifier implements amplify_core.ModelIdentifier<Video> {
  final String id;

  /** Create an instance of VideoModelIdentifier using [id] the primary key. */
  const VideoModelIdentifier({
    required this.id});
  
  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{
    'id': id
  });
  
  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap()
    .entries
    .map((entry) => (<String, dynamic>{ entry.key: entry.value }))
    .toList();
  
  @override
  String serializeAsString() => serializeAsMap().values.join('#');
  
  @override
  String toString() => 'VideoModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is VideoModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}