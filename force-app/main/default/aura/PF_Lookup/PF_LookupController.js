({
	 doInit : function(component, event, helper){
        helper.doInit(component);
    },
    populatevalue : function(component, event, helper){
      	var selectedName = event.getSource().get("v.value"); 
     	var selectedId = event.getSource().get("v.title");
        var oName = component.get("v.objName");
        console.log(selectedName +' :'+ selectedId);
        var compEvent = component.getEvent("PF_LookupEvent");
        compEvent.setParams({"selectedvalue" : selectedName});
    	compEvent.setParams({"selectedId" : selectedId});
        compEvent.setParams({"selectedField" : oName});
        //compEvent.setParams({"handled" : false});
		compEvent.fire();
        //var cmp = component.find("lookupcard");
        //$A.util.removeClass(cmp, 'tabshow');
        //$A.util.addClass(cmp, 'tabhide'); 
        
    },
})