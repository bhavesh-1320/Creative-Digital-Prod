@isTest(SeeAllData = false)
class GetRecordTypeInfoByDeveloperName_Test {
    @TestSetup
    static void makeData(){
        String taskRecordTypeId = Schema.sObjectType.Task.getRecordTypeInfosByDeveloperName().get('System_Callout').getRecordTypeId();
        Task theTask = new Task(RecordTypeId = taskRecordTypeId, Subject = 'Test');
        insert theTask;
    }

    @isTest
    static void execute() {
        Task theTask = [SELECT Id, RecordTypeId FROM Task LIMIT 1];
        String taskRecordTypeDeveloperName = 'System_Callout';
        String taskRecordTypeId = Schema.sObjectType.Task.getRecordTypeInfosByDeveloperName().get('System_Callout').getRecordTypeId();
        Test.startTest();
        GetRecordTypeInfoByDeveloperName.ProcessRequest request = new GetRecordTypeInfoByDeveloperName.ProcessRequest();
        request.objectDeveloperName = 'Task';
        request.recordTypeDeveloperName = taskRecordTypeDeveloperName;
        List<GetRecordTypeInfoByDeveloperName.ProcessResponse> responseList = GetRecordTypeInfoByDeveloperName.execute(new List<GetRecordTypeInfoByDeveloperName.ProcessRequest>{request});
        request = new GetRecordTypeInfoByDeveloperName.ProcessRequest();
        request.recordId = theTask.Id;
        request.recordTypeId = taskRecordTypeId;
        responseList = GetRecordTypeInfoByDeveloperName.execute(new List<GetRecordTypeInfoByDeveloperName.ProcessRequest>{request});
        Test.stopTest();
    }
}