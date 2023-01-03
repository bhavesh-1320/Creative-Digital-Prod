@isTest
public class RescheduleInstallmentTest {
	@isTest
    static void unitTest1(){
        Opportunity opp = new Opportunity( StageName='Bank Verification', closeDate=Date.Today(), Name='Test' );
        INSERT opp;
        Loan__c loan = new Loan__c( Loan_Amount__c = 1000, Opportunity__c = opp.id );
        INSERT loan;
        Loan_Detail__c lDetail = new Loan_Detail__c( Loan2__c = loan.Id );
        INSERT lDetail;
        RescheduleInstallmentCtrl.getLoanDetails( loan.Id );
        RescheduleInstallmentCtrl.getLoanUser( loan.Id );
        RescheduleInstallmentCtrl.updateLoanDetail( lDetail, '1', 'Void' );
        RescheduleInstallmentCtrl.getPayMethodPickListValue();
        List<Map<String, String>> lDetails = new List<Map<String, String>>();
        Map<String, String> lMap = new Map<String, String>();
        lMap.put( 'lId', String.valueOf(loan.id) );
        lMap.put( 'PayMethod', 'ACH' );
        lMap.put( 'Amount', '123' );
        lMap.put( 'DueDate', '2022-2-2' );
        lMap.put( 'PAmt', '12' );
        lMap.put( 'insNum', '1' );
        lMap.put( 'AccEmail', 'test@g.com' );
        lDetails.add( lMap );
        RescheduleInstallmentCtrl.updateLoanDetailResch( lDetails, 'Refund', lDetail.Id );
    }
}