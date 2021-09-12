trigger MeetupRegistrationTrigger on MeetupRegistration__c (before insert) {
    if (Trigger.isInsert && Trigger.isBefore) 
        MeetupRegistrationHelper.verifyUniqueEmail(Trigger.new);
}