public with sharing class HLPR_RecordCreator {
	
	public static Merchandise__c createMerchendise ()
	{
		Merchandise__c mer = new Merchandise__c();
		mer.Name = 'Test Merchandise';
		mer.Price__c = 100;
		mer.Total_Inventory__c = 1000;
		mer.Description__c = 'Test Merchandise Description';
		
		return mer;
	}
	
	public static Invoice_Statement__c createInvoice ()
	{
		Invoice_Statement__c inv = new Invoice_Statement__c();
		
		return inv;
	}
	
	public static Line_Item__c createLineItem (Id merchendiseId, Id invoiceId)
	{
		Line_Item__c li = new Line_Item__c();
		li.Invoice_Statement__c = invoiceId;
		li.Merchandise__c = merchendiseId;
		li.Name = 'Test LI';
		li.Units_Sold__c = 1;
		
		return li;
	}

}