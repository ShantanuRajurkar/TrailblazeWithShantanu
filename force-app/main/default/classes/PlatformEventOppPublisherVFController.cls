public class PlatformEventOppPublisherVFController {
    public Date oppDate {get; set;}
    public String oppName {get; set;}
    public Integer oppAmount {get; set;}
    public Opportunity opp { get; set; }
    public List<SelectOption> leadSourceOptions { get; set; }
    public List<SelectOption> leadStageOptions { get; set; }
    public PlatformEventOppPublisherVFController(){
        system.debug('Hi Bro');
        opp = new Opportunity();
        leadSourceOptions = new List<SelectOption>();
        leadStageOptions = new List<SelectOption>();
        populateLeadSourceOptions();
    }
    private void populateLeadSourceOptions() {
        // Get the picklist values for LeadSource field
        Schema.DescribeFieldResult fieldResult = Opportunity.LeadSource.getDescribe();
        Schema.DescribeFieldResult fieldResult1 = Opportunity.StageName.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        List<Schema.PicklistEntry> ple1 = fieldResult1.getPicklistValues();
        for (Schema.PicklistEntry f : ple) {
            leadSourceOptions.add(new SelectOption(f.getValue(), f.getLabel()));
        }
        for (Schema.PicklistEntry f : ple1) {
            leadStageOptions.add(new SelectOption(f.getValue(), f.getLabel()));
        }
    }
    public void submit(){
        system.debug('Lead Source : '+ opp.LeadSource+' Name : '+ oppName);
        PlatformEventOppPublisher.PlatformEventPublisherMethod(oppName, oppAmount, oppDate, opp.LeadSource, opp.StageName);
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Opportunity submitted successfully!'));
        emptyData();
    }
    public void emptyData(){
        oppName='';
        oppAmount=null;
        oppDate=null;
        opp.LeadSource='';
        opp.StageName='';
    }
}