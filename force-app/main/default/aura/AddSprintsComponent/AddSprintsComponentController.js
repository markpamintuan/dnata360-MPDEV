({
	addSprints : function(component, event, helper) {
            var action = component.get("c.createSprints");	
            action.setParams({
                numberOfSprints : component.get("v.sprintCount"),
            });
        
            action.setCallback(this, function(a) {
                if (a.getState() === "SUCCESS") {
					alert("Sprints/s successfully created!");
                    $A.get("e.force:closeQuickAction").fire();
                    var sprintListViewLink = $A.get("$Label.c.Sprint_List_View_Link");
                    window.open(sprintListViewLink,'_top');
                }
            });	

            $A.enqueueAction(action);		
	}
})