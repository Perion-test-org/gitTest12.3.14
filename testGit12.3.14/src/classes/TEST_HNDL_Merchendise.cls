/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TEST_HNDL_Merchendise {

    static testMethod void test_updateNewPriceInLinItems() 
    {
    	//Creating data.
    	Merchandise__c tmpMer = HLPR_RecordCreator.createMerchendise();
    	insert tmpMer;
    	
    	Invoice_Statement__c tmpInv = HLPR_RecordCreator.createInvoice();
    	insert tmpInv;
    	
    	Line_Item__c tmpLI = HLPR_RecordCreator.createLineItem(tmpMer.Id, tmpInv.Id);
    	insert tmpLI;
    	
    	//Scenario 1 - Decreasing the price of the merchendise.
    	tmpMer.Price__c = 1;
    	update tmpMer;
    	
    	//Getting the line item from the DB.
    	Line_Item__c LIFromDB = [select Unit_Price__c from Line_Item__c where Id = :tmpLI.Id limit 1];
    	
    	//Checking with system assert that we get the desired price in the line item.
    	system.assertEquals(1, LIFromDB.Unit_Price__c);
    }
}