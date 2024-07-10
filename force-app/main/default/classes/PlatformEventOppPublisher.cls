public class PlatformEventOppPublisher {
	public static void PlatformEventPublisherMethod(String opportunityName, Integer amount, Date closeDate, String leadSource, String stageName) {
        List<Opportunity_Event__e> plateFormEventList = new List<Opportunity_Event__e>();
        plateFormEventList.add(new Opportunity_Event__e(Opportunity_Name__c=opportunityName, Amount__c=amount, Close_Date__c=closeDate, Lead_Source__c=leadSource, Stage_Name__c=stageName));
        PlatformEventDemoCallBack callBackInstance = new PlatformEventDemoCallBack();
        list<Database.SaveResult> srResultList=EventBus.publish(plateFormEventList, callBackInstance);
        for(Database.SaveResult srResult : srResultList) {
            if(srResult.isSuccess()) {
                system.debug('Successfully published event.');
            } else {
                for(Database.Error err : srResult.getErrors()) {
                    system.debug('Error returned:'+err.getMessage());
                }
            }
        }
    }
}