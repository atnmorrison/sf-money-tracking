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
private class eventViewControllerTests {

    static testMethod void eventViewTest() {
       
   		DataFixtures.ClearData();
   		DataFixtures.LoadConfiguration1();


		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		User u = [SELECT Id, Name FROM User WHERE ProfileId = :p.Id LIMIT 1];
	
		Event e = new Event(OwnerId = u.Id, Subject = 'Test Event', StartDateTime = System.now(), EndDateTime = System.now().addHours(3));
		insert e; 

		PageReference pageRef = Page.View_Expenses; 
       	Test.setCurrentPageReference(pageRef);
       
       	Test.startTest();
       	
       	//Test without any events
       	
       	eventViewController evc = new eventViewController(new ApexPages.StandardController(e)); 
       	
       	//Test with an entered event;
       	
       	Expense_Group__c eg = new Expense_Group__c(EventId__c = e.Id);
       	insert eg; 
       	
       	Expense__c e1 = new Expense__c(Expense_Group__c= eg.Id, Expense_Type__c = DataFixtures.expense_types[1].Id, Amount__c = 200, Subtotal__c = 200, Tax_Total__c = 50, Total__c = 250, Comment__c = 'test'); 
       	insert e1; 
       	
       	evc = new eventViewController(new ApexPages.StandardController(e));
       	evc.getEventGroupId();
      
       	
       	Test.stopTest(); 
       
    }
}