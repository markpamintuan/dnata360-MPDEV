({
	showSuccessToast : function(component, event, helper, successMessage) {
        //alert('dd');
        try{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Success!",
                "type": "success",
                "message": successMessage              
                
                
            });
            toastEvent.fire();
        }
        catch(e){
            alert(e.message);
        }
        
	},
    
    // for view all modal
    addOpacityViewAll : function(component, event, helper) {
        // setting opacity for view all modal
        var viewAllModal = component.find("viewAllModalId");
        if(!$A.util.isUndefinedOrNull(viewAllModal)){
        	$A.util.addClass(viewAllModal, 'viewAllOpacity');
        }
    },
    
    // for view all modal
    removeOpacityViewAll : function(component, event, helper) {
        // setting opacity for view all modal
        var viewAllModal = component.find("viewAllModalId");
        if(!$A.util.isUndefinedOrNull(viewAllModal)){
            $A.util.removeClass(viewAllModal, 'viewAllOpacity');
        }
    },
})