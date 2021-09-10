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
}