@isTest
private class LeadTriggerHandlerTest {

    // ── Gmail domain tests ──────────────────────────────────────────

    @isTest
    static void testGmailDomainSetsPersonalSource() {
        Lead ld = buildLead('Test', 'Gmail User', 'user@gmail.com');

        Test.startTest();
        insert ld;
        Test.stopTest();

        Lead result = [SELECT LeadSource FROM Lead WHERE Id = :ld.Id];
        System.assertEquals('Personal', result.LeadSource,
            'Gmail domain should set Lead Source to Personal');
    }

    @isTest
    static void testGmailDomainCaseInsensitive() {
        Lead ld = buildLead('Test', 'Mixed Case', 'user@GMAIL.COM');

        Test.startTest();
        insert ld;
        Test.stopTest();

        Lead result = [SELECT LeadSource FROM Lead WHERE Id = :ld.Id];
        System.assertEquals('Personal', result.LeadSource,
            'Gmail domain check should be case-insensitive');
    }

    // ── Business domain test ────────────────────────────────────────

    @isTest
    static void testBusinessDomain() {
        Lead ld = buildLead('Test', 'Biz User', 'user@acme.com');

        Test.startTest();
        insert ld;
        Test.stopTest();

        Lead result = [SELECT LeadSource FROM Lead WHERE Id = :ld.Id];
        System.assertEquals('Business', result.LeadSource,
            'Non-gmail domain should set Lead Source to Business');
    }

    // ── Null / blank email test ─────────────────────────────────────

    @isTest
    static void testNullEmailSkipsAssignment() {
        Lead ld = buildLead('Test', 'No Email', null);

        Test.startTest();
        insert ld;
        Test.stopTest();

        Lead result = [SELECT LeadSource FROM Lead WHERE Id = :ld.Id];
        System.assertEquals(null, result.LeadSource,
            'Null email should not set Lead Source');
    }

    // ── Bulk insert test (200 records) ──────────────────────────────

    @isTest
    static void testBulkInsert() {
        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i < 200; i++) {
            String email = (Math.mod(i, 2) == 0)
                ? 'user' + i + '@gmail.com'
                : 'user' + i + '@corp.com';
            leads.add(buildLead('Test', 'Bulk ' + i, email));
        }

        Test.startTest();
        insert leads;
        Test.stopTest();

        List<Lead> results = [
            SELECT Email, LeadSource
            FROM Lead
            WHERE Id IN :leads
        ];

        for (Lead ld : results) {
            if (ld.Email.endsWith('@gmail.com')) {
                System.assertEquals('Personal', ld.LeadSource,
                    'Bulk gmail leads should be Personal');
            } else {
                System.assertEquals('Business', ld.LeadSource,
                    'Bulk non-gmail leads should be Business');
            }
        }
    }

    // ── Helper ──────────────────────────────────────────────────────

    private static Lead buildLead(String firstName, String lastName, String email) {
        return new Lead(
            FirstName = firstName,
            LastName  = lastName,
            Company   = 'Test Company',
            Email     = email
        );
    }
}
