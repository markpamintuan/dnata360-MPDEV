({
	openModal : function(component, event, helper) {
		component.set("v.isOpen", true);
        var delId = component.get("v.recordId");
         helper.fetchData(component,event,delId);    
	},
    closeModal: function(component, event, helper) {
        var type = component.find("category").set("v.value",'');
        var status = component.find("status").set("v.value",'');
        var subject = component.find("subject").set("v.value",'');
        var description = component.find("description").set("v.value",'');
        helper.clear(component,event,helper);
        component.set('v.dataToPush',[]);
      component.set("v.isOpen", false);
      $A.get('e.force:refreshView').fire();
      helper.refreshFocusedTab(component,event,helper);
   },
    init: function (component, event, helper) {
        var actions = helper.getRowActions.bind(this, component);
      	var delId = component.get("v.recordId");
        console.log('bookingid ' + delId);
        component.set('v.columns', [                
            {label: 'Category', fieldName: 'Category__c', type: 'picklist' ,editable: false},
            {label: 'Subject', fieldName: 'Subject', type: 'text' ,editable: false},            
            {label: 'Status', fieldName: 'Org_Case_Status__c', type: 'picklist' ,editable: false},
            { type: "action", typeAttributes: { rowActions: actions}},                      
        ]);        
        helper.fetchData(component,event,delId);          
    },
    onblur : function(component,event,helper){       
        component.set("v.listOfSearchRecords", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
     onSelectChange : function(component, event, helper) {
        var selectedSearchType = component.find("lkptype").get("v.value");
        //do something else
        component.set("v.selLookupType", selectedSearchType);
    },
    keyPressController : function(component, event, helper) {
        
        // get the search Input keyword   
        var getInputkeyWord = component.get("v.SearchKeyWord");
        // check if getInputKeyWord size id more then 0 then open the lookup result List and 
        // call the helper 
        // else close the lookup result List part.   
        if( getInputkeyWord.length > 0 ){
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            var sellkptype = component.get("v.selLookupType");
            helper.searchHelper(component,event,getInputkeyWord,sellkptype);
        }
        else{  
            component.set("v.listOfSearchRecords", null ); 
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },
	handleComponentEvent : function(component, event, helper) {
        // get the selected Account record from the COMPONETN event 	 
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        console.log('selectedAccountGetFromEvent ' + JSON.stringify(selectedAccountGetFromEvent));
        component.set("v.selectedRecord" , selectedAccountGetFromEvent); 
        
        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');
        
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
        $A.util.addClass(lookUpTarget, 'slds-hide');
        $A.util.removeClass(lookUpTarget, 'slds-show');  
        
    },
    clear :function(component,event,helper){
        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField"); 
        
        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');
        
        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');
        
        component.set("v.SearchKeyWord",null);
        component.set("v.listOfSearchRecords", null );
        component.set("v.selectedRecord", {} );   
    },
     onchange : function(component,event,helper){
        component.set('v.Subject',component.get('v.Category__c'));
    },
      addInternalRequest : function(component , event, helper){
      	var actions = helper.getRowActions.bind(this, component);
         component.set('v.columns', [
                      
            {label: 'Category', fieldName: 'Category__c', type: 'picklist' ,editable: false},
            {label: 'Subject', fieldName: 'Subject', type: 'text' ,editable: false},            
            {label: 'Status', fieldName: 'Org_Case_Status__c', type: 'picklist' ,editable: false},
             { type: "action", typeAttributes: { rowActions: actions }}
            
             
        ]); 
        var myData = component.get("v.data"); 
        var type = component.find("category").get("v.value");
        var status = component.find("status").get("v.value");
        var subject = component.find("subject").get("v.value");
         var description = component.find("description").get("v.value");
        var seluserorqueue = component.get("v.selectedRecord.rid"); 
        myData.push(
            {
                Subject:subject,
                Category__c:type,
                Org_Case_Status__c:status,
                OwnerId:seluserorqueue,
                Description:description
            });        
        component.set("v.data", myData);     
        var type = component.find("category").set("v.value",'');
        var status = component.find("status").set("v.value",'');
        var subject = component.find("subject").set("v.value",'');
        var description = component.find("description").set("v.value",'');
        helper.clear(component,event,helper);
        $A.get('e.force:refreshView').fire();
        
        var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                     title: 'Success',
                     type: 'success',
                    message: 'Successfully added to the bottom of the List!'
                });
                toastEvent.fire();
        },
    handleAction: function(component, event, helper) {
        console.log('handling action');
        var action = event.getParam("action"),
            row = event.getParam("row"),
            data = component.get("v.data"),
            rowIndex = data.indexOf(row);
        switch(action.name) {
            case 'del': data.splice(rowIndex, 1);
                break;
        }
        component.set("v.data", data);
    }, 
    finish : function(component,event,helper){
         var json = component.get('v.data');
            var finalJson = [];
            for(var i = 0; i < json.length; i++) {
    			var obj = json[i];
                if(!obj.hasOwnProperty('Id')){
                    finalJson.push(obj);
                }
            }
            console.log(JSON.stringify(finalJson));
            component.set('v.dataToPush',finalJson);
        component.set('v.isLoading','true');
        var bookingid = component.get('v.recordId');
        helper.insertInternalAndIssuefinal(component,event,helper,bookingid);
        
    },
})