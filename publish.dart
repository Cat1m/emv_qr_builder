// ignore_for_file: avoid_print

import 'dart:io';

/// Script tự động hóa quy trình publish package lên Pub.dev
/// Repository: https://github.com/Cat1m/emv_qr_builder.git
///
/// Cách dùng: chạy lệnh `dart publish.dart`
void main() async {
  print('🚀 Bắt đầu quy trình Publish...');

  // 1. Lấy version hiện tại từ pubspec.yaml
  final version = _getVersionFromPubspec();
  if (version == null) {
    print('❌ Không tìm thấy version trong pubspec.yaml');
    exit(1);
  }
  print('📦 Detected Version: $version');

  // Hỏi người dùng nội dung commit message (tùy chọn)
  stdout.write('📝 Nhập nội dung commit (Enter để dùng mặc định): ');
  var note = stdin.readLineSync();
  if (note == null || note.trim().isEmpty) {
    note = 'Add business QR examples and notes'; // Mặc định như bạn yêu cầu
  }
  final commitMessage = 'Bump version to $version: $note';

  print('\n-------------------------------------------------------------');
  print('🔍 BƯỚC 1: KIỂM TRA CHẤT LƯỢNG (Quality Checks)');
  print('-------------------------------------------------------------');

  if (!await _runCommand('dart', ['format', '.'])) exit(1);
  if (!await _runCommand('dart', ['analyze'])) exit(1);
  if (!await _runCommand('dart', ['test'])) exit(1);

  // Dry-run để kiểm tra warning lần cuối
  print('\nrunning: dart pub publish --dry-run...');
  final dryRunProcess = await Process.start(
    'dart',
    ['pub', 'publish', '--dry-run'],
    mode: ProcessStartMode
        .inheritStdio, // Để hiển thị màu sắc và output trực tiếp
  );
  final dryRunExitCode = await dryRunProcess.exitCode;
  if (dryRunExitCode != 0) {
    print('❌ Dry-run thất bại. Vui lòng kiểm tra lỗi.');
    exit(1);
  }

  print('\n-------------------------------------------------------------');
  print('octocat: BƯỚC 2: GIT OPERATIONS');
  print('-------------------------------------------------------------');

  if (!await _runCommand('git', ['add', '.'])) exit(1);

  // Commit
  if (!await _runCommand('git', ['commit', '-m', commitMessage])) {
    print(
      '⚠️ Git commit có thể thất bại nếu không có thay đổi nào. Tiếp tục...',
    );
  }

  // Tag
  final tagName = 'v$version';
  // Xóa tag cũ nếu lỡ tạo rồi (để tránh lỗi duplicate tag ở local)
  await Process.run('git', ['tag', '-d', tagName]);
  if (!await _runCommand('git', ['tag', tagName])) exit(1);

  // Push Code
  if (!await _runCommand('git', ['push', 'origin', 'main'])) exit(1);

  // Push Tag
  if (!await _runCommand('git', ['push', 'origin', tagName])) exit(1);

  print('\n-------------------------------------------------------------');
  print('🚀 BƯỚC 3: PUBLISH LÊN PUB.DEV');
  print('-------------------------------------------------------------');

  // Dùng inheritStdio để bạn có thể tương tác (nhập 'y') với lệnh publish
  final publishProcess = await Process.start('dart', [
    'pub',
    'publish',
  ], mode: ProcessStartMode.inheritStdio);

  final publishExitCode = await publishProcess.exitCode;

  if (publishExitCode == 0) {
    print('\n✅✅✅ THÀNH CÔNG! Version $version đã được publish.');
    print('👉 Kiểm tra tại: https://pub.dev/packages/emv_qr_builder');
  } else {
    print('\n❌ Publish thất bại hoặc đã bị hủy.');
    exit(1);
  }
}

/// Hàm hỗ trợ chạy lệnh hệ thống
Future<bool> _runCommand(String cmd, List<String> args) async {
  print('running: $cmd ${args.join(' ')} ...');
  final process = await Process.start(
    cmd,
    args,
    mode: ProcessStartMode.inheritStdio,
  );
  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    print('❌ Lệnh thất bại: $cmd ${args.join(' ')}');
    return false;
  }
  return true;
}

/// Đọc version từ file pubspec.yaml
String? _getVersionFromPubspec() {
  try {
    final file = File('pubspec.yaml');
    final lines = file.readAsLinesSync();
    for (var line in lines) {
      if (line.trim().startsWith('version:')) {
        return line.split(':')[1].trim();
      }
    }
  } catch (e) {
    print('Lỗi đọc file pubspec.yaml: $e');
  }
  return null;
}
