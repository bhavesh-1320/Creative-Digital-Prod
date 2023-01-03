/* Class Name: Opportunity_CreateInverite
* Usage: This Class Creates an Inverite Account for the Customer and after creating Inverite record ,it updates the Inverite_iFrame_URL__c ,Inverite_Username__c on the Account..
*/
public with sharing class Opportunity_CreateInverite {
     /* Method Name: execute
* Accepts the ProcessRequest Parameters from the Process Opportunity Bank Verification Step 3,sends Api request to Create an Inverite account 
 and then updates the Inverite_iFrame_URL__c ,Inverite_Username__c on the Salesforce Account and saves the IntegrationLog Object with Request Payload and Response fields.
*/
    @InvocableMethod(label='Opportunity CreateInverite')
    public static List<ProcessResponse> execute(List<ProcessRequest> processRequestList) {
        List<ProcessResponse> responseList = new List<ProcessResponse>();
        List<Integration_Log__c> insertIntegrationLogList = new List<Integration_Log__c>();
        for(ProcessRequest request : processRequestList){   //request contains the Paramters passed from the flow.
            Integration_Log__c log = new Integration_Log__c();
            ProcessResponse response = new ProcessResponse();
            response.isSuccess = true;
            try{
                system.debug('request--> '+request);
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                req.setEndpoint(request.url);
                req.setMethod('POST');
                req.setHeader('Accept', 'application/json');
                req.setHeader('Content-Type', 'application/json; charset=UTF-8');
                req.setHeader('Auth', request.auth);
                System.debug('Auth'+request.auth);
                System.debug('siteId'+request.siteId);
                System.debug('url'+request.url);
                
                
                InveriteRequest createRequest = new InveriteRequest();
                String firstName;                                                                                   
                String lastName;
                if(!request.accountName.containsWhitespace()||request.accountName.endsWith(' ')||request.accountName.startsWith(' ')){
                    firstName=request.accountName.trim();
                    lastName=request.accountName.trim();
                }
                else{
                firstName=request.accountName.substringBefore(' ');   //name field on account is split,based on first space ,text before first space is firstName and after is lastName.                                                                                   
                lastName=request.accountName.substringAfter(' ');   
                }                                 
                createRequest.firstName=firstName;
                createRequest.lastname=lastName;
                createRequest.email = request.email;
               // createRequest.province = request.province;
                createRequest.siteID = request.siteId;
                createRequest.referenceid = request.opportunityId;
                createRequest.ip = request.sourceIp;
                String bodyString = JSON.serialize(createRequest);  //createRequest is converted to Json Request payload.
                log.Request_Payload__c = bodyString;
                req.setBody(bodyString);
                HttpResponse res = h.send(req);
                response.httpStatusCode = res.getStatusCode();
                log.HTTP_Status_Code__c = String.valueOf(res.getStatusCode());
                log.HTTP_Status__c = res.getStatus();
           
                /*
                If(res.getStatusCode() == 301 || res.getStatusCode() == 302)
                   {   
                 req.setEndpoint(res.getHeader('Location'));
                 res = h.send(req);
                response.httpStatusCode = res.getStatusCode();
                log.HTTP_Status_Code__c = String.valueOf(res.getStatusCode());
                log.HTTP_Status__c = res.getStatus();
                   }
                */
                
                
                if(res.getStatusCode() == 200){             //Response is Success,createResponse is deserialize,Account is updated.
                    String responseBody = res.getBody();
                    response.httpResponseBody = responseBody;
                    log.Response_Body__c = responseBody;
                    CreateResponse createResponse = (CreateResponse)(JSON.deserialize(responseBody, CreateResponse.class));
                    response.guid = createResponse.request_guid;
                    response.inveriteUsername = createResponse.username;
                    Opportunity theOpportunity = [SELECT Id, Inverite_iFrame_URL__c,Inverite_Username__c FROM Opportunity WHERE Id =: request.opportunityId];
                    theOpportunity.Inverite_iFrame_URL__c = createResponse.iframeurl;
                    theOpportunity.Inverite_Username__c = createResponse.username;
                    update theOpportunity;
                   
               
               
                    
                }else{
                    response.httpErrorStatus = res.getStatus();
                }
            }catch(Exception e){
                response.isSuccess = false;
                response.errorMessage = e.getMessage();
                response.stacktrace = e.getStackTraceString();
                log.Error_Message__c = response.errorMessage.left(255);
                log.Stacktrace__c = response.stacktrace.left(131072);
            }
            insertIntegrationLogList.add(log);       //IntegrationLog is saved to store the request Payload and response from the Rest Api request..
            responseList.add(response);
        }
        if(!insertIntegrationLogList.isEmpty()){
            insert insertIntegrationLogList;
        }
        return responseList;
    }

    public class ProcessRequest{
        @InvocableVariable(label='URL Endpoint')
        public String url;
        @InvocableVariable(label='Email')
        public String email;
        @InvocableVariable(label='Account Name')
        public String accountName;
        @InvocableVariable(label='Province')
        public String province;
        @InvocableVariable(label='Site Id')
        public String siteId;
        @InvocableVariable(label='Source IP')
        public String sourceIp;
        @InvocableVariable(label='Auth')
        public String auth;
        @InvocableVariable(label='opportunityId')
        public String opportunityId;
    }

    public class ProcessResponse{
        @InvocableVariable(label='Is Success')
        public Boolean isSuccess;
        @InvocableVariable(label='Error Message')
        public String errorMessage;
        @InvocableVariable(label='Error Stacktrace')
        public String stacktrace;
        @InvocableVariable(label='HTTP Response Body')
        public String httpResponseBody;
        @InvocableVariable(label='HTTP Status Code')
        public Integer httpStatusCode;
        @InvocableVariable(label='HTTP Error Status')
        public String httpErrorStatus;
        @InvocableVariable(label='guid')
        public String guid;
        @InvocableVariable(label='Inverite Username')
        public String inveriteUsername;
    }
}