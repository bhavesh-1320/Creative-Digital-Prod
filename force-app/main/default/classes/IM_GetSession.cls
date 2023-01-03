public with sharing class IM_GetSession {
    @TestVisible
    static Boolean forceException = false;

    @InvocableMethod(label='Get Session')
    public static List<ProcessResponse> execute(List<ProcessRequest> requestList) {
        List<ProcessResponse> responseList = new List<ProcessResponse>();
        for(ProcessRequest request : requestList){
            ProcessResponse response = new ProcessResponse();
            try{
                if(!Test.isRunningTest()){
                    Map<String, String> sessionMap = Auth.SessionManagement.getCurrentSession();
                    response.sourceIp = sessionMap.get('SourceIp');
                }else{
                    if(forceException){
                        Account theAccount = [SELECT Id FROM Account WHERE Name = 'abcd'];
                    }
                }
                response.isSuccess = true;
            }catch(Exception e){
                response.isSuccess = false;
                response.errorMessage = e.getMessage();
                response.stacktrace = e.getStackTraceString();
            }
            responseList.add(response);
        }
        return responseList;
    }

    public class ProcessRequest{
        @InvocableVariable(label='Current User ID - Not Used')
        public String userId;
    }

    public class ProcessResponse{
        @InvocableVariable(label='Is Success')
        public Boolean isSuccess;
        @InvocableVariable(label='Error Message')
        public String errorMessage;
        @InvocableVariable(label='Error Stacktrace')
        public String stacktrace;
        @InvocableVariable(label='Source IP')
        public String sourceIp;
    }
}