import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import registrationIsOpen from '@salesforce/apex/MeetupRegistrationHelper.registrationIsOpen';
import REG_CODE_FIELD from '@salesforce/schema/Meetup__c.RegistrationCode__c';

export default class MeetupRegistrationButton extends NavigationMixin(LightningElement) {
    @api recordId;

    regCode;
    registrationAvailability;
    @track buttonActive;

    @wire(registrationIsOpen, { recordId: '$recordId' }) 
    wiredResult ({error, data}) {
        if (data) {
            if (data === 'This Meetup is open.')
                this.buttonActive = true;
            else {
                this.registrationAvailability = data;
                this.buttonActive = false;
            }
        } else if (error) {
            this.buttonActive = false;
            this.registrationAvailability = error.body;
        }
    };

    @wire(getRecord, { recordId: '$recordId', fields: [REG_CODE_FIELD]})
    wiredRecord ({ error, data }) {
        if (data) {
            this.regCode = getFieldValue(data, REG_CODE_FIELD);
        } else if (error) {
            registrationAvailability = 'Error retrieving record.';
            this.buttonActive = false;
        }
    }
    navigateToRegistration(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: 'c__MeetupRegistrationFormWrapper'
            },
            state: {
                c__regCode: this.regCode
            }
        });
    }
}