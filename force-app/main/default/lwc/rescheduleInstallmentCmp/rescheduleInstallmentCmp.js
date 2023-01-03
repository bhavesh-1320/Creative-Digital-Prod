import { api, LightningElement } from 'lwc';
import getLoanDetails from '@salesforce/apex/RescheduleInstallmentCtrl.getLoanDetails';
import updateLoanDetail from '@salesforce/apex/RescheduleInstallmentCtrl.updateLoanDetail';
import updateLoanDetailResch from '@salesforce/apex/RescheduleInstallmentCtrl.updateLoanDetailResch';
import getPayMethodPickListValue from '@salesforce/apex/RescheduleInstallmentCtrl.getPayMethodPickListValue';
import getLoanUser from '@salesforce/apex/RescheduleInstallmentCtrl.getLoanUser';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class RescheduleInstallmentCmp extends LightningElement {
    // @api recId;
    @api recordId;
    tomDate;
    value = '';
    loanDetails;
    options;
    selectInstallment=false;
    insAmt;
    insPenalty;
    insDueDate;
    insName;
    insPaymentMethod;
    selectedLd;
    insNum;
    showError = false;
    sfdcBaseURL;
    showSpinner = false;
    nextBtnEditable = true;
    reschBtnEditable = true;
    paymentMethods;
    actionValue = '';
    selectAction = true;
    insSplitNum;
    showInsNums = false;
    showInsDetails=false;
    showResch = false;
    reschRecs = [];
    actions = [];
    get insNumbers(){
        var nums = [];
        for( var i =1; i<=10; i++ ){
            var obj = {label:i, value:i};
            nums.push(obj);
        }
        return nums;
    }
    connectedCallback(){
        this.showSpinner = true;
        getLoanUser( {loanId : this.recordId} ).then( res=>{
            this.showSpinner = false;
            console.log('Res:',res);
            if( res ){
                this.actions =  [
                                    { label: 'Reschedule', value: 'Reschedule' },
                                    { label: 'Refund', value: 'Refund' },
                                    { label: 'Void', value: 'Void' }
                                ];
            }else{
                this.actions =  [
                                    { label: 'Reschedule', value: 'Reschedule' }
                                ];
            }
        } );
        this.sfdcBaseURL  = window.location.origin + "/" + this.recordId;
        console.log(this.sfdcBaseURL);
    }
    handleGetLoanDetails(){
        getLoanDetails( {loanId : this.recordId} ).then( res=>{
            console.log(res);
            this.insNum = res.length + 1;
            var lDetails = [];
            var loanDetail = {};
            var today = this.getDate(new Date());
            var tomorrowDate = this.getDate(new Date(new Date().getTime() + 24 * 60 * 60 * 1000)); 
            this.tomDate = tomorrowDate;
            res.forEach(lDetail => {
                if( this.actionValue == 'Refund' ){
                    if( lDetail.Status__c == 'Paid' ){
                        if( lDetail.Due_date__c >= today ){
                            loanDetail[lDetail.Id] = lDetail;
                            var option = { label: 'Installment-'+lDetail.Installment__c, value: lDetail.Id };
                            lDetails.push( option );
                        }
                    }
                }else if( this.actionValue == 'Void' ){
                    if( lDetail.Status__c == 'Not Started' ){
                            loanDetail[lDetail.Id] = lDetail;
                            var option = { label: 'Installment-'+lDetail.Installment__c, value: lDetail.Id };
                            lDetails.push( option );
                    }
                }else if( this.actionValue == 'Reschedule' ){
                    if( lDetail.Status__c == 'Not Started' ){
                        console.log(lDetail.Due_date__c);
                        if( (lDetail.Payment_Method__c == 'ACH' || lDetail.Payment_Method__c == 'E-Transfer') && (lDetail.Due_date__c == today || lDetail.Due_date__c == tomorrowDate) ){
                            console.log(today);
                            console.log(tomorrowDate);
                        }else{
                            loanDetail[lDetail.Id] = lDetail;
                            var option = { label: 'Installment-'+lDetail.Installment__c, value: lDetail.Id };
                            lDetails.push( option );
                        }
                    }
                }
            });
            this.options = lDetails;
            this.loanDetails = loanDetail;
            if( lDetails.length <= 0 ){
                this.showError = true;
            }
            this.showSpinner = false;
        } ).catch( err=>{

        } );
    }
    getDate( today ){
        const month = String(today.getMonth()+1).padStart(2, '0');
        const year = today.getFullYear();
        const day = String(today.getDate()).padStart(2, '0');
        var todayDate = year +'-'+month+'-'+day;
        return todayDate;
    }
    handleActionRadioChange( event ){
        var actionVal = event.target.value;
        this.actionValue = actionVal;
        if( actionVal == 'Reschedule' ){
            this.showInsNums = true;
            this.nextBtnEditable = true;
        }else{
            this.showInsNums = false;
            this.nextBtnEditable = false;
        }
    }
    handleInsNumChange( event ){
        this.insSplitNum = parseInt(event.target.value);
        this.nextBtnEditable = false;
    }
    handleRadioChange( event ){
        console.log(event);
        this.nextBtnEditable = false;
        this.value = event.target.value;
    }
    handleNextBtn(){
        this.selectInstallment = true;
        this.selectAction = false;
        this.showSpinner = true;
        this.nextBtnEditable = true;
        this.handleGetLoanDetails();
    }
    handleSelectInsNextBtn( event ){
        this.getPickValues();
        if( this.actionValue == 'Refund' || this.actionValue == 'Void' ){
            this.showInsDetails = true;
            // this.reschBtnEditable = false;
            this.selectedLd = this.loanDetails[this.value];
            console.log(this.selectedLd);
            this.insAmt = this.selectedLd.Amount__c;
            this.insPaymentMethod = this.selectedLd.Payment_Method__c;
            this.insPenalty = this.selectedLd.Penalty_Amount__c;
            this.insDueDate = this.selectedLd.Due_date__c;
            this.insName= this.selectedLd.Installment__c;
        }else{
            this.showResch = true;
            this.selectedLd = this.loanDetails[this.value];
            console.log(this.selectedLd);
            var recs = [];
            for( var i = 0; i< this.insSplitNum; i++ ){
                var obj = {'TotalAmt':this.selectedLd.Total_Installment_Amount__c,'lId' : this.selectedLd.Loan2__c, 'AccEmail' : this.selectedLd.Account_Email__c, 'Amount':0, 'PayMethod':this.selectedLd.Payment_Method__c, 'PAmt':this.selectedLd.Penalty_Amount__c, 'DueDate':this.selectedLd.Due_date__c, 'idx':i};
                recs.push(obj);
            }
            this.reschRecs = recs;
            this.insName= this.selectedLd.Installment__c;
        }
        this.selectInstallment = false;
    }
    handleFieldChangeNotResch( event ){
        this.reschBtnEditable = false;
        if( event.target.label == 'Penalty Amount' ){
                this.insPenalty = event.target.value;
        }else if( event.target.label == 'Due Date' ){
            this.insDueDate = event.target.value;
            /*  if( new Date(this.insDueDate) >= new Date( this.tomDate ) ){
                this.reschBtnEditable = false;
            }else{
                this.reschBtnEditable = true;
            } */
        }else if( event.target.label == 'Payment Method' ){
            this.insPaymentMethod = event.target.value;
        }
    }
    handleFieldChange( event ){
        var idx = event.target.dataset.idx;
        var rRec = this.reschRecs[idx];
        if( event.target.label == 'Penalty Amount' ){
            if( rRec.idx == idx ){
                rRec.PAmt = event.target.value;
            }
        }else if( event.target.label == 'Due Date' ){
            if( rRec.idx == idx ){
                this.reschRecs[idx].DueDate = event.target.value;
            }
        }else if( event.target.label == 'Payment Method' ){
            if( rRec.idx == idx ){
                this.reschRecs[idx].PayMethod = event.target.value;
            }
        }else if( event.target.label == 'Amount' ){
            if( rRec.idx == idx ){
                this.reschRecs[idx].Amount = event.target.value;
            }
        }
    }
    handleVoidSaveBtn(){
        console.log(this.insPenalty);
        console.log(new Date(this.insDueDate));
        console.log(this.selectedLd);
        this.selectedLd.Due_date__c = this.insDueDate;
        this.selectedLd.Penalty_Amount__c = this.insPenalty;
        this.selectedLd.Payment_Method__c = this.insPaymentMethod;
        if( new Date(this.insDueDate) >= new Date( this.tomDate ) || this.insPaymentMethod == 'Cash' || this.insPaymentMethod == 'Debit' ){
            this.showSpinner = true;
            updateLoanDetail( {lDetail : this.selectedLd, insNum : this.insNum+'', action : this.actionValue} ).then( res =>{
                if( res != undefined ){
                    window.location  = window.location.origin + "/CRM/" + res;
                }
            } ).catch( err =>{
                console.log(err);
            } );
        }else{
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Due date should be greater than today.',
                variant: 'Error',
            });
            this.dispatchEvent(evt);
        }
    }
    handleReschBtn(){
        console.log(this.reschRecs);
        var lAmt = 0;
        var dueDateErr = false;
        var amtErr = false;
        var iNum = this.insNum;
        for( var rec of this.reschRecs ){
            lAmt += parseInt(rec.Amount);
            rec.insNum = iNum;
            ++iNum;
            if( rec.Amount == 0 || rec.Amount == null || rec.Amount == undefined || rec.Amount == 'null' ){
                amtErr = true;
            }
            if( (rec.DueDate <= this.getDate(new Date()) && rec.PayMethod != 'Debit' && rec.PayMethod != 'Cash') 
                || rec.DueDate == null || rec.DueDate == undefined || rec.DueDate == 'null' ){
                dueDateErr = true;
            }
        }
        if( lAmt != this.selectedLd.Amount__c || amtErr ){
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Total installment(s) amount must equal to the installment being rescheduled.',
                variant: 'Error',
            });
            this.dispatchEvent(evt);
        } else if( dueDateErr ){
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Payment due date must be greater than today',
                variant: 'Error',
            });
            this.dispatchEvent(evt);
        } else{
            this.showSpinner = true;
            var rRecs = this.reschRecs;
            if( rRecs.length > 0 ){
                for( var i = 0; i<rRecs.length - 1; i++ ){
                    for( var j = i+1; j<rRecs.length; j++ ){
                        if( rRecs[i].DueDate < rRecs[j].DueDate  ){
                            var tempLd = rRecs[i];
                            rRecs[i] = rRecs[j];
                            rRecs[j] = tempLd;
                        }
                    }    
                }
            }
            this.reschRecs = rRecs;
            console.log('Updated:',this.reschRecs);
            updateLoanDetailResch( {lDetails : this.reschRecs, action : this.actionValue, recId:this.selectedLd.Id} ).then( res =>{
                console.log('Called');
                window.location  = window.location.origin + "/CRM/" + this.recordId;
            } ).catch( err =>{
                console.log(err);
            } );
        }
    }
    getPickValues(){
        getPayMethodPickListValue().then( pickValues=>{
            var pickVals = [];
            pickValues.forEach( pickValue =>{
                var obj = {label: pickValue, value: pickValue};
                pickVals.push( obj );
            } )
            this.paymentMethods = pickVals;
            this.showSpinner = false;
        } );
    }
}