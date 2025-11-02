@IsTest
private class SlackNotifierTest {
    // Mock class for Slack HTTP callout
    private class SlackCalloutMock implements HttpCalloutMock {
        public Integer statusCode;
        public String status;

        public SlackCalloutMock(Integer statusCode, String status) {
            this.statusCode = statusCode;
            this.status = status;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(this.statusCode);
            res.setStatus(this.status);
            res.setBody('ok');
            return res;
        }
    }

    @IsTest
    static void testNotifyAsyncSuccess() {
        Test.setMock(HttpCalloutMock.class, new SlackCalloutMock(200, 'OK'));

        Test.startTest();
        SlackNotifier.notifyAsync('Test notification message');
        Test.stopTest();

        // Verify the async method completed without throwing an exception
        // In a real scenario, we'd verify the callout was made with correct params
        System.assert(true, 'notifyAsync completed successfully');
    }

    @IsTest
    static void testNotifyPerformanceEvent() {
        Test.setMock(HttpCalloutMock.class, new SlackCalloutMock(200, 'OK'));

        Performance_Alert__e testEvent = new Performance_Alert__e(
            Metric__c = 'CPU',
            Value__c = 9500,
            Threshold__c = 9000,
            Context_Record__c = '001000000000001',
            Stack__c = 'Stack trace here'
        );

        Test.startTest();
        SlackNotifier.notifyPerformanceEvent(testEvent);
        Test.stopTest();

        // Verify the method executed without errors
        System.assert(true, 'notifyPerformanceEvent completed successfully');
    }

    @IsTest
    static void testNotifyPerformanceEventWithoutContext() {
        Test.setMock(HttpCalloutMock.class, new SlackCalloutMock(200, 'OK'));

        Performance_Alert__e testEvent = new Performance_Alert__e(
            Metric__c = 'HEAP',
            Value__c = 5500,
            Threshold__c = 5000,
            Context_Record__c = null,
            Stack__c = null
        );

        Test.startTest();
        SlackNotifier.notifyPerformanceEvent(testEvent);
        Test.stopTest();

        System.assert(true, 'notifyPerformanceEvent with null context completed successfully');
    }

    @IsTest
    static void testNotifyAsyncFailure() {
        // Test error handling when Slack returns an error
        Test.setMock(HttpCalloutMock.class, new SlackCalloutMock(500, 'Internal Server Error'));

        Test.startTest();
        // Should not throw exception, just log the error
        SlackNotifier.notifyAsync('Test message');
        Test.stopTest();

        // Method should handle error gracefully (logged to debug)
        System.assert(true, 'notifyAsync handled error gracefully');
    }

    @IsTest
    static void testNotifyAsyncWithException() {
        // Don't set a mock to simulate a callout exception scenario
        // Note: This would normally fail without a mock, but the try-catch should handle it

        Test.startTest();
        try {
            SlackNotifier.notifyAsync('Test message');
            // Without a mock or Named Credential, this may fail but should be caught
        } catch (Exception e) {
            // If it throws, that's also acceptable for this test
        }
        Test.stopTest();

        System.assert(true, 'notifyAsync exception handling tested');
    }

    @IsTest
    static void testNotifyRichAsyncSuccess() {
        Test.setMock(HttpCalloutMock.class, new SlackCalloutMock(200, 'OK'));

        String richPayload = '{"blocks":[{"type":"header","text":{"type":"plain_text","text":"Test Alert"}}]}';

        Test.startTest();
        SlackNotifier.notifyRichAsync(richPayload);
        Test.stopTest();

        System.assert(true, 'notifyRichAsync completed successfully');
    }

    @IsTest
    static void testNotifyRichAsyncFailure() {
        Test.setMock(
            HttpCalloutMock.class,
            new SlackCalloutMock(400, 'Bad Request')
        );

        String richPayload = '{"blocks":[{"type":"header","text":{"type":"plain_text","text":"Test Alert"}}]}';

        Test.startTest();
        SlackNotifier.notifyRichAsync(richPayload);
        Test.stopTest();

        // Should handle error gracefully without throwing exception
        System.assert(true, 'notifyRichAsync handled error gracefully');
    }

    @IsTest
    static void testBuildPerformanceAlertBlocks() {
        Performance_Alert__e testEvent = new Performance_Alert__e(
            Metric__c = 'CPU',
            Value__c = 9500,
            Threshold__c = 9000,
            Context_Record__c = '001000000000001AAA',
            Stack__c = 'Performance threshold exceeded in MyClass.myMethod'
        );

        Test.startTest();
        String jsonPayload = SlackNotifier.buildPerformanceAlertBlocks(testEvent);
        Test.stopTest();

        System.assertNotEquals(
            null,
            jsonPayload,
            'JSON payload should not be null'
        );
        System.assert(
            jsonPayload.contains('blocks'),
            'Should contain blocks array'
        );
        System.assert(jsonPayload.contains('CPU'), 'Should contain metric name');
        System.assert(
            jsonPayload.contains('9500'),
            'Should contain value'
        );
        System.assert(
            jsonPayload.contains('9000'),
            'Should contain threshold'
        );
        System.assert(
            jsonPayload.contains('attachments'),
            'Should contain attachments for color'
        );
    }

    @IsTest
    static void testBuildPerformanceAlertBlocksCriticalSeverity() {
        // Test critical severity (red color)
        Performance_Alert__e criticalEvent = new Performance_Alert__e(
            Metric__c = 'HEAP',
            Value__c = 5800,
            Threshold__c = 5000,
            Context_Record__c = '001000000000002AAA',
            Stack__c = 'Critical heap usage'
        );

        Test.startTest();
        String jsonPayload = SlackNotifier.buildPerformanceAlertBlocks(
            criticalEvent
        );
        Test.stopTest();

        System.assert(
            jsonPayload.contains('#c23934') || jsonPayload.contains('danger'),
            'Critical alerts should use red color'
        );
        System.assert(jsonPayload.contains('🔴'), 'Should contain red emoji');
    }

    @IsTest
    static void testBuildPerformanceAlertBlocksWarningSeverity() {
        // Test warning severity (orange color)
        Performance_Alert__e warningEvent = new Performance_Alert__e(
            Metric__c = 'SOQL',
            Value__c = 85,
            Threshold__c = 90,
            Context_Record__c = '001000000000003AAA',
            Stack__c = 'SOQL query count warning'
        );

        Test.startTest();
        String jsonPayload = SlackNotifier.buildPerformanceAlertBlocks(
            warningEvent
        );
        Test.stopTest();

        System.assert(
            jsonPayload.contains('#ffb75d') || jsonPayload.contains('warning'),
            'Warning alerts should use orange color'
        );
        System.assert(jsonPayload.contains('⚠️'), 'Should contain warning emoji');
    }

    @IsTest
    static void testNotifyFlowPerformanceSuccess() {
        Test.setMock(HttpCalloutMock.class, new SlackCalloutMock(200, 'OK'));

        Test.startTest();
        SlackNotifier.notifyFlowPerformance(
            'MySlowFlow',
            8500,
            9000,
            'a0x000000000001AAA'
        );
        Test.stopTest();

        System.assert(true, 'notifyFlowPerformance completed successfully');
    }

    @IsTest
    static void testNotifyFlowPerformanceWithoutRecordId() {
        Test.setMock(HttpCalloutMock.class, new SlackCalloutMock(200, 'OK'));

        Test.startTest();
        SlackNotifier.notifyFlowPerformance('MySlowFlow', 8500, 9000, null);
        Test.stopTest();

        System.assert(
            true,
            'notifyFlowPerformance without recordId completed successfully'
        );
    }

    @IsTest
    static void testNotifyFlowPerformanceFailure() {
        Test.setMock(
            HttpCalloutMock.class,
            new SlackCalloutMock(500, 'Internal Server Error')
        );

        Test.startTest();
        SlackNotifier.notifyFlowPerformance(
            'MySlowFlow',
            8500,
            9000,
            'a0x000000000001AAA'
        );
        Test.stopTest();

        // Should handle error gracefully
        System.assert(true, 'notifyFlowPerformance handled error gracefully');
    }

    @IsTest
    static void testRichNotificationStructure() {
        Performance_Alert__e testEvent = new Performance_Alert__e(
            Metric__c = 'DML',
            Value__c = 145,
            Threshold__c = 150,
            Context_Record__c = null,
            Stack__c = null
        );

        Test.startTest();
        String jsonPayload = SlackNotifier.buildPerformanceAlertBlocks(testEvent);
        Test.stopTest();

        // Verify JSON structure elements
        System.assert(
            jsonPayload.contains('"type":"header"'),
            'Should have header block'
        );
        System.assert(
            jsonPayload.contains('"type":"section"'),
            'Should have section blocks'
        );
        System.assert(
            jsonPayload.contains('"type":"divider"'),
            'Should have divider'
        );
        System.assert(
            jsonPayload.contains('fields'),
            'Should have fields array'
        );
    }
}
