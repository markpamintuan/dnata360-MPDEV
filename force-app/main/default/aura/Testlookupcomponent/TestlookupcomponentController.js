({
	myAction : function(component, event, helper) {
		console.log('doInit');
	},
    setValues : function(component,event){
        var name = event.getParam("selectedvalue");
     	var id = event.getParam("selectedId");
        console.log(name);
        component.find("emp").set("v.value",name);
        component.set("v.isLookup",false);
    },
    searchstring : function (component,event) {
  		var lookupView=component.find("emp").get("v.value");
        //alert(lookupView);
        component.set("v.searchstrp",lookupView);
        //alert(component.get("v.searchstrp"));
        
    },
})