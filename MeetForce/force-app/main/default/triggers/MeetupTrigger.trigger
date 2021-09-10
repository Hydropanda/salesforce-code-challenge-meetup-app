trigger MeetupTrigger on Meetup__c (before insert) {
    if (Trigger.isInsert && Trigger.isBefore)
        MeetupRegistrationHelper.generateRegistrationCodes(Trigger.new);
}