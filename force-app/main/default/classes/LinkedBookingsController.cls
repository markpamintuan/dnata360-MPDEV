/**************************************************************************************************
* Name               : LinkedBookingsController 
* Description        : This is a controller used for lightning components        
* Created Date       : 09-July-2018                                                                 
* Created By         : Sri Bala                                                    
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR           DATE           COMMENTS                
* v1.0        Sri Bala         09-July-2019   Initial version                                                        
**************************************************************************************************/

public class LinkedBookingsController {
    @AuraEnabled
    public static List<Booking__c> getAllBookingsRelatedToCase(String caseID){
        system.debug('case ID'+caseID);
        List<Booking__c> lOpenBookingHeader = new List<Booking__c>();
        Case cse = new Case();
        Booking__c booking =new Booking__c();
        Id recordId = Id.valueof(caseId);
        String sObjName = recordId.getSObjectType().getDescribe().getName();
        system.debug('Object Name '+sObjName);
        if(sObjName == 'Case'){
            cse = [Select CaseNumber,Id,Org_Booking__c,Org_Booking__r.Org_Booking_Ref__c,Org_Booking__r.Booking_Header__c,Org_Booking__r.RecordType.Name from Case where id =: caseID];
            system.debug('cse @@@@'+cse);
             if(cse.Org_Booking__c != null){
            if(cse.Org_Booking__r.RecordType.Name == 'Booking Header'){
               
                for(Booking__c book : [SELECT Id,Product_Type__c,Org_Travel_End_Date__c,Org_Date_To__c, Org_Title__c, Org_Date_From__c,
                                       Org_Account_Name__c,Org_BookedById__c,Org_BookedByName__c, Org_Travel_Start_Date__c,
                                       Org_Booked_Date__c,Booking_ID__c,Org_Booking_Ref__c,
                                       Booking_Status__c,Org_Booking_Type__c,Org_Brand__c,Booking_Header__c,
                                       CreatedDate,Name,Opportunity__c,Owner.Name,
                                       Destination__c,Departure_Date__c, 
                                       (SELECT Id, 
                                        Org_Booking_Type__c,
                                        Org_Title__c,
                                        Name
                                        FROM Bookings__r )
                                       FROM Booking__c 
                                       WHERE Booking_Header__c =: cse.Org_Booking__c  AND
                                       Booking_Status__c IN ('Active', 'Pending','Receipted')
                                      ]) {            
                                          lOpenBookingHeader.add(book); 
                                      }
                system.debug('lOpenBookingHeader'+lOpenBookingHeader);
            }
             else{
                 for(Booking__c book : [SELECT Id,Product_Type__c,Org_Travel_End_Date__c,Org_Date_To__c, Org_Title__c, Org_Date_From__c,
                                       Org_Account_Name__c,Org_BookedById__c,Org_BookedByName__c, Org_Travel_Start_Date__c,
                                       Org_Booked_Date__c,Booking_ID__c,Org_Booking_Ref__c,
                                       Booking_Status__c,Org_Booking_Type__c,Org_Brand__c,Booking_Header__c,
                                       CreatedDate,Name,Opportunity__c,Owner.Name,
                                       Destination__c,Departure_Date__c, 
                                       (SELECT Id, 
                                        Org_Booking_Type__c,
                                        Org_Title__c,
                                        Name
                                        FROM Bookings__r)
                                       FROM Booking__c 
                                       WHERE Booking_Header__c =: cse.Org_Booking__r.Booking_Header__c AND
                                       Booking_Status__c IN ('Active', 'Pending','Receipted')
                                      ]){              
                                          lOpenBookingHeader.add(book);  
                                      }
            }
             }
         
        }
        
        else if(sObjName == 'Booking__c'){
            booking = [Select Id,Booking_Header__c,RecordType.Name from Booking__c where id=:caseId];
            system.debug('Booking '+booking);
            system.debug('case @@'+cse);
            if(booking.RecordType.Name == 'Booking'){
                for(Booking__c book : [SELECT Id,Product_Type__c,Org_Travel_End_Date__c,Org_Date_To__c, Org_Title__c, Org_Date_From__c,
                                       Org_Account_Name__c,Org_BookedById__c,Org_BookedByName__c, Org_Travel_Start_Date__c,
                                       Org_Booked_Date__c,Booking_ID__c,Org_Booking_Ref__c,
                                       Booking_Status__c,Org_Booking_Type__c,Org_Brand__c,Booking_Header__c,
                                       CreatedDate,Name,Opportunity__c,Owner.Name,
                                       Destination__c,Departure_Date__c, 
                                       (SELECT Id, 
                                        Org_Booking_Type__c,
                                        Org_Title__c,
                                        Name
                                        FROM Bookings__r)
                                       FROM Booking__c 
                                       WHERE Booking_Header__c =: booking.Booking_Header__c  AND
                                       Booking_Status__c IN ('Active', 'Pending','Receipted')
                                      ]){              
                                          lOpenBookingHeader.add(book);  
                                      }
                
            }
            else{
                 for(Booking__c book : [SELECT Id,Product_Type__c,Org_Travel_End_Date__c,Org_Date_To__c, Org_Title__c, Org_Date_From__c,
                                       Org_Account_Name__c,Org_BookedById__c,Org_BookedByName__c, Org_Travel_Start_Date__c,
                                       Org_Booked_Date__c,Booking_ID__c,Org_Booking_Ref__c,
                                       Booking_Status__c,Org_Booking_Type__c,Org_Brand__c,Booking_Header__c,
                                       CreatedDate,Name,Opportunity__c,Owner.Name,
                                       Destination__c,Departure_Date__c, 
                                       (SELECT Id, 
                                        Org_Booking_Type__c,
                                        Org_Title__c,
                                        Name
                                        FROM Bookings__r)
                                       FROM Booking__c 
                                       WHERE Booking_Header__c =: booking.ID  AND
                                       Booking_Status__c IN ('Active', 'Pending','Receipted')
                                      ]){              
                                          lOpenBookingHeader.add(book);  
                                      }
            }
            
          
        }
        system.debug('#### lOpenBookingHeader: ' + lOpenBookingHeader);
        return lOpenBookingHeader;
    }
}