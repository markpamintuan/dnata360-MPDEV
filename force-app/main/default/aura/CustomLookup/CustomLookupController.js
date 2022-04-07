({
  doInit : function(component, event, helper) {

    var selectedRecord = component.get("v.selectedRecord");
    //searchText = event.getParam("defaultValue");
    if(!$A.util.isEmpty(selectedRecord)) {
        //this.clear(component, event, helper);

        var objectAPIName = component.get("v.objectAPIName");


        var action = component.get("c.fetchDefaultLookupValue");

        action.setParams({
            'hotelId' : selectedRecord.Id,
            'ObjectName' : objectAPIName
        });

        action.setCallback(this, function (a) {

            if (a.getState() === 'SUCCESS') {
                console.log( a.getReturnValue());
                    component.set("v.selectedRecord" , a.getReturnValue()); 

                var forclose = component.find("lookup-pill");
                   $A.util.addClass(forclose, 'slds-show');
                   $A.util.removeClass(forclose, 'slds-hide');

                var forclose = component.find("searchRes");
                   $A.util.addClass(forclose, 'slds-is-close');
                   $A.util.removeClass(forclose, 'slds-is-open');

                var lookUpTarget = component.find("lookupField");
                    $A.util.addClass(lookUpTarget, 'slds-hide');
                    $A.util.removeClass(lookUpTarget, 'slds-show');  
            } else if (a.getState() === "ERROR") {
                var errors = a.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                        var message = "Error message: " + errors[0].message;

                    }
                } else {
                    console.log('Unknown error');
                    var message = 'Unknown error';

                }
            }
        });

        $A.enqueueAction(action);
    }
  },

   onfocus : function(component,event,helper){
       $A.util.addClass(component.find("mySpinner"), "slds-show");
        var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC  
         var getInputkeyWord = '';
         helper.searchHelper(component,event,getInputkeyWord);
    },
    onblur : function(component,event,helper){       
        component.set("v.listOfSearchRecords", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
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
            helper.searchHelper(component,event,getInputkeyWord);
        }
        else{  
             component.set("v.listOfSearchRecords", null ); 
             var forclose = component.find("searchRes");
               $A.util.addClass(forclose, 'slds-is-close');
               $A.util.removeClass(forclose, 'slds-is-open');
          }
	},
    
  // function for clear the Record Selaction 
    clear :function(component,event,heplper){
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
    
  // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
    // get the selected record from the COMPONENT event 	 
       var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        console.log(selectedAccountGetFromEvent);
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
})