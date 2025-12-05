/**
 * SentinelComplianceCopilotTest - Comprehensive Tests for Compliance Copilot
 * 
 * Tests all query types, error handling, and edge cases
 * 
 * @author Sentinel Enterprise
 * @version 2.0
 */
@isTest
private class SentinelComplianceCopilotTest {
    
    /**
     * Test data setup helper
     */
    @TestSetup
    static void setupTestData() {
        // Note: Sentinel_Compliance_Graph__b is a BigObject, so we can't insert test data
        // Tests will rely on existing data or mock responses
        // In a real scenario, you might use a test data factory or mock framework
    }
    
    /**
     * Test: Score change query classification and response
     */
    @isTest
    static void testScoreChangeQuery() {
        Test.startTest();
        SentinelComplianceCopilot.CopilotResponse response = 
            SentinelComplianceCopilot.askCopilot('Why did my compliance score drop?');
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, response, 'Should return response');
        System.assertEquals(SentinelConstants.QUERY_SCORE_CHANGE, response.queryType, 
            'Should classify as score change query');
        System.assertNotEquals(null, response.answer, 'Should have an answer');
        System.assert(response.confidence >= 0 && response.confidence <= 1, 
            'Confidence should be between 0 and 1');
    }
    
    /**
     * Test: Score change query with alternative phrasing
     */
    @isTest
    static void testScoreChangeQueryVariations() {
        List<String> queries = new List<String>{
            'Why did my score drop?',
            'Why did my compliance score change?',
            'What caused my score to go down?',
            'Why did my score went down?'
        };
        
        Test.startTest();
        for (String query : queries) {
            SentinelComplianceCopilot.CopilotResponse response = 
                SentinelComplianceCopilot.askCopilot(query);
            System.assertEquals(SentinelConstants.QUERY_SCORE_CHANGE, response.queryType, 
                'Query: "' + query + '" should classify as score change');
        }
        Test.stopTest();
    }
    
    /**
     * Test: Risky flows query
     */
    @isTest
    static void testRiskyFlowsQuery() {
        Test.startTest();
        SentinelComplianceCopilot.CopilotResponse response = 
            SentinelComplianceCopilot.askCopilot('Show me all risky flows touching PII');
        Test.stopTest();
        
        System.assertNotEquals(null, response, 'Should return response');
        System.assertEquals(SentinelConstants.QUERY_RISKY_FLOWS, response.queryType, 
            'Should classify as risky flows query');
        System.assertNotEquals(null, response.answer, 'Should have an answer');
    }
    
    /**
     * Test: Evidence request query
     */
    @isTest
    static void testEvidenceRequest() {
        Test.startTest();
        SentinelComplianceCopilot.CopilotResponse response = 
            SentinelComplianceCopilot.askCopilot('Generate SOC2 evidence for Q4');
        Test.stopTest();
        
        System.assertNotEquals(null, response, 'Should return response');
        System.assertEquals(SentinelConstants.QUERY_EVIDENCE_REQUEST, response.queryType, 
            'Should classify as evidence request');
        System.assertNotEquals(null, response.answer, 'Should have an answer');
    }
    
    /**
     * Test: Evidence request with different frameworks
     */
    @isTest
    static void testEvidenceRequestFrameworks() {
        List<String> frameworks = new List<String>{ 'HIPAA', 'SOC2', 'NIST', 'FedRAMP', 'GDPR' };
        
        Test.startTest();
        for (String framework : frameworks) {
            SentinelComplianceCopilot.CopilotResponse response = 
                SentinelComplianceCopilot.askCopilot('Generate ' + framework + ' evidence');
            System.assertEquals(SentinelConstants.QUERY_EVIDENCE_REQUEST, response.queryType, 
                'Should classify as evidence request for ' + framework);
        }
        Test.stopTest();
    }
    
    /**
     * Test: Framework status query
     */
    @isTest
    static void testFrameworkStatus() {
        Test.startTest();
        SentinelComplianceCopilot.CopilotResponse response = 
            SentinelComplianceCopilot.askCopilot('What is our HIPAA compliance status?');
        Test.stopTest();
        
        System.assertNotEquals(null, response, 'Should return response');
        System.assertEquals(SentinelConstants.QUERY_FRAMEWORK_STATUS, response.queryType, 
            'Should classify as framework status');
        System.assertNotEquals(null, response.answer, 'Should have an answer');
    }
    
    /**
     * Test: User access query
     */
    @isTest
    static void testUserAccessQuery() {
        Test.startTest();
        SentinelComplianceCopilot.CopilotResponse response = 
            SentinelComplianceCopilot.askCopilot('Who has Modify All Data permission?');
        Test.stopTest();
        
        System.assertNotEquals(null, response, 'Should return response');
        System.assertEquals(SentinelConstants.QUERY_USER_ACCESS, response.queryType, 
            'Should classify as user access query');
        System.assertNotEquals(null, response.answer, 'Should have an answer');
    }
    
    /**
     * Test: User access query variations
     */
    @isTest
    static void testUserAccessQueryVariations() {
        List<String> queries = new List<String>{
            'Who has elevated access?',
            'Show me users with permissions',
            'Who can access all data?'
        };
        
        Test.startTest();
        for (String query : queries) {
            SentinelComplianceCopilot.CopilotResponse response = 
                SentinelComplianceCopilot.askCopilot(query);
            System.assertEquals(SentinelConstants.QUERY_USER_ACCESS, response.queryType, 
                'Query: "' + query + '" should classify as user access');
        }
        Test.stopTest();
    }
    
    /**
     * Test: Violation search query
     */
    @isTest
    static void testViolationSearch() {
        Test.startTest();
        SentinelComplianceCopilot.CopilotResponse response = 
            SentinelComplianceCopilot.askCopilot('Show me recent violations');
        Test.stopTest();
        
        System.assertNotEquals(null, response, 'Should return response');
        System.assertEquals(SentinelConstants.QUERY_VIOLATION_SEARCH, response.queryType, 
            'Should classify as violation search');
        System.assertNotEquals(null, response.answer, 'Should have an answer');
    }
    
    /**
     * Test: General query fallback
     */
    @isTest
    static void testGeneralQuery() {
        Test.startTest();
        SentinelComplianceCopilot.CopilotResponse response = 
            SentinelComplianceCopilot.askCopilot('Hello, what can you do?');
        Test.stopTest();
        
        System.assertNotEquals(null, response, 'Should return response');
        System.assertEquals(SentinelConstants.QUERY_GENERAL, response.queryType, 
            'Should classify as general query');
        System.assertNotEquals(null, response.answer, 'Should have an answer');
        System.assert(response.answer.contains('help'), 
            'General query should contain help text');
    }
    
    /**
     * Test: Get quick commands
     */
    @isTest
    static void testGetQuickCommands() {
        Test.startTest();
        List<Map<String, String>> commands = SentinelComplianceCopilot.getQuickCommands();
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, commands, 'Should return commands list');
        System.assert(commands.size() > 0, 'Should return at least one quick command');
        
        // Verify structure
        for (Map<String, String> command : commands) {
            System.assert(command.containsKey('command'), 
                'Each command should have "command" key');
            System.assert(command.containsKey('icon'), 
                'Each command should have "icon" key');
            System.assertNotEquals(null, command.get('command'), 
                'Command text should not be null');
        }
    }
    
    /**
     * Test: Empty query handling
     */
    @isTest
    static void testEmptyQuery() {
        Test.startTest();
        SentinelComplianceCopilot.CopilotResponse response = 
            SentinelComplianceCopilot.askCopilot('');
        Test.stopTest();
        
        System.assertNotEquals(null, response, 'Should return response even for empty query');
        // Empty query should fall back to general query
        System.assertEquals(SentinelConstants.QUERY_GENERAL, response.queryType, 
            'Empty query should classify as general');
    }
    
    /**
     * Test: Null query handling
     */
    @isTest
    static void testNullQuery() {
        Test.startTest();
        SentinelComplianceCopilot.CopilotResponse response = 
            SentinelComplianceCopilot.askCopilot(null);
        Test.stopTest();
        
        System.assertNotEquals(null, response, 'Should return response even for null query');
        // Null query should fall back to general query
        System.assertEquals(SentinelConstants.QUERY_GENERAL, response.queryType, 
            'Null query should classify as general');
    }
    
    /**
     * Test: Query with special characters
     */
    @isTest
    static void testQueryWithSpecialCharacters() {
        Test.startTest();
        SentinelComplianceCopilot.CopilotResponse response = 
            SentinelComplianceCopilot.askCopilot('What\'s our HIPAA status?');
        Test.stopTest();
        
        System.assertNotEquals(null, response, 'Should handle special characters');
        System.assertNotEquals(null, response.answer, 'Should return an answer');
    }
    
    /**
     * Test: Framework detection in queries
     */
    @isTest
    static void testFrameworkDetection() {
        Map<String, String> frameworkQueries = new Map<String, String>{
            'HIPAA' => 'Show me HIPAA violations',
            'SOC2' => 'What is our SOC 2 compliance?',
            'NIST' => 'Generate NIST evidence',
            'FedRAMP' => 'FedRAMP compliance status',
            'GDPR' => 'GDPR data subject rights'
        };
        
        Test.startTest();
        for (String framework : frameworkQueries.keySet()) {
            SentinelComplianceCopilot.CopilotResponse response = 
                SentinelComplianceCopilot.askCopilot(frameworkQueries.get(framework));
            System.assertNotEquals(null, response, 
                'Should return response for ' + framework + ' query');
        }
        Test.stopTest();
    }
    
    /**
     * Test: Timeframe detection
     */
    @isTest
    static void testTimeframeDetection() {
        List<String> timeframeQueries = new List<String>{
            'Show me today\'s violations',
            'What happened yesterday?',
            'This week\'s compliance changes',
            'This month\'s evidence',
            'Q1 compliance report'
        };
        
        Test.startTest();
        for (String query : timeframeQueries) {
            SentinelComplianceCopilot.CopilotResponse response = 
                SentinelComplianceCopilot.askCopilot(query);
            System.assertNotEquals(null, response, 
                'Should handle timeframe in query: ' + query);
        }
        Test.stopTest();
    }
    
    /**
     * Test: Response structure validation
     */
    @isTest
    static void testResponseStructure() {
        Test.startTest();
        SentinelComplianceCopilot.CopilotResponse response = 
            SentinelComplianceCopilot.askCopilot('Test query');
        Test.stopTest();
        
        // Verify response structure
        System.assertNotEquals(null, response, 'Response should not be null');
        System.assertNotEquals(null, response.answer, 'Answer should not be null');
        System.assertNotEquals(null, response.evidence, 'Evidence list should not be null');
        System.assertNotEquals(null, response.actions, 'Actions list should not be null');
        System.assertNotEquals(null, response.queryType, 'Query type should not be null');
        System.assertNotEquals(null, response.confidence, 'Confidence should not be null');
        
        // Verify confidence range
        System.assert(response.confidence >= 0 && response.confidence <= 1, 
            'Confidence should be between 0 and 1');
    }
    
    /**
     * Test: Error handling with invalid query that might cause exception
     */
    @isTest
    static void testErrorHandling() {
        // This test verifies that exceptions are caught and handled gracefully
        // The actual implementation should handle errors without throwing
        
        Test.startTest();
        try {
            SentinelComplianceCopilot.CopilotResponse response = 
                SentinelComplianceCopilot.askCopilot('Test query for error handling');
            
            // Should not throw exception
            System.assertNotEquals(null, response, 'Should return response even on potential errors');
            System.assertNotEquals(null, response.answer, 'Should have an answer or error message');
        } catch (Exception e) {
            System.assert(false, 'Should not throw exception: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
    /**
     * Test: Multiple queries in sequence
     */
    @isTest
    static void testMultipleQueries() {
        List<String> queries = new List<String>{
            'Why did my score drop?',
            'Show me risky flows',
            'Generate HIPAA evidence',
            'Who has elevated access?',
            'What is our SOC2 status?'
        };
        
        Test.startTest();
        for (String query : queries) {
            SentinelComplianceCopilot.CopilotResponse response = 
                SentinelComplianceCopilot.askCopilot(query);
            System.assertNotEquals(null, response, 
                'Should handle multiple queries: ' + query);
            System.assertNotEquals(null, response.answer, 
                'Should return answer for: ' + query);
        }
        Test.stopTest();
    }
}
