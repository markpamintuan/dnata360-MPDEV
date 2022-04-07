({
	callToServer : function(component, method, callback, params) {
        //alert('Calling helper callToServer function');
		var action = component.get(method);
        if(params){
            action.setParams(params);
        }
        //alert(JSON.stringify(params));
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //alert('Processed successfully at server');
                callback.call(this,response.getReturnValue());
            }else if(state === "ERROR"){
                alert('Problem with connection. Please try again.');
            }
        });
		$A.enqueueAction(action);
    }
})