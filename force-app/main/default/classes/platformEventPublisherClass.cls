public with sharing class platformEventPublisherClass {
    @AuraEnabled
    public static void platformEventPublish(string Id, string status){
        try {
            List<Case_Event__e> plateFormEventList = new List<Case_Event__e>();
            plateFormEventList.add(new Case_Event__e(Case_Id__c=Id, Case_Status__c=status));
            platformEventPublisherClassCallBack callBackInstance = new platformEventPublisherClassCallBack();
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
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}