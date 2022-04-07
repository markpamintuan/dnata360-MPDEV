({
	handleEvent : function(component, event, helper) {
        debugger;
        var eventType = event.getParam("message");         
        if(eventType == 'refreshlinkedrecords'){
            var childComponent = component.find('linkedrecord');
        	childComponent.refresh('refreshlinkedrecords');
        }
        
        /**
        else if(eventType == 'refreshpossiblerecords'){           
            var childComponent = component.find('possiblematch');
        	childComponent.refresh('refreshpossiblerecords');            
        } 
        ***/
    }
})