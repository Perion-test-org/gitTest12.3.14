public with sharing class HNDL_Merchendise {
	
	/*
    *  Author: Gad Sharon Raviv
	*  Date: 24-01-2013
    *  Entry from: TRGR_Merchendise::after update
    *  Input:  trigger new + trigger Old Map - Merchandise__c.
    *  Output: - None -
    *  Description: When the unit price for a mrechendise decreases, we populate
    *				the change to all related line items in unclosed invoices. 
    */
    
    public static void updateNewPriceInLinItems (map <Id, Merchandise__c> triggerNewMap, map <Id, Merchandise__c> triggerOldMap)
    {
    	set <Id> set_ids = new set <Id>();
    	list <Line_Item__c> lst_lineItems = new list <Line_Item__c>();
    	
    	//Going through all merchendise in the trigger and check if their price decreased.
    	for (Merchandise__c curMer :triggerNewMap.values())
    	{
    		if (curMer.Price__c < triggerOldMap.get(curMer.Id).Price__c)
    			set_ids.add(curMer.Id);
    	}
    	
    	//Continue only if we found relevant merchendise.
    	if (!set_ids.isEmpty())
    	{
    		lst_lineItems = [Select l.Unit_Price__c, l.Merchandise__c, 
    								l.Invoice_Statement__r.Status__c, l.Invoice_Statement__c 
    						 From Line_Item__c l
    						 Where Merchandise__c in :set_ids
    						 And Invoice_Statement__r.Status__c != 'Closed'];
    						 
    		//Update the line items we found.
    		for (Line_Item__c curLI :lst_lineItems)
    		{
    			curLI.Unit_Price__c = triggerNewMap.get(curLI.Merchandise__c).Price__c;
    		}
    		
    		//Update the line items in the DB.
    		if (!lst_lineItems.isEmpty())
    			update lst_lineItems;
    	}
    }

}