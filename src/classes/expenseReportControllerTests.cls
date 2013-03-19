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
private with sharing class expenseReportControllerTests {

    static testMethod void emptyOrganizationTest() {
   		DataFixtures.ClearData();
   		
   		PageReference pageRef = Page.Expense_Report; 
   		Test.setCurrentPageReference(pageRef);
   		
   		expenseReportController erc = new expenseReportController(); 
		List<SelectOption> monthOptions = erc.getMonthOptions(); 
		
		System.assertEquals(13, monthOptions.size());
		
		erc.Month = Integer.valueOf(monthOptions[5].getValue());

		System.assertEquals(5, erc.Month);
		
		erc.loadReport();
		
		System.assertEquals(null, erc.DarkColor); 
    	System.assertEquals(null, erc.LightColor);
    	System.assertEquals(null, erc.CurrencyString);
    	System.assertEquals(null, erc.LogoId);
    

    	System.assertEquals('0.00', erc.getFormatedTotal());
    	
    	erc.getTaxTotals();
    	
    	System.assertEquals(0, erc.getItemExpenses().size());    	
   
   		erc.ItemExpenses = null; 
   		erc.getItemExpenses();
    	
    }
    
    
    
    static testMethod void configuredOrganizationTest() {
    	
   		DataFixtures.ClearData();
   		DataFixtures.LoadConfiguration1();
   		
   		PageReference pageRef = Page.Expense_Report; 
   		Test.setCurrentPageReference(pageRef);
   		
   		expenseReportController erc = new expenseReportController(); 
		List<SelectOption> monthOptions = erc.getMonthOptions(); 
		
		System.assertEquals(13, monthOptions.size());
		
		erc.Month = Integer.valueOf(monthOptions[2].getValue());

		System.assertEquals(2, erc.Month);
		
		erc.loadReport();
		
		System.assertEquals('000000', erc.DarkColor); 
    	System.assertEquals('FFFFFF', erc.LightColor);
    	System.assertEquals('Canadian', erc.CurrencyString);
    	System.assertNotEquals(null, erc.LogoId);
    
    	System.assertEquals('0.00', erc.getFormatedTotal());
    	System.assertEquals(0, erc.getItemExpenses().size());
    	
    	erc.getTaxTotals();   	
   
  		erc.ExpenseTypeWrappers[0].getFormatedSubtotal();
  		erc.ExpenseTypeWrappers[0].getFormatedTotal(); 

    	DataFixtures.LoadThisMonthEvents(10);	   	
    	erc.loadReport(); 
    	erc.getItemExpenses();

		pageRef.getParameters().put('month', String.valueOf(System.today().month()));
		erc = new expenseReportController();  
    	
    	erc.Month = System.today().addMonths(1).month();
    	erc.loadReport();
    	  	
    }
    
    
    static testMethod void sendPdfTest() {

		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		User u = [SELECT Id, Name FROM User WHERE ProfileId = :p.Id LIMIT 1];


   		DataFixtures.ClearData();
   		DataFixtures.LoadConfiguration1();
   		DataFixtures.LoadThisMonthEvents(20);
   		
   		PageReference pageRef = Page.Expense_Report; 
   		Test.setCurrentPageReference(pageRef);
   		
   		
   		Test.startTest();
   		expenseReportController erc = new expenseReportController(); 
		
		//Test with null user 
		erc.DeliverAsPDF(); 
		
		erc.UserHolder.OwnerId = u.Id;
		erc.Month = System.today().Month();
		erc.DeliverAsPDF();

		//Test last month
		erc.Month = System.today().addMonths(-1).month();
		erc.DeliverAsPDF();
		
		//Test next month
		erc.Month = System.today().addMonths(1).month();
		erc.DeliverAsPDF(); 
		
		erc.Month = 0;
		erc.DeliverAsPDF();
		
		Test.stopTest();
	
    }
    
  	static testMethod void classTests() {
    	
    	DataFixtures.ClearData();
   		DataFixtures.LoadConfiguration1();
    	DataFixtures.LoadThisMonthEvents(3);
   		
   		PageReference pageRef = Page.Expense_Report; 
   		Test.setCurrentPageReference(pageRef);
   	
   		Test.startTest();
   		expenseReportController erc = new expenseReportController(); 
   		erc.Month = System.today().month();
   		erc.loadReport();
   		
 		expenseReportController.ItemExpensesWrapper iew = new expenseReportController.ItemExpensesWrapper('Test');
 		System.assertEquals(0, iew.getExpenseWrappers().size());   		 	
   
 		expenseReportController.ExpenseWrapper ew = new expenseReportController.ExpenseWrapper(DataFixtures.thisMonthEvents[0], DataFixtures.thisMonthExpenses[0], 1); 
 		ew.getFormatedDate();
 		ew.getFormatedSubtotal();
 		ew.getFormatedTax();
 		ew.expense.Subtotal__c = null;
 		ew.expense.Tax_Total__c = null;
 		ew.getFormatedSubtotal(); 
 		ew.getFormatedTax();
    	
    	expenseReportController.EventExpenseWrapper eew = new expenseReportController.EventExpenseWrapper(DataFixtures.thisMonthEvents[0], erc.ExpenseTypeWrappers);
    	eew.ExpenseMap.put(erc.ExpenseTypeWrappers[0].expense_type.Id, new expenseReportController.ExpenseWrapper(DataFixtures.thisMonthEvents[0], DataFixtures.thisMonthExpenses[0], 1));
    
    	eew.getEventExpenses();
    	eew.getFormatedDate();
    
    
    	Test.stopTest();
    	
    }
    
    
    
}