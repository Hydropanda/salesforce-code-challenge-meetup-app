public with sharing class MeetupRegistrationHelper {
    /*
    * Registration codes are generated using the Crypto class to keep code short and easily maintainable.
    * The smallest AES key is 16 characters, so a temporary string variable is used to store each generated
    * key which is split in four to serve as up to four registration codes and save performance.
    */
    public static void generateRegistrationCodes(List<Meetup__c> meetups) {
        String regCode;
        for (Integer i = 0; i < meetups.size(); i++) {
            switch on Math.mod(i,4) {
                when 0 {
                    regCode = EncodingUtil.convertToHex(Crypto.generateAesKey(128));
                    meetups.get(i).RegistrationCode__c = regCode.substring(0, 8);
                }
                when 1 {meetups.get(i).RegistrationCode__c = regCode.substring(8, 16);}
                when 2 {meetups.get(i).RegistrationCode__c = regCode.substring(16, 24);}
                when 3 {meetups.get(i).RegistrationCode__c = regCode.substring(24, 32);}
            }
        }
    }
    /*
    * Fetches a single meetup matching the registration code provided.
    * Sends an error message if that meetup is closed or full.
    */
    /*@AuraEnabled (cacheable=true)
    public static Meetup__c getMeetupByRegistrationCode(String regCode) {
        Meetup__c meetup = [SELECT Id, Name, RegistrationLimit__c, NumberOfRegistrations__c, Status__c
            FROM Meetup__c WHERE RegistrationCode__c =: regCode LIMIT 1];

        if (meetup.NumberOfRegistrations__c >= meetup.RegistrationLimit__c)
            throw new AuraHandledException('This Meetup is currently at its maximum number of registrations.');

        if (meetup.Status__c == 'Closed')
            throw new AuraHandledException('This Meetup is closed.');

        return meetup;
    }*/
    @AuraEnabled (cacheable=true)
    public static Id getMeetupIdByRegistrationCode(String regCode) {
        return [SELECT Id FROM Meetup__c WHERE RegistrationCode__c =: regCode LIMIT 1].Id;
    }
    @AuraEnabled (cacheable=true)
    public static String registrationIsOpen(Id recordId) {
        Meetup__c meetup = [SELECT RegistrationLimit__c, NumberOfRegistrations__c, Status__c
        FROM Meetup__c WHERE Id =: recordId];

        if (meetup.Status__c == 'Closed')
        return 'This Meetup is closed.';

        if (meetup.NumberOfRegistrations__c >= meetup.RegistrationLimit__c)
            return 'This Meetup is currently at its maximum number of registrations.';

        return 'This Meetup is open.';
    }
    public static void verifyUniqueEmail(List<MeetupRegistration__c> meetupRegs) {
        Set<Id> parentIds = new Set<Id>();
        for (MeetupRegistration__c meetupReg: meetupRegs) {
            parentIds.add(meetupReg.Meetup__c);
        }
        Map<Id, Meetup__c> parentMeetups = new Map<Id, Meetup__c>(
            [SELECT Id, (SELECT Email__c FROM MeetupRegistrations__r) FROM Meetup__c WHERE Id IN: parentIds]);

        for (MeetupRegistration__c meetupReg: meetupRegs) {
            Meetup__c parentMeetup = parentMeetups.get(meetupReg.Meetup__c);
            Set<String> emails = new Set<String>();

            for (MeetupRegistration__c childMeetupReg: parentMeetup.MeetupRegistrations__r)
                emails.add(childMeetupReg.Email__c.toLowerCase());

            if (emails.contains(meetupReg.Email__c.toLowerCase()))
                meetupReg.addError('Meetup Registrations of the same Meetup must have unique email addresses.');
        }
    }
}