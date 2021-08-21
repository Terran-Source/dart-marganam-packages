import 'dart:async';

import 'package:dart_marganam/utils/ready_or_not.dart';
import 'package:test/test.dart';

import '../matcher.dart';

void main() {
  late ReadyMade readyMade;

  setUp(() {
    readyMade = ReadyMade();
  });

  tearDown(() {
    readyMade.dispose();
  });

  group('ReadyOrNot getReady() test', () {
    test('initiation test', () {
      // assert
      expect(readyMade, isNotNull);
      expect(readyMade.dummy, isNull);
      expect(readyMade.timeRange, isNull);
      expect(readyMade.ready, isFalse);
      expect(readyMade.working, isFalse);
    });
    test('getReady() test', () async {
      // assert at begin
      expect(readyMade, isNotNull);
      expect(readyMade.dummy, isNull);
      expect(readyMade.timeRange, isNull);
      expect(readyMade.ready, isFalse);
      expect(readyMade.working, isFalse);

      // act
      final result = readyMade.getReady();

      // assert after
      expect(result, isA<Future<dynamic>>());
      expect(readyMade.dummy, isNull);
      expect(readyMade.timeRange, 0);
      expect(readyMade.ready, isFalse);
      expect(readyMade.working, isTrue);
      // 1 second elapsed & still working
      await Future.delayed(const Duration(seconds: 1)).then((_) {
        expect(readyMade.dummy, isNull);
        expect(readyMade.timeRange, 0);
        expect(readyMade.ready, isFalse);
        expect(readyMade.working, isTrue);
      });
      // another 1 second & it's finished
      await Future.delayed(const Duration(seconds: 1)).then((_) {
        expect(readyMade.dummy, 'dummy');
        expect(readyMade.timeRange?.toDouble(), moreOrLessEquals(2.0));
        expect(readyMade.ready, isTrue);
        expect(readyMade.working, isFalse);
      });
    });
    test('concurrent getReady() test', () async {
      // assert at begin
      expect(readyMade, isNotNull);
      expect(readyMade.dummy, isNull);
      expect(readyMade.timeRange, isNull);
      expect(readyMade.ready, isFalse);

      // act
      // triggered once
      readyMade.getReady();
      // triggered again & again
      final result1 = readyMade.getReady();
      final result2 = readyMade.getReady();

      // assert after
      expect(result1, isA<Future<dynamic>>());
      expect(result2, isA<Future<dynamic>>());
      expect(readyMade.dummy, isNull);
      expect(readyMade.timeRange, 0);
      expect(readyMade.ready, isFalse);
      // 1 second elapsed & still working
      await Future.delayed(const Duration(seconds: 1)).then((_) {
        expect(readyMade.dummy, isNull);
        expect(readyMade.timeRange, 0);
        expect(readyMade.ready, isFalse);
      });
      // another 1 second & it's finished
      await Future.delayed(const Duration(seconds: 1)).then((_) {
        expect(readyMade.dummy, 'dummy');
        expect(readyMade.timeRange?.toDouble(), moreOrLessEquals(2.0));
        expect(readyMade.ready, isTrue);
      });
    });
  });

  group('ReadyOrNot triggerJob() test', () {
    test('initiation test', () {
      // assert
      expect(readyMade, isNotNull);
      expect(readyMade.dummy, isNull);
      expect(readyMade.dummy1, isNull);
      expect(readyMade.dummy2, isNull);
      expect(readyMade.timeRange, isNull);
      expect(readyMade.timeRange1, isNull);
      expect(readyMade.timeRange2, isNull);
      expect(readyMade.ready, isFalse);
      expect(readyMade.working, isFalse);
    });
    test('triggerJob() test', () async {
      // assert at begin
      expect(readyMade, isNotNull);
      expect(readyMade.dummy, isNull);
      expect(readyMade.dummy1, isNull);
      expect(readyMade.dummy2, isNull);
      expect(readyMade.timeRange, isNull);
      expect(readyMade.timeRange1, isNull);
      expect(readyMade.timeRange2, isNull);
      expect(readyMade.ready, isFalse);
      expect(readyMade.working, isFalse);

      // act
      final result1 = readyMade.triggerJob('job1');
      final result2 = readyMade.triggerJob('job2');

      // assert after
      expect(result1, isA<FutureOr<dynamic>>());
      expect(result2, isA<FutureOr<dynamic>>());
      expect(readyMade.dummy, isNull);
      expect(readyMade.dummy1, isNull);
      expect(readyMade.dummy2, isNull);
      expect(readyMade.timeRange, isNull);
      expect(readyMade.timeRange1, 0);
      expect(readyMade.timeRange2, 0);
      expect(readyMade.ready, isFalse);
      expect(readyMade.working, isTrue);
      // 1 second elapsed & still working
      await Future.delayed(const Duration(seconds: 1)).then((_) {
        expect(readyMade.dummy, isNull);
        expect(readyMade.dummy1, isNull);
        expect(readyMade.dummy2, isNull);
        expect(readyMade.timeRange, isNull);
        expect(readyMade.timeRange1, 0);
        expect(readyMade.timeRange2, 0);
        expect(readyMade.ready, isFalse);
        expect(readyMade.working, isTrue);
      });
      // another 1 second & job1's finished
      await Future.delayed(const Duration(seconds: 1)).then((_) {
        expect(readyMade.dummy, isNull);
        expect(readyMade.dummy1, 'dummy1');
        expect(readyMade.dummy2, isNull);
        expect(readyMade.timeRange, isNull);
        expect(readyMade.timeRange1?.toDouble(), moreOrLessEquals(2.0));
        expect(readyMade.timeRange2, 0);
        expect(readyMade.ready, isFalse);
        expect(readyMade.working, isTrue);
      });
      // another 1 second & both job1 and job2 are finished
      await Future.delayed(const Duration(seconds: 1)).then((_) {
        expect(readyMade.dummy, isNull);
        expect(readyMade.dummy1, 'dummy1');
        expect(readyMade.dummy2, 'dummy2');
        expect(readyMade.timeRange, isNull);
        expect(readyMade.timeRange1?.toDouble(), moreOrLessEquals(2.0));
        expect(readyMade.timeRange2?.toDouble(), moreOrLessEquals(3.0));
        expect(readyMade.ready, isFalse);
        expect(readyMade.working, isFalse);
      });
    });
    test('triggerJob(), with getReady() test', () async {
      // assert at begin
      expect(readyMade, isNotNull);
      expect(readyMade.dummy, isNull);
      expect(readyMade.dummy1, isNull);
      expect(readyMade.dummy2, isNull);
      expect(readyMade.timeRange, isNull);
      expect(readyMade.timeRange1, isNull);
      expect(readyMade.timeRange2, isNull);
      expect(readyMade.ready, isFalse);
      expect(readyMade.working, isFalse);

      // act
      final result = readyMade.getReady();
      final result1 = readyMade.triggerJob('job1');
      final result2 = readyMade.triggerJob('job2');

      // assert after
      expect(result, isA<FutureOr<dynamic>>());
      expect(result1, isA<FutureOr<dynamic>>());
      expect(result2, isA<FutureOr<dynamic>>());
      expect(readyMade.dummy, isNull);
      expect(readyMade.dummy1, isNull);
      expect(readyMade.dummy2, isNull);
      expect(readyMade.timeRange, 0);
      expect(readyMade.timeRange1, 0);
      expect(readyMade.timeRange2, 0);
      expect(readyMade.ready, isFalse);
      expect(readyMade.working, isTrue);
      // 1 second elapsed & still working
      await Future.delayed(const Duration(seconds: 1)).then((_) {
        expect(readyMade.dummy, isNull);
        expect(readyMade.dummy1, isNull);
        expect(readyMade.dummy2, isNull);
        expect(readyMade.timeRange, 0);
        expect(readyMade.timeRange1, 0);
        expect(readyMade.timeRange2, 0);
        expect(readyMade.ready, isFalse);
        expect(readyMade.working, isTrue);
      });
      // another 1 second & getReady and job1 are finished
      await Future.delayed(const Duration(seconds: 1)).then((_) {
        expect(readyMade.dummy, 'dummy');
        expect(readyMade.dummy1, 'dummy1');
        expect(readyMade.dummy2, isNull);
        expect(readyMade.timeRange?.toDouble(), moreOrLessEquals(2.0));
        expect(readyMade.timeRange1?.toDouble(), moreOrLessEquals(2.0));
        expect(readyMade.timeRange2, 0);
        expect(readyMade.ready, isTrue);
        expect(readyMade.working, isTrue);
      });
      // another 1 second & both getReady and job1 and job2 are finished
      await Future.delayed(const Duration(seconds: 1)).then((_) {
        expect(readyMade.dummy, 'dummy');
        expect(readyMade.dummy1, 'dummy1');
        expect(readyMade.dummy2, 'dummy2');
        expect(readyMade.timeRange?.toDouble(), moreOrLessEquals(2.0));
        expect(readyMade.timeRange1?.toDouble(), moreOrLessEquals(2.0));
        expect(readyMade.timeRange2?.toDouble(), moreOrLessEquals(3.0));
        expect(readyMade.ready, isTrue);
        expect(readyMade.working, isFalse);
      });
    });
    test('triggerJob(), onReady: false test', () async {
      // assert at begin
      expect(readyMade, isNotNull);
      expect(readyMade.dummy, isNull);
      expect(readyMade.dummy1, isNull);
      expect(readyMade.dummy2, isNull);
      expect(readyMade.timeRange, isNull);
      expect(readyMade.timeRange1, isNull);
      expect(readyMade.timeRange2, isNull);
      expect(readyMade.ready, isFalse);
      expect(readyMade.working, isFalse);

      // act
      final result1 = readyMade.triggerJob('job1', onReady: false);
      final result2 = readyMade.triggerJob('job2', onReady: false);

      // assert after
      expect(result1, isA<FutureOr<dynamic>>());
      expect(result2, isA<FutureOr<dynamic>>());
      expect(readyMade.dummy, isNull);
      expect(readyMade.dummy1, isNull);
      expect(readyMade.dummy2, isNull);
      expect(readyMade.timeRange, isNull);
      expect(readyMade.timeRange1, 0);
      expect(readyMade.timeRange2, 0);
      expect(readyMade.ready, isFalse);
      expect(readyMade.working, isTrue);
      // 1 second elapsed & still working
      await Future.delayed(const Duration(seconds: 1)).then((_) {
        expect(readyMade.dummy, isNull);
        expect(readyMade.dummy1, isNull);
        expect(readyMade.dummy2, isNull);
        expect(readyMade.timeRange, isNull);
        expect(readyMade.timeRange1, 0);
        expect(readyMade.timeRange2, 0);
        expect(readyMade.ready, isFalse);
        expect(readyMade.working, isTrue);
      });
      // another 1 second & job1's finished
      await Future.delayed(const Duration(seconds: 1)).then((_) {
        expect(readyMade.dummy, isNull);
        expect(readyMade.dummy1, 'dummy1');
        expect(readyMade.dummy2, isNull);
        expect(readyMade.timeRange, isNull);
        expect(readyMade.timeRange1?.toDouble(), moreOrLessEquals(2.0));
        expect(readyMade.timeRange2, 0);
        expect(readyMade.ready, isFalse);
        expect(readyMade.working, isTrue);
      });
      // another 1 second & both job1 and job2 are finished
      await Future.delayed(const Duration(seconds: 1)).then((_) {
        expect(readyMade.dummy, isNull);
        expect(readyMade.dummy1, 'dummy1');
        expect(readyMade.dummy2, 'dummy2');
        expect(readyMade.timeRange, isNull);
        expect(readyMade.timeRange1?.toDouble(), moreOrLessEquals(2.0));
        expect(readyMade.timeRange2?.toDouble(), moreOrLessEquals(3.0));
        expect(readyMade.ready, isFalse);
        expect(readyMade.working, isFalse);
      });
    });
    test('triggerJob(), onReady: false with getReady() test', () async {
      // assert at begin
      expect(readyMade, isNotNull);
      expect(readyMade.dummy, isNull);
      expect(readyMade.dummy1, isNull);
      expect(readyMade.dummy2, isNull);
      expect(readyMade.timeRange, isNull);
      expect(readyMade.timeRange1, isNull);
      expect(readyMade.timeRange2, isNull);
      expect(readyMade.ready, isFalse);
      expect(readyMade.working, isFalse);

      // act
      final result = readyMade.getReady();
      final result1 = readyMade.triggerJob('job1', onReady: false);
      final result2 = readyMade.triggerJob('job2', onReady: false);

      // assert after
      expect(result, isA<FutureOr<dynamic>>());
      expect(result1, isA<FutureOr<dynamic>>());
      expect(result2, isA<FutureOr<dynamic>>());
      expect(readyMade.dummy, isNull);
      expect(readyMade.dummy1, isNull);
      expect(readyMade.dummy2, isNull);
      expect(readyMade.timeRange, 0);
      expect(readyMade.timeRange1, 0);
      expect(readyMade.timeRange2, 0);
      expect(readyMade.ready, isFalse);
      expect(readyMade.working, isTrue);
      // 1 second elapsed & still working
      await Future.delayed(const Duration(seconds: 1)).then((_) {
        expect(readyMade.dummy, isNull);
        expect(readyMade.dummy1, isNull);
        expect(readyMade.dummy2, isNull);
        expect(readyMade.timeRange, 0);
        expect(readyMade.timeRange1, 0);
        expect(readyMade.timeRange2, 0);
        expect(readyMade.ready, isFalse);
        expect(readyMade.working, isTrue);
      });
      // another 1 second & getReady and job1 are finished
      await Future.delayed(const Duration(seconds: 1)).then((_) {
        expect(readyMade.dummy, 'dummy');
        expect(readyMade.dummy1, 'dummy1');
        expect(readyMade.dummy2, isNull);
        expect(readyMade.timeRange?.toDouble(), moreOrLessEquals(2.0));
        expect(readyMade.timeRange1?.toDouble(), moreOrLessEquals(2.0));
        expect(readyMade.timeRange2, 0);
        expect(readyMade.ready, isTrue);
        expect(readyMade.working, isTrue);
      });
      // another 1 second & both getReady and job1 and job2 are finished
      await Future.delayed(const Duration(seconds: 1)).then((_) {
        expect(readyMade.dummy, 'dummy');
        expect(readyMade.dummy1, 'dummy1');
        expect(readyMade.dummy2, 'dummy2');
        expect(readyMade.timeRange?.toDouble(), moreOrLessEquals(2.0));
        expect(readyMade.timeRange1?.toDouble(), moreOrLessEquals(2.0));
        expect(readyMade.timeRange2?.toDouble(), moreOrLessEquals(3.0));
        expect(readyMade.ready, isTrue);
        expect(readyMade.working, isFalse);
      });
    });
    test('concurrent triggerJob() test', () async {
      // assert at begin
      expect(readyMade, isNotNull);
      expect(readyMade.dummy, isNull);
      expect(readyMade.dummy1, isNull);
      expect(readyMade.dummy2, isNull);
      expect(readyMade.timeRange, isNull);
      expect(readyMade.timeRange1, isNull);
      expect(readyMade.timeRange2, isNull);
      expect(readyMade.ready, isFalse);
      expect(readyMade.working, isFalse);

      // act
      readyMade.triggerJob('job1');
      final result1_1 = readyMade.triggerJob('job1');
      final result1_2 = readyMade.triggerJob('job1');
      readyMade.triggerJob('job2');
      final result2_1 = readyMade.triggerJob('job2');
      final result2_2 = readyMade.triggerJob('job2');

      // assert after
      expect(result1_1, isA<FutureOr<dynamic>>());
      expect(result1_2, isA<FutureOr<dynamic>>());
      expect(result2_1, isA<FutureOr<dynamic>>());
      expect(result2_2, isA<FutureOr<dynamic>>());
      expect(readyMade.dummy, isNull);
      expect(readyMade.dummy1, isNull);
      expect(readyMade.dummy2, isNull);
      expect(readyMade.timeRange, isNull);
      expect(readyMade.timeRange1, 0);
      expect(readyMade.timeRange2, 0);
      expect(readyMade.ready, isFalse);
      expect(readyMade.working, isTrue);
      // 1 second elapsed & still working
      await Future.delayed(const Duration(seconds: 1)).then((_) {
        expect(readyMade.dummy, isNull);
        expect(readyMade.dummy1, isNull);
        expect(readyMade.dummy2, isNull);
        expect(readyMade.timeRange, isNull);
        expect(readyMade.timeRange1, 0);
        expect(readyMade.timeRange2, 0);
        expect(readyMade.ready, isFalse);
        expect(readyMade.working, isTrue);
      });
      // another 1 second & job1's finished
      await Future.delayed(const Duration(seconds: 1)).then((_) {
        expect(readyMade.dummy, isNull);
        expect(readyMade.dummy1, 'dummy1');
        expect(readyMade.dummy2, isNull);
        expect(readyMade.timeRange, isNull);
        expect(readyMade.timeRange1?.toDouble(), moreOrLessEquals(2.0));
        expect(readyMade.timeRange2, 0);
        expect(readyMade.ready, isFalse);
        expect(readyMade.working, isTrue);
      });
      // another 1 second & both job1 and job2 are finished
      await Future.delayed(const Duration(seconds: 1)).then((_) {
        expect(readyMade.dummy, isNull);
        expect(readyMade.dummy1, 'dummy1');
        expect(readyMade.dummy2, 'dummy2');
        expect(readyMade.timeRange, isNull);
        expect(readyMade.timeRange1?.toDouble(), moreOrLessEquals(2.0));
        expect(readyMade.timeRange2?.toDouble(), moreOrLessEquals(3.0));
        expect(readyMade.ready, isFalse);
        expect(readyMade.working, isFalse);
      });
    });
    test('concurrent triggerJob(), onReady: false test', () async {
      // assert at begin
      expect(readyMade, isNotNull);
      expect(readyMade.dummy, isNull);
      expect(readyMade.dummy1, isNull);
      expect(readyMade.dummy2, isNull);
      expect(readyMade.timeRange, isNull);
      expect(readyMade.timeRange1, isNull);
      expect(readyMade.timeRange2, isNull);
      expect(readyMade.ready, isFalse);
      expect(readyMade.working, isFalse);

      // act
      readyMade.triggerJob('job1', onReady: false);
      final result1_1 = readyMade.triggerJob('job1', onReady: false);
      final result1_2 = readyMade.triggerJob('job1', onReady: false);
      readyMade.triggerJob('job2');
      final result2_1 = readyMade.triggerJob('job2', onReady: false);
      final result2_2 = readyMade.triggerJob('job2', onReady: false);

      // assert after
      expect(result1_1, isA<FutureOr<dynamic>>());
      expect(result1_2, isA<FutureOr<dynamic>>());
      expect(result2_1, isA<FutureOr<dynamic>>());
      expect(result2_2, isA<FutureOr<dynamic>>());
      expect(readyMade.dummy, isNull);
      expect(readyMade.dummy1, isNull);
      expect(readyMade.dummy2, isNull);
      expect(readyMade.timeRange, isNull);
      expect(readyMade.timeRange1, 0);
      expect(readyMade.timeRange2, 0);
      expect(readyMade.ready, isFalse);
      expect(readyMade.working, isTrue);
      // 1 second elapsed & still working
      await Future.delayed(const Duration(seconds: 1)).then((_) {
        expect(readyMade.dummy, isNull);
        expect(readyMade.dummy1, isNull);
        expect(readyMade.dummy2, isNull);
        expect(readyMade.timeRange, isNull);
        expect(readyMade.timeRange1, 0);
        expect(readyMade.timeRange2, 0);
        expect(readyMade.ready, isFalse);
        expect(readyMade.working, isTrue);
      });
      // another 1 second & job1's finished
      await Future.delayed(const Duration(seconds: 1)).then((_) {
        expect(readyMade.dummy, isNull);
        expect(readyMade.dummy1, 'dummy1');
        expect(readyMade.dummy2, isNull);
        expect(readyMade.timeRange, isNull);
        expect(readyMade.timeRange1?.toDouble(), moreOrLessEquals(2.0));
        expect(readyMade.timeRange2, 0);
        expect(readyMade.ready, isFalse);
        expect(readyMade.working, isTrue);
      });
      // another 1 second & both job1 and job2 are finished
      await Future.delayed(const Duration(seconds: 1)).then((_) {
        expect(readyMade.dummy, isNull);
        expect(readyMade.dummy1, 'dummy1');
        expect(readyMade.dummy2, 'dummy2');
        expect(readyMade.timeRange, isNull);
        expect(readyMade.timeRange1?.toDouble(), moreOrLessEquals(2.0));
        expect(readyMade.timeRange2?.toDouble(), moreOrLessEquals(3.0));
        expect(readyMade.ready, isFalse);
        expect(readyMade.working, isFalse);
      });
    });
    test('triggerJob(), onReady: true, immediate run test', () async {
      // assert at begin
      expect(readyMade, isNotNull);
      expect(readyMade.dummy, isNull);
      expect(readyMade.dummy1, isNull);
      expect(readyMade.dummy2, isNull);
      expect(readyMade.timeRange, isNull);
      expect(readyMade.timeRange1, isNull);
      expect(readyMade.timeRange2, isNull);
      expect(readyMade.ready, isFalse);
      expect(readyMade.working, isFalse);

      // act
      readyMade.getReady();
      final result1 = readyMade.triggerJob('job1', onReady: true);
      final result2 = readyMade.triggerJob('job2', onReady: true);

      // assert after
      expect(result1, isA<FutureOr<dynamic>>());
      expect(result2, isA<FutureOr<dynamic>>());
      expect(readyMade.dummy, isNull);
      expect(readyMade.dummy1, isNull);
      expect(readyMade.dummy2, isNull);
      expect(readyMade.timeRange, 0);
      expect(readyMade.timeRange1, isNull);
      expect(readyMade.timeRange2, isNull);
      expect(readyMade.ready, isFalse);
      expect(readyMade.working, isTrue);
      // 1 second elapsed & getReady working
      await Future.delayed(const Duration(seconds: 1)).then((_) {
        expect(readyMade.dummy, isNull);
        expect(readyMade.dummy1, isNull);
        expect(readyMade.dummy2, isNull);
        expect(readyMade.timeRange, 0);
        expect(readyMade.timeRange1, isNull);
        expect(readyMade.timeRange2, isNull);
        expect(readyMade.ready, isFalse);
        expect(readyMade.working, isTrue);
      });
      // another 1 second & getReady's finished
      await Future.delayed(const Duration(seconds: 1)).then((_) {
        expect(readyMade.dummy, 'dummy');
        expect(readyMade.dummy1, isNull);
        expect(readyMade.dummy2, isNull);
        expect(readyMade.timeRange?.toDouble(), moreOrLessEquals(2.0));
        expect(readyMade.timeRange1, isNull);
        expect(readyMade.timeRange2, isNull);
        expect(readyMade.ready, isTrue);
        expect(readyMade.working, isFalse);
      });

      // act again
      final result1_2 = readyMade.triggerJob('job1', onReady: true);
      final result2_2 = readyMade.triggerJob('job2', onReady: true);

      // assert after 2nd run
      expect(result1_2, isA<FutureOr<dynamic>>());
      expect(result2_2, isA<FutureOr<dynamic>>());
      expect(readyMade.dummy, 'dummy');
      expect(readyMade.dummy1, isNull);
      expect(readyMade.dummy2, isNull);
      expect(readyMade.timeRange?.toDouble(), moreOrLessEquals(2.0));
      expect(readyMade.timeRange1, 0); // started
      expect(readyMade.timeRange2, 0); // started
      expect(readyMade.ready, isTrue);
      expect(readyMade.working, isTrue);
      // 1 second elapsed & still working
      await Future.delayed(const Duration(seconds: 1)).then((_) {
        expect(readyMade.dummy1, isNull);
        expect(readyMade.dummy2, isNull);
        expect(readyMade.timeRange1, 0);
        expect(readyMade.timeRange2, 0);
        expect(readyMade.working, isTrue);
      });
      // another 1 second & job1's finished
      await Future.delayed(const Duration(seconds: 1)).then((_) {
        expect(readyMade.dummy1, 'dummy1');
        expect(readyMade.dummy2, isNull);
        expect(readyMade.timeRange1?.toDouble(), moreOrLessEquals(2.0));
        expect(readyMade.timeRange2, 0);
        expect(readyMade.working, isTrue);
      });
      // another 1 second & both job1 and job2 are finished
      await Future.delayed(const Duration(seconds: 1)).then((_) {
        expect(readyMade.dummy1, 'dummy1');
        expect(readyMade.dummy2, 'dummy2');
        expect(readyMade.timeRange1?.toDouble(), moreOrLessEquals(2.0));
        expect(readyMade.timeRange2?.toDouble(), moreOrLessEquals(3.0));
        expect(readyMade.working, isFalse);
      });
    });
    test('triggerJob(), onReady: true, run after ready test', () async {
      // assert at begin
      expect(readyMade, isNotNull);
      expect(readyMade.dummy, isNull);
      expect(readyMade.dummy1, isNull);
      expect(readyMade.dummy2, isNull);
      expect(readyMade.timeRange, isNull);
      expect(readyMade.timeRange1, isNull);
      expect(readyMade.timeRange2, isNull);
      expect(readyMade.ready, isFalse);
      expect(readyMade.working, isFalse);

      // act
      await readyMade.getReady();
      final result1 = readyMade.triggerJob('job1', onReady: true);
      final result2 = readyMade.triggerJob('job2', onReady: true);

      // assert after
      expect(result1, isA<FutureOr<dynamic>>());
      expect(result2, isA<FutureOr<dynamic>>());
      expect(readyMade.dummy, 'dummy');
      expect(readyMade.dummy1, isNull);
      expect(readyMade.dummy2, isNull);
      expect(readyMade.timeRange?.toDouble(), moreOrLessEquals(2.0));
      expect(readyMade.timeRange1, 0);
      expect(readyMade.timeRange2, 0);
      expect(readyMade.ready, isTrue);
      expect(readyMade.working, isTrue);
      // 1 second elapsed & still working
      await Future.delayed(const Duration(seconds: 1)).then((_) {
        expect(readyMade.dummy1, isNull);
        expect(readyMade.dummy2, isNull);
        expect(readyMade.timeRange1, 0);
        expect(readyMade.timeRange2, 0);
        expect(readyMade.working, isTrue);
      });
      // another 1 second & job1's finished
      await Future.delayed(const Duration(seconds: 1)).then((_) {
        expect(readyMade.dummy1, 'dummy1');
        expect(readyMade.dummy2, isNull);
        expect(readyMade.timeRange1?.toDouble(), moreOrLessEquals(2.0));
        expect(readyMade.timeRange2, 0);
        expect(readyMade.working, isTrue);
      });
      // another 1 second & both job1 and job2 are finished
      await Future.delayed(const Duration(seconds: 1)).then((_) {
        expect(readyMade.dummy1, 'dummy1');
        expect(readyMade.dummy2, 'dummy2');
        expect(readyMade.timeRange1?.toDouble(), moreOrLessEquals(2.0));
        expect(readyMade.timeRange2?.toDouble(), moreOrLessEquals(3.0));
        expect(readyMade.working, isFalse);
      });
    });
    test('concurrent triggerJob(), onReady: true, run after ready test',
        () async {
      // assert at begin
      expect(readyMade, isNotNull);
      expect(readyMade.dummy, isNull);
      expect(readyMade.dummy1, isNull);
      expect(readyMade.dummy2, isNull);
      expect(readyMade.timeRange, isNull);
      expect(readyMade.timeRange1, isNull);
      expect(readyMade.timeRange2, isNull);
      expect(readyMade.ready, isFalse);
      expect(readyMade.working, isFalse);

      // act
      await readyMade.getReady();
      readyMade.triggerJob('job1', onReady: true);
      final result1_1 = readyMade.triggerJob('job1', onReady: true);
      final result1_2 = readyMade.triggerJob('job1', onReady: true);
      readyMade.triggerJob('job2', onReady: true);
      final result2_1 = readyMade.triggerJob('job2', onReady: true);
      final result2_2 = readyMade.triggerJob('job2', onReady: true);

      // assert after
      expect(result1_1, isA<FutureOr<dynamic>>());
      expect(result1_2, isA<FutureOr<dynamic>>());
      expect(result2_1, isA<FutureOr<dynamic>>());
      expect(result2_2, isA<FutureOr<dynamic>>());
      expect(readyMade.dummy, 'dummy');
      expect(readyMade.dummy1, isNull);
      expect(readyMade.dummy2, isNull);
      expect(readyMade.timeRange?.toDouble(), moreOrLessEquals(2.0));
      expect(readyMade.timeRange1, 0);
      expect(readyMade.timeRange2, 0);
      expect(readyMade.ready, isTrue);
      expect(readyMade.working, isTrue);
      // 1 second elapsed & still working
      await Future.delayed(const Duration(seconds: 1)).then((_) {
        expect(readyMade.dummy1, isNull);
        expect(readyMade.dummy2, isNull);
        expect(readyMade.timeRange1, 0);
        expect(readyMade.timeRange2, 0);
        expect(readyMade.working, isTrue);
      });
      // another 1 second & job1's finished
      await Future.delayed(const Duration(seconds: 1)).then((_) {
        expect(readyMade.dummy1, 'dummy1');
        expect(readyMade.dummy2, isNull);
        expect(readyMade.timeRange1?.toDouble(), moreOrLessEquals(2.0));
        expect(readyMade.timeRange2, 0);
        expect(readyMade.working, isTrue);
      });
      // another 1 second & both job1 and job2 are finished
      await Future.delayed(const Duration(seconds: 1)).then((_) {
        expect(readyMade.dummy1, 'dummy1');
        expect(readyMade.dummy2, 'dummy2');
        expect(readyMade.timeRange1?.toDouble(), moreOrLessEquals(2.0));
        expect(readyMade.timeRange2?.toDouble(), moreOrLessEquals(3.0));
        expect(readyMade.working, isFalse);
      });
    });
  });
}

// dummy class for testing
class ReadyMade with ReadyOrNotMixin {
  String? dummy;
  String? dummy1;
  String? dummy2;
  int? timeRange;
  int? timeRange1;
  int? timeRange2;

  ReadyMade() {
    super.getReadyWorker = _getReady;
    super.additionalSingleJobs['job1'] = _additionalJob1;
    super.additionalSingleJobs['job2'] = _additionalJob2;
  }

  Future _getReady() {
    timeRange = 0;
    final timeNow = DateTime.now();
    return Future.delayed(const Duration(seconds: 2)).then((_) {
      dummy = 'dummy';
      timeRange = DateTime.now().difference(timeNow).inSeconds;
    });
  }

  Future _additionalJob1() {
    timeRange1 = 0;
    final timeNow = DateTime.now();
    return Future.delayed(const Duration(seconds: 2)).then((_) {
      dummy1 = 'dummy1';
      timeRange1 = DateTime.now().difference(timeNow).inSeconds;
    });
  }

  Future _additionalJob2() {
    timeRange2 = 0;
    final timeNow = DateTime.now();
    return Future.delayed(const Duration(seconds: 3)).then((_) {
      dummy2 = 'dummy2';
      timeRange2 = DateTime.now().difference(timeNow).inSeconds;
    });
  }

  void dispose() {
    dummy = dummy1 = dummy2 = null;
    timeRange = timeRange1 = timeRange2 = null;
  }
}
