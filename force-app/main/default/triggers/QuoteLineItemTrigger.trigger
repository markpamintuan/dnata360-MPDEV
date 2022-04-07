trigger QuoteLineItemTrigger on Quote_Line_Item__c (after insert, after update) {
    
    //As soon as a Quote Line Item is inserted, create Quote Product & Quote Product Segments records 
    //These are the objects which store the data from dnata's Quote page and derwent db
    if(trigger.isafter && trigger.isInsert ){
        QuoteLineItemTriggerHandler.insertQuoteProduct(trigger.new);
    }
}