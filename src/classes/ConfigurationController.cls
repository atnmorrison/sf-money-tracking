public with sharing class ConfigurationController {

	public List<Expense_Config__c> configs {get; set;}
	public Map<String, Expense_Config__c> configMap {get; set;}
	public Map<String, String> nameValue {get; set;}

	public String DarkColor{get; set;}
	public String LightColor {get; set;}
	public String Logo {get; set;}
	public String CurrencyString {get; set;}
	public Document newDocument {get; set;}
	public String Mode {get; set;}

	public Expense_Type__c[] expense_types {get; set;}
	public Expense_Tax_Type__c[] tax_types {get; set;}
	public Map<Integer, Expense_Type__c> expense_types_order {get; set;}
	
	public ConfigurationController(){
		this.LoadConfigs();
		this.Mode = 'view';
		
		this.expense_types = [SELECT Id, Name, Entry_Type__c, Rate__c, Log__c, Show_Comment__c, Order__c, Has_Tax__c FROM Expense_Type__c ORDER BY Order__c];
		this.tax_types = [SELECT Id, Name, Rate__c FROM Expense_Tax_Type__c];
	

		this.expense_types_order = new Map<Integer, Expense_Type__c>();  
		Expense_Type__c[] newtypes = new List<Expense_Type__c>(); 
		
		for(Expense_Type__c et: expense_types) {
			if(et.Order__c == null) {
				newtypes.add(et);
			} else {
				this.expense_types_order.put(et.Order__c.intValue(), et);
			} 
		}
		
		for(Expense_Type__c nt: newtypes) {
			nt.Order__c = this.expense_types_order.size() + 1;
			this.expense_types_order.put(nt.Order__c.intValue(), nt);
		}
		
		
		this.expense_types = this.expense_types_order.values(); 
	}

	public void LoadConfigs() {

		this.configs = [SELECT Id, Name, Value__c FROM Expense_Config__c];
		this.configMap = new Map<String, Expense_Config__c>();
		this.nameValue = new Map<String, String>(); 
		this.newDocument = new Document(Name='Expense Report Logo', IsPublic = true); 
		
		for(Expense_Config__c ec: configs) {
			this.configMap.put(ec.Name, ec);
			this.nameValue.put(ec.Name, ec.Value__c);
		}
		
		this.DarkColor = this.nameValue.get('Dark Color');
		this.LightColor = this.nameValue.get('Light Color');
		this.CurrencyString = this.nameValue.get('Currency');
		this.Logo = this.nameValue.get('Logo');		
		
	}
	

	public PageReference edit() {
		this.Mode = 'edit';
		return null;
	}

	public PageReference save() {
		
		if(this.newDocument.Body != null) {
			this.newDocument.folderId = UserInfo.getUserId();
			insert this.newDocument;
		}
		
		if(this.configMap.containsKey('Dark Color')) {
			this.configMap.get('Dark Color').Value__c = this.DarkColor;
		} else {
			this.configs.add(new Expense_Config__c(Name='Dark Color', Value__c = this.DarkColor));
		}	

		if(this.configMap.containsKey('Light Color')) {
			this.configMap.get('Light Color').Value__c = this.LightColor;
		} else {
			this.configs.add(new Expense_Config__c(Name='Light Color', Value__c = this.LightColor));
		}		
		
		if(this.configMap.containsKey('Currency')) {
			this.configMap.get('Currency').Value__c = this.CurrencyString;
		} else {
			this.configs.add(new Expense_Config__c(Name='Currency', Value__c = this.CurrencyString));
		}
		
		
		if(this.newDocument.Id != null) {
			if(this.configMap.containsKey('Logo')) {
				this.configMap.get('Logo').Value__c = this.newDocument.Id;
				this.Logo = this.newDocument.Id; 
			} else {
				this.configs.add(new Expense_Config__c(Name='Logo', Value__c = this.newDocument.Id));
			}
		}

		upsert this.configs; 
		this.mode = 'view';
		this.newDocument = new Document(Name='Expense Report Logo', IsPublic = true); 

		return null; 
	}

	public PageReference cancel() {
		this.LoadConfigs(); 
		this.mode = 'view';
		return null; 	
	}
	
	public PageReference newExpenseType() {

		Schema.DescribeSObjectResult r = Expense_Type__c.SObjectType.getDescribe();
		PageReference pageRef = new PageReference('/'+r.getKeyPrefix()+'/e?retURL='+EncodingUtil.urlEncode('/apex/Configuration', 'UTF-8')); 
		
		return pageRef; 

	}
	
	public PageReference deleteExpenseType() {
		
		String type_id = System.currentPageReference().getParameters().get('id');
		
		if(type_id != null) {
			Expense_Type__c et = new Expense_Type__c(id = type_id);
			delete et; 
		}
	
		this.expense_types = [SELECT Id, Name, Entry_Type__c, Rate__c, Log__c, Show_Comment__c, Order__c FROM Expense_Type__c ORDER BY Order__c];
	
		Integer count = 1; 
		for(Expense_Type__c et: this.expense_types) {
			et.Order__c = count;
			++count; 			
		}

		upsert this.expense_types;
		return null;
	}
	
	public PageReference moveDown() {
		String indexStr = System.currentPageReference().getParameters().get('index'); 
		Integer index = Double.valueOf(indexStr).intValue();
		Integer index2 = index+1; 
	
		Expense_Type__c temp = this.expense_types_order.get(index);
		Expense_Type__c temp2 = this.expense_types_order.get(index2);
	
		temp.Order__c = index2; 
		temp2.Order__c = index; 
			
		this.expense_types_order.put(index, temp2);
		this.expense_types_order.put(index2, temp);

		this.expense_types = new List<Expense_Type__c>();		

		for(Integer i = 1; i<= this.expense_types_order.size(); ++i) {
			this.expense_types.add(this.expense_types_order.get(i));
		}

		upsert this.expense_types; 
		
		return null; 
	}
	
	public PageReference moveUp() {
		
		String indexStr = System.currentPageReference().getParameters().get('index'); 
		Integer index = Double.valueOf(indexStr).intValue();
		Integer index2 = index-1; 
	
		Expense_Type__c temp = this.expense_types_order.get(index);
		Expense_Type__c temp2 = this.expense_types_order.get(index2);
	
		temp.Order__c = index2; 
		temp2.Order__c = index; 
			
		this.expense_types_order.put(index, temp2);
		this.expense_types_order.put(index2, temp);

		this.expense_types = new List<Expense_Type__c>();		

		for(Integer i = 1; i<= this.expense_types_order.size(); ++i) {
			this.expense_types.add(this.expense_types_order.get(i));
		}

		upsert this.expense_types; 		
		
		return null; 	
	}
	
	public void saveExpenseTypes(){
		upsert this.expense_types; 
	}
	
	
	public PageReference newTaxType() {
		
		Schema.DescribeSObjectResult r = Expense_Tax_Type__c.SObjectType.getDescribe();
		PageReference pageRef = new PageReference('/'+r.getKeyPrefix()+'/e?retURL='+EncodingUtil.urlEncode('/apex/Configuration', 'UTF-8')); 
		return pageRef; 
		
	}
	
	public PageReference deleteTaxType() {
		
		String type_id = System.currentPageReference().getParameters().get('id');
		
		if(type_id != null) {
			Expense_Tax_Type__c et = new Expense_Tax_Type__c(id = type_id);
			delete et; 
		}
	
		this.tax_types = [SELECT Id, Name, Rate__c FROM Expense_Tax_Type__c];
		return null;
	}


}