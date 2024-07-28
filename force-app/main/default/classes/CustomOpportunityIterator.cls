public class CustomOpportunityIterator
   implements Iterator<Opportunity>{ 
 
   private List<Opportunity> opportunities;
   private Integer currentIndex;
 
   public CustomOpportunityIterator(List<Opportunity> opportunities){
       this.opportunities = opportunities;
       this.currentIndex = 0;
   }
 
   public Boolean hasNext(){ 
       return currentIndex < opportunities.size();
   }    
 
   public Opportunity next(){
       if(hasNext()) {
           return opportunities[currentIndex++];
       } else {
           throw new NoSuchElementException('Iterator has no more elements.');
       }
   } 
}