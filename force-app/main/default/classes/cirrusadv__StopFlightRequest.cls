/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class StopFlightRequest {
    @InvocableVariable( required=false)
    global Integer flightPlanId;
    @InvocableVariable( required=false)
    global Datetime nextFlightStartDate;
    @InvocableVariable( required=true)
    global String outcome;
    @InvocableVariable( required=true)
    global Id personId;
    @InvocableVariable( required=true)
    global Id userId;
    global StopFlightRequest() {

    }
}
