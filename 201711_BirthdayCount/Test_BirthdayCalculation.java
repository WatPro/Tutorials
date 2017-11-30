

import static org.junit.Assert.assertEquals;
import org.junit.Test;

 

public class Test_BirthdayCalculation {
    @Test
    public void calculator() {
        BirthdayCalculation BC_bc=new BirthdayCalculation(); 
        int ans; 
        
        ans = BC_bc.calculator(11,30);
        assertEquals(0,ans); 
        
        ans = BC_bc.calculator(12,1);
        assertEquals(1,ans); 
    }
}