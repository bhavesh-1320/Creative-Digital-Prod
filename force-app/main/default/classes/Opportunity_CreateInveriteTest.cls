/* Class Name: Opportunity_CreateInveriteTest
* Usage: This Class checks the functionality of Opportunity_CreateInverite class(Checks whether an Inverite Record is Created Successfully or not.).
*/
@isTest
class Opportunity_CreateInveriteTest {
     /* Method Name: makeData
* Preparing test data Creates Account and  Opportunity record.
*/
    @TestSetup
    static void makeData(){
        Account testAccount=new Account(name='Andy Leung',type='Referral Partner',email__c='andy.leung@jumpmodel.com',Inverite__c=true);
        insert testAccount;
        Opportunity testOpportunity=new Opportunity(name='test1 opportunity1',Lead_Referred_To__c=testAccount.Id,AccountId=testAccount.Id,
                                                    CloseDate=System.Today(),StageName='Qualification');
        insert testOpportunity;
    }
    
  /* Method Name: testSendCreateRequest
*  calls execute method of Opportunity_CreateInverite Class ,checks for the response httpStatusCode is 200 or Not.
*/
    @isTest
    static void testSendCreateRequest(){
      Opportunity testOpportunity = [SELECT Id,Lead_Referred_To__r.name,Lead_Referred_To__r.email__c,Lead_Referred_To__c FROM Opportunity LIMIT 1];
         String url;
         String accountId=testOpportunity.Lead_Referred_To__c;
         String opportunityId=testOpportunity.Id;
         String email=testOpportunity.Lead_Referred_To__r.email__c;
         String accountName=testOpportunity.Lead_Referred_To__r.name;  
         String province=null;
         String siteId = System.Label.SiteId;
         String sourceIp = '1.2.3.4';
         String auth=System.Label.Authorization_Token;
       // String province = 'Ontario';
  
        Opportunity_CreateInverite.ProcessRequest req = new Opportunity_CreateInverite.ProcessRequest();
        req.url = System.Label.Url;
        req.email = email;
        req.opportunityId = opportunityId;  //Request Parameters which are passed by Bank Verification Step 3 Process are preapred and passed to execute method of Opportunity_CreateInverite Class.
        req.accountName = accountName;
        req.province = province;
        req.siteId = siteId;
        req.sourceIp = sourceIp;
        req.auth=auth;
        Test.setMock(HttpCalloutMock.class, new Inverite_CreateRequest_CalloutMock());
        Test.startTest();
        List<Opportunity_CreateInverite.ProcessResponse> responseList = Opportunity_CreateInverite.execute(new List<Opportunity_CreateInverite.ProcessRequest>{req});
        System.debug('res'+responseList);
        System.assertEquals(200, responseList[0].httpStatusCode,'Status Code not 200,failed.');//Assertion fails when status received from callout is other than 200.
        Test.stopTest();
    }
}