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
    public static String registrationIsOpen(Id recordId) {
        Meetup__c meetup = [SELECT RegistrationLimit__c, NumberOfRegistrations__c, Status__c
        FROM Meetup__c WHERE Id =: recordId];

        if (meetup.NumberOfRegistrations__c >= meetup.RegistrationLimit__c)
            return 'This Meetup is currently at its maximum number of registrations.';

        if (meetup.Status__c == 'Closed')
            return 'This Meetup is closed.';

        return 'This Meetup is open.';
    }
}