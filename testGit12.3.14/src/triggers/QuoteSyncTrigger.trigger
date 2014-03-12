trigger QuoteSyncTrigger on Quote (after insert, after update) {
    
    //Check if the trigger alreay run. If not, continue.
    if (TriggerStopper.stopQuote) return;
    
    //Set stop quote to true so the trigger won't run twice in the same transaction.
    TriggerStopper.stopQuote = true;
    
    //Get all the required fields from quote that needs to be synced to the opp.
    Set<String> quoteFields = QuoteSyncUtil.getQuoteFields();
    
    //Get all of the opp fields we need to update when syncing quote.
    List<String> oppFields = QuoteSyncUtil.getOppFields();
    
    //Get all quote sync fields to a string.
    String quote_fields = QuoteSyncUtil.getQuoteFieldsString();
    
    //Get all opp sync fields to a string.
    String opp_fields = QuoteSyncUtil.getOppFieldsString();

    Map<Id, Id> startSyncQuoteMap = new Map<Id, Id>();
    String quoteIds = '';
    
    //Go through all quotes in the trigger.
    for (Quote quote : trigger.new) {
    	//If the quote was not synced before but now we sync it
        if (quote.isSyncing && !trigger.oldMap.get(quote.Id).isSyncing) {
        	//add the quote id and the related opp to a map.
            startSyncQuoteMap.put(quote.Id, quote.OpportunityId);
        }
        
        //add the quote Id to string of quote ids in the DB.
        if (quoteIds != '') quoteIds += ', ';
        quoteIds += '\'' + quote.Id + '\'';
    }
    
    //Create the sql query using the quote fields and the quote ids.
    String quoteQuery = 'select Id, OpportunityId, isSyncing' + quote_fields + ' from Quote where Id in (' + quoteIds + ')';
    //System.debug(quoteQuery);
    
    //Get all quotes from the DB. 
    List<Quote> quotes = Database.query(quoteQuery);
    
    String oppIds = '';    
    Map<Id, Quote> quoteMap = new Map<Id, Quote>();
    
    //Go through all the quotes form the DB.
    for (Quote quote : quotes) {
    	//If it's insert or the current quote is synced quote.
        if (trigger.isInsert || (trigger.isUpdate && quote.isSyncing)) {
        	//Put the opp Id of the quote and the quote record in a map.
            quoteMap.put(quote.OpportunityId, quote);
            
            //Add the opp id to string of opp ids.
            if (oppIds != '') oppIds += ', ';
            oppIds += '\'' + quote.opportunityId + '\'';            
        }
    }
    
    //Continue only if it's insert of quotes or there are synced quotes in the trigger. 
    if (oppIds != '') {
    	
    	//Create the sql query for the opps related to the quotes in the trigger.
        String oppQuery = 'select Id, HasOpportunityLineItem' + opp_fields + ' from Opportunity where Id in (' + oppIds + ')';
        //System.debug(oppQuery);     
    	
    	//Get relevant opps from the DB.
        List<Opportunity> opps = Database.query(oppQuery);
        
        List<Opportunity> updateOpps = new List<Opportunity>();
        List<Quote> updateQuotes = new List<Quote>();        
        
        //Go through the opps we found in the DB.
        for (Opportunity opp : opps) {
        	
        	//Get the quote related to this opp only in insert or update + synced quote.
            Quote quote = quoteMap.get(opp.Id);
            
            // store the new quote Id if corresponding opportunity has line items
            if (trigger.isInsert && opp.HasOpportunityLineItem) {
            	//If it's insert of quotes and the related opp already have line items, add the quote id to set of quotes ids.
                QuoteSyncUtil.addNewQuoteId(quote.Id);
            }
            
            boolean hasChange = false;
            //Go through all of the quote fields that needs to be synced to the opportunity.
            for (String quoteField : quoteFields) {
            	//Get the opp field mapped to the current quote field.
                String oppField = QuoteSyncUtil.getQuoteFieldMapTo(quoteField);
                
                //Get the values of the quote and opp fields.
                Object oppValue = opp.get(oppField);
                Object quoteValue = quote.get(quoteField);
                
                //If the values between the quote and opp are different.
                if (oppValue != quoteValue) {                   
                	
                	//If it's insert and the quote value is null
                    if (trigger.isInsert && quoteValue == null) {
                    	//put the value from the opp in the quote and set boolean to true.
                        quote.put(quoteField, oppValue);
                        hasChange = true;
                        //If it's update.                        
                    } else if (trigger.isUpdate) {
                    	//If there's no value in the quote field, set the opp field to null.
                        if (quoteValue == null) opp.put(oppField, null);
                        //else, put the value from the quote field in the opp field
                        else opp.put(oppField, quoteValue);
                        //set the boolean to true.
                        hasChange = true;                          
                    }                    
                }                     
            }    
            //If we set the boolean to true.
            if (hasChange) {
            	//If it's insert, add the quote to the list of quotes to update.
                if (trigger.isInsert) { 
                    updateQuotes.add(quote);
                    //Else if it's update, add the opp to the list of opps to update.
                } else if (trigger.isUpdate) {
                    updateOpps.add(opp);                
                }               
            }                                  
        } 
   
        if (trigger.isInsert) {
            Database.update(updateQuotes);
        } else if (trigger.isUpdate) {
            TriggerStopper.stopOpp = true;            
            Database.update(updateOpps);
            TriggerStopper.stopOpp = false;              
        }    
    }
       
    TriggerStopper.stopQuote = false; 
}