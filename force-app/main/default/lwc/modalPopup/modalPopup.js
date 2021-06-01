import {
    LightningElement,
    api,
    track
} from 'lwc';
import deleteMileages from '@salesforce/apex/GetDriverData.deleteMileages'
import approveMileages from '@salesforce/apex/GetDriverData.approveMileages';

export default class ModalPopup extends LightningElement {
    @api modalHeader;
    @track spinnerLoad = false;
    @api modalContent;
    @api approvedTripList;
    @api isChecked = false;
    @api ModalClassList() {
        let sectionElement = this.template.querySelector("section");
        return sectionElement;
    }
    @api ModalBackdrop() {
        let modalbackdrop = this.template.querySelector("div.modalBackdrops");
        return modalbackdrop;
    }
    @track sendEmailValue = false;

    // Yes Button Click Event
    handleEmailSend() {
        if (this.isChecked != null) {
            this.sendEmailValue = true;
            this.SendEmailCheck();
            //window.location.reload();
        }else{
            this.handleDeleteTrip();
        }
        this.template.querySelector("section").classList.add("slds-hide");
        this.template
            .querySelector("div.modalBackdrops")
            .classList.add("slds-hide");
        console.log("is checked" , this.isChecked);
      
    }

    // No Button Click Event
    handleNoEmailSend() {
        this.spinnerLoad = true;
        if (this.isChecked != null) {
            this.sendEmailValue = false;
            this.SendEmailCheck();
            //window.location.reload();
        }
        this.template.querySelector("section").classList.add("slds-hide");
        this.template
            .querySelector("div.modalBackdrops")
            .classList.add("slds-hide");
        //window.location.reload();
    }

    // Will Send Email To List Of Users For Approve / Reject
  async  SendEmailCheck() {
      try{
        this.approveTrip = this.approvedTripList;
        this.selectedCheck = this.isChecked;
        let approveData = await approveMileages({
                checked: this.selectedCheck,
                emailaddress: this.approveTrip,
                sendEmail: this.sendEmailValue
            });
            if(approveData){
                const emailSend = new CustomEvent("handlesendemailevent", {
                    detail: approveData
                });
                this.dispatchEvent(emailSend);
                this.spinnerLoad = false;
            }
      }catch (error) {
        console.log(error);
    }
       
    }

    // Close 'X' Event
    handleCancel() {
        this.template.querySelector("section").classList.add("slds-hide");
        this.template
            .querySelector("div.modalBackdrops")
            .classList.add("slds-hide");
    }

    // delete trip event
    handleDeleteTrip(){
        this.approveTrip = this.approvedTripList;
        deleteMileages({
            emailaddress: this.approveTrip
        })
        .then((result) => {
            console.log(result);
            if(result){
                const deleteTrip = new CustomEvent("handledeletetripevent", {
                    detail: result
                });
          
                this.dispatchEvent(deleteTrip);
            }
        })
        .catch((error) => {
            console.log(error)
        })
    }
   
}