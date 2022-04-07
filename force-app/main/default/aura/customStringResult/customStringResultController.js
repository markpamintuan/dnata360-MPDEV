({
   selectRecord : function(component, event, helper){      
    // get the selected record from list  
      var getSelectRecord = component.get("v.StringName");
    // call the event   
      var compEvent = component.getEvent("oSelectedStringEvent");
    // set the Selected sObject Record to the event attribute.  
         compEvent.setParams({"stringEvent" : getSelectRecord });   
    // fire the event  
         compEvent.fire();
    },
})