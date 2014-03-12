trigger TRGR_Merchendise on Merchandise__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
	
	if (trigger.isAfter && trigger.isUpdate)
	{
		HNDL_Merchendise.updateNewPriceInLinItems(trigger.NewMap, trigger.OldMap);
	}

}