// class TestRemark {
//   final int remarkId;
//   final String remark;
//   final bool isDeleted;
//   final DateTime createdAt;

//   TestRemark({
//     required this.remarkId,
//     required this.remark,
//     required this.isDeleted,
//     required this.createdAt,
//   });

//   factory TestRemark.fromJson(Map<String, dynamic> json) {
//     return TestRemark(
//       remarkId: json['remark_id'],
//       remark: json['remark'],
//       isDeleted:
//           json['is_deleted'] == 1, // Assuming 1 means true, 0 means false
//       createdAt: DateTime.parse(json['created_at']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'remark_id': remarkId,
//       'remark': remark,
//       'is_deleted': isDeleted ? 1 : 0,
//       'created_at': createdAt.toIso8601String(),
//     };
//   }
// }
// not in use