@isTest(SeeAllData=false)
class IM_GetSession_Test {
    @isTest
    static void testGetSession(){
        List<IM_GetSession.ProcessRequest> requestList = new List<IM_GetSession.ProcessRequest>();
        IM_GetSession.ProcessRequest req = new IM_GetSession.ProcessRequest();
        req.userId = UserInfo.getUserId();
        requestList.add(req);
        Test.startTest();
        List<IM_GetSession.ProcessResponse> responseList = IM_GetSession.execute(requestList);
        Test.stopTest();
    }
    @isTest
    static void testException(){
        List<IM_GetSession.ProcessRequest> requestList = new List<IM_GetSession.ProcessRequest>();
        IM_GetSession.ProcessRequest req = new IM_GetSession.ProcessRequest();
        req.userId = UserInfo.getUserId();
        requestList.add(req);
        IM_GetSession.forceException = true;
        Test.startTest();
        List<IM_GetSession.ProcessResponse> responseList = IM_GetSession.execute(requestList);
        Test.stopTest();
    }
}