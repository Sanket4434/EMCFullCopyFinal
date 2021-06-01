/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class StartFlightRequest {
    @InvocableVariable( required=false)
    global String errorEmail;
    @InvocableVariable( required=true)
    global Integer flightPlanId;
    @InvocableVariable( required=false)
    global Boolean notifyOnSuccess;
    @InvocableVariable( required=true)
    global Id personId;
    @InvocableVariable( required=false)
    global Boolean skipValidation;
    @InvocableVariable( required=false)
    global Datetime startDate;
    @InvocableVariable( required=true)
    global Id userId;
    @InvocableVariable( required=false)
    global Id whatId;
    global StartFlightRequest() {

    }
}
