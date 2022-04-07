({
    doInit: function(component, event, helper) {
        debugger;
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getAllTabInfo().then(function(response) {
            console.log(response);
        })
        .catch(function(error) {
            console.log(error);
        });

        // Prepare a new record from template
        component.find("contactRecordCreator").getNewRecord(
            "Contact", // sObject type (entityAPIName)
            null,      // recordTypeId
            false,     // skip cache?
            $A.getCallback(function() {
                var rec = component.get("v.newContact");
                var error = component.get("v.newContactError");
                if(error || (rec === null)) {
                    console.log("Error initializing record template: " + error);
                }
                else {
                    console.log("Record template initialized: " + rec.sobjectType);
                }
            })
        );
    },
    handleSaveContact: function(component, event, helper) {
        if(helper.validateContactForm(component)) {
            component.set("v.simpleNewContact.AccountId", component.get("v.recordId"));
            component.find("contactRecordCreator").saveRecord(function(saveResult) {
                var newExamID = '';

                if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                    newExamID = saveResult.recordId;
                    console.log('newExamID::' + newExamID);
                    console.log('saveResult::' + JSON.stringify(saveResult));

                    var workspaceAPI = component.find("workspace");
                    workspaceAPI.getFocusedTabInfo().then(function(response) {
                        workspaceAPI.openSubtab({
                            parentTabId: response.tabId,
                            //recordId: newExamID,
                            url: 'http://www.google.ie',
                            //url: '#/apex/Quote?Id=a0C0E000001TJpmUAG',
                            focus: true
                        });

                       //  workspaceAPI.getAllTabInfo().then(function(response) {
                       //      console.log(response);
                       //      console.log(JSON.stringify(response));
                             $A.get("e.force:closeQuickAction").fire();
                       // })
                       //  .catch(function(error) {
                       //      console.log(error);
                       //  });

                        
                    })
                    .catch(function(error) {
                        console.log(error);
                    });
                




                    // record is saved successfully
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "title": "Saved",
                        "message": "The record was saved."
                    });
                    resultsToast.fire();
                } else if (saveResult.state === "INCOMPLETE") {
                    // handle the incomplete state
                    console.log("User is offline, device doesn't support drafts.");
                } else if (saveResult.state === "ERROR") {
                    // handle the error state
                    console.log('Problem saving contact, error: ' + 
                                 JSON.stringify(saveResult.error));
                } else {
                    console.log('Unknown problem, state: ' + saveResult.state +
                                ', error: ' + JSON.stringify(saveResult.error));
                }
            });



        }


    },

    getOpenedTabInfo : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
            workspaceAPI.getTabInfo({
                tabId: response
            }).then(function(response) {
                console.log(response);
        }).catch(function(error) {
            console.log(error);
        });
    }
})