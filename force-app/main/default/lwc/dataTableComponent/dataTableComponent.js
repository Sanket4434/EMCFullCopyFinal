/* eslint-disable no-console */
import {
  LightningElement,
  wire,
  track,
  api
} from "lwc";
import fetchMileages from "@salesforce/apex/GetDriverData.fetchMileages";
import fetchMileagesSize from "@salesforce/apex/GetDriverData.fetchMileagesSize";
import MileageDashboardMessage from '@salesforce/label/c.MileageDashboardMessage';
import LwcDesignImage from "@salesforce/resourceUrl/LwcDesignImage";
import updateMileages from '@salesforce/apex/GetDriverData.updateMileages';


import {
  formatData,
  validateDate,
  excelData,
  excelFormatDate,
  changeKeyObjects
} from 'c/commonLib';
const recordsPerPage = [25, 50, 100, 250, 500];
export default class DataTableComponent extends LightningElement {
  ready = false;
  isRenderCallbackActionExecuted = true;
  isRowSplitterExcecuted = false;
  isPerPageActionExecuted = false;
  isDisabled = false;
  selectBool = false;
  rowLimit;
  rowOffSet = 0;
  @track mileageRowLimit;
  @track statusAppImg;
  @track statusRejImg;
  @track columns = [{
      label: "Date & Time",
      fieldName: "Date",
      type: "datetime",
    },
    {
      label: "Driver",
      fieldName: "Name",
    },
    {
      label: "Vehicle",
      fieldName: "VehicleType",
    },
    {
      label: "Mileage",
      fieldName: "Mileage",
    },
    {
      label: "From",
      fieldName: "TripOrigin",
    },
    {
      label: "To",
      fieldName: "TripDestination",
    },
    {
      label: "Notes",
      fieldName: "notes",
    },
  ];
  @api accountID;
  @api contactID;
  @track record = {};
  @track wiredData = [];
  @track currentPage = 1;
  @track loadingSpinner = true;
  @track pageClick = false;
  @track searchallList = [];
  @track allowSorting = false;
  @track reverse = false;
  @track totalrows;
  @track currentData = [];
  @track searchData = [];
  @track option;
  @track totalmileage;
  @track driverId;
  @track field;
  @track object;
  @track key;
  @track searchkeyvalue;
  @track wherefieldvalue;
  @track pageSize;
  @track dataSize;
  @track xlsHeader = [];
  @track xlsData = [];
  @track filename;
  @track xlsSheetContent = [];
  @track workSheetNameList = [];
  @api approveRejectCheck = [];
  @api approveRejectCheckSearch = [];
  @api pageSizeOptions = recordsPerPage;
  @track loadingText = MileageDashboardMessage;
  @track isButtonDisabled = true;
  isSend = false;
  isloadingText = false;
  searchFlag = false;
  searchDataLength = false;
  currentDataLength = false;

  @api getRowLimit() {
    var mileageRowLt = this.mileageRowLimit;
    // console.log("inside row limit", mileageRowLt);
    return mileageRowLt;
  }
  // Advance Search Based on lookups such as Date,Driver,Mileage etc
  @api getSearchData(value, isMailSend, dataLen, rLength) {
    // console.log("Mileage Size: ", dataLen);
    this.template.querySelector('.paginate').classList.remove('blur');
    if (isMailSend === 'trip deleted') {
      this.isSend = true;
      this.isloadingText = false;
      const successDeleteEvent = new CustomEvent("handledeletesuccessevent", {
        detail: "Event Send"
      })
      this.dispatchEvent(successDeleteEvent);
    } else if (isMailSend === 'email send') {
      this.isSend = true;
      this.isloadingText = true;
      const successEvent = new CustomEvent("handlesuccessevent", {
        detail: "Event Send"
      })
      this.dispatchEvent(successEvent);
    }
    if (!this.loadingSpinner) {
      this.loadingSpinner = true;
    }
    this.isRowSplitterExcecuted = false;
    this.template.querySelector("div.tableContainer").classList.add('blur');
    this.searchallList = [];
    this.searchFlag = true;
    this.searchallList = value;
    if (this.searchallList.length < 25 && !this.pageClick) {
      this.template.querySelector("c-paginator").classList.add("slds-hide");
    } else {
      this.template.querySelector("c-paginator").classList.remove("slds-hide");
      this.totalrows = dataLen;
      // console.log(this.pageClick)
      if (!this.pageClick) {
        // console.log('inside paginator change')
        this.template.querySelector("c-paginator").defaultPageSize(dataLen, rLength);
      }

      // this.template.querySelector("c-paginator").pageData(value, this.pageSize);
    }

    this.searchallList = this.defaultSortingByDate(
      this.searchallList,
      "ConvertedStartTime__c"
    );


    if (this.searchallList.length != 0) {
      this.searchDataLength = true;
      this.loadingSpinner = false;
    } else {
      this.searchDataLength = false;
    }

    this.setSearchRecordsToDisplay();
  }

  // Get all <tr> of accordion(table)
  @api
  getElement() {
    this.deleteRow();
    const table_tr = this.template.querySelectorAll(".collapsible");
    if (table_tr) {
      return table_tr;
    }
  }


  //Get tripRoute Icon
  @api
  getIcon;

  //Get <table> element
  @api
  getTableElement() {
    this.template.querySelector('.paginate').classList.add('blur');
    const table = this.template.querySelector(".accordion_table");
    if (table) {
      return table;
    }
  }

  //Download Excel based selected trips
  @api exportSelectedTrip() {
    this.exportSelectedData = [];
    var checkbox = this.template.querySelectorAll(
      ".checkboxCheckUncheckSearch"
    );

    var checkbox2 = this.template.querySelectorAll(
      ".checkboxCheckUncheck"
    );
    if (this.searchData.length != 0) {
      var i,
        exportTripData = [],
        j = checkbox.length;
      for (i = 0; i < j; i++) {
        if (checkbox[i].checked === true) {
          if (this.searchData[i].id === checkbox[i].dataset.id) {
            exportTripData.push(excelData(this.searchData[i]));

          }
        }
        //formatted data for excel download
        this.exportSelectedData = exportTripData;
      }
    } else {
      var i,
        exportTripData = [],


        j = checkbox2.length;

      for (i = 0; i < j; i++) {
        if (checkbox2[i].checked === true) {
          if (this.currentData[i].id === checkbox2[i].dataset.id) {
            exportTripData.push(excelData(this.currentData[i]));

          }
        }

        //formatted data for excel download
        this.exportSelectedData = exportTripData;
      }
    }

    this.xlsFormatter(this.exportSelectedData);
  }

  // Filter Modal For CSV Download
  @api showFilterModal() {
    // Calls function from child component (c-filter-modal-popup)
    let filtermodalShow = this.template
      .querySelector("c-filter-modal-popup")
      .ModalClassList();
    var filtermodalbackdrop = this.template
      .querySelector("c-filter-modal-popup")
      .ModalBackdrop();
    filtermodalShow.classList.remove("slds-hide");
    filtermodalbackdrop.classList.remove("slds-hide");
    this.template
      .querySelector("c-filter-modal-popup")
      .infoID(this.accountID, this.contactID);

  }

  // Apex Method Call For Default Data To Display in table
  @api apexMethodCall(isEmailSend, rowLimit, rowOffSet) {
    //  setTimeout(() => {
    /*console.log("rowLimit", rowLimit);
    console.log("rowOffSet", rowOffSet);*/
    if (isEmailSend != undefined || isEmailSend != null) {
      if (isEmailSend === 'trip deleted') {
        this.isloadingText = false;
        const deleteEvent = new CustomEvent("handledeleteevent", {
          detail: "Event Send"
        })
        this.dispatchEvent(deleteEvent);
      } else {
        this.isloadingText = true;
        const successDefaultEvent = new CustomEvent("handledefaultsuccessevent", {
          detail: "Event Send"
        })
        this.dispatchEvent(successDefaultEvent);
      }
      this.isSend = true;
      this.isRowSplitterExcecuted = false;

    }

    fetchMileages({
        accID: this.accountID,
        AdminId: this.contactID,
        limitSize: rowLimit,
        offset: rowOffSet
      })
      .then((data) => {
        if (this.wiredData.length != 0) {
          this.wiredData = [];
        }
        this.wiredData = data;
        // console.log('From fetch mileage', data);

        // console.log('%c fetchMileages data length : %d', 'display: inline-block ; background-color: #e0005a ; color: #ffffff ; font-weight: bold ; padding: 3px 7px 3px 7px ; border-radius: 3px 3px 3px 3px ;', this.wiredData.length);
        this.setRecordsToDisplay();
      })
      .catch((error) => {
        console.log(error);
      });
    // }, 10);
  }

  // Get total number of trips on load
  getDataSize() {
    fetchMileagesSize({
        accID: this.accountID,
        adminId: this.contactID
      })
      .then((data) => {
        this.dataSize = parseInt(data);
        this.template.querySelector("c-paginator").defaultPageSize(this.dataSize, this.pageSize);
        this.totalrows = this.dataSize;
        // console.log("mileage data size", this.dataSize);
      })
      .catch((error) => {
        console.log(error);
      });
  }

  // On click event of child (c-validate-data-list-component) component
  handleDriverSelect(event) {
    // eslint-disable-next-line no-console
    event.preventDefault();

    this.driverId = event.detail; // stores id of driver

    // options to be displayed in dropdown based on field,object,key,wherefieldvalue,searchkeyvalue
    this.field = "Trip_Origin__c";
    this.object = "Employee_Mileage__c";
    this.searchkeyvalue = "Trip_Origin__c";
    this.key = "Destination_Name__c";
    this.wherefieldvalue = "EmployeeReimbursement__r.Contact_Id__c";

    //Call function from child component
    this.template
      .querySelector(".fromdatalistcomponent")
      .deleteSelectedOption();
    this.template.querySelector(".todatalistcomponent").deleteSelectedOption();
  }

  // On click event of each row in table
  clickHandler(event) {
    // console.log('inside click handler',event);
    // process.exit(0);
    var i;
    var checkbox;
    var to = event.target ? event.target : event.toElement;
    if (to.parentElement != null || to.parentElement != undefined) {
      checkbox = to.parentElement.previousElementSibling;
      //To prevent checkbox click starts -->
      if (event.target !== event.currentTarget) {
        if (checkbox.checked) {
          checkbox.checked = false;
          if (to.className === "slds-checkbox_faux") {
            return (
              this.CheckUncheckForApprove(), this.CheckUncheckForSearchApprove()
            );
          }
        } else {
          if (to.className === "slds-checkbox_faux") {
            checkbox.checked = true;
            return (
              this.CheckUncheckForApprove(), this.CheckUncheckForSearchApprove()
            );
          }
        }
      }
    }

    var insideTr = to.localName;

    if (insideTr === "input") {
      return;
    }

    //To prevent checkbox click Ends -->

    // data-id of row <tr> -- >
    let targetId = event.currentTarget.dataset.id;

    // Display list of rows with class name 'content'
    let rowList = this.template.querySelectorAll(
      `[data-id="${targetId}"],.content`
    );


    var j = rowList.length;
    //Hide show accordion on each row click Starts -->
    for (i = 0; i < j; i++) {
      let row = rowList[i];
      if (
        row.className === "collapsible even" ||
        row.className === "collapsible odd"
      ) {
        if (targetId === row.dataset.id) {

          if (row.style.display === "table-row" || row.style.display === "")
            row.style.display = "none";
          else row.style.display = "table-row";
        }
      } else if (row.className === "content") {
        if (targetId === row.dataset.id) {
          if (row.style.display === "table-row") row.style.display = "none";
          else row.style.display = "table-row";
        }
      }
    }
    //Hide show accordion on each row click Ends -->

    // To get data inside each row based on targetRow Starts -->
    let targetRow = event.currentTarget.cells;
    this.datetime = targetRow[3].textContent;
    if (this.datetime != '') {
      this.date = this.datetime.slice(0, 10);

      this.date = new Date(this.date);
      this.date =
        this.date.getFullYear() +
        "-" +
        (this.date.getMonth() + 1) +
        "-" +
        this.date.getDate();
    } else {
      this.date = '';
    }

    //get data for 'From' Dropdown list as selected option
    this.fromlocation = targetRow[6].textContent;

    //get data for 'To' Dropdown list as selected option
    this.tolocation = targetRow[7].textContent;


    // Show map component on click of each row in table

    // Pass 'from' and 'to' location to child component (c-map-creation-component) based on target row
    this.template
      .querySelector(`c-map-creation-component[data-id="${targetId}"]`)
      .mapAccess();

    // Pass Stored Data to child component functions Starts -->

    let datetimeComponent = this.template.querySelectorAll(
      `[data-id="${targetId}"],.datetimecomponent`
    );
    var datetimelen = datetimeComponent.length;
    for (i = 0; i < datetimelen; i++) {
      let datelist = datetimeComponent[i];
      if (datelist.className === "datetimecomponent") {
        if (targetId === datelist.dataset.id) {
          datelist.getTime(this.date);
        }
      }
    }

    // Pass Stored Data to child component functions Ends -->

    // To get data inside each row based on targetRow Ends -->
  }

  handleTagInput(event) {
    let tId = event.currentTarget.dataset.id;
    let rList = this.template.querySelector(
      `[data-id="${tId}"],.tags_Input`
    );
    rList.value = event.target.value;
  }
  // Accordion Save  Button click event
  handleSave(event) {
    var tripID, tagName;
    let tId = event.currentTarget.dataset.id;
    let rList = this.template.querySelector(
      `[data-id="${tId}"],.tags_Input`
    );
    tripID = tId;
    tagName = rList.value;
    updateMileages({
        tripId: tripID,
        tripTag: tagName
      })
      .then((data) => {
        // console.log("updateMileages List", data);
        if (data) {
          // console.log("inside list element")
          this.handlecloselookUp(event, tId, tagName)
          const saveEvent = new CustomEvent("handleupdateevent", {
            detail: data
          })
          this.dispatchEvent(saveEvent);
        }
      })
      .catch((error) => {
        console.log(error);
      });
  }

  // Click event to close opened row
  handlecloselookUp(event, uId, tag) {
    // console.log('inside list');
    var i, j;
    let targetId;
    if (uId != undefined) {
      targetId = uId;
    } else {
      targetId = event.currentTarget.dataset.id;
    }

    let closerowList = this.template.querySelectorAll(
      `[data-id="${targetId}"],.content`
    );

    j = closerowList.length;
    //Hide show accordion on each row click
    for (i = 0; i < j; i++) {
      let closerow = closerowList[i];
      if (
        closerow.className === "collapsible even" ||
        closerow.className === "collapsible odd"
      ) {
        if (targetId === closerow.dataset.id) {
          if (
            closerow.style.display === "table-row" ||
            closerow.style.display === ""
          )
            closerow.style.display = "none";
          else closerow.style.display = "table-row";
        }
      } else if (closerow.className === "content") {
        if (targetId === closerow.dataset.id) {
          // console.log(closerow);
          if (tag != undefined) {
            if (closerow.previousElementSibling) {
              closerow.previousElementSibling.style.backgroundColor = "#f7cb4d";
              setTimeout(() => {
                if (closerow.previousElementSibling.className.includes("even")) {
                  closerow.previousElementSibling.style.backgroundColor = "#ffffff";
                } else if (closerow.previousElementSibling.className.includes("odd")) {
                  closerow.previousElementSibling.style.backgroundColor = "#f7f7f7";
                }
              }, 3000);
              closerow.previousElementSibling.cells[8].innerText = tag;
            }
          }

          if (closerow.style.display === "table-row")
            closerow.style.display = "none";
          else closerow.style.display = "table-row";
        }
      }
    }
  }

  // Default Sorting By Date
  defaultSortingByDate(sortArr, keyName) {

    if (!this.reverse) {
      this.reverse = true;
    }
    if (keyName === "ConvertedStartTime__c") {
      sortArr.sort(function (a, b) {
        var dateA =
          a[keyName] == null || undefined ?
          "" :
          new Date(a[keyName].toLowerCase()),
          dateB =
          b[keyName] == null || undefined ?
          "" :
          new Date(b[keyName].toLowerCase());
        //sort string ascending
        if (dateA < dateB) {
          return -1;
        } else if (dateA > dateB) {
          return 1;
        } else {
          return 0;
        }
      });

    }

    return sortArr;

  }
  // Sorting based on header click 'chevronup' and 'chevrondown' icons in table
  updateColumnSorting(event) {
    this.deleteRow();
    this.loadingSpinner = true;
    var header, keyName;
    this.allowSorting = true;
    var targetValue = event.currentTarget.children[0].firstChild;
    setTimeout(() => {
      this.loadingSpinner = false;
      if (targetValue) {
        header = targetValue.data;
        // header = targetelem.parentElement.parentNode.textContent;
        if (header === "Driver") {
          keyName = "Name";
        } else if (header === "From") {
          keyName = "TripOrigin";
        } else if (header === "To") {
          keyName = "TripDestination";
        } else if (header === "Mileage") {
          keyName = "Mileage";
        } else if (header === "Date & Time") {
          keyName = "Date";
        } else if (header === "Tags") {
          keyName = "Tags";
        } else if (header === "Notes") {
          keyName = "notes";
        }
      }
      if (!this.reverse) {
        this.reverse = true;
        if (
          keyName === "Name" ||
          keyName === "TripOrigin" ||
          keyName === "TripDestination" ||
          keyName === "Tags" ||
          keyName === "notes"
        ) {
          if (this.searchData.length != 0) {
            this.searchData.sort(function (a, b) {
              var nameA = a[keyName] == null || undefined ?
                "" : a[keyName].toLowerCase(),
                nameB = b[keyName] == null || undefined ?
                "" : b[keyName].toLowerCase();
              //sort string ascending
              if (nameA < nameB) {
                return -1;
              } else if (nameA > nameB) {
                return 1;
              } else {
                return 0;
              }
            });
          } else {
            this.currentData.sort(function (a, b) {
              var nameA = a[keyName] == null || undefined ?
                "" : a[keyName].toLowerCase(),
                nameB = b[keyName] == null || undefined ?
                "" : b[keyName].toLowerCase();
              //sort string ascending
              if (nameA < nameB) {
                return -1;
              } else if (nameA > nameB) {
                return 1;
              } else {
                return 0;
              }
            });
          }
        } else if (keyName === "Mileage") {
          if (this.searchData.length != 0) {
            this.searchData.sort(function (a, b) {
              var floatA = a[keyName] == null || undefined ?
                "" : parseFloat(a[keyName]),
                floatB = b[keyName] == null || undefined ?
                "" : parseFloat(b[keyName]);

              //sort string ascending
              if (floatA < floatB) {
                return -1;
              } else if (floatA > floatB) {
                return 1;
              } else {
                return 0;
              }
            });
          } else {
            this.currentData.sort(function (a, b) {
              var floatA = a[keyName] == null || undefined ?
                "" : parseFloat(a[keyName]),
                floatB = b[keyName] == null || undefined ?
                "" : parseFloat(b[keyName]);

              //sort string ascending
              if (floatA < floatB) {
                return -1;
              } else if (floatA > floatB) {
                return 1;
              } else {
                return 0;
              }
            });
          }
        } else if (keyName === "Date") {
          if (this.searchData.length != 0) {
            this.searchData.sort(function (a, b) {
              var formatDateA = a[keyName] == null || undefined ?
                "" : a[keyName].slice(0, 9),
                formatDateB = b[keyName] == null || undefined ?
                "" : b[keyName].slice(0, 9);
              var dateA = formatDateA == "" ? "" : new Date(formatDateA.toLowerCase()),
                dateB = formatDateB == "" ? "" : new Date(formatDateB.toLowerCase());
              //sort string ascending
              const searchTime12to24 = (time12h, cdate) => {
                const [time, modifier] = time12h.split(' ');

                let [hours, minutes] = time.split(':');

                if (hours === '12') {
                  hours = '00';
                }

                if (modifier === 'PM') {
                  hours = parseInt(hours, 10) + 12;
                }
                let seconds = '00'
                cdate.setHours(hours, minutes, seconds);
                return cdate
                //return `${hours}:${minutes}`;
              }

              let timeA = searchTime12to24(a.StartTime, dateA),
                time = searchTime12to24(b.StartTime, dateB);
              if (dateA < dateB) {
                return -1;
              } else if (dateA > dateB) {
                return 1;
              } else {
                return 0;
              }
            });
          } else {
            this.currentData.sort(function (a, b) {
              var formatDateA = a[keyName] == null || undefined ?
                "" : a[keyName].slice(0, 9),
                formatDateB = b[keyName] == null || undefined ?
                "" : b[keyName].slice(0, 9);

              var dateA = formatDateA == "" ? "" : new Date(formatDateA.toLowerCase()),
                dateB = formatDateB == "" ? "" : new Date(formatDateB.toLowerCase());

              const Time12to24 = (time12h, cdate) => {
                const [time, modifier] = time12h.split(' ');

                let [hours, minutes] = time.split(':');

                if (hours === '12') {
                  hours = '00';
                }

                if (modifier === 'PM') {
                  hours = parseInt(hours, 10) + 12;
                }
                let seconds = '00'
                cdate.setHours(hours, minutes, seconds);
                return cdate
                //return `${hours}:${minutes}`;
              }

              let timeA = Time12to24(a.StartTime, dateA),
                time = Time12to24(b.StartTime, dateB);
              //sort string ascending
              if (dateA < dateB) {
                return -1;
              } else if (dateA > dateB) {
                return 1;
              } else {
                return 0;
              }
            });
          }
        }
      } else {
        this.reverse = false;
        if (
          keyName === "Name" ||
          keyName === "TripOrigin" ||
          keyName === "TripDestination" ||
          keyName === "Tags" ||
          keyName === "notes"
        ) {
          if (this.searchData.length != 0) {
            this.searchData.sort(function (a, b) {
              var nameA = a[keyName] == null || undefined ?
                "" : a[keyName].toLowerCase(),
                nameB = b[keyName] == null || undefined ?
                "" : b[keyName].toLowerCase();
              //sort string descending
              if (nameA < nameB) {
                return 1;
              } else if (nameA > nameB) {
                return -1;
              } else {
                return 0;
              }
            });
          } else {
            this.currentData.sort(function (a, b) {
              var nameA = a[keyName] == null || undefined ?
                "" : a[keyName].toLowerCase(),
                nameB = b[keyName] == null || undefined ?
                "" : b[keyName].toLowerCase();
              //sort string descending
              if (nameA < nameB) {
                return 1;
              } else if (nameA > nameB) {
                return -1;
              } else {
                return 0;
              }
            });
          }
        } else if (keyName === "Mileage") {
          if (this.searchData.length != 0) {
            this.searchData.sort(function (a, b) {
              var floatA = a[keyName] == null || undefined ?
                "" : parseFloat(a[keyName]),
                floatB = b[keyName] == null || undefined ?
                "" : parseFloat(b[keyName]);

              //sort string descending
              if (floatA < floatB) {
                return 1;
              } else if (floatA > floatB) {
                return -1;
              } else {
                return 0;
              }
            });
          } else {
            this.currentData.sort(function (a, b) {
              var floatA = a[keyName] == null || undefined ?
                "" : parseFloat(a[keyName]),
                floatB = b[keyName] == null || undefined ?
                "" : parseFloat(b[keyName]);

              //sort string descending
              if (floatA < floatB) {
                return 1;
              } else if (floatA > floatB) {
                return -1;
              } else {
                return 0;
              }
            });
          }
        } else if (keyName === "Date") {
          if (this.searchData.length != 0) {
            this.searchData.sort(function (a, b) {
              var formatDateA = a[keyName] == null || undefined ?
                "" : a[keyName].slice(0, 9),
                formatDateB = b[keyName] == null || undefined ?
                "" : b[keyName].slice(0, 9);

              var dateA = formatDateA == "" ? "" : new Date(formatDateA.toLowerCase()),
                dateB = formatDateB == "" ? "" : new Date(formatDateB.toLowerCase());

              const searchconvertTime12to24 = (time12h, cdate) => {
                const [time, modifier] = time12h.split(' ');

                let [hours, minutes] = time.split(':');

                if (hours === '12') {
                  hours = '00';
                }

                if (modifier === 'PM') {
                  hours = parseInt(hours, 10) + 12;
                }
                let seconds = '00'
                cdate.setHours(hours, minutes, seconds);
                return cdate
                //return `${hours}:${minutes}`;
              }

              var time12 = searchconvertTime12to24(a.StartTime, dateA),
                timeB12 = searchconvertTime12to24(b.StartTime, dateB);
              //sort string descending
              if (dateA < dateB) {
                return 1;
              } else if (dateA > dateB) {
                return -1;
              } else {
                return 0;
              }
            });
          } else {
            this.currentData.sort(function (a, b) {
              var formatDateA = a[keyName] == null || undefined ?
                "" : a[keyName].slice(0, 9),
                formatDateB = b[keyName] == null || undefined ?
                "" : b[keyName].slice(0, 9);

              var dateA = formatDateA == "" ? "" : new Date(formatDateA.toLowerCase()),
                dateB = formatDateB == "" ? "" : new Date(formatDateB.toLowerCase());

              const convertTime12to24 = (time12h, cdate) => {
                const [time, modifier] = time12h.split(' ');

                let [hours, minutes] = time.split(':');

                if (hours === '12') {
                  hours = '00';
                }

                if (modifier === 'PM') {
                  hours = parseInt(hours, 10) + 12;
                }
                let seconds = '00'
                cdate.setHours(hours, minutes, seconds);
                return cdate
                //return `${hours}:${minutes}`;
              }

              var time12 = convertTime12to24(a.StartTime, dateA),
                timeB12 = convertTime12to24(b.StartTime, dateB);

              //sort string descending
              if (dateA < dateB) {
                return 1;
              } else if (dateA > dateB) {
                return -1;
              } else {
                return 0;
              }
            });
          }
        }
      }
    }, 1000)
  }

  //function to display data based on advance search
  setSearchRecordsToDisplay() {
    if (!this.loadingSpinner) {
      this.loadingSpinner = true;
    }
    setTimeout(() => {
      this.template.querySelector("div.tableContainer").classList.remove('blur');
      this.loadingSpinner = false;
      this.isloadingText = false;
      if (this.pageClick) {
        this.pageClick = false;
      }
    }, 100);
    this.searchData = [];
    var mileagecount = 0;
    this.totalmileage = 0;
    //  console.log(this.searchallList)
    this.searchData = formatData(this.searchallList);
    if (this.searchData.length != 0) {
      this.searchData.forEach((value) => {
        mileagecount = mileagecount + parseFloat(value.Mileage);
        mileagecount =
          Math.round(
            parseFloat((mileagecount * Math.pow(10, 2)).toFixed(2))
          ) / Math.pow(10, 2);
      });

      this.totalmileage = mileagecount;
    }



  }

  validateState(stateVal) {
    var regDigit = /\b\d{5}\b/g,
      tripSate, bool;
    bool = /^[0-9,-.]*$/.test(stateVal);
    if (!bool) {
      let state = stateVal;
      let digit = state.slice(-5);
      if (digit.match(regDigit)) {
        tripSate = stateVal.slice(-9);
      } else {
        tripSate = '';
      }
    } else {
      tripSate = '';
    }

    return tripSate;
  }
  // Pagination event
  pageEventClick(event) {
    this.pageClick = true;
    this.isRowSplitterExcecuted = false;
    let page = event.detail;
    this.rowOffSet = page;
    this.rowOffSet = (this.rowOffSet - 1) * this.rowLimit

    if (this.searchData.length != 0) {
      // console.log("inside row action", this.rowOffSet)
      const rowAction = new CustomEvent("rowactionevent", {
        detail: {
          rowLimit: this.rowLimit,
          rowOffSet: this.rowOffSet
        }
      })
      this.dispatchEvent(rowAction);
    } else {
      this.apexMethodCall(undefined, this.rowLimit, this.rowOffSet);
    }

  }


  // from filter modal event passed
  handleCSVEvent(event) {
    if (event.detail) {
      const excelEvent = new CustomEvent("handleexportexcelevent", {
        detail: "Excel Event"
      });
      this.dispatchEvent(excelEvent);
    }
  }
  //function to display default data
  setRecordsToDisplay() {
    if (!this.loadingSpinner) {
      this.loadingSpinner = true;
    }

    setTimeout(() => {
      this.loadingSpinner = false;
      this.isloadingText = false;
      if (this.pageClick) {
        this.pageClick = false;
      }
    }, 400);

    this.isRenderCallbackActionExecuted = true;
    var mileagecount = 0;

    this.currentData = [];
    // console.log("from records display",this.currentData.length);
    this.totalmileage = 0;

    let apexData = [];
    apexData = JSON.parse(JSON.stringify(this.wiredData));
    //apexData = this.defaultSortingByDate(apexData, "ConvertedStartTime__c");
    // this.totalrows = apexData.length;
    this.currentData = formatData(apexData);

    // console.log('Modified', this.currentData);
    if (this.currentData.length != 0) {
      this.currentDataLength = true;
      this.currentData.forEach((value) => {
        mileagecount = mileagecount + parseFloat(value.Mileage);
        mileagecount =
          Math.round(
            parseFloat((mileagecount * Math.pow(10, 2)).toFixed(2))
          ) / Math.pow(10, 2);
      });

      this.totalmileage = mileagecount;
    } else {
      this.currentDataLength = false;
    }



  }

  actionForPerPage = (pageEntry) => {
    this.isPerPageActionExecuted = true;
    this.isRowSplitterExcecuted = false;
    this.rowLimit = pageEntry;

    if (this.searchData.length != 0) {
      this.rowOffSet = 0;
      const perPageAction = new CustomEvent("perpageactionevent", {
        detail: {
          rowLimit: this.rowLimit,
          rowOffSet: this.rowOffSet
        }
      })
      this.dispatchEvent(perPageAction);
      //this.setSearchRecordsToDisplay();
    } else {
      this.template.querySelector("c-paginator").defaultPageSize(this.dataSize, this.rowLimit);
      this.apexMethodCall(undefined, this.rowLimit, this.rowOffSet);
      //this.setRecordsToDisplay();
    }

  }
  // Change event of display number of records in table based on dropdown values
  handleRecordsPerPage(event) {
    var $pageNo;
    $pageNo = parseInt(event.target.value);
    setTimeout(() => {
      this.actionForPerPage($pageNo);
    }, 2)
  }

  // Click event to check all checkbox checked in table
  IsAllCheckForApprove(event) {
    //console.log('checkbox checked for All', event);
    // process.exit(0);
    var checkbox = this.template.querySelectorAll(".checkboxCheckUncheck");
    var checkbox2 = this.template.querySelectorAll(
      ".checkboxCheckUncheckSearch"
    );
    if (this.searchData.length != 0) {
      if (event.target.checked === true) {
        checkbox2.forEach(value => {
          value.checked = true;
        });
        this.CheckUncheckForSearchApprove();
      } else {
        checkbox2.forEach(value => {
          value.checked = false;
        });
      }
    } else {
      if (event.target.checked === true) {
        //  console.time("foreach")
        checkbox.forEach(value => {
          value.checked = true;
        });
        // console.timeEnd("foreach");
        this.CheckUncheckForApprove();
      } else {
        checkbox.forEach(value => {
          value.checked = false;
        });
      }
    }
  }

  //Click event to check single checkbox checked for advance search data
  CheckUncheckForSearchApprove() {
    var checkboxlist = this.template.querySelectorAll(
      ".checkboxCheckUncheckSearch"
    );
    var approveCheckForSearch = [];

    checkboxlist.forEach((list, index) => {
      if (list.checked === true) {
        if (this.searchData[index].id === list.dataset.id) {
          approveCheckForSearch.push({
            Id: list.dataset.id,
            employeeEmailId: this.searchData[index].emailID,
          });
        }
      }
    });
    this.approveRejectCheckSearch = approveCheckForSearch;
    if (this.approveRejectCheckSearch != 0) {
      const approveRejectSearch = new CustomEvent(
        "handleapproverejectsearchevent", {
          detail: this.approveRejectCheckSearch,
        }
      );

      this.dispatchEvent(approveRejectSearch);
    }
  }

  //Click event to check single checkbox checked for default data
  CheckUncheckForApprove() {
    var checkboxlist = this.template.querySelectorAll(".checkboxCheckUncheck");
    var approveCheck = [];
    //  chkblistlen = checkboxlist.length;

    checkboxlist.forEach((list, index) => {
      if (list.checked === true) {
        if (this.currentData[index].id === list.dataset.id) {
          approveCheck.push({
            Id: list.dataset.id,
            employeeEmailId: this.currentData[index].emailID,
          });
        }
      }
    });
    this.approveRejectCheck = approveCheck;

    if (this.approveRejectCheck) {
      const approveReject = new CustomEvent("handleapproverejectevent", {
        detail: this.approveRejectCheck
      });
      this.dispatchEvent(approveReject);
    }
  }

  // Style row based on approve and reject trips
  RowStatusStyle() {
    // console.log('RowStatusStyle');
    var row = this.template.querySelectorAll(".collapsible");
    if (this.searchData.length != 0) {
      // var j = this.searchData.length;
      this.searchData.forEach((rowItem, index) => {
        var routeicon = this.template.querySelectorAll('.ms-help-icon');
        if (rowItem.FromLatitude === undefined && rowItem.FromLongitude === undefined &&
          rowItem.ToLatitude === undefined && rowItem.ToLongitude === undefined) {
          if (row[index].dataset.id === routeicon[index].dataset.id) {
            routeicon[index].classList.add('slds-hide');
          }
        } else {
          routeicon[index].classList.remove('slds-hide')
        }

        if (rowItem.TripStatus === "Approved") {
          this.statusAppImg = LwcDesignImage + "/LwcImages/status_Approve.png";
          let imgAppClass = this.template.querySelectorAll(".statusApImage");
          if (rowItem.id === row[index].dataset.id) {
            row[index].style.backgroundColor = "#b3ffe6";
            if (row[index].dataset.id === imgAppClass[index].dataset.id) {
              imgAppClass[index].style.display = "block";
            }
          }
        } else if (rowItem.TripStatus === "Rejected") {
          let imgRejClass = this.template.querySelectorAll(".statusRejImage");
          this.statusRejImg = LwcDesignImage + "/LwcImages/status_Reject.png";
          if (rowItem.id === row[index].dataset.id) {
            row[index].style.backgroundColor = "#f4a4a4";
            if (row[index].dataset.id === imgRejClass[index].dataset.id) {
              imgRejClass[index].style.display = "block";
            }
          }
        }
      })
    } else {
      // console.log('RowStatusStyle current data');

      this.currentData.forEach((rowElem, ind) => {
        // console.log(rowElem.Name,rowElem.Mileage,rowElem.TripStatus,rowElem.StartTime)
        var routeicon = this.template.querySelectorAll('.ms-help-icon');
        if (rowElem.FromLatitude === undefined && rowElem.FromLongitude === undefined &&
          rowElem.ToLatitude === undefined && rowElem.ToLongitude === undefined) {
          if (row[ind].dataset.id === routeicon[ind].dataset.id) {
            routeicon[ind].classList.add('slds-hide');
          }
        } else {
          routeicon[ind].classList.remove('slds-hide')
        }
        if (rowElem.TripStatus === "Approved") {
          this.statusAppImg = LwcDesignImage + "/LwcImages/status_Approve.png";
          let imgAppClass = this.template.querySelectorAll(".statusApImage");
          if (rowElem.id === row[ind].dataset.id) {
            row[ind].style.backgroundColor = "#b3ffe6";
            if (row[ind].dataset.id === imgAppClass[ind].dataset.id) {
              imgAppClass[ind].style.display = "block";
            }
          }
        } else if (rowElem.TripStatus === "Rejected") {
          let imgRejClass = this.template.querySelectorAll(".statusRejImage");
          this.statusRejImg = LwcDesignImage + "/LwcImages/status_Reject.png";
          if (rowElem.id === row[ind].dataset.id) {
            row[ind].style.backgroundColor = "#f4a4a4";
            if (row[ind].dataset.id === imgRejClass[ind].dataset.id) {
              imgRejClass[ind].style.display = "block";
            }
          }
        }
      });
    }
  }

  // Send formatted excel data to child component 'c-excel-sheet'
  xlsFormatter(data) {
    let Header = Object.keys(data[0]);
    Header[5] = "Start Time";
    Header[6] = "End Time";
    Header[7] = "Stay Time";
    Header[8] = "Drive Time";
    Header[9] = "Total Time";
    Header[11] = "Mileage (mi)";
    Header[12] = "From Location Name";
    Header[13] = "From Location Address";
    Header[14] = "To Location Name";
    Header[15] = "To Location Address";
    Header[19] = "Tracking Method";
    this.xlsHeader.push(Header);
    this.xlsData.push(data);
    this.template.querySelector("c-excel-sheet").download();
  }

  // function to format date with week day
  fullDateFormat(rowObj) {
    if (rowObj.ConvertedStartTime__c != undefined) {
      let newdate = new Date(rowObj.ConvertedStartTime__c);
      let dayofweek;
      let dd = newdate.getDate();
      let mm = newdate.getMonth() + 1;
      let yy = newdate.getFullYear();
      if (rowObj.Day_Of_Week__c != undefined) {
        dayofweek = rowObj.Day_Of_Week__c.toString().slice(0, 3);
      } else {
        dayofweek = "";
        dayofweek = dayofweek.toString();
      }
      return mm + "/" + ("0" + dd).slice(-2) + "/" + yy + " " + dayofweek;
    } else {
      return "";
    }
  }
  // function to format date
  dateFormat(rowObj) {
    if (rowObj.ConvertedStartTime__c != undefined) {
      let newdate = new Date(rowObj.ConvertedStartTime__c);
      let dd = newdate.getDate();
      let mm = newdate.getMonth() + 1;
      let yy = newdate.getFullYear();

      return mm + "/" + dd + "/" + yy;
    } else {
      return "";
    }
  }

  // Trip Status Tooltip Starts
  handleMouseEnter(event) {
    let targetId = event.target.dataset.id;
    this.template
      .querySelector(`c-tooltip-component[data-id="${targetId}"]`)
      .classList.remove("slds-hide");
  }
  handleMouseLeave(event) {
    let targetId = event.target.dataset.id;
    this.template
      .querySelector(`c-tooltip-component[data-id="${targetId}"]`)
      .classList.add("slds-hide");
  }
  // Trip Status Tooltip Ends

  // function to format time
  TimeFormat(timeObj) {
    if (timeObj != undefined) {
      let startendTime = new Date(timeObj);
      let convertedTime = startendTime.toLocaleTimeString("en-US", {
        timeZone: "America/Panama",
        hour: "2-digit",
        minute: "2-digit",
      });
      return convertedTime;
    } else {
      return "";
    }
  }

  // Dynamic row creation
  createRow(rowElem) {
    rowElem.classList.add("list-split-top");
    var table = this.template.querySelector(".accordion_table");
    var extraRow = table.insertRow(rowElem.rowIndex);
    extraRow.className = "extra_row";
    var cell = extraRow.insertCell(0);
    cell.setAttribute("colspan", "10");
    cell.style["padding"] = "0px";
    cell.style["line-height"] = "0px";
    cell.innerHTML =
      "<div class='row_splitter' style='height: 8px;background-color: #ffffff;border-right: 1px solid #dfdfdf;border-top: #dfdfdf 1px solid'></div>";
  }

  // Delete Unused rows from table
  deleteRow() {
    var i, tblRowLen;
    var table = this.template.querySelector(".accordion_table");
    var tableRow = table.rows;

    tblRowLen = tableRow.length;
    for (i = tblRowLen; i > 0; i--) {
      if (tableRow[i] != undefined) {
        if (tableRow[i].className === "extra_row") {
          table.deleteRow(i);
        }
      }
    }
    this.isPerPageActionExecuted = false;
  }

  // Row Splitter after every new date
  rowSplitter() {
    this.isRowSplitterExcecuted = true;
    var i,
      extraRow,
      rowslen,
      regExp = /(\d{1,4}([.\-/])\d{1,2}([.\-/])\d{1,4})/g;
    extraRow = this.template.querySelectorAll(".collapsible");
    rowslen = extraRow.length;
    if (!this.allowSorting) {
      if (rowslen > 0) {
        for (i = 0; i < rowslen; i++) {
          let beforeRow = extraRow[i];
          let afterRow = extraRow[i + 1];
          if (beforeRow != undefined && afterRow != undefined) {
            let beforeRowDate = new Date(
              beforeRow.cells[3].textContent.match(regExp)
            );
            let afterRowDate = new Date(
              afterRow.cells[3].textContent.match(regExp)
            );
            if (beforeRowDate < afterRowDate) {
              this.createRow(afterRow);
            }
          }
        }
      }
    }
    if (this.searchFlag || this.isPerPageActionExecuted || this.isSend) {
      this.isRowSplitterExcecuted = false;
    }
  }


  // fires when a component is inserted into the DOM.
  connectedCallback() {
    this.getDataSize();
    if (this.pageSizeOptions && this.pageSizeOptions.length > 0) {
      this.selectBool = true;
      this.pageSize = this.pageSizeOptions[2];
      this.rowLimit = this.pageSize;
      this.mileageRowLimit = this.pageSize;
    }
    this.apexMethodCall(undefined, this.rowLimit, this.rowOffSet);
  }

  // fires after every render of the component.
  renderedCallback() {
    if (this.selectBool) {
      let selected = this.template.querySelector('.recordperpageSelect');
      selected.value = this.pageSizeOptions[2];
      this.selectBool = false;
    }
    var i, rowslen;
    if (this.isPerPageActionExecuted || this.searchFlag || this.pageClick || this.isSend) {
      this.deleteRow();
    }
    if (!this.isRenderCallbackActionExecuted && !this.isRowSplitterExcecuted) {
      this.rowSplitter();
    }

    let rows = [];
    rows = this.template.querySelectorAll(".collapsible");
    rowslen = rows.length;
    // avoid change in row style while sorting
    //if (!this.allowSorting) {
    if (rowslen > 0) {
      for (i = 0; i < rowslen; i++) {
        let even_row = rows[i * 2];
        let odd_row = rows[i * 2 + 1];
        if (even_row != undefined) {
          even_row.classList.add("even");
        }
        if (odd_row != undefined) {
          odd_row.classList.add("odd");
        }
      }

      this.RowStatusStyle();
    }
    // }
    this.isRenderCallbackActionExecuted = false;
  }
}