public with sharing class RescheduleInstallmentCtrl {
    public string recId{get;set;}
    public RescheduleInstallmentCtrl( ApexPages.StandardSetController sc ) {
        recId = ApexPages.currentPage().getParameters().get('id');
    }
    @AuraEnabled
    public static List<Loan_Detail__c> getLoanDetails( Id loanId ){
        try {
            return [SELECT Id, Loan2__c, Payment_Method__c, Account_Email__c, Amount__c, Due_Date__c, Installment__c, Penalty_Amount__c,
                    Status__c, Total_Installment_Amount__c FROM Loan_Detail__c WHERE Loan2__c = :loanId /* AND Status__c = 'Not Started' */ ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static boolean getLoanUser( Id loanId ){
        try {
            Id ownerId = [SELECT OwnerId FROM Loan__c WHERE Id = :loanId LIMIT 1].OwnerId;
            return [ SELECT Manager__c FROM User WHERE id = :ownerId LIMIT 1].Manager__c;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static Id updateLoanDetail( Loan_Detail__c lDetail, String insNum, String action ){
        try {
            System.debug(insNum);
            Loan_Detail__c oldLDetail = new Loan_Detail__c( Id = lDetail.Id, Status__c = action, Mark_it_paid__c = false, Mark_it_unpaid__c = false );
            UPDATE oldLDetail;
            lDetail.Id = null;
            lDetail.Status__c = 'Not Started';
            lDetail.Installment__c = insNum;
            INSERT lDetail;
            return lDetail.id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static void updateLoanDetailResch( List<Map<String, String>> lDetails, String action, String recId ){
        try {
            Loan_Detail__c oldLDetail = new Loan_Detail__c( Id = recId, Status__c = action );
            UPDATE oldLDetail;
            List<Loan_Detail__c> newLDetails = new List<Loan_Detail__c>();
            for( Map<String, String> lDetailMap : lDetails ){
                Loan_Detail__c lDetail = new Loan_Detail__c();
                lDetail.Loan2__c = lDetailMap.get('lId');
                lDetail.Payment_Method__c = lDetailMap.get('PayMethod');
                lDetail.Amount__c = Decimal.valueOf(lDetailMap.get( 'Amount' ));
                lDetail.Due_Date__c = date.valueOf(lDetailMap.get( 'DueDate' ));
                lDetail.Penalty_Amount__c = Decimal.valueOf(lDetailMap.get( 'PAmt' ));
                lDetail.Installment__c = lDetailMap.get( 'insNum' );
                lDetail.Account_Email__c = lDetailMap.get('AccEmail');
                lDetail.Status__c = 'Not Started';
                newLDetails.add( lDetail );
            }
            System.debug('lDetails'+newLDetails);   
            INSERT newLDetails;
            return;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static List < String > getPayMethodPickListValue() {
        List<String> pickListValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = Loan_Detail__c.Payment_Method__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			pickListValuesList.add(pickListVal.getLabel());
		}     
		return pickListValuesList;
      }
}