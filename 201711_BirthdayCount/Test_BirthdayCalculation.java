

import static org.junit.Assert.assertEquals;
import java.util.Calendar; 
import java.util.Date;

import org.junit.Test;
import static org.mockito.Mockito.*; 

public class Test_BirthdayCalculation {
    @Test
    public void calculator() {
        Calendar today = Calendar.getInstance();
        today.set(2017,11-1,15);
        BirthdayCalculation BC_bc = new BirthdayCalculation(); 
        BirthdayCalculation spy_bc = spy(BC_bc); 
        when(spy_bc.getToday()).thenReturn(today);
        
        int ans; 
        
        ans = spy_bc.calculator(11,15);
        assertEquals(0,ans); 
        
        ans = spy_bc.calculator(11,16);
        assertEquals(1,ans); 
    }
}
