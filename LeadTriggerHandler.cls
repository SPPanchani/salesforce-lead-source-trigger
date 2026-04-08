public class LeadTriggerHandler {

    private static final String PERSONAL_DOMAIN = 'gmail.com';
    private static final String SOURCE_PERSONAL = 'Personal';
    private static final String SOURCE_BUSINESS = 'Business';

    /**
     * Entry point called from LeadTrigger on before insert.
     * @param newLeads List of Lead records being inserted.
     */
    public static void handleBeforeInsert(List<Lead> newLeads) {
        setLeadSourceByEmailDomain(newLeads);
    }

    /**
     * Sets LeadSource based on the email domain:
     *   - gmail.com → "Personal"
     *   - Any other domain → "Business"
     *   - Null/blank email → skipped (no change)
     *
     * Runs in before-insert context so field updates require no extra DML.
     * Bulk-safe: iterates the full list with no SOQL/DML inside the loop.
     */
    private static void setLeadSourceByEmailDomain(List<Lead> leads) {
        for (Lead ld : leads) {
            if (String.isBlank(ld.Email)) {
                continue;
            }

            String domain = ld.Email.substringAfter('@').toLowerCase();

            if (domain == PERSONAL_DOMAIN) {
                ld.LeadSource = SOURCE_PERSONAL;
            } else {
                ld.LeadSource = SOURCE_BUSINESS;
            }
        }
    }
}
