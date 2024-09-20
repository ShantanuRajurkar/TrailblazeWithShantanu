public with sharing class LeadConversionController {
    
    @AuraEnabled
    public static void convertLeadsToOpportunities(Id leadId) {
        Lead leadToConvert = [SELECT Id, Name, Company, IsConverted FROM Lead WHERE Id = :leadId LIMIT 1];
        try {
            // Setup the LeadConvert object for each lead
            Database.LeadConvert leadConvert = new Database.LeadConvert();
            leadConvert.setLeadId(leadId);
            leadConvert.setConvertedStatus('Closed - Converted'); // Use a valid status from your org
            leadConvert.setDoNotCreateOpportunity(false); // Ensure opportunity is created
            leadConvert.setOpportunityName(leadToConvert.Name);
                
            Database.LeadConvertResult result = Database.convertLead(leadConvert);
            system.debug('AccountId : '+ result.getAccountId());
            system.debug('AccountId : '+ result.getContactId());
            system.debug('AccountId : '+ result.getOpportunityId());
            
            
        } catch (Exception e) {
            system.debug('Error converting Lead ' + leadId + ': ' + e.getMessage());
        }
    }
}

