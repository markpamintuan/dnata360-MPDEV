/*Purpose: Controller for PF_CloneTestCasewithChild page to clone current Test Case with its selected related Test Case Assignment and Test Case steps */
public with sharing class PF_CloneTestCasewithChildController {
    
    private Id parentRecordId {get;set;}
    public String parentObjName {get;set;}
    public String parentObjLabel {get;set;}
    public String parentRecordName {get; set;}
    public PF_TestCases__c testCaseRecord {get;set;}
    public Boolean isSelected{get; set;}
    public List<childObjectWrapper> childObjectList {get;set;}
    public List<childObjectWrapper> selectedChildWrapperList {get;set;}
    public Integer testCaseStepSize {get; set;}
    public Integer testCaseAssignmentSize {get; set;}
    private ApexPages.StandardController controller {get; set;}
    public Boolean displaySuccessMessage {get; set;}  
    public Id clonedParentId {get; set;} 
    public boolean isHavingPermission {get;set;}
     
    public PF_CloneTestCasewithChildController(ApexPages.StandardController controller) {
 
        this.controller = controller;
        testCaseRecord = (PF_TestCases__c)controller.getRecord();
        childObjectList = new List<childObjectWrapper>();
        selectedChildWrapperList = new List<childObjectWrapper>();
        //returns the parent Object Name from the Id passed as a URL parameter
        //parentRecordId = ApexPages.currentPage().getParameters().get('Id');
        parentRecordId = testCaseRecord.Id;
        list<PF_TestCases__c> parentName = [select Name from PF_TestCases__c where Id =:parentRecordId];
        parentRecordName = parentName[0].Name;
        parentObjName = PF_Utility.getObjectNameFromId(parentRecordId);
        parentObjLabel = PF_Utility.getObjectLabelFromId(parentRecordId);
        List<Schema.ChildRelationship> childObjList = PF_Utility.getChildRelationshipsFromId(parentRecordId);
        for(Schema.ChildRelationship childObj : childObjList){
            system.debug('Child object List inside For - '+childObj.getChildSObject().getDescribe().getName());
            if(childObj.getChildSObject().getDescribe().isQueryable() && (childObj.getChildSObject().getDescribe().getName() == 'PF_TestCaseExecution__c' || childObj.getChildSObject().getDescribe().getName() == 'PF_Test_Case_Step__c')){
                if(childObj.getField().getDescribe().isCreateable())
                    childObjectList.add(new childObjectWrapper(childObj.getChildSObject().getDescribe().getLabel(), childObj.getChildSObject().getDescribe().getName(),false,parentRecordId,String.valueOf(childObj.getField())));
            	system.debug('Final childObjectList - '+childObjectList);
            }
        }

        testCaseStepSize = [select count() from PF_Test_Case_Step__c where PF_Test_Case__c =:parentRecordId];
        //testCaseStepSize = testCaseStepList.size();
        testCaseAssignmentSize = [select count() from PF_TestCaseExecution__c where PF_Test_Case__c =:parentRecordId];
        //testCaseAssignmentSize = testCaseAssignmentList.size();
        displaySuccessMessage = false;
        isHavingPermission = true;
        checkPermssion();
    }
    
    //called on click of Cancel button; redirects the user back to the origination screen
    public PageReference cancel(){
        return new PageReference('/'+parentRecordId);
    }
    
    //called when Select All checkbox is checked/unchecked
    public PageReference checkSelectAll(){
        system.debug('Check if selected'+isSelected);
        for(childObjectWrapper chldObj : childObjectList){
            if(isSelected){
                chldObj.isSelected = true;
            }else{
                chldObj.isSelected = false;
            }
        }
        return null;
    }
    
    public void showSuccessMessage() {        
        displaySuccessMessage = true;  
        cloneParentwithSelectedChild();  
    }
    
    //called on click of Clone button, clones parent and its selected child records 
    public PageReference cloneParentwithSelectedChild(){
        for(childObjectWrapper chldObj : childObjectList){
            if(chldObj.isSelected){
                selectedChildWrapperList.add(chldObj);
            }
        }
        //clone parent object record
        List<sObject> clonedParentObj = PF_Utility.cloneObject(parentObjName, parentRecordId, true, null, null);
        system.debug('Cloned Parent - '+clonedParentObj[0].get('PF_Status__c'));
        //clonedParentObj[0].put('PF_Status__c', 'New');
        //insert clonedParentObj;
        for(sObject clonedPrnt: clonedParentObj){
            clonedPrnt.put('Name', parentRecordName);
            clonedPrnt.put('PF_Status__c', 'New');
        }
        system.debug('Cloned Parent after update- '+clonedParentObj[0].get('PF_Status__c'));
        insert clonedParentObj;
        
        //clone child records
        List<sObject> childObjList = new List<sObject>();
        if(selectedChildWrapperList.size() > 0){
            for(childObjectWrapper selectedObj : selectedChildWrapperList){
                List<sObject> clonedChildObj = PF_Utility.cloneObject(selectedObj.objName, selectedObj.childRecordId, false, selectedObj.parentLookUpField, clonedParentObj.get(0).Id);
                system.debug('CHILD OBJECT LIST - '+clonedChildObj);
                //system.debug('Cloned Child - '+clonedChildObj[0].get('PF_Status__c'));
                for(sObject clChild: clonedChildObj){
                    if(clChild.getSObjectType() == Schema.getGlobalDescribe().get('PF_TestCaseExecution__c')){
                        clChild.put('PF_Status__c', 'Not Started');
                        clChild.put('PF_Target_Completion_Date__c',PF_Utility.addBusinessDays(Date.today(),5));
                        clChild.put('PF_Date_Passed__c',null);
                        clChild.put('PF_Test_Data_Notes__c',null);
                        clChild.put('PF_Test_Execution_Notes__c',null);
                        
                    }
                }
                if(clonedChildObj.size() > 0){
                    childObjList.addAll(clonedChildObj);
                }
            }
        }
        
        system.debug('Final Child Object List - '+childObjList);
        Database.insert(childObjList,false);
        clonedParentId = clonedParentObj.get(0).Id;
        Apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.CONFIRM,'Test Case ' + parentRecordName + ' created.');
        Apexpages.addmessage(msg);
        PageReference pgRef = new PageReference('/'+clonedParentObj.get(0).Id);
        //pgRef.setRedirect(true);
        if(displaySuccessMessage){
            return null;
        }else{
            return pgRef;
        }
        
    }
    
    public void checkPermssion(){
        Id userId = UserInfo.getUserId();
        PermissionSetAssignment[] psRec = [select PermissionSet.Name from PermissionSetAssignment where Assignee.Id =:userId AND PermissionSet.Name = 'PF_ProjectForce_Read_Only' order by PermissionSet.Name];
        system.debug('psRec' +psRec.size());
        if(psRec.size() > 0){
            isHavingPermission = false;
        }  
    }
    
    
    public PageReference redirectToClonedRecord(){
        PageReference pgRef = new PageReference('/'+clonedParentId);
        return pgRef;
    }
    
    
    //wrapper class to hold the value of related child records
    public class childObjectWrapper{
        
        public String objLabel {get;set;}
        public String objName {get;set;}
        public boolean isSelected {get;set;}
        public String childRecordId {get;set;}
        public String parentLookUpField {get;set;}
        
        public childObjectWrapper(String objLabel, String objName, Boolean isSelected,String childRecordId, String parentLookUpField){
            this.objLabel = objLabel;
            this.objName = objName;
            this.isSelected = isSelected;
            this.childRecordId = childRecordId;
            this.parentLookUpField = parentLookUpField;
        }
        
    }
    
    
    
    
    
}