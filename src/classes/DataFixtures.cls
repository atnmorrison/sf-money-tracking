public class DataFixtures {

	public static Expense_Type__c[] expense_types;
	public static Map<String, Expense_Type__c> expense_type_map;
	public static Expense_Tax_Type__c[] tax_types;
	public static Expense_Config__c[] configs; 
	public static Event[] lastMonthEvents;
	public static Event[] thisMonthEvents;
	public static Event[] nextMonthEvents;
	public static Expense__c[] thisMonthExpenses;  

	public static void ClearData() {
		
		Expense__c[] expenses = [SELECT Id FROM Expense__c];
		Expense_Tax__c[] expense_tax = [SELECT Id FROM Expense_Tax__c];
		
		Expense_Type__c[] types = [SELECT Id FROM Expense_Type__c]; 
	    Expense_Tax_Type__c[] taxtypes = [SELECT Id FROM Expense_Tax_Type__c]; 
		Expense_Group__c[] groups = [SELECT Id FROM Expense_Group__c];
		Expense_Config__c[] config = [SELECT Id FROM Expense_Config__c];
		
		delete expenses;
		delete expense_tax;
		delete groups;
		delete taxtypes;
		delete types;
		delete config; 
		 
	}


	public static void LoadConfiguration1() {
		
		Document Logo = new Document(Name = 'Logo', FolderId = UserInfo.getUserId());
		insert Logo; 
		
		//Create configuration 
		Expense_Config__c ec1 = new Expense_Config__c(Name = 'Dark Color', Value__c = '000000');
		Expense_Config__c ec2 = new Expense_Config__c(Name = 'Light Color', Value__c = 'FFFFFF');
		Expense_Config__c ec3 = new Expense_Config__c(Name = 'Currency', Value__c = 'Canadian');
		Expense_Config__c ec4 = new Expense_Config__c(Name = 'Logo', Value__c = Logo.Id);
	
		configs = new List<Expense_Config__c>{ec1, ec2, ec3, ec4}; 
		insert configs;
	
		//Create expense types
		Expense_Type__c et1 = new Expense_Type__c(Name = 'Meals', Entry_Type__c = 'Amount', Rate__c = 1, Has_Tax__c = true);
		Expense_Type__c et2 = new Expense_Type__c(Name = 'Hotels', Entry_Type__c = 'Amount', Rate__c = 1, Has_Tax__c = true);	
		Expense_Type__c et3 = new Expense_Type__c(Name = 'Parking', Entry_Type__c = 'Amount', Rate__c = 1, Has_Tax__c = true);
		Expense_Type__c et4 = new Expense_Type__c(Name = 'Rental Car/Fuel', Entry_Type__c = 'Amount', Rate__c = 1, Has_Tax__c = true);
		Expense_Type__c et5 = new Expense_Type__c(Name = 'Mileage', Entry_Type__c = 'Quantity', Rate__c = 0.5, Log__c = true);
		Expense_Type__c et6 = new Expense_Type__c(Name = 'Log Test', Entry_Type__c = 'Quantity', Rate__c = 0.75, Log__c = true);
	
		expense_types = new List<Expense_Type__c>{et1, et2, et3, et4, et5, et6};
		insert expense_types; 
	
	
		//Create tax types		
		Expense_Tax_Type__c ett1 = new Expense_Tax_Type__c(Name = 'GST', Rate__c = 0.05);
		Expense_Tax_Type__c ett2 = new Expense_Tax_Type__c(Name = 'PST', Rate__c = 0.08); 
	
		tax_types = new list<Expense_Tax_Type__c>{ett1, ett2};
		insert tax_types;
		
		expense_type_map = new Map<String, Expense_Type__c>();
		
		for(Expense_Type__c et: expense_types){
			expense_type_map.put(et.Name, et);
		}
	}


	public static void LoadThisMonthEvents(Integer amount) {
		
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		User u = [SELECT Id, Name FROM User WHERE ProfileId = :p.Id LIMIT 1];
		Opportunity o = new Opportunity(Name = 'Test Op', CloseDate = System.today().addMonths(3), StageName ='Prospecting');
		insert o; 
				
		thisMonthEvents = new List<Event>(); 
		
		for(Integer i=0; i<amount; ++i) {
			DateTime startTime = DateTime.newInstance(System.now().year(), System.now().month(), Math.mod(i,30));
			Date ad = Date.newInstance(System.now().year(), System.now().month(), Math.mod(i,30));
			
			if(Math.mod(i, 2) == 1) {
				thisMonthEvents.add(new Event(OwnerId = u.Id, Subject = 'Test Event', ActivityDate = ad, StartDateTime = startTime, EndDateTime = startTime.addHours(3)));
			} else {
				thisMonthEvents.add(new Event(OwnerId = u.Id, WhatId = o.Id, Subject = 'Test Event', ActivityDate = ad, StartDateTime = startTime, EndDateTime = startTime.addHours(3)));
			}
		}
	
		insert thisMonthEvents; 
		
		Expense_Group__c[] groups = new List<Expense_Group__c>(); 
		
		for(Event e: thisMonthEvents) {
			groups.add(new Expense_Group__c(EventId__c = e.Id, ActivityDate__c = e.ActivityDate));
		}
		
		insert groups;
		
		thisMonthExpenses = new List<Expense__c>();
		for(Expense_Group__c g: groups) {
			Integer number_expenses = Math.round(Math.random()*expense_types.size()); 
						
			for(Integer i=0; i<number_expenses; ++i) {
				thisMonthExpenses.add(new Expense__c(Expense_Group__c= g.Id, Expense_Type__c = expense_types[i].Id, Amount__c = 200, Subtotal__c = 200, Tax_Total__c = 50, Total__c = 250));
			}
			
		}
	
		insert thisMonthExpenses; 
	
	}


}