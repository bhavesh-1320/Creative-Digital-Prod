global with sharing class GetRecordTypeInfoByDeveloperName {

    @InvocableMethod(label='GetRecordTypeInfoByDeveloperName' description='Get Record Type Info by Developer Name.  Either use Record ID or Object Developer Name')
    global static List<ProcessResponse> execute(List<ProcessRequest> processRequestList) {
        List<ProcessResponse> processResponseList = new List<ProcessResponse>();
        for(ProcessRequest processRequest : processRequestList){
            Schema.SObjectType sobjectType;
            if(String.isNotBlank(processRequest.recordId)){
                sobjectType = ((Id)processRequest.recordId).getSObjectType();
            }else if(String.isNotBlank(processRequest.objectDeveloperName)){
                sobjectType = Schema.getGlobalDescribe().get(processRequest.objectDeveloperName);
            }
            Schema.RecordTypeInfo recordTypeInfo;
            if(String.isNotBlank(processRequest.recordTypeId)){
                recordTypeInfo = sobjectType.getDescribe().getRecordTypeInfosById().get(processRequest.recordTypeId);
            }else if(String.isNotBlank(processRequest.recordTypeDeveloperName)){
                recordTypeInfo = sobjectType.getDescribe().getRecordTypeInfosByDeveloperName().get(processRequest.recordTypeDeveloperName);
            }
            ProcessResponse processResponse = new ProcessResponse();
            processResponse.recordTypeId = recordTypeInfo.getRecordTypeId();
            processResponse.recordTypeLabel = recordTypeInfo.getName();
            processResponse.recordTypeDeveloperName = recordTypeInfo.getDeveloperName();
            processResponseList.add(processResponse);
        }
        return processResponseList;
    }

    global class ProcessRequest{
        @InvocableVariable(label='Record ID' description='Record ID')
        global String recordId;

        @InvocableVariable(label='Object Developer Name' description='Object Developer Name')
        global String objectDeveloperName;
        
        @InvocableVariable(label='Record Type ID' description='Record Type ID')
        global String recordTypeId;

        @InvocableVariable(label='Record Type Developer Name' description='Record Type Developer Name')
        global String recordTypeDeveloperName;
    }

    global class ProcessResponse{
        @InvocableVariable(label='Record Type Id' description='Record Type Id')
        global String recordTypeId;

        @InvocableVariable(label='Record Type Label' description='Record Type Label')
        global String recordTypeLabel;
        
        @InvocableVariable(label='Developer Name' description='Record Type Developer Name')
        global String recordTypeDeveloperName;
    }
}