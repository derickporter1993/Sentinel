@IsTest
private class TopOffendersControllerTest {
    @TestSetup
    static void setup() {
        // Create test data for Flow Executions
        List<Flow_Execution__c> flowExecs = new List<Flow_Execution__c>();
        for (Integer i = 0; i < 10; i++) {
            flowExecs.add(
                new Flow_Execution__c(
                    Flow_Name__c = 'TestFlow1',
                    CPU__c = 5000 + (i * 500), // Range: 5000-9500ms
                    SOQL__c = 10,
                    DML__c = 5,
                    Status__c = 'SUCCESS',
                    Run_Time__c = System.now()
                )
            );
        }
        // Add another Flow with different performance
        for (Integer i = 0; i < 5; i++) {
            flowExecs.add(
                new Flow_Execution__c(
                    Flow_Name__c = 'TestFlow2',
                    CPU__c = 2000 + (i * 200), // Range: 2000-2800ms
                    SOQL__c = 5,
                    DML__c = 2,
                    Status__c = 'SUCCESS',
                    Run_Time__c = System.now()
                )
            );
        }
        insert flowExecs;

        // Create test data for Performance Alerts
        List<Performance_Alert_History__c> alerts = new List<Performance_Alert_History__c>();
        for (Integer i = 0; i < 5; i++) {
            alerts.add(
                new Performance_Alert_History__c(
                    Metric__c = 'CPU',
                    Value__c = 8000 + (i * 200),
                    Threshold__c = 9000,
                    Context_Record__c = 'TestClass' + i
                )
            );
        }
        insert alerts;

        // Create test data for API Usage
        List<API_Usage_Snapshot__c> snapshots = new List<API_Usage_Snapshot__c>();
        for (Integer i = 0; i < 3; i++) {
            snapshots.add(
                new API_Usage_Snapshot__c(
                    Taken_On__c = System.now().addHours(-i),
                    Daily_Used__c = 75000 + (i * 1000),
                    Daily_Limit__c = 100000,
                    Percent_Used__c = 75 + i
                )
            );
        }
        insert snapshots;
    }

    @IsTest
    static void testGetTopOffenders() {
        Test.startTest();
        TopOffendersController.TopOffendersData data = TopOffendersController.getTopOffenders(
            5,
            7
        );
        Test.stopTest();

        System.assertNotEquals(null, data, 'Data should not be null');
        System.assertNotEquals(null, data.lastUpdated, 'Last updated should be set');
    }

    @IsTest
    static void testSlowFlows() {
        Test.startTest();
        TopOffendersController.TopOffendersData data = TopOffendersController.getTopOffenders(
            5,
            7
        );
        Test.stopTest();

        System.assertNotEquals(
            null,
            data.slowestFlows,
            'Slowest flows should not be null'
        );
        System.assert(data.slowestFlows.size() > 0, 'Should have slow flows');

        // TestFlow1 should be slower than TestFlow2
        TopOffendersController.OffenderMetric slowest = data.slowestFlows[0];
        System.assertEquals('TestFlow1', slowest.name, 'TestFlow1 should be slowest');
        System.assertEquals('Flow', slowest.type, 'Type should be Flow');
        System.assert(slowest.avgValue > 5000, 'Average should be > 5000ms');
        System.assertNotEquals(
            null,
            slowest.severity,
            'Severity should be set'
        );
        System.assertNotEquals(null, slowest.trend, 'Trend should be set');
    }

    @IsTest
    static void testHighCpuAlerts() {
        Test.startTest();
        TopOffendersController.TopOffendersData data = TopOffendersController.getTopOffenders(
            5,
            7
        );
        Test.stopTest();

        System.assertNotEquals(
            null,
            data.highestCpuClasses,
            'Highest CPU classes should not be null'
        );
        System.assert(
            data.highestCpuClasses.size() > 0,
            'Should have CPU alerts'
        );

        TopOffendersController.OffenderMetric highest = data.highestCpuClasses[0];
        System.assertEquals('Class', highest.type, 'Type should be Class');
        System.assert(
            highest.avgValue >= 8000,
            'Average should be >= 8000ms'
        );
    }

    @IsTest
    static void testApiConsumers() {
        Test.startTest();
        TopOffendersController.TopOffendersData data = TopOffendersController.getTopOffenders(
            5,
            7
        );
        Test.stopTest();

        System.assertNotEquals(
            null,
            data.mostApiConsumers,
            'API consumers should not be null'
        );
        System.assert(
            data.mostApiConsumers.size() > 0,
            'Should have API consumers'
        );

        TopOffendersController.OffenderMetric api = data.mostApiConsumers[0];
        System.assertEquals('API Usage', api.name, 'Name should be API Usage');
        System.assertEquals('API', api.type, 'Type should be API');
        System.assertNotEquals(null, api.trend, 'Trend should be set');
    }

    @IsTest
    static void testSeverityCalculation() {
        Test.startTest();
        TopOffendersController.TopOffendersData data = TopOffendersController.getTopOffenders(
            5,
            7
        );
        Test.stopTest();

        for (TopOffendersController.OffenderMetric metric : data.slowestFlows) {
            System.assert(
                metric.severity == 'Critical' ||
                metric.severity == 'Warning' ||
                metric.severity == 'Good',
                'Severity should be one of the valid values'
            );
        }
    }

    @IsTest
    static void testWithEmptyData() {
        // Delete all test data
        delete [SELECT Id FROM Flow_Execution__c];
        delete [SELECT Id FROM Performance_Alert_History__c];
        delete [SELECT Id FROM API_Usage_Snapshot__c];

        Test.startTest();
        TopOffendersController.TopOffendersData data = TopOffendersController.getTopOffenders(
            5,
            7
        );
        Test.stopTest();

        System.assertNotEquals(null, data, 'Data should not be null');
        System.assertEquals(
            0,
            data.slowestFlows.size(),
            'Should have no slow flows'
        );
        System.assertEquals(
            0,
            data.highestCpuClasses.size(),
            'Should have no CPU alerts'
        );
        System.assertEquals(
            0,
            data.mostApiConsumers.size(),
            'Should have no API consumers'
        );
    }

    @IsTest
    static void testLimitSize() {
        Test.startTest();
        TopOffendersController.TopOffendersData data = TopOffendersController.getTopOffenders(
            2,
            7
        );
        Test.stopTest();

        System.assert(
            data.slowestFlows.size() <= 2,
            'Should respect limit size'
        );
    }
}
