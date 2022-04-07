({
	removeTestStep : function(component, event, helper) {
        var compEvent = component.getEvent("removeAssigne");
        var id = component.get("v.index");
        var remId1 = component.get("v.test");
        var remId = remId1.Id;
        compEvent.setParams({"removedIndex": id, "removedId": remId});
		compEvent.fire();
	},
    checkboxSelect : function(component, event, helper) {
        // var selectedHeaderCheck1 = event.getSource().get("v.value");
        var parentCheckbox = component.get("v.checkBoxB");
        var childCheckbox = component.get("v.checkBox2");
       
        alert("------ parentCheckbox : " + parentCheckbox + ' ----- childCheckbox: ' + childCheckbox);
        
        var compEvent = component.getEvent("removeAssigne");
        var id = component.get("v.index");
        var remId1 = component.get("v.test");
        var remId = remId1.Id;
        compEvent.setParams({"removedIndex": id, "removedId": remId});
		//compEvent.fire();
        
    }
   /* checkboxSelect : function(component, event, helper) {
       	var selectedHeaderCheck1 = event.getSource().get("v.value");
        var selectedId = event.getSource().getLocalId();
        
        alert(selectedId);
       // var getAllId = component.find("chkBoxSel");
        if (selectedHeaderCheck1 == true) {
            //for (var i = 0; i < getAllId.length; i++) {
              component.find(selectedId).set("v.value", true);
              // component.set("v.parentCheckBox", true);
            
        } else {
            component.find(selectedId).set("v.value", false);
            //for (var i = 0; i < getAllId.length; i++) {
                //component.find("boxPack")[i].set("v.value", false);
               // component.set("v.selectedCount", 0);
               // 
              // component.set("v.parentCheckBox", false);
            
        }}*/
})