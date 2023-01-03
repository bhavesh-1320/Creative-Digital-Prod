@isTest(SeeAllData=false)
class Inverite_Webhook_Test {
    @TestSetup
    static void makeData(){
        Account theAccount = new Account(name = 'Test',type='Referral Partner');
        insert theAccount;
        Opportunity theOpportunity=new Opportunity(StageName='BankVerification',Name='testOpp',closedate=System.today(),Lead_Referred_To__c=theAccount.Id);
        insert theOpportunity;
    }

    @isTest
    static void testNoPostCall(){
        Opportunity theOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
        Test.startTest();
        InveriteWebhookRequest webhookRequest = new InveriteWebhookRequest();
        webhookRequest.referenceid = theOpportunity.Id;
        webhookRequest.request = 'GUID_1234';
        webhookRequest.complete_datetime = 'test completion datetime';
        webhookRequest.status = 'test status';
        webhookRequest.error = 'test error';
        webhookRequest.name = 'test name';
        webhookRequest.address = 'test address';
        webhookRequest.type = 'test type';
        webhookRequest.accounts = new List<InveriteWebhook_Account>();
        InveriteWebhook_Account testAccount = new InveriteWebhook_Account();
        testAccount.type = 'Test Account';
        testAccount.bank = 'Test Bank';
        testAccount.institution = 'Test institution';
        testAccount.transit = 'Test transit';
        testAccount.routing_code = 'Test routing_code';
        testAccount.account = 'Test account';
        webhookRequest.accounts.add(testAccount);
        webhookRequest.contacts = new List<InveriteWebhook_Contact>();
        InveriteWebhook_Contact testContact = new InveriteWebhook_Contact();
        testContact.contact = 'Test Contact';
        testContact.type = 'Test type';
        webhookRequest.contacts.add(testContact);
        Test.stopTest();
    }

    @isTest
    static void testWebhookReceived(){  
        Account theAccount = [SELECT Id FROM Account LIMIT 1];
        Opportunity theOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
        Test.startTest();
        InveriteWebhookRequest webhookRequest = new InveriteWebhookRequest();
        webhookRequest.referenceid = theOpportunity.Id;
        webhookRequest.request = 'GUID_1234';
        webhookRequest.accounts = new List<InveriteWebhook_Account>();
        InveriteWebhook_Account testAccount = new InveriteWebhook_Account();
        testAccount.type = 'Test Account';
        testAccount.account='123456';
        testAccount.account_description='test';
        testAccount.bank='test';
        testAccount.institution='test';
        testAccount.membership_number='123';
        testAccount.routing_code='1234';
        testAccount.transit='123';
     
        Transactions t=new Transactions();
        t.details='test details';
        t.category='test category';
        t.balance='231';
        t.credit='0';
        t.debit='55';
        t.flags=new List<String>{'test1','test2'};
        t.dateInv='2022-04-19';    
        testAccount.transactions=new List<Transactions>();
        testAccount.transactions.add(t);
   
        webhookRequest.accounts.add(testAccount);
        webhookRequest.contacts = new List<InveriteWebhook_Contact>();
        InveriteWebhook_Contact testContact = new InveriteWebhook_Contact();
        testContact.contact = 'Test Contact';
        webhookRequest.contacts.add(testContact);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/inveritewebhook/';
        req.httpMethod = 'POST';
        req.headers.put('Content-Type','application/json');
        req.requestBody = Blob.valueOf(JSON.serialize(webhookRequest));
        RestContext.request = req;
        RestContext.response = res;
        Inverite_Webhook.doPost();
        Opportunity theOpportunityUpdated = [SELECT Id,Inverite_GUID__c FROM Opportunity where  Lead_Referred_To__c=:theAccount.Id LIMIT 1];
        System.assertEquals(theOpportunityUpdated.Inverite_GUID__c, 'GUID_1234', ' Invalid GUID');
        Test.stopTest();
    }
}