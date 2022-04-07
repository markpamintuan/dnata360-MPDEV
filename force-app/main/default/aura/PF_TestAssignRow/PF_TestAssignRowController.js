({
    doInit : function(component, event, helper) {
        var test = component.get("v.test");
 		var pStatus = component.find("PF_status");
        var pStatusVal = component.find("PF_status").get("v.value");
        
        if(pStatusVal == 'Passed')
            $A.util.addClass(pStatus,'Passed');
        else if(pStatusVal == 'failed')
            $A.util.addClass(pStatus,'failed');
        else(pStatusVal == 'Not Started')
        	$A.util.addClass(pStatus,'otherstatus');
        
        if(!test.PF_Assigned_To__c == '')
        	{ 
            console.log(test);
        	var searchname = '' + test.PF_Assigned_To__r.Name;
        	console.log(searchname);
        	component.set("v.searchtext", searchname);
        	}
    },
	removeAssigne : function(component, event, helper) {
        console.log('----- entered removeAssignee method');
        var compEvent = component.getEvent("removeAssigne");
        var id = component.get("v.index");
        var remId1 = component.get("v.test");
        console.log(id+"Deleted Id---remId1",remId1);
        var remId = remId1.Id;
        console.log("Deleted Id---",remId);
        console.log("Deleted Id",id);
        compEvent.setParams({"removedIndex": id, "removedId": remId});
		compEvent.fire();
	},
    setValues : function(component,event){
        var name = event.getParam("selectedvalue");
     	var id = event.getParam("selectedId");
        console.log(name);
        component.find("emp").set("v.value",name);
         console.log("Deleted Id",id);
        component.set("v.test.PF_Assigned_To__c",id);
         console.log("Deleted Id",id);
        component.set("v.isLookup",false);
        
    },
    searchstring : function (component,event) {
        console.log('----- Entered searchstring');     
  		var lookupView=component.find("emp").get("v.value");
        //alert(lookupView);
        component.set("v.searchstrp",lookupView);
        //alert(component.get("v.searchstrp"));
        
    }
})