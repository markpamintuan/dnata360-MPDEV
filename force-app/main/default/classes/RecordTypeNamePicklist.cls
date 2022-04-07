global class RecordTypeNamePicklist extends VisualEditor.DynamicPickList {
    global override VisualEditor.DataRow getDefaultvalue(){
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('None','None');
        return defaultValue;
    }
    global override VisualEditor.DynamicPickListRows getValues(){
        VisualEditor.DataRow defaultValue = getDefaultValue();
        List<RecordType> recordTypeList = [Select Id,Name from RecordType where sObjectType = 'Case' and (Name LIKE '%Enquiry%' OR Name Like '%Booking Enquiry%')];
        VisualEditor.DynamicPicklistRows recordTypes = new VisualEditor.DynamicPicklistRows();
        recordTypes.addRow(defaultValue);
        for(RecordType rec: recordTypeList){
            VisualEditor.DataRow value = new VisualEditor.DataRow(rec.Name,string.valueof(rec.Id));
            recordTypes.addRow(value);
            
        }
        return recordTypes;
    }
}