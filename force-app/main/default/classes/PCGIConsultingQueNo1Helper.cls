public with sharing class PCGIConsultingQueNo1Helper {
    @future
    public static void insertUser(set<Id> conIds) {
        List<User> usList = new List<User>();
        Profile communityUserProfile = [SELECT Id FROM Profile WHERE Name = 'Customer Community Plus User' LIMIT 1]; // Replace with your profile name
        for(Contact con : [SELECT Id, FirstName, LastName, Email From Contact Where Id IN :conIds]){
            User us = new User();
            us.Username = con.FirstName+con.LastName+'@gmail.com'; // Ensure the username is unique
            us.Email = con.Email;
            us.LastName = con.LastName;
            us.FirstName = con.FirstName;
            us.Alias = con.LastName;
            us.TimeZoneSidKey = 'GMT';
            us.LocaleSidKey = 'en_US';
            us.EmailEncodingKey = 'UTF-8';
            us.ProfileId = communityUserProfile.Id;
            us.LanguageLocaleKey = 'en_US';
            us.CommunityNickname = 'Boss'+con.FirstName;
            us.ContactId = con.Id;
            usList.add(us);
        }
        if(usList.size()>0){
            insert usList;
        }
        assignToPublicGroup(usList);
    }

    public static void assignToPublicGroup(list<User> usList){  
        Group publicGroup = [SELECT Id, Name FROM Group Where Name = 'Wipro Clients' LIMIT 1];
        list<GroupMember> gmList = new list<GroupMember>();
        for(User us : usList){
            GroupMember gm = new GroupMember();
            gm.UserOrGroupId = us.Id;
            gm.GroupId = publicGroup.Id;
            gmList.add(gm);
        }
        if(gmList.size()>0){
            insert gmList;
        }
    }
}