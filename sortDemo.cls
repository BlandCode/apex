global class sortDemo{

@RemoteAction
public static list<business> getTopFifty(){
    list<business> top_fifty = new list<business>();
    for(account a : [select id, name, Rating, AnnualRevenue, owner.name, (select id, ActivityDate FROM Tasks WHERE status = 'Completed' ORDER BY ActivityDate LIMIT 1) FROM account WHERE AnnualRevenue != null order by AnnualRevenue DESC LIMIT 50]){
        business b = new business(a);
        if(b.last_activity !=null && b.revenue !=null)
            top_fifty.add(b);
    }
    top_fifty.sort();
    return top_fifty;
}


@RemoteAction
public static list<business> getRandomFifty(){
    list<business> top_fifty = new list<business>();
    for(account a : [select id, name, Rating, AnnualRevenue, owner.name, (select id, ActivityDate FROM Tasks WHERE status = 'Completed' ORDER BY ActivityDate LIMIT 1) FROM account WHERE AnnualRevenue != null order by AnnualRevenue DESC LIMIT 50]){
        business b = new business(a);
        if(b.last_activity !=null && b.revenue !=null)
            top_fifty.add(b);
    }
    //top_fifty.sort();
    return top_fifty;
}


global class business implements Comparable{
    public string name {get;set;}
    public string rating {get;set;}
    public decimal revenue {get;set;}
    public id id {get;set;}
    public string owner_name {get;set;}
    public date last_activity {get;set;}
    public integer days_since_contact {get;set;}
    public string last_activity_date {get;set;}
    global Integer compareTo(Object compareTo) {
        business compareToBusiness = (business)compareTo;
        if(last_activity == compareToBusiness.last_activity) return 0;
        else if(last_activity > compareToBusiness.last_activity) return 1;
        else return -1;
    }
    
    
    public business (account a){
        this.name = a.name;
        this.rating = a.rating;
        this.revenue = a.AnnualRevenue;
        this.id = a.id;
        this.owner_name = a.owner.name;
        for(task t : a.tasks){
            if(t.ActivityDate !=null){
                this.last_activity = t.ActivityDate;
                this.last_activity_date = t.ActivityDate.format();
                this.days_since_contact = t.ActivityDate.daysBetween(system.today());
                }
            
        }
    }
}

private static testMethod void testSort(){
    account a = new account();
    a.name = 'Sample '+system.now();
    a.AnnualRevenue = 5000;
    insert a;
    
    task t = new task();
    t.status = 'Completed';
    t.ActivityDate = system.today();
    t.whatid = a.id;
    insert t;
    
    account a1 = new account();
    a1.name = 'Sample '+system.now();
    a1.AnnualRevenue = 10000;
    insert a1;
    
    task t1 = new task();
    t1.status = 'Completed';
    t1.ActivityDate = system.today()-5;
    t1.whatid = a1.id;
    insert t1;
    
    list<business> sorted = getTopFifty();
    system.assert(sorted[1].id==a.id);
    
    list<business> unsorted = getRandomFifty();
    system.assert(unsorted[1].id==a.id);
    
    task t2 = new task();
    t2.status = 'Completed';
    t2.ActivityDate = system.today()+5;
    t2.whatid = a1.id;
    insert t2;
    
    sorted = getTopFifty();
    system.assert(sorted[0].id==a1.id);
    
}
}