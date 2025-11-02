public with sharing class TopOffendersController {
    public class OffenderMetric {
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String type; // 'Flow', 'API', 'Class'
        @AuraEnabled
        public Decimal avgValue;
        @AuraEnabled
        public Decimal maxValue;
        @AuraEnabled
        public Integer executionCount;
        @AuraEnabled
        public String severity; // 'Critical', 'Warning', 'Good'
        @AuraEnabled
        public Decimal percentOfLimit;
        @AuraEnabled
        public String trend; // 'Improving', 'Stable', 'Degrading'
    }

    public class TopOffendersData {
        @AuraEnabled
        public List<OffenderMetric> slowestFlows;
        @AuraEnabled
        public List<OffenderMetric> highestCpuClasses;
        @AuraEnabled
        public List<OffenderMetric> mostApiConsumers;
        @AuraEnabled
        public Datetime lastUpdated;
    }

    @AuraEnabled(cacheable=true)
    public static TopOffendersData getTopOffenders(Integer limitSize, Integer daysBack) {
        TopOffendersData data = new TopOffendersData();
        data.lastUpdated = System.now();

        Datetime startDate = System.now().addDays(-Math.abs(daysBack));

        // Get slowest Flows
        data.slowestFlows = getSlowFlows(limitSize, startDate);

        // Get highest CPU consumers (from Performance Alerts)
        data.highestCpuClasses = getHighCpuAlerts(limitSize, startDate);

        // Get API consumers
        data.mostApiConsumers = getApiConsumers(limitSize, startDate);

        return data;
    }

    private static List<OffenderMetric> getSlowFlows(Integer limitSize, Datetime startDate) {
        List<OffenderMetric> results = new List<OffenderMetric>();

        // Aggregate Flow execution data
        AggregateResult[] groupedResults = [
            SELECT
                Flow_Name__c,
                AVG(CPU__c) avgCpu,
                MAX(CPU__c) maxCpu,
                COUNT(Id) execCount
            FROM Flow_Execution__c
            WHERE
                CreatedDate >= :startDate
                AND CPU__c != NULL
            GROUP BY Flow_Name__c
            ORDER BY AVG(CPU__c) DESC
            LIMIT :Math.max(1, limitSize)
        ];

        for (AggregateResult ar : groupedResults) {
            OffenderMetric metric = new OffenderMetric();
            metric.name = String.valueOf(ar.get('Flow_Name__c'));
            metric.type = 'Flow';
            metric.avgValue = (Decimal) ar.get('avgCpu');
            metric.maxValue = (Decimal) ar.get('maxCpu');
            metric.executionCount = (Integer) ar.get('execCount');
            metric.percentOfLimit = (metric.avgValue / 10000) * 100; // CPU limit is 10,000ms
            metric.severity = calculateSeverity(metric.percentOfLimit);
            metric.trend = calculateTrend(metric.name, 'Flow', startDate);
            results.add(metric);
        }

        return results;
    }

    private static List<OffenderMetric> getHighCpuAlerts(
        Integer limitSize,
        Datetime startDate
    ) {
        List<OffenderMetric> results = new List<OffenderMetric>();

        // Get CPU alerts grouped by context
        AggregateResult[] groupedResults = [
            SELECT
                Context_Record__c,
                AVG(Value__c) avgValue,
                MAX(Value__c) maxValue,
                COUNT(Id) alertCount
            FROM Performance_Alert_History__c
            WHERE
                CreatedDate >= :startDate
                AND Metric__c = 'CPU'
                AND Context_Record__c != NULL
            GROUP BY Context_Record__c
            ORDER BY AVG(Value__c) DESC
            LIMIT :Math.max(1, limitSize)
        ];

        for (AggregateResult ar : groupedResults) {
            OffenderMetric metric = new OffenderMetric();
            metric.name = String.valueOf(ar.get('Context_Record__c'));
            metric.type = 'Class';
            metric.avgValue = (Decimal) ar.get('avgValue');
            metric.maxValue = (Decimal) ar.get('maxValue');
            metric.executionCount = (Integer) ar.get('alertCount');
            metric.percentOfLimit = (metric.avgValue / 10000) * 100;
            metric.severity = calculateSeverity(metric.percentOfLimit);
            metric.trend = 'Stable'; // Simplified for now
            results.add(metric);
        }

        return results;
    }

    private static List<OffenderMetric> getApiConsumers(Integer limitSize, Datetime startDate) {
        List<OffenderMetric> results = new List<OffenderMetric>();

        // Get recent API snapshots and calculate trends
        List<API_Usage_Snapshot__c> snapshots = [
            SELECT Daily_Used__c, Daily_Limit__c, Percent_Used__c, Taken_On__c
            FROM API_Usage_Snapshot__c
            WHERE Taken_On__c >= :startDate
            ORDER BY Taken_On__c DESC
            LIMIT :Math.max(1, limitSize * 2)
        ];

        if (!snapshots.isEmpty()) {
            OffenderMetric metric = new OffenderMetric();
            metric.name = 'API Usage';
            metric.type = 'API';

            // Calculate average from recent snapshots
            Decimal totalUsed = 0;
            Decimal totalLimit = 0;
            for (API_Usage_Snapshot__c snapshot : snapshots) {
                totalUsed += snapshot.Daily_Used__c;
                totalLimit += snapshot.Daily_Limit__c;
            }

            metric.avgValue = totalUsed / snapshots.size();
            metric.maxValue = snapshots[0].Daily_Used__c; // Most recent
            metric.executionCount = snapshots.size();
            metric.percentOfLimit = (metric.avgValue / (totalLimit / snapshots.size())) * 100;
            metric.severity = calculateSeverity(metric.percentOfLimit);
            metric.trend = calculateApiTrend(snapshots);
            results.add(metric);
        }

        return results;
    }

    private static String calculateSeverity(Decimal percentOfLimit) {
        if (percentOfLimit >= 90) {
            return 'Critical';
        } else if (percentOfLimit >= 70) {
            return 'Warning';
        } else {
            return 'Good';
        }
    }

    private static String calculateTrend(String name, String type, Datetime startDate) {
        // Compare first half vs second half of time period
        Datetime midpoint = startDate.addSeconds(
            (Integer) ((System.now().getTime() - startDate.getTime()) / 2000)
        );

        if (type == 'Flow') {
            AggregateResult[] firstHalf = [
                SELECT AVG(CPU__c) avgCpu
                FROM Flow_Execution__c
                WHERE
                    Flow_Name__c = :name
                    AND CreatedDate >= :startDate
                    AND CreatedDate < :midpoint
            ];

            AggregateResult[] secondHalf = [
                SELECT AVG(CPU__c) avgCpu
                FROM Flow_Execution__c
                WHERE Flow_Name__c = :name AND CreatedDate >= :midpoint
            ];

            if (firstHalf.isEmpty() || secondHalf.isEmpty()) {
                return 'Stable';
            }

            Decimal firstAvg = (Decimal) firstHalf[0].get('avgCpu');
            Decimal secondAvg = (Decimal) secondHalf[0].get('avgCpu');

            if (firstAvg == null || secondAvg == null) {
                return 'Stable';
            }

            Decimal change = ((secondAvg - firstAvg) / firstAvg) * 100;

            if (change < -10) {
                return 'Improving';
            } else if (change > 10) {
                return 'Degrading';
            } else {
                return 'Stable';
            }
        }

        return 'Stable';
    }

    private static String calculateApiTrend(List<API_Usage_Snapshot__c> snapshots) {
        if (snapshots.size() < 2) {
            return 'Stable';
        }

        // Compare most recent to oldest in the set
        Decimal recent = snapshots[0].Percent_Used__c;
        Decimal old = snapshots[snapshots.size() - 1].Percent_Used__c;

        Decimal change = recent - old;

        if (change < -5) {
            return 'Improving';
        } else if (change > 5) {
            return 'Degrading';
        } else {
            return 'Stable';
        }
    }
}
