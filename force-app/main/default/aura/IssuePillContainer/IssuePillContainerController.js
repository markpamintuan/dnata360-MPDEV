({
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
    handleItemRemove: function (cmp, event,helper) {
        var id = event.getParam("item").id;
        var promptAnswer = confirm('Do you want to delete this? Action cannot be reverted.');
        if(promptAnswer){
            helper.deleteIssue(cmp,event,helper,id);
        }else{
            
        }
        //alert(name + ' pill was removed!');
        // Remove the pill from view
        //var items = cmp.get('v.items');
        //var item = event.getParam("index");
        //items.splice(item, 1);
        //cmp.set('v.items', items);
    }
})