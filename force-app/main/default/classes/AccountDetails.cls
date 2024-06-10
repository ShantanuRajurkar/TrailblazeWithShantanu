public with sharing class AccountDetails {
    @AuraEnabled
    public static string updateAccountRecord(string recordId, string newPhone) {
        Account acc = new Account(Id=recordId, Phone=newPhone);
        try{
            update acc;
            return 'Success';
        }catch(Exception Ex){
            return ex.getMessage();
        }
    }
}