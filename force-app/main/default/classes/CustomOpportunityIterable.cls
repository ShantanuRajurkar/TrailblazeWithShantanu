public class CustomOpportunityIterable implements Iterable<Opportunity> {
    public Iterator<Opportunity> iterator(){
       List<Opportunity> opportunities =
       [SELECT Id, Name 
        FROM Opportunity WHERE Amount<100000 LIMIT 2];
       return new CustomOpportunityIterator(opportunities);
    }
 }