/**
 * Test class for SentinelConstants
 * 
 * @author Sentinel Enterprise
 * @version 1.0
 */
@isTest
private class SentinelConstantsTest {
    
    @isTest
    static void testGetSeverityFromRiskScore() {
        // Test null
        System.assertEquals(SentinelConstants.SEVERITY_LOW, 
            SentinelConstants.getSeverityFromRiskScore(null), 
            'Null should return LOW');
        
        // Test critical threshold
        System.assertEquals(SentinelConstants.SEVERITY_CRITICAL, 
            SentinelConstants.getSeverityFromRiskScore(9.5), 
            '9.5 should be CRITICAL');
        
        // Test high threshold
        System.assertEquals(SentinelConstants.SEVERITY_HIGH, 
            SentinelConstants.getSeverityFromRiskScore(7.5), 
            '7.5 should be HIGH');
        
        // Test medium threshold
        System.assertEquals(SentinelConstants.SEVERITY_MEDIUM, 
            SentinelConstants.getSeverityFromRiskScore(5.5), 
            '5.5 should be MEDIUM');
        
        // Test low threshold
        System.assertEquals(SentinelConstants.SEVERITY_LOW, 
            SentinelConstants.getSeverityFromRiskScore(2.0), 
            '2.0 should be LOW');
    }
    
    @isTest
    static void testGetRatingFromScore() {
        // Test null
        System.assertEquals(SentinelConstants.RATING_CRITICAL, 
            SentinelConstants.getRatingFromScore(null), 
            'Null should return CRITICAL');
        
        // Test excellent
        System.assertEquals(SentinelConstants.RATING_EXCELLENT, 
            SentinelConstants.getRatingFromScore(95), 
            '95 should be EXCELLENT');
        
        // Test good
        System.assertEquals(SentinelConstants.RATING_GOOD, 
            SentinelConstants.getRatingFromScore(85), 
            '85 should be GOOD');
        
        // Test fair
        System.assertEquals(SentinelConstants.RATING_FAIR, 
            SentinelConstants.getRatingFromScore(75), 
            '75 should be FAIR');
        
        // Test needs improvement
        System.assertEquals(SentinelConstants.RATING_NEEDS_IMPROVEMENT, 
            SentinelConstants.getRatingFromScore(55), 
            '55 should be NEEDS_IMPROVEMENT');
        
        // Test critical
        System.assertEquals(SentinelConstants.RATING_CRITICAL, 
            SentinelConstants.getRatingFromScore(40), 
            '40 should be CRITICAL');
    }
    
    @isTest
    static void testGetScoreEmoji() {
        System.assertEquals('🔴', SentinelConstants.getScoreEmoji(null), 'Null should be red');
        System.assertEquals('🟢', SentinelConstants.getScoreEmoji(95), '95 should be green');
        System.assertEquals('🟡', SentinelConstants.getScoreEmoji(85), '85 should be yellow');
        System.assertEquals('🟠', SentinelConstants.getScoreEmoji(75), '75 should be orange');
        System.assertEquals('🔴', SentinelConstants.getScoreEmoji(40), '40 should be red');
    }
    
    @isTest
    static void testGetScoreColor() {
        System.assertEquals('#e74c3c', SentinelConstants.getScoreColor(null), 'Null should be red');
        System.assertEquals('#2ecc71', SentinelConstants.getScoreColor(95), '95 should be green');
        System.assertEquals('#f39c12', SentinelConstants.getScoreColor(85), '85 should be yellow');
        System.assertEquals('#e67e22', SentinelConstants.getScoreColor(75), '75 should be orange');
        System.assertEquals('#e74c3c', SentinelConstants.getScoreColor(40), '40 should be red');
    }
    
    @isTest
    static void testIsValidFramework() {
        // Test valid frameworks
        System.assert(SentinelConstants.isValidFramework('HIPAA'), 'HIPAA should be valid');
        System.assert(SentinelConstants.isValidFramework('SOC2'), 'SOC2 should be valid');
        System.assert(SentinelConstants.isValidFramework('NIST'), 'NIST should be valid');
        System.assert(SentinelConstants.isValidFramework('FedRAMP'), 'FedRAMP should be valid');
        System.assert(SentinelConstants.isValidFramework('GDPR'), 'GDPR should be valid');
        
        // Test case insensitivity
        System.assert(SentinelConstants.isValidFramework('hipaa'), 'hipaa should be valid (case insensitive)');
        
        // Test invalid frameworks
        System.assert(!SentinelConstants.isValidFramework('INVALID'), 'INVALID should not be valid');
        System.assert(!SentinelConstants.isValidFramework(''), 'Empty string should not be valid');
        System.assert(!SentinelConstants.isValidFramework(null), 'Null should not be valid');
    }
    
    @isTest
    static void testConstantValues() {
        // Verify key constants are defined correctly
        System.assertEquals('HIPAA', SentinelConstants.FRAMEWORK_HIPAA);
        System.assertEquals('SOC2', SentinelConstants.FRAMEWORK_SOC2);
        System.assertEquals('CRITICAL', SentinelConstants.SEVERITY_CRITICAL);
        System.assertEquals('HIGH', SentinelConstants.SEVERITY_HIGH);
        System.assertEquals(9.0, SentinelConstants.RISK_THRESHOLD_CRITICAL);
        System.assertEquals(7.0, SentinelConstants.RISK_THRESHOLD_HIGH);
        System.assertEquals('Slack', SentinelConstants.CHANNEL_SLACK);
        System.assertEquals('Teams', SentinelConstants.CHANNEL_TEAMS);
        System.assertEquals(90, SentinelConstants.INACTIVE_USER_THRESHOLD_DAYS);
        System.assertEquals('63.0', SentinelConstants.SALESFORCE_API_VERSION);
    }
    
    @isTest
    static void testAllFrameworksSet() {
        // Verify all frameworks are in the set
        System.assert(SentinelConstants.ALL_FRAMEWORKS.contains(SentinelConstants.FRAMEWORK_HIPAA));
        System.assert(SentinelConstants.ALL_FRAMEWORKS.contains(SentinelConstants.FRAMEWORK_SOC2));
        System.assert(SentinelConstants.ALL_FRAMEWORKS.contains(SentinelConstants.FRAMEWORK_NIST));
        System.assert(SentinelConstants.ALL_FRAMEWORKS.contains(SentinelConstants.FRAMEWORK_FEDRAMP));
        System.assert(SentinelConstants.ALL_FRAMEWORKS.contains(SentinelConstants.FRAMEWORK_GDPR));
        System.assert(SentinelConstants.ALL_FRAMEWORKS.contains(SentinelConstants.FRAMEWORK_SOX));
        System.assert(SentinelConstants.ALL_FRAMEWORKS.contains(SentinelConstants.FRAMEWORK_PCI_DSS));
        
        // Verify count
        System.assertEquals(7, SentinelConstants.ALL_FRAMEWORKS.size(), 'Should have 7 frameworks');
    }
}

