({
    doInit : function(component,event,helper){
        // alert('do init get called');
        helper.callToServer(
            component,
            "c.findRecordTypes",
            function(response) {
                //alert(JSON.parse(response));
                var jsonObject=JSON.parse(response);
                component.set('v.recordTypeList',jsonObject);  
                component.set('v.selectedRecordType',jsonObject[0].recordTypeId); 
            }, 
            {objName: component.get('v.objType')}
        ); 
    },
    
    onChange : function(component, event, helper) {
        var value = event.getSource().get("v.text");
        component.set('v.selectedRecordType', value);
    },
    defaultCloseAction : function(component, event, helper) {
        //$A.util.addClass(component, "hideModal");
        //$A.util.addClass(component, "slds-hide");
        $A.get("e.force:closeQuickAction").fire()
    },
    onconfirm : function(component, event, helper){
        //alert('confirm get called');
        var selectedRecType=component.get('v.selectedRecordType');
        //alert('selected recordtype:'+selectedRecType);
    },
    createRecord : function (component, event, helper) {
        //alert(component.get("v.recordId"));
        var selectedRecType = component.get('v.selectedRecordType');
        //alert('selected recordtype: '+selectedRecType);
        
        var parentId = component.get('v.recordId');
        console.log(parentId);
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Case",
            "recordTypeId": selectedRecType,
            "defaultFieldValues": {
                'Subject' : 'New Case',
                'AccountId' : '0010E00000H4X5gQAF',
                'Account.Name' : 'Damien Lee',
                'Contact.Name' : 'Damien Lee',
                'ContactId' : '0030E00000HcpJ6QAJ'
            }
        });
        
        createRecordEvent.fire();
        
        var a = component.get('c.navigateToExternal');
        $A.enqueueAction(a);
        
        //sforce.one.navigateToURL("https://www.google.com?q=salesforce+lightning");
        //window.setTimeout(window.open("https://www.google.com?q=salesforce+lightning"), 3000);
    },
    navigateToExternal : function(component, event, helper){
        //window.open("https://www.google.com?q=salesforce+lightning");
        window.open("https://www.google.com?q=salesforce+lightning");
    }
    
})