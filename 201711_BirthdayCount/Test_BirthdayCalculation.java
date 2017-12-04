

import static org.junit.Assert.assertEquals;
import java.util.Calendar; 
import java.util.Date;
import java.util.Arrays;
import java.util.Collection;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized; 
import org.junit.runners.Parameterized.Parameters; 
import static org.mockito.Mockito.spy; 
import static org.mockito.Mockito.when; 

@RunWith(Parameterized.class)
public class Test_BirthdayCalculation {
    @Parameters 
    public static Collection<Object[]> data(){
        return Arrays.asList( 
            new Object[][] {
                {2017,11,15,11,15,0}, 
                {2017,11,15,11,16,1}, 
                {2017,11,15,11,17,2}
            }
        );
    }
    
    private Calendar today;
    
    private int DOB_month;
    
    private int DOB_day;
    
    private int expectedAns; 
    
    public Test_BirthdayCalculation( int now_year, int now_month, int now_day, int dob_month, int dob_day, int expect_ans ) {
        today = Calendar.getInstance(); 
        today.set(now_year,now_month-1,now_day);  
        
        DOB_month = dob_month; 
        DOB_day = dob_day;
        
        expectedAns = expect_ans; 
    }
    
    @Test
    public void calculator() {
        try {
            BirthdayCalculation BC_bc = spy(new BirthdayCalculation());  
            when(BC_bc.getToday()).thenReturn(today);
            int ans = BC_bc.calculator(DOB_month,DOB_day);
            assertEquals(expectedAns,ans); 
        } catch (AssertionError e) {
            throw e; 
        }
    }
}

