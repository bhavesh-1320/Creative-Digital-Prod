public with sharing class Inverite_CreateRequest {
    @InvocableMethod(label='Inverite Create API')
    public static List<ProcessResponse> execute(List<ProcessRequest> processRequestList) {
        List<ProcessResponse> responseList = new List<ProcessResponse>();
        List<Integration_Log__c> insertIntegrationLogList = new List<Integration_Log__c>();
        for(ProcessRequest request : processRequestList){
            Integration_Log__c log = new Integration_Log__c();
            ProcessResponse response = new ProcessResponse();
            response.isSuccess = true;
            try{
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                req.setEndpoint(request.url);
                req.setMethod('POST');
                req.setHeader('Accept', 'application/json');
                req.setHeader('Content-Type', 'application/json; charset=UTF-8');
                req.setHeader('Auth', request.auth);
                CreateRequest createRequest = new CreateRequest();
                createRequest.email = request.leadEmail;
                createRequest.firstname = request.leadFirstName;
                createRequest.lastname = request.leadLastName;
                createRequest.province = request.province;
                createRequest.siteID = request.siteId;
                createRequest.referenceid = request.leadId;
                createRequest.ip = request.sourceIp;
                String bodyString = JSON.serialize(createRequest);
                log.Request_Payload__c = bodyString;
                req.setBody(bodyString);
                HttpResponse res = h.send(req);
                response.httpStatusCode = res.getStatusCode();
                log.HTTP_Status_Code__c = String.valueOf(res.getStatusCode());
                log.HTTP_Status__c = res.getStatus();
                if(res.getStatusCode() == 200){
                    String responseBody = res.getBody();
                    response.httpResponseBody = responseBody;
                    log.Response_Body__c = responseBody;
                    CreateResponse createResponse = (CreateResponse)(JSON.deserialize(responseBody, CreateResponse.class));
                    response.guid = createResponse.request_guid;
                    response.inveriteUsername = createResponse.username;
                    Lead theLead = [SELECT Id, Inverite_iFrame_URL__c,Inverite_Username__c FROM Lead WHERE Id =: request.leadId];
                    theLead.Inverite_iFrame_URL__c = createResponse.iframeurl;
                    theLead.Inverite_Username__c = createResponse.username;
                    update theLead;
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
            insertIntegrationLogList.add(log);
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
        @InvocableVariable(label='Lead Id')
        public String leadId;
        @InvocableVariable(label='Lead Email')
        public String leadEmail;
        @InvocableVariable(label='Lead First Name')
        public String leadFirstName;
        @InvocableVariable(label='Lead Last Name')
        public String leadLastName;
        @InvocableVariable(label='Province')
        public String province;
        @InvocableVariable(label='Site Id')
        public String siteId;
        @InvocableVariable(label='Source IP')
        public String sourceIp;
        @InvocableVariable(label='Auth')
        public String auth;
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