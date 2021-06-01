@RestResource(urlMapping='/webhookSite/*')
global with sharing class MyRestResource {

    @HttpGet
    global static void getRecord() {
        System.debug('Site called');
    }
}