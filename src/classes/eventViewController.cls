public with sharing class eventViewController{

	private final Event event {get; set;}
	private Expense_Group__c[] expense_groups;
	private Expense_Group__c expense_group; 
	public Expense__c[] expenses {get; set;}

	public eventViewController(ApexPages.StandardController stdController){
		
		this.event = (Event) stdController.getRecord();
		this.expense_groups = [SELECT Id FROM Expense_Group__c WHERE EventId__c =: this.event.Id LIMIT 1];

		//load expenses for display
	
		if(this.expense_groups.size() > 0){
			this.expense_group =  this.expense_groups[0];
			this.expenses = [SELECT Id, Amount__c, Comment__c, Expense_Type__c, Expense_Type__r.Name, Expense_Group__c, Total__c, Subtotal__c, Tax_Total__c, Tip__c FROM Expense__c WHERE Expense_Group__c =: this.expense_group.Id];
		} else {
			this.expenses = new List<Expense__c>(); 
		}
	
	}

	public String getEventGroupId(){
		return 'None';
	}

}