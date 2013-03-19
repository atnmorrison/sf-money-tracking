public with sharing class expenseReportController {

		public class ExpenseReportException extends Exception{
		}


		public class ExpenseTypeWrapper {
			public Expense_Type__c expense_type {get; set;}
			public Expense__c[] expenses {get; set;}
			public ExpenseWrapper[] LogExpenses {get; set;}
		 
			public Double Subtotal {get; set;}
			public Double AmountTotal {get; set;}
			public Map<Id, TaxWrapper> Taxes {get; set;}
			public Double TipTotal {get; set;}
			public Double Total {get; set;}
				
			public ExpenseTypeWrapper(Expense_Type__c et, Expense_Tax_Type__c[] tax_types) {
				this.expense_type = et; 
				this.expenses = new List<Expense__c>();
				this.LogExpenses = new List<ExpenseWrapper>(); 
				this.Subtotal = 0; 
				this.Total = 0; 
				this.AmountTotal = 0; 
				this.TipTotal = 0; 
				
				this.Taxes = new Map<Id, TaxWrapper>(); 
				
				if(tax_types != null) {
					for(Expense_Tax_Type__c tt: tax_types) {
	    				this.Taxes.put(tt.Id, new TaxWrapper(tt, 0.0));
	    			}
				}
				
			}
			
			public TaxWrapper[] getTaxes() {
				return this.Taxes.values(); 
			}

			public String getFormatedSubtotal() {
				return DoubleUtils.formatDouble(this.Subtotal, 2);
			}

			public String getFormatedTotal() {
				return DoubleUtils.formatDouble(this.Total, 2);
			}
			
			public String getFormatedAmountTotal() {
				return DoubleUtils.formatDouble(this.Total, 2);
			}		
	
			public String getFormatedTipTotal() {
				return DoubleUtils.formatDouble(this.TipTotal, 2);
			}
			
		}


		public class ItemExpensesWrapper{
			public String Name {get; set;}
			public Map<Id, EventExpenseWrapper> EventExpenseWrappers;
			
			
			public ItemExpensesWrapper(String n) {
				this.Name = n;
				this.EventExpenseWrappers = new Map<Id, EventExpenseWrapper>();
			}
			
			public EventExpenseWrapper[] getExpenseWrappers() {
				return this.EventExpenseWrappers.values(); 
			}
		
			
		}

		public class EventExpenseWrapper{ 
			public Event event {get; set;}
			public String[] testList {get; set;}
			public Map<Id, ExpenseWrapper> ExpenseMap;
			public ExpenseTypeWrapper[] typeWrappers; 
			public EventExpenseWrapper(Event e, ExpenseTypeWrapper[] etws) {
				this.event = e;
				this.typeWrappers = etws; 
				this.ExpenseMap = new Map<Id, ExpenseWrapper>();
			}
			
			public ExpenseWrapper[] getEventExpenses() {

				//build the expense array 
				ExpenseWrapper[] expenseList = new List<ExpenseWrapper>();
				
				for(ExpenseTypeWrapper etw: this.typeWrappers) {
					if(ExpenseMap.containsKey(etw.expense_type.Id)) {
						expenseList.add(ExpenseMap.get(etw.expense_type.Id));	
					} else {
						expenseList.add(new ExpenseWrapper(new Event(), new Expense__c(), null));
					}
				}
		
				return expenseList; 

			}
			
			public String getFormatedDate() {
				DateTime newDate = DateTime.newInstance(this.event.ActivityDate.year(), this.event.ActivityDate.month(), this.event.ActivityDate.day()); 
				return newDate.format('yyyy-MM-dd');
			}
					
		}

		public class ExpenseWrapper {
			public Event event {get; set;}
			public Expense__c expense {get; set;}
			public Integer footnote {get; set;}
			public String comment {get; set;}
			
			public ExpenseWrapper(Event e, Expense__c ex, Integer i) {
				this.event = e;
				this.expense = ex; 
				this.footnote = i; 
			}
			
			public String getFormatedSubtotal() {
				if(this.expense.Subtotal__c != null) {
					return DoubleUtils.formatDouble(this.expense.Subtotal__c.doubleValue(), 2);	
				}
				return DoubleUtils.formatDouble(0.0, 2);
			}	

			public String getFormatedTax() {
				if(this.expense.Subtotal__c != null) {
					return DoubleUtils.formatDouble(this.expense.Tax_Total__c.doubleValue(), 2);	
				}
				return DoubleUtils.formatDouble(0.0, 2);
			}
			
	
			public String getFormatedDate() {
				if(this.event != null) {
					DateTime newDate = DateTime.newInstance(this.event.ActivityDate.year(), this.event.ActivityDate.month(), this.event.ActivityDate.day()); 
					return newDate.format('yyyy-MM-dd');
				}
				
				return '';
			}			
						
		}


		public class CommentWrapper {
			public Integer index {get; set;} 
			public String comment {get; set;} 
			
			public CommentWrapper(integer i, String c) {
				index = i;
				comment = c; 
			}
			
		}
		
		
		public class TaxWrapper{
			
			public Expense_Tax_Type__c tax_type {get; set;} 
			public Double total {get; set;}

			TaxWrapper(Expense_Tax_Type__c tt, Double value) {
				this.tax_type = tt; 
				this.total = value; 
			}

			public String getFormattedTotal() {
				return DoubleUtils.formatDouble(this.total, 2);
			}

		}
		

		public class TaxExpenseWrapper{
			
			public Expense_Tax_Type__c tax_type {get; set;}
			public TaxWrapper[] TaxTypeValues {get; set;} 

			public String getFormatedTotal() {
				
				Double total = 0.0; 
				
				for(TaxWrapper tw: this.TaxTypeValues) {
					if(tw != null) {
						total += tw.total;
					}
				}
				
				return DoubleUtils.formatDouble(total, 2);	
			
			}
		
		}
		
		public String FirstDisplay {get; set;}
		
		public Integer Month {get; set;}
		public Integer Year {get; set;}
		public String ViewUserId {get; set;}
		public Map<Id, User> UserMap {get; set;}
		
		public Event UserHolder {get; set;}
		public Date StartDate {get; set;}
		public String StartString {get; set;}
		public String PrintDay {get; set;}
		public Boolean RenderForm {get; set;}
		public Date EndDate {get; set;}
		
		public ExpenseTypeWrapper[] ExpenseTypeWrappers {get; set;}
		public Map<Id, ExpenseTypeWrapper> ExpenseTypeWrapperMap;
		public ExpenseTypeWrapper[] ExpenseTypeLogs {get; set;}
		public ExpenseTypeWrapper[] AllExpenseTypeWrappers {get; set;} 
		
		public Map<Id, Event> ExpenseEvents {get; set;}
		public Expense__c[] Expenses{get; set;}
		public Map<Id, EventExpenseWrapper> EventExpenses {get; set;}
		public Map<String, ItemExpensesWrapper> ItemExpenses;
		
		public String LightColor {get; set;}
		public String DarkColor {get; set;}
		public String LogoId {get; set;}
		public String CurrencyString {get; set;}
		public CommentWrapper[] CommentList {get; set;}


		public Expense_Tax_Type__c[] tax_types {get {
			return [SELECT Id, Name, Rate__c FROM Expense_Tax_Type__c];
		}} 

		public Double Total {get; set;}
		public Double TipTotal {get; set;}
		public Boolean hasExpenses{get; set;}

        public expenseReportController() {
        	
        	this.FirstDisplay = 'display: none'; 
    		this.Total = 0; 
			this.UserHolder = new Event(); 
    		
    		//Load Configs 
    		Expense_Config__c[] configs = new List<Expense_Config__c>([SELECT Name, Value__c FROM Expense_Config__c]); 
    		
    		Map<String, String> configMap = new Map<String, String>();
    		
    		for(Expense_Config__c ec: configs) {
    			configMap.put(ec.Name, ec.Value__c);
    		}
    		
    		this.CurrencyString = configMap.get('Currency'); 
    		this.LightColor = configMap.get('Light Color');
    		this.DarkColor = configMap.get('Dark Color');
    		this.LogoId = configMap.get('Logo'); 	
    
    
    		String monthStr = ApexPages.currentPage().getParameters().get('month');
    		String yearStr = ApexPages.currentPage().getParameters().get('year');
    		String userStr = ApexPages.currentPage().getParameters().get('user');
			String pdfStr = ApexPages.currentPage().getParameters().get('pdf');

			if(yearStr == null) {
				this.Year = System.today().year(); 
			} else {
				this.Year = Integer.valueOf(yearStr);
			}   
	        	
        	if(userStr == null) {
        		this.ViewUserId = UserInfo.getUserId(); 
        	} else {
        		this.ViewUserId = userStr; 
        	}

        	if(monthStr != null){
				this.Month = Integer.valueOf(monthStr);
				this.loadReport();
				this.FirstDisplay = '';
        	}        	
    			
        }

		public TaxExpenseWrapper[] getTaxTotals() {
		
			TaxExpenseWrapper[] totals = new List<TaxExpenseWrapper>(); 
			
			for(Expense_Tax_Type__c tt: this.tax_types) {
				TaxExpenseWrapper tew = new TaxExpenseWrapper(); 
				tew.tax_type = tt;
				tew.TaxTypeValues = new List<TaxWrapper>(); 
				
				if(ExpenseTypeWrappers != null) {
					for(ExpenseTypeWrapper etw: ExpenseTypeWrappers) {
						tew.TaxTypeValues.add(etw.Taxes.get(tt.Id));
					}
				}
				totals.add(tew);
			}
			return totals; 
		
		}
		
		
		public String getFormatedTotal() {
			return DoubleUtils.formatDouble(this.Total, 2);
		}

		public String getFormatedTipTotal() {
			if(this.TipTotal != null) {
				return DoubleUtils.formatDouble(this.TipTotal, 2);	
			}
			return DoubleUtils.formatDouble(0.0, 2);
		}	

		public ItemExpensesWrapper[] getItemExpenses() {
			if(ItemExpenses != null) {
				return this.ItemExpenses.values(); 
			}
			return null;
		}

        public List<SelectOption> getMonthOptions() {
        	List<SelectOption> options = new List<SelectOption>();
        	options.add(new SelectOption('','-- Month --'));
        	options.add(new SelectOption('1','January'));
        	options.add(new SelectOption('2','February'));
        	options.add(new SelectOption('3','March'));
        	options.add(new SelectOption('4','April'));
        	options.add(new SelectOption('5','May'));
        	options.add(new SelectOption('6','June'));
        	options.add(new SelectOption('7','July'));
        	options.add(new SelectOption('8','August'));
        	options.add(new SelectOption('9','September'));
        	options.add(new SelectOption('10','October'));
        	options.add(new SelectOption('11','November'));
        	options.add(new SelectOption('12','December'));
        	return options;
        }
        
        public List<SelectOption> getYearOptions() {
        	List<SelectOption> options = new List<SelectOption>();			
			Integer startYear = System.today().year() - 7; 

			for(Integer i = startYear; i< startYear + 14; ++i) {
				options.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
			}

        	return options;
        }  

        public List<SelectOption> getUserOptions() {
        	List<SelectOption> options = new List<SelectOption>();			
			options.add(new SelectOption(UserInfo.getUserId(),'Me'));

			//Get a list of all the users I manage
			if(this.UserMap == null) {
				this.UserMap = new Map<Id, User>([SELECT Id, Name FROM User WHERE ManagerId =: UserInfo.getUserId()]);
			}
        	
        	for(User u: this.UserMap.values()) {
        		options.add(new SelectOption(u.Id,u.Name));
        	}
        	
        	return options;

        }  

		public String getUserName() {
			if(this.ViewUserId == UserInfo.getUserId()){
				return UserInfo.getFirstName()+' '+UserInfo.getLastName();
			} else {
				return this.UserMap.get(this.ViewUserId).Name; 
			}
		}

        public void loadReport() {

			this.Total = 0; 
			this.TipTotal = 0;

			this.StartDate = Date.newInstance(this.Year, this.Month, 1); 
			this.EndDate = this.StartDate.addMonths(1);
						
			Expense_Group__c[] ExpenseGroups = [SELECT Id, EventId__c FROM Expense_Group__c WHERE OwnerId = :this.ViewUserId AND ActivityDate__c >= :this.StartDate AND ActivityDate__c < :this.EndDate];
			Expense_Type__c[] ExpenseTypes = [SELECT Id, Name, Log__c, Rate__c, Show_Comment__c, Entry_Type__c FROM Expense_Type__c ORDER By Order__c, Name];	
	
			this.ExpenseTypeWrappers = new List<ExpenseTypeWrapper>();
			this.ExpenseTypeLogs = new List<ExpenseTypeWrapper>();
			this.ExpenseTypeWrapperMap = new Map<Id, ExpenseTypeWrapper>();
			this.AllExpenseTypeWrappers = new List<ExpenseTypeWrapper>();
			Map<Id, Integer> typeOrder = new Map<Id, Integer>(); 
			Integer count = 0; 
			for(Expense_Type__c et: ExpenseTypes) {
				ExpenseTypeWrapper etw = new ExpenseTypeWrapper(et, this.tax_types);
				
				if(et.Log__c == true ) {
					this.ExpenseTypeLogs.add(etw);
				} else {
					this.ExpenseTypeWrappers.add(etw);
				}
			
				this.AllExpenseTypeWrappers.add(etw);
				this.ExpenseTypeWrapperMap.put(et.Id, etw);
				typeOrder.put(et.Id, count);
				++count;
			}	
	

			Set<Id> EventIds = new Set<Id>();
			Set<Id> GroupIds = new Set<Id>();
			
			Map<Id, Id> eventGroupMap = new Map<Id, Id>();
			
			for(Expense_Group__c eg: ExpenseGroups) {
				EventIds.add(eg.EventId__c);
				GroupIds.add(eg.Id);
				eventGroupMap.put(eg.Id, eg.EventId__c);
			}
			
			this.ExpenseEvents = new Map<Id, Event>([SELECT Id, Subject, ActivityDate, WhatId, What.Name, WhoId, Who.Name, Location FROM Event WHERE Id IN: EventIds ORDER By WhatId, ActivityDate]);
			this.Expenses = [SELECT Id, Amount__c, Comment__c, Expense_Type__c, Expense_Group__c, Total__c, Subtotal__c, Tax_Total__c, Tip__c, (SELECT Amount__c, Expense_Tax_Type__c, Expense_Tax_Type__r.Rate__c, Expense_Tax_Type__r.Name FROM Expense_Taxes__r) FROM Expense__c WHERE Expense_Group__c IN: GroupIds]; 
		
			if(this.Expenses.size() > 0) {
				this.hasExpenses = true; 
			} else {
				this.hasExpenses = false; 
			}
		
			this.ItemExpenses = new Map<String, ItemExpensesWrapper>(); 
			this.CommentList = new List<CommentWrapper>();
			
			for(Expense__c e: this.Expenses) {
				Event event = this.ExpenseEvents.get(eventGroupMap.get(e.Expense_Group__c));
				Integer footnote = null;
				ExpenseTypeWrapper wrapper = this.ExpenseTypeWrapperMap.get(e.Expense_Type__c);
			
				if(wrapper != null) {
					if(e.Comment__c != null && wrapper.expense_type.Show_Comment__c == true && wrapper.expense_type.Log__c == false) {
						footnote = this.CommentList.size() + 1; 
						this.CommentList.add(new CommentWrapper(footnote, e.Comment__c));
					}
				}
			
				ExpenseTypeWrapper etw = ExpenseTypeWrapperMap.get(e.Expense_Type__c);
			
				if(etw != null) {
					if(etw.expense_type.Log__c == false) {
						if(event != null) {
							if(event.WhatId == null) {
			
								if(!this.ItemExpenses.containsKey('General')) {
									this.ItemExpenses.put('General', new ItemExpensesWrapper('General'));
								}
								
								if(!this.ItemExpenses.get('General').EventExpenseWrappers.containsKey(event.Id)) {
									this.ItemExpenses.get('General').EventExpenseWrappers.put(event.Id, new EventExpenseWrapper(event, this.ExpenseTypeWrappers));
								}
																		
												
								this.ItemExpenses.get('General').EventExpenseWrappers.get(event.Id).ExpenseMap.put(e.Expense_Type__c, new ExpenseWrapper(event,e, footnote));			
							
							} else {
				
								if(!this.ItemExpenses.containsKey(event.WhatId)) {
									this.ItemExpenses.put(event.WhatId, new ItemExpensesWrapper(event.What.Name));
								}
								
								if(!this.ItemExpenses.get(event.WhatId).EventExpenseWrappers.containsKey(event.Id)) {
									this.ItemExpenses.get(event.WhatId).EventExpenseWrappers.put(event.Id, new EventExpenseWrapper(event, this.ExpenseTypeWrappers));
								}
														
								this.ItemExpenses.get(event.WhatId).EventExpenseWrappers.get(event.Id).ExpenseMap.put(e.Expense_Type__c, new ExpenseWrapper(event,e, footnote));
							}
						}
					}

					etw.Subtotal += e.Subtotal__c;
		
					for(Expense_Tax__c et: e.Expense_Taxes__r) {
						
						if(etw.Taxes.get(et.Expense_Tax_Type__r.Id) != null && et.Amount__c != null) {
							etw.Taxes.get(et.Expense_Tax_Type__r.Id).total += et.Amount__c; 
						} 
						
					}

					if(e.Tip__c != null) {
						etw.TipTotal += e.Tip__c; 
						this.TipTotal += e.Tip__c; 
					}
		
					etw.Total += e.Total__c;
					etw.AmountTotal += e.Amount__c; 
	
					this.Total += e.Total__c; 
						
					etw.expenses.add(e);
					etw.LogExpenses.add(new ExpenseWrapper(event, e, footnote));
					
				}
			}
			
			Datetime temp = Datetime.newInstance(this.StartDate.year(), this.StartDate.month(), this.StartDate.day());
			this.StartString = temp.format('MMMM dd, yyyy');
			this.PrintDay = System.now().format('MMMM dd, yyyy');
			this.RenderForm = true;

        }


		public PageReference SendAsPDF() {

			if(this.Month == null) {
				
				
				ApexPages.addMessages(new ExpenseReportException('Please select a month'));
				return null;
				
			} 
			
			PageReference pageRef = new PageReference('/apex/Expense_Report?month='+this.Month+'&year='+this.Year+'&user='+this.ViewUserId);
			pageRef.setRedirect(true);
			
			return pageRef;
		}

		public PageReference DeliverAsPDF() {
			
			PageReference pageRef = new PageReference('/apex/Expense_Report?month='+this.Month+'&year='+this.Year+'&user='+this.ViewUserId+'&p=1');
			Blob b = pageRef.getContentAsPDF();

     		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

			if(this.UserHolder.OwnerId == null) {
				return null;	
			}

			this.StartDate = Date.newInstance(this.Year, this.Month, 1); 
			this.EndDate = this.StartDate.addMonths(1);

			Datetime temp = Datetime.newInstance(this.StartDate.year(), this.StartDate.month(), this.StartDate.day());

			User u = [SELECT Id, Email, Name FROM User WHERE Id = :this.UserHolder.OwnerId]; 

     		email.setSubject(temp.format('MMMM yyyy') + ' Expense Report for '+u.Name);
     		String [] toAddresses = new String[] {u.Email};
     		email.setToAddresses(toAddresses);
     		email.setPlainTextBody('My expense report for '+temp.format('MMMM yyyy'));

     		Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
     		efa.setFileName(UserInfo.getFirstName()+temp.format('_yyyyMMdd')+'.pdf');
     		efa.setBody(b);
     		email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
    		// send it, ignoring any errors (bad!)
     		Messaging.SendEmailResult [] r =
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
     		return null;

 		}

}