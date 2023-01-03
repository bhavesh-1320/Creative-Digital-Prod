@isTest(SeeAllData=false)
class Inverite_CreateRequest_Test {
    /*
    {"password": "ckicenbr","request_guid": "2ACAD72D-F399-40C0-82EA-1CB1F2E9E10C","username": "andy.leung@jumpmodel.com","iframeurl": "https://sandbox.inverite.com/customer/v2/web/start/2ACAD72D-F399-40C0-82EA-1CB1F2E9E10C/0/modern"}
*/
    @TestSetup
    static void makeData(){
        String leadFirstName = 'Andy';
        String leadLastName = 'Leung';
        Lead testLead = new Lead(FirstName = leadFirstName, LastName = leadLastName);
        insert testLead;
    }

    @isTest
    static void testSendCreateRequest(){
        Lead testLead = [SELECT Id FROM Lead LIMIT 1];
        String leadEmail = 'andy.leung@jumpmodel.com';
        String leadFirstName = 'Andy';
        String leadLastName = 'Leung';
        String province = 'Ontario';
        String leadId = testLead.Id;
        String siteId = '252';
        String sourceIp = '1.2.3.4';
        Inverite_CreateRequest.ProcessRequest req = new Inverite_CreateRequest.ProcessRequest();
        req.url = 'https://sandbox.inverite.com/api/v2/create';
        req.leadEmail = leadEmail;
        req.leadId = leadId;
        req.leadFirstName = leadFirstName;
        req.leadLastName = leadLastName;
        req.province = province;
        req.siteId = siteId;
        req.sourceIp = sourceIp;
        Test.setMock(HttpCalloutMock.class, new Inverite_CreateRequest_CalloutMock());
        Test.startTest();
        List<Inverite_CreateRequest.ProcessResponse> responseList = Inverite_CreateRequest.execute(new List<Inverite_CreateRequest.ProcessRequest>{req});
        Test.stopTest();
    }
}