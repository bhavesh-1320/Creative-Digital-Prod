public  class Inverite_CreateRequest_CalloutMock implements HttpCalloutMock{
    public HttpResponse respond(HTTPRequest req) {
        String responseJSONString = '{"password": "ckicenbr","request_guid": "2ACAD72D-F399-40C0-82EA-1CB1F2E9E10C","username": "andy.leung@jumpmodel.com","iframeurl": "https://sandbox.inverite.com/customer/v2/web/start/2ACAD72D-F399-40C0-82EA-1CB1F2E9E10C/0/modern"}';
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(responseJSONString);
        res.setStatusCode(200);
        return res;
    }
}