//@RestResource(urlMapping='/inveritewebhook1/*')
@RestResource(urlMapping='/inveritewebhook/*')
global class Inverite_Webhook {
    /*
    String complete_datetime, 
    String request, 
    InveriteWebhook_Account[] accounts,
    InveriteWebhook_Contact[] contacts,
    String status,
    String error,
    String name,
    String address,
    String referenceid,
    String type
    */
    @HttpPost
    global static void doPost() {
        RestRequest restRequest = RestContext.request;
        Map<String, String> headers = restRequest.headers;
        System.debug('restRequest'+restRequest);
        System.debug('headers'+headers);
        Integration_Log__c log = new Integration_Log__c();
        if(headers.isEmpty()){
            log.Headers__c = 'No headers';
        }else{
            String headersString = '';
            for(String key : headers.keySet()){
                headersString = 'key:'+key+', value:'+headers.get(key)+'\n';
            }
            log.Headers__c = headersString;
        }
        Blob requestBody = restRequest.requestBody;
        String payload = EncodingUtil.base64Decode(EncodingUtil.base64Encode(requestBody)).toString();
        InveriteWebhookRequest inveriteRequest = (InveriteWebhookRequest)JSON.deserialize(payload, InveriteWebhookRequest.class);
    
        
        System.debug('referenceId'+inveriteRequest.referenceid);
        Opportunity theOpportunity = [SELECT Id, Inverite_GUID__c,Lead_Referred_To__c FROM opportunity WHERE Id =:inveriteRequest.referenceid];
        theOpportunity.Inverite_GUID__c = inveriteRequest.request;
        
       
        update theOpportunity;
        
    
        System.debug(payload);
        MapJsonToInveriteAccount.mapInveriteBankAccount(payload, theOpportunity.Id, theOpportunity.Lead_Referred_To__c);
        log.Request_Payload__c = 'From Webhook:\n'+payload;
        insert log;
        
    }
}