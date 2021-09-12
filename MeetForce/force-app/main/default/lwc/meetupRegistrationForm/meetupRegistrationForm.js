import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

import OBJECT_API_NAME from '@salesforce/schema/MeetupRegistration__c';
import FIRST_NAME_FIELD from '@salesforce/schema/MeetupRegistration__c.FirstName__c';
import LAST_NAME_FIELD from '@salesforce/schema/MeetupRegistration__c.LastName__c';
import EMAIL_FIELD from '@salesforce/schema/MeetupRegistration__c.Email__c';

import getMeetupIdByRegistrationCode from '@salesforce/apex/MeetupRegistrationHelper.getMeetupIdByRegistrationCode';

export default class MeetupRegistrationForm extends LightningElement {
    @track regCode;
    parentId;

    fields = [FIRST_NAME_FIELD, LAST_NAME_FIELD, EMAIL_FIELD];

    @wire(CurrentPageReference) 
    getState (currentPageReference) {
        if (currentPageReference) {
            this.regCode = currentPageReference.state.c__regCode;
        }
    }

    @wire (getMeetupIdByRegistrationCode, {regCode: '$regCode'})
    wiredResult ({error, data}) {
        if (data) {
            this.parentId = data;
        } else if (error) {
            // Sophisticated error handling
            console.log(error);
            console.log(this.regCode);
        }
    }

    handleSubmit(event) {
        event.preventDefault();
        const submitFields = event.detail.fields;
        submitFields.Meetup__c = this.parentId;
        this.template.querySelector('lightning-record-form').submit(submitFields);
    }

    get registerPrompt() {
        return "Register for Meetup with code: " + this.regCode;
    }

    get objectApiName() {
        return OBJECT_API_NAME;
    }

    /*handleSuccess(event) {
        event.preventDefault();
        event.stopImmediatePropogation();

        const evt = new ShowToastEvent({
            title: "Account created",
            message: "Successfully registered for Meetup with code: " + this.regCode,
            variant: "success"
        });
        this.dispatchEvent(evt);
    }*/
}