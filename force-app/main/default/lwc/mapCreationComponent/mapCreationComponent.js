import {
  LightningElement,
  api,
  track
} from "lwc";
import fetchWayPointPostAPI from "@salesforce/apex/GetDriverData.fetchWayPointPostAPI";
export default class MapCreationComponent extends LightningElement {
// vfHost = 'https://fullcopy-mburse.cs8.force.com/app/googleMapIframe';
// origin = 'https://fullcopy-mburse.cs8.force.com';
  iframeObj;
  @api vfHost;
  @api startLocationLt = "";
  @api startLocationLg = "";
  @api endLocationLt = "";
  @api endLocationLg = "";
  @api tripId;
  @api tripLogApi;
  @api timeZone;
  @api wayPt;

  @api mapAccess() {
     let url =  location.origin;
     let urlHost = url + '/app/googleMapIframe';
    //this.vfHost = loaction.origin + '/app/googleMapIframe';
    this.vfHost = urlHost;
    //this.vfHost = 'https://fullcopy-mburse.cs8.force.com/app/googleMapIframe';
    this.iframeObj =  this.template.querySelector(".vf-iframe").contentWindow;
    if (this.wayPt != undefined) {
      setTimeout(()=>{
        this.defaultCallout(this.wayPt);
      }, 1000);
    } else {
      setTimeout(()=>{
      this.handleCallout();
      }, 1000);
    }
   }

 defaultCallout(mapContent) {
    var wptarr = JSON.parse(mapContent);
    var routearray = wptarr.routes;
    // console.log(wptarr,routearray);
    //  wptarr = wptarr.routes;

    if (routearray.length > 25) {
      routearray = routearray.slice(0, 25);
    }

    let locations = [{
      startLocation: {
        Latitude: this.startLocationLt,
        Longitude: this.startLocationLg
      },
      endLocation: {
        Latitude: this.endLocationLt,
        Longitude: this.endLocationLg
      },
      timeZone: this.timeZone,
      waypoints: routearray
    }];

    if (
      locations[0].startLocation.Latitude != undefined &&
      locations[0].endLocation.Latitude != undefined &&
      locations[0].startLocation.Longitude != undefined &&
      locations[0].endLocation.Longitude != undefined
    ) {
      console.log('Iframe : ' + this.iframeObj)
      this.iframeObj.postMessage(JSON.stringify(locations), location.origin);
    } else {
      this.vfHost = '';
    }
  }
  async handleCallout() {
    try {
      // console.log('inside-api calls-->', this.wpt);
      let result = await fetchWayPointPostAPI({
        tripId: this.tripId,
        apikey: this.tripLogApi
      });
      var apiJSON = JSON.parse(result);
      var resultArray = apiJSON.routes;
      // console.log('apiCall->', resultArray);
      if (resultArray.length > 25) {
        resultArray = resultArray.slice(0, 25);
      }

      let mapLocations = [{
        startLocation: {
          Latitude: this.startLocationLt,
          Longitude: this.startLocationLg
        },
        endLocation: {
          Latitude: this.endLocationLt,
          Longitude: this.endLocationLg
        },
        timeZone: this.timeZone,
        waypoints: resultArray
      }];

      if (
        mapLocations[0].startLocation.Latitude != undefined &&
        mapLocations[0].endLocation.Latitude != undefined &&
        mapLocations[0].startLocation.Longitude != undefined &&
        mapLocations[0].endLocation.Longitude != undefined
      ) {
        console.log('inside apiCall->')
        this.iframeObj.postMessage(JSON.stringify(mapLocations), location.origin);
      } else {
           this.vfHost = '';
      }

    } catch (err) {
      console.log(err);
    }

  }

  // handleCallout() {
  //     const proxyurl = "https://cors-anywhere.herokuapp.com/";
  //     const url = 'https://triplogmileage.com/web/api/trips/' + this.tripId + '/routes';
  //     console.log(this.tripLogApi);
  //     fetch(proxyurl + url,{method: 'GET',
  //     headers: {'Authorization':`apikey ${this.tripLogApi}`},
  //     credentials:'same-origin'})
  //                 .then( (response) => {
  //                         if(response.ok){
  //                             return console.log(response.json());
  //                         }else{
  //                             throw new Error('BAD HTTP Request')
  //                         }
  //                 })
  //                 .catch( (err) => {
  //                     console.log('ERROR:', err.message);
  //                 });

  // }

  connectedCallback() {

  }
  renderedCallback() {
  }
}