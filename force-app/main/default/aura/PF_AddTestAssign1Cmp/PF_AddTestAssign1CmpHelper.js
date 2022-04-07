({
	helperMethod1 : function(TCSteps) {
		var wrappers = new Array(); 
            for(var i=0;i<TCSteps.length;i++){
                var wrapper = {'TCStepRec':TCSteps[i],
                               'selected':false};
                wrappers.push(wrapper);            
            }	
	return wrappers;	
	}
})