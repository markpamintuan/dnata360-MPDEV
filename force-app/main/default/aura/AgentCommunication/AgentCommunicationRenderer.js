({
    render : function(component, helper) {
        console.log("---entry in render---");
        var ret = this.superRender();
        //component.set("v.welcomeMsg",component.get("v.welcomeMsg")+"To ");
        return ret;
    },
 
    afterRender : function(component, helper){
        console.log("---entry in afterRender---");
        this.superAfterRender();
       	//component.find('scrollerTop').scrollTo("bottom",0,0);
    },
 
    rerender : function(component, helper){ 
        console.log("---entry in rerender---");        
        this.superRerender();
        component.find('scrollerTop').scrollTo("bottom",0,0);        
    },
 
     
})