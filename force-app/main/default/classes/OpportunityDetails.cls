public with sharing class OpportunityDetails {
    @AuraEnabled(cacheable=true)
    public static list<Opportunity> getOppListForMindRubyQueNo3(String Stage){
        try {
            return [SELECT Id, Name, Amount, CloseDate, StageName FROM Opportunity WHERE StageName =:Stage WITH SECURITY_ENFORCED];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}