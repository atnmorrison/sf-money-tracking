public with sharing class EditExpensesController {

	private Id eventId;
	private Expense_Group__c expenseGroup; 
	private Map<Id, Expense__c> expenses; 
	private Map<Id, Expense_Type__c> expenseTypesMap;
	private Expense_Type__c[] expenseTypes; 
	public Expense_Tax_Type__c[] taxTypes{get; set;}
	public ExpenseWrapper[] expenseList {get; set;}
	public Integer removeId {get; set;} 
	public Boolean hasErrors {get; set;}
	
	public Expense__c[] deleteExpenseList; 
	public Map<Id,Expense_Tax__c> deleteTaxList;  
	
	public class ExpenseException extends Exception {
	}
	
	
	public class TaxWrapper {
		public Expense_Tax__c tax {get; set;}
		public Expense_Tax_Type__c taxType {get; set;}
		public Boolean hasTax {get; set;}
			
		public TaxWrapper(Expense_Tax__c t, Expense_Tax_Type__c tt) {
			this.tax = t; 
			this.taxType = tt; 
			this.hasTax = false; 
			
			if(this.tax.Amount__c != null && this.tax.Amount__c > 0) {
				this.hasTax = true; 	
			}		
		}
		
		public void calculateTax(Double amount) {
			if(this.taxType != null) {
				this.tax.Amount__c = this.taxType.rate__c * amount;
			} else {
				this.tax.Amount__c = 0; 
			}
		}					
	}

	public class ExpenseWrapper {
	
		public Expense__c expense {get; set;}
		public Expense_Type__c expense_type {get; set;}
		public TaxWrapper[] taxes;
		public Integer index {get; set;}
		public Map<Id, Boolean> hasTax {get; set;}
		
		public ExpenseWrapper(Expense__c e, Expense_Tax_Type__c[] taxtypes, Expense_Type__c etype) {
			this.expense = e; 
			this.taxes = new List<TaxWrapper>();
			this.expense_type = etype; 
		
			
			Map<Id, Expense_Tax__c> existing_taxes = new Map<Id, Expense_Tax__c>();
			for(Expense_Tax__c et: e.Expense_Taxes__r) {
				existing_taxes.put(et.Expense_Tax_Type__r.Id, et); 
			}
			
			for(Expense_Tax_Type__c taxtype: taxtypes){
				if(existing_taxes.containsKey(taxtype.Id)) {
					this.taxes.add(new TaxWrapper(existing_taxes.get(taxtype.Id), taxtype));	
				} else {
					this.taxes.add(new TaxWrapper(new Expense_Tax__c(Expense_Tax_Type__c = taxtype.Id), taxtype));
				}
			}		
		}
	
		public ExpenseWrapper(Expense_Tax_type__c[] taxtypes, Expense_Type__c etype) {
			this.expense = new Expense__c();
			this.expense_type = etype; 
			this.taxes = new List<TaxWrapper>();
			for(Expense_Tax_Type__c taxtype: taxtypes){
				this.taxes.add(new TaxWrapper(new Expense_Tax__c(Expense_Tax_Type__c = taxtype.Id), taxtype));
			}
		}
		
		public TaxWrapper[] gettaxes() {
		
			TaxWrapper[] tax_list = new List<TaxWrapper>(); 	
			for(TaxWrapper tw: this.taxes) {
				if(tw.hasTax) {
					tax_list.add(tw);	
				}
			}
			return tax_list; 
			
		}
		
	}

	public EditExpensesController() {
		
		try {
		
			this.eventId = (Id) System.currentPageReference().getParameters().get('id'); 
			
			//Check if there's an expense group if there isn't create it;
			if(this.eventId != null ) {	
				
				Event event = [SELECT Id, ActivityDate FROM Event WHERE Id =: this.eventId];
				Expense_Group__c[] groups = [SELECT Id FROM Expense_Group__c WHERE EventId__c =: this.eventId AND OwnerId =: UserInfo.getUserId()];
		
				//Load Expense types
				this.expenseTypes = [SELECT Id, Name, Rate__c, Entry_Type__c, Has_Tax__c, Has_Tip__c, Tax_Included__c, Auto_Calculate_Taxes__c, (SELECT Id, Expense_Type__c, Expense_Tax_Type__c, Expense_Tax_Type__r.Rate__c FROM Expense_Type_Taxes__r)  FROM Expense_Type__c ORDER By Order__c ];
				
				if(this.expenseTypes.size() == 0) {
					throw new ExpenseException('You have not configured any expense types. Please configure expense types before adding expenses. Refer to the Installation and User Guide for detailed instructions.'); 
				}
				
				
				this.expenseTypesMap = new Map<Id, Expense_Type__c>();			
				
				for(Expense_Type__c et: this.expenseTypes) {
					this.expenseTypesMap.put(et.Id, et);
				}
				
				
				this.taxTypes = [SELECT Id, Name, Rate__c FROM Expense_Tax_Type__c];
				this.expenseList = new List<ExpenseWrapper>();
	
				this.deleteExpenseList = new List<Expense__c>(); 
				this.deleteTaxList = new Map<Id, Expense_Tax__c>();  
	
				//Load Expense Tax Types		
				if(groups.size() > 0) {
					this.expenseGroup = groups[0];
					//load existing expenses for this event 
					this.expenses = new Map<Id, Expense__c>([SELECT Id, Amount__c, Comment__c, Expense_Type__c, Expense_Group__c, Total__c, Tip__c, (SELECT Amount__c, Expense_Tax_Type__c, Expense_Tax_Type__r.Rate__c, Expense_Tax_Type__r.Name FROM Expense_Taxes__r) FROM Expense__c WHERE Expense_Group__c =: this.expenseGroup.Id]);		
						
					for(Expense__c e: this.expenses.values()) {
						this.expenseList.add(new ExpenseWrapper(e, this.taxTypes, this.expenseTypesMap.get(e.Expense_Type__c)));	
					}
		
				} else {
					this.expenseGroup = new Expense_Group__c(EventId__c = this.eventId);
				}
				
				this.expenseGroup.ActivityDate__c = event.ActivityDate; 
		
				if(this.expenseList.size() <= 0) {
					this.addExpense(); 
				}
			}
			
			this.setIndexes();
		
		} catch(StringException e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The event id is invalid. Please click the Add/Edit Event button from an event that you have read / write permssion too.'));
			this.hasErrors = true; 
		} catch(ExpenseException e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, e.getMessage()));
			this.hasErrors = true;
		} catch(NullPointerException e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The event id is invalid. Please click the Add/Edit Event button from an event that you have read / write permssion too.'));
			this.hasErrors = true;
		}
	}

	
	public void setIndexes() {
		
		Integer count = 0; 
		for(ExpenseWrapper ew: this.expenseList) {
			ew.index = count;
			++count;
		}
		
	}

	
	public void addExpense() {
		this.expenseList.add(new ExpenseWrapper(this.taxTypes, null));
		this.setIndexes(); 
	}
	
	
	public void removeExpense() {

		if(this.removeId != null) {
			ExpenseWrapper ew = this.expenseList.remove(this.removeId);
			
			if(ew.expense.Id != null) {
				deleteExpenseList.add(ew.expense);
				for(TaxWrapper tw: ew.taxes) {
					if(tw.tax.Id != null) {
						deleteTaxList.put(tw.tax.Id, tw.tax);	
					}
				}
			}
			
		}
		
		this.setIndexes(); 	
	}
	
	public void calculateTaxes() {
		for(ExpenseWrapper ew: expenseList) {
			
			Expense_Type__c et = expenseTypesMap.get(ew.expense.Expense_Type__c);
			if(et != null)	{
				ew.expense_type = et;
			
				Set<Id> tax_type_ids = new Set<Id>(); 
				Double percentSum = 0.0; 
				
				for(Expense_Type_Tax__c ett: ew.expense_type.Expense_Type_Taxes__r) {
					tax_type_ids.add(ett.Expense_Tax_Type__c);
					percentSum += ett.Expense_Tax_Type__r.Rate__c; 
				}
							
				for(TaxWrapper tw: ew.taxes) {
	
					if(tax_type_ids.contains(tw.taxType.Id)) {
						tw.hasTax = true; 
						
						if(et.Auto_Calculate_Taxes__c) {
							if(ew.expense.Amount__c != null) {													
								if(et.Tax_Included__c) {
									tw.calculateTax(ew.expense.Amount__c.doubleValue()/(1+percentSum));
								} else {
									tw.calculateTax(ew.expense.Amount__c.doubleValue()*et.Rate__c);
								}
							}
								
							if(this.deleteTaxList.containsKey(tw.tax.Id)){
								this.deleteTaxList.remove(tw.tax.Id);
							}
						}
				
					} else {
						tw.hasTax = false; 
						if(tw.tax.Id != null) {	
							this.deleteTaxList.put(tw.tax.Id, tw.tax);
						}
					}
				}
			}
		}
	}


	public SelectOption[] getExpenseTypes() {
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('', '-- None --'));
		for(Expense_Type__c et: this.expenseTypes) {
			options.add(new SelectOption(et.Id, et.Name));
		}

		return options;		
	}

	
	public PageReference save() {
	
		try {
	
			Expense__c[] saveExpensesList = new List<Expense__c>(); 
			Expense_Tax__c[] saveTaxesList = new List<Expense_Tax__c>();
			
			upsert expenseGroup; 
			
			for(ExpenseWrapper ew: expenseList){		
				if(ew.expense.Expense_Group__c == null) {
					ew.expense.Expense_Group__c = expenseGroup.Id;
				}	
	
				ew.expense.Tax_Total__c = 0;
				for(TaxWrapper tw: ew.taxes) {
					if(tw.tax.Amount__c != null && tw.hasTax == true) {
						ew.expense.Tax_Total__c += tw.tax.Amount__c; 
					}
				}
				
				if(ew.expense.Expense_Type__c != null && ew.expense.Amount__c != null) {
					Expense_Type__c et = expenseTypesMap.get(ew.expense.Expense_Type__c);
					ew.expense.Subtotal__c = ew.expense.Amount__c * et.Rate__c; 
					
					if(et.Tax_Included__c == true) {
						ew.expense.Subtotal__c = ew.expense.Amount__c - ew.expense.Tax_Total__c; 
						ew.expense.Total__c = ew.expense.Amount__c * et.Rate__c;	
					} else {
						ew.expense.Total__c = ew.expense.Amount__c * et.Rate__c + ew.expense.Tax_Total__c;
					}	
					
					if(et.Has_Tip__c && ew.expense.Tip__c != null) {
						ew.expense.Total__c += ew.expense.Tip__c; 
					}
					saveExpensesList.add(ew.expense);
				}
				
			}
			
			upsert saveExpensesList; 
		
			for(ExpenseWrapper ew: expenseList){
				if(ew.expense.Id != null) {
					for(TaxWrapper tw: ew.taxes) {
						if(tw.hasTax == true) {
							tw.tax.Expense__c = ew.expense.Id;
							saveTaxesList.add(tw.tax);
						} else {
							if(tw.tax.Id != null) {
								this.deleteTaxList.put(tw.tax.Id, tw.tax);
							}
						}
					}
				}
			}
		
			upsert saveTaxesList; 
		
			//clean up deletes 
			delete this.deleteTaxList.values();
			delete this.deleteExpenseList; 
		
			return new PageReference('/'+eventId);
		
		} catch (DMLException e) {
			return null;
		}
	
	}

	public PageReference cancel() {
		return new PageReference('/'+eventId);
	}
	

}