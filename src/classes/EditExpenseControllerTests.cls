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
private class EditExpenseControllerTests {

    static testMethod void emptyOrganizationTest() {
		DataFixtures.ClearData();

		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		User u = [SELECT Id, Name FROM User WHERE ProfileId = :p.Id LIMIT 1];
	
		Event e = new Event(OwnerId = u.Id, Subject = 'Test Event', StartDateTime = System.now(), EndDateTime = System.now().addHours(3));
		insert e; 

		Test.startTest(); 

		//Test going to the edit page without any expense types
		EditExpensesController eec = new EditExpensesController();
		
		//Added an expense type for the next tests
		Expense_Type__c et1 = new Expense_Type__c(Name = 'Meals', Entry_Type__c = 'Amount (eg. Meals)', Rate__c = 1); 
		insert et1;

		PageReference pageRef = Page.Edit_Expenses;
		pageRef.getParameters().put('id', e.Id);
		Test.setCurrentPageReference(pageRef);		
		
	 	eec = new EditExpensesController(); 
		
		System.assertEquals(1, eec.expenseList.size());
		
		eec.addExpense();
		
		System.assertEquals(2, eec.expenseList.size());
		
		
		eec.expenseList[0].expense.Amount__c = 100.0;
		eec.expenseList[1].expense.Amount__c = 200.0;
		
		eec.removeId = 0; 
		eec.removeExpense();
		
		System.assertEquals(1, eec.expenseList.size());
		System.assertEquals(200.0, eec.expenseList[0].expense.Amount__c);
				
		pageRef = Page.Edit_Expenses;
		pageRef.getParameters().put('id', '');
		Test.setCurrentPageReference(pageRef);		

		eec = new EditExpensesController();
		
		pageRef = Page.Edit_Expenses;
		Test.setCurrentPageReference(pageRef);		

		eec = new EditExpensesController();
		
		Test.stopTest();


    }
    
    
    static testMethod void configuredOrganizationTest() {
		DataFixtures.ClearData();
		DataFixtures.LoadConfiguration1(); 

		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		User u = [SELECT Id, Name FROM User WHERE ProfileId = :p.Id LIMIT 1];

		Event e = new Event(OwnerId = u.Id, Subject = 'Test Event', StartDateTime = System.now(), EndDateTime = System.now().addHours(3));
		insert e; 
		
		PageReference pageRef = Page.Edit_Expenses;
		pageRef.getParameters().put('id', e.Id);
		Test.setCurrentPageReference(pageRef);		

		Test.startTest(); 

		EditExpensesController eec = new EditExpensesController(); 
    	
		List<SelectOption> options = eec.getExpenseTypes();
		System.assertEquals(7, options.size());

		//add expenses 
		
		eec.addExpense();
		eec.addExpense();
		eec.addExpense();
		
		System.assertEquals(4, eec.expenseList.size());
		System.assertEquals(2, eec.expenseList[0].taxes.size());
		
		Integer index = 0; 
		for(EditExpensesController.ExpenseWrapper ew: eec.expenseList) {
			
			ew.expense.Expense_Type__c = DataFixtures.expense_types[index].Id;
			ew.expense.Amount__c = index * 100; 
			ew.taxes[Math.mod(index,2)].hasTax = true; 
			++index;
		}
		
		eec.calculateTaxes();
		eec.save(); 

		//load saved expenses
		
		eec = new EditExpensesController(); 
		System.assertEquals(4, eec.expenseList.size());

		//delete existing expense

		eec.removeId = 1;
		eec.removeExpense();

		eec.save(); 
		eec.cancel();

		Test.stopTest(); 

    }
    
    
}