({
	initializeMethod : function(component, event, helper) {
		helper.getDuplicateRecord(component);        
	},
    
    // for Display Model,set the "isOpen" attribute to "true"
    openModel: function(component, event, helper) {            
      component.set("v.isOpen", true);
   	},
 
    // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
   	closeModel: function(component, event, helper) {      
      component.set("v.isOpen", false);
   },
    
    refreshSection : function(component, event, helper) {
        helper.getDuplicateRecord(component);
    }
})