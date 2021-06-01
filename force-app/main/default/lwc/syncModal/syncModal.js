import {
    LightningElement,
    api
} from 'lwc';
import deleteTrips from '@salesforce/apex/GetDriverData.deleteTrips';
import MassSyncTrips from '@salesforce/apex/GetDriverData.MassSyncTrips';
/* Import common js file */
import {
    dateTypeFormat,
    yearMonthDate
} from 'c/commonLib';
export default class SyncModal extends LightningElement {
    waiting = false;
    chkValue = false;
    syStDate;
    syEnDate;
    selectedMonth;
    /* Get account Id */
    @api accId;

    /* Get Modal Class */
    @api modalClassName() {
        var sectionElement = this.template.querySelector("section");
        return sectionElement;
    }

    /* Get Modal Backdrop Class */
    @api modalBackdropClass() {
        var backdrop = this.template.querySelector("div.Backdrops");
        return backdrop;
    }

    /* options to bind with lightning comboBox */
    get options() {
        var optionList;
        var currentDate = new Date();
        var previousDate = new Date(currentDate.getFullYear(), currentDate.getMonth() - 1, 1);
        var lastSyncMonth = dateTypeFormat(previousDate);
        var currentSyncMonth = dateTypeFormat(currentDate);
        optionList = [{
            label: lastSyncMonth,
            value: lastSyncMonth
        }, {
            label: currentSyncMonth,
            value: currentSyncMonth
        }];
        return optionList;
    }

    get status() {
        var statusList;
        statusList = [{
                label: "Un Submitted",
                value: "U"
            },
            {
                label: "Submitted",
                value: "S"
            }
        ]
        return statusList;
    }
    // Close 'X' Event
    handleCancel() {
        this.template.querySelector("section").classList.add("slds-hide");
        this.template
            .querySelector("div.Backdrops")
            .classList.add("slds-hide");

    }

    // Select Button Click Event
    handleChange(event) {
        if (event.detail.value != undefined && this.stValue != undefined) {
            this.template.querySelector('.slds-button_brand').disabled = false;
        } else {
            this.template.querySelector('.slds-button_brand').disabled = true;
        }
        this.value = event.detail.value;
        this.selectedMonth = this.value;
        var today = new Date();
        var cDate = dateTypeFormat(today);
        if (cDate === this.value) {
            var now = new Date(today.getFullYear(), today.getMonth(), 1);
            var last = new Date(today.getFullYear(), today.getMonth() + 1, 0);
            this.syStDate = yearMonthDate(now);
            this.syEnDate = yearMonthDate(last);
        } else {
            var previousNow = new Date(today.getFullYear(), today.getMonth() - 1, 1);
            var previousLast = new Date(today.getFullYear(), today.getMonth(), 0);
            this.syStDate = yearMonthDate(previousNow);
            this.syEnDate = yearMonthDate(previousLast);
        }
    }

    // On Trip Status Change
    handleStatusChange(event) {
        this.stValue = event.detail.value;
        if (event.detail.value != undefined && this.selectedMonth != undefined) {
            this.template.querySelector('.slds-button_brand').disabled = false;
        } else {
            this.template.querySelector('.slds-button_brand').disabled = true;
        }
    }
    // handleCheckboxChange(event) {
    //     this.chkValue = event.detail.checked;
    // }
    // On Select Click Event
    async handleSelect() {
        console.log("Start", this.syStDate);
        console.log("End", this.syEnDate);
        console.log("Month", this.selectedMonth);
        console.log("Account", this.accId);
        console.log("Trip", this.stValue);
        if (this.stValue != undefined && this.selectedMonth != undefined) {
            this.waiting = true;
            try {
                let deleteResult = await deleteTrips({
                    accountId: this.accId,
                    month: this.selectedMonth
                });
                console.log("M1", deleteResult);
                if (deleteResult) {
                    let massResult = await MassSyncTrips({
                        accountId: this.accId,
                        startDate: this.syStDate,
                        endDate: this.syEnDate,
                        month: this.selectedMonth,
                        tripStatus: this.stValue
                    });
                    console.log("M2", massResult);
                    if (massResult) {
                        const resultEvent = new CustomEvent("handlesyncevent", {
                            detail: massResult
                        });
                        this.dispatchEvent(resultEvent);
                        setTimeout(() => {
                            this.waiting = false;
                            this.handleCancel();
                        }, 4000);

                    }
                }
            } catch (error) {
                console.log(error);
            }
        }

    }

}