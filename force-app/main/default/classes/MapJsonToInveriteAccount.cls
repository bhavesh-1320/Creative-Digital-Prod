/* Class Name: MapJsonToInveriteAccount
* Usage: This Class Maps the response, from Inverite webhook ,when status is changed to Verified,and creates Inverite Bank Account and Transactions Records.
*/
public class MapJsonToInveriteAccount {
    
         /*    
    Method Name: mapInveriteBankAccount
   *Accepts json payload,opportunityId,accountId and then maps the json Payload response to MapJsonResponse Class and then creates Inverite Bank Account and Transactions Records
    where Inverite Bank Account is related to Opportunity and Account Records.
        */
    
    public static void mapInveriteBankAccount(String payload,Id opportunityId,Id accountId){

            List<Transaction__c> accountTransactions=new List<Transaction__c>();
        List<Inverite_Bank_Account__c> accounts=new List<Inverite_Bank_Account__c>();
        Map<String,List<Transaction__c>> AccTransMap=new Map<String,List<Transaction__c>>();
        payload=payload.replace('date','dateInv');
        MapJsonResponse inveriteResponse = (MapJsonResponse)JSON.deserialize(payload, MapJsonResponse.class); //Mapped the payload to MapJsonResponse Class. 
         /* 
         for each account in jsonResponse Payload a new Inverite_Bank_Account record is created in salesforce,
         and for each Transaction in jsonResponse a new Transaction Record is created related to Inverite_bank_Account. 
         Inverite_Bank_Account records are inserted.
          */
        for(Inverite_Bank_Account account:inveriteResponse.accounts){
            Inverite_Bank_Account__c bankAccount=new Inverite_Bank_Account__c();
            List<Transaction__c> transactionObjs=new List<Transaction__c>();
           
            for(Transactions trans:account.transactions){
         
                Transaction__c obj=new Transaction__c();
                if(trans.flags!=null){
                for(String flag:trans.flags){
                    if(obj.flags__c!=null){
                       obj.flags__c=obj.flags__c+flag+' '; 
                    }
                    else{
                         obj.flags__c=flag+' ';                            
                                                                                                                                         
                    }
                }
                if(obj.flags__c!=null){
                obj.flags__c=obj.flags__c.trim();
                }
                }
                
                if(trans.balance!=null){
                    obj.balance__c=Double.valueOf(trans.balance);
                }
                if(trans.category!=null){
                     obj.category__c=trans.category;
                }
                if(trans.debit!=null){
                if(trans.debit.length()>0){
                 obj.debit__c=Double.valueOf(trans.debit.trim());
                }
                }
                if(trans.details!=null){
                obj.details__c=trans.details;
                }
                if(trans.credit!=null){
                if(trans.credit.length()>0){
                 obj.credit__c=Double.valueOf(trans.credit.trim());
                }
                }
                if(trans.dateInv!=null){
                     Date d = Date.valueOf(trans.dateInv);
                     obj.date__c=d;
                }
    
                transactionObjs.add(obj);
            }
            if(account.bank!=null){
            bankAccount.bank__c=account.bank;
            }
            if(account.institution!=null){
            bankAccount.institution__c=account.institution;
            }
            if(account.transit!=null){
             bankAccount.transit__c=account.transit;
            }
            if(account.routing_code!=null){
            bankAccount.routing_code__c=account.routing_code;
            }
            bankAccount.Name=account.account;
            if(account.membership_number!=null){
            bankAccount.membership_number__c=Integer.valueOf(account.membership_number.trim());
            }
            if(account.account_description!=null){
            bankAccount.account_description__c=account.account_description;
            }
            bankAccount.Opportunity__c=opportunityId;
            bankAccount.Account__c=accountId;
            bankAccount.type__c=account.type;
            bankAccount.Name__c=inveriteResponse.name;
            bankAccount.Address__c=inveriteResponse.address;
            if(inveriteResponse.contacts!=null){
            for(InveriteWebhook_Contact con:inveriteResponse.contacts){   
                if(con.type=='email'){
                    bankAccount.Email__c=con.contact;                         //contacts list is mapped here to Inverite Bank Account Object fields Email and Phone.
                }
                else if(con.type=='phone'){
                    bankAccount.Phone__c=con.contact;
                }
            }
            }
            AccTransMap.put(bankAccount.Name,transactionObjs);
            accounts.add(bankAccount);
         }
          insert accounts;               
         //Transaction records are inserted.
        for(Inverite_Bank_Account__c acc:accounts){
             List<Transaction__c> transList=AccTransMap.get(acc.Name);
             for(Transaction__c t:transList){
              t.BankAccountId__c=acc.Id;      //here each Transaction object is related to its Inverite_Bank_AccountId.
              accountTransactions.add(t);  
            }
   
        }
        insert accountTransactions;
    }
   
}