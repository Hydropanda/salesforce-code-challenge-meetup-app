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
    @isTest
    static void getMeetupIdByRegistrationCodeTest() {
        Test.startTest();
        Meetup__c meetup = [SELECT Id, RegistrationCode__c FROM Meetup__c LIMIT 1];
        Id fetchedId = MeetupRegistrationHelper.getMeetupIdByRegistrationCode(meetup.RegistrationCode__c);
        Test.stopTest();

        System.assertEquals(meetup.Id, fetchedId);
    }
    @isTest
    static void registrationIsOpenTest() {
        Test.startTest();
        List<Meetup__c> meetups = [SELECT Id, Status__c, RegistrationLimit__c FROM Meetup__c WHERE Status__c = 'Open' LIMIT 3];
        meetups.get(1).Status__c = 'Closed';
        meetups.get(2).RegistrationLimit__c = 0;
        update meetups;

        List<String> responses = new List<String>();
        for (Meetup__c meetup: meetups) {
            responses.add(MeetupRegistrationHelper.registrationIsOpen(meetup.Id));
        }
        Test.stopTest();

        System.assertEquals('This Meetup is open.', responses.get(0));
        System.assertEquals('This Meetup is closed.', responses.get(1));
        System.assertEquals('This Meetup is currently at its maximum number of registrations.', responses.get(2));
    }
    @isTest
    static void verifyUniqueEmailTest() {
        String errorMessage;
        Test.startTest();
        Meetup__c meetup = [SELECT Id FROM Meetup__c LIMIT 1];
        MeetupRegistration__c reg1 = new MeetupRegistration__c(FirstName__c = 'John', LastName__c = 'Johnson',
            Email__c = 'jj@jj.com', Meetup__c = meetup.Id);

        MeetupRegistration__c reg2 = new MeetupRegistration__c(FirstName__c = 'John', LastName__c = 'Johnson',
            Email__c = 'jj@jj.com', Meetup__c = meetup.Id);

        insert reg1;
        try {
            insert reg2;
        } catch (DMLException e) {
            errorMessage = e.getMessage();
        }
        Test.stopTest();

        System.assertNotEquals(null, reg1.Id);
        System.assertEquals(null, reg2.Id);
        System.assertEquals(
            'Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, Meetup Registrations of the same Meetup must have unique email addresses.',
            errorMessage);
    }
}