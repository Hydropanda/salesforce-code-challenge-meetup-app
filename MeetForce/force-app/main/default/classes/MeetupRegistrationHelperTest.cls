@isTest
class MeetupRegistrationHelperTest {
    @TestSetup
    static void makeData() {
        List<Meetup__c> meetups = new List<Meetup__c>();
        for (Integer i = 0; i < 200; i++)
            meetups.add(new Meetup__c(Name = 'TestMeetup' + i, RegistrationLimit__c = 8));
        
        insert meetups;
    }
    @isTest
    static void generateRegistrationCodesTest() {
        List<String> regCodes = new List<String>();
        Boolean noRepeats = true;
        Integer i = 0;
        
        Test.startTest();
        List<Meetup__c> meetups = [SELECT RegistrationCode__c FROM Meetup__c WHERE Status__c = 'Open'];
        while (noRepeats && i < meetups.size()) {
            if (regCodes.contains(meetups.get(i).RegistrationCode__c))
                noRepeats = false;
            else regCodes.add(meetups.get(i).RegistrationCode__c);
            i++;
        }
        Test.stopTest();

        System.assertEquals(8, meetups.get(0).RegistrationCode__c.length());
        System.assert(noRepeats);
    }
}