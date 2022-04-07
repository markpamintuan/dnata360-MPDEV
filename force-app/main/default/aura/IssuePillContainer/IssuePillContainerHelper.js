({
	deleteIssue : function(cmp,event,helper,id) {
		var action = cmp.get("c.deleteIssue");
        action.setParams({
            "idToDelete": id
        });
        action.setCallback(this, function(response) {
            
            var state = response.getState();
                if (state === "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                             title: 'Success',
                             type: 'success',
                             message: 'Issue has been removed.'
                           
                            
                        });
                        toastEvent.fire();
                    helper.init(cmp,event,helper);
                }
            
            // error handling when state is "INCOMPLETE" or "ERROR"
        });
        
        $A.enqueueAction(action);
	},
    init : function(component, event, helper) {
		var recId = component.get('v.recordId');          
        var action = component.get("c.findRelatedIssuesWithSupplier");
        action.setParams({ 
               "caseId" : recId 
        });
        action.setCallback(this, function(response){
               var state = response.getState();
               console.log(state);
               if(state === 'SUCCESS' && component.isValid()){
                   var custs = [];
                    var conts = response.getReturnValue();
                   console.log('new' + JSON.stringify(conts));
                    for(var key in conts){
                        
                        custs.push({value:conts[key], key:key});
                    }
                   
                   console.log(custs);
                   component.set('v.items',custs);
                   /*var items = component.get('v.items');
                   var issues = response.getReturnValue();
                   for(var i = 0; i < issues.length; i++) {
                       //alert(issues[i].Supplier_Name__c);
                       items.push({
                           label: issues[i].Issue__c + ' ► ' + issues[i].Issue_Type__c + ' ► ' +  issues[i].Supplier_Name__c
                       })
                       component.set('v.items',items);
                   }*/
               }else{
                   alert('Error');
               }
        });
        
        $A.enqueueAction(action);
                 
	},
})