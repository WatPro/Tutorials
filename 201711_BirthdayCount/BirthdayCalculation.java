
import java.io.Console;
import java.util.Calendar; 

public class BirthdayCalculation {
    private final static int [] DAYS = {0, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
    // Array is always mutable
    private final static int leapYear = 2000; 
    private int month; 
    private int day; 
    public void reset() {
        this.month = 0;
        this.day   = 0;
    }
    BirthdayCalculation() {
        this.reset(); 
    }
    public boolean setMonth(int month) {
        if( 1<=month && month<=12 ) {
            if( this.day==0 ) {
                this.month = month;
                return true; 
            } else {
                if( this.day<=DAYS[month] ) {
                    this.month = month; 
                    return true; 
                } 
            }
        } 
        return false; 
    } 
    public boolean setDay(int day) {
        if( this.month==0 ) {
            if( 1<=day && day<31 ) {
                this.day=day; 
                return true; 
            }
        } else {
            if( day<=DAYS[this.month] ) {
                this.day=day; 
                return true; 
            }
        }
        return false; 
    }
    private boolean isBirthday( Calendar date ) {
        if( date.get(Calendar.MONTH)+1==this.month && date.get(Calendar.DAY_OF_MONTH)==this.day ) {
            return true; 
        }
        return false; 
    }
/******************************************************************************/
/* As of Mockito 2.x, static methods such as Calendar.getInstance() cannot be */
/* mocked, neither can private methods. See the limitations on:               */
/*   https://github.com/mockito/mockito/wiki/FAQ                              */
/* A simple workaround adopted here is using a public method to wrap the      */
/* static Calendar.getInstance(), and the method would be spied/mocked.       */
/******************************************************************************/
/* ORIGINAL:                                                                  */
/*
    public int calculator( int month, int day ) {
        if( setMonth(month) && setDay(day) ) {
            Calendar date = Calendar.getInstance(); 
            for( int dd=0; dd<1000; dd+=1 ) { // 'dd<1000' could be set to 'true' 
                if( isBirthday(date) ) {
                    return dd; 
                } 
                date.add(Calendar.DAY_OF_MONTH, 1); 
            }
        } 
        reset(); 
        return -1; 
    }
/* END OF ORIGINAL                                                            */
/******************************************************************************/
/* REPLACEMENT:                                                               */
    public Calendar getToday() { 
        return Calendar.getInstance();
    }
    public int calculator( int month, int day ) {
        if( setMonth(month) && setDay(day) ) {
            Calendar date = getToday(); 
            for( int dd=0; dd<1000; dd+=1 ) { // 'dd<1000' could be set to 'true' 
                if( isBirthday(date) ) {
                    return dd; 
                } 
                date.add(Calendar.DAY_OF_MONTH, 1); 
            }
        } 
        reset(); 
        return -1; 
    }
/* END OF REPLACEMENT                                                         */
/******************************************************************************/
    public int calculator() {
        int month=this.month;
        int day=this.day; 
        int ans = calculator(this.month, this.day);
        this.month=month;
        this.day=day; 
        return ans; 
    }
    public static void main(String[] args) {
        BirthdayCalculation BC_bc = new BirthdayCalculation();
        if(args.length>=2) {
            try
            {
                int month = Integer.parseInt(args[0].trim()); 
                int day = Integer.parseInt(args[1].trim()); 
                if( BC_bc.setMonth(month) && BC_bc.setDay(day) ) {
                    System.out.println( BC_bc.calculator() ); 
                    return; 
                } else {
                    throw new NumberFormatException();
                }
            }
            catch (NumberFormatException e) {
                BC_bc.reset(); 
            }
        }
        if( UserInterface.hasConsole() && UserInterface.setMonth( BC_bc ) && UserInterface.setDay( BC_bc ) ) {
            UserInterface.print( BC_bc ); 
        }
    }
}
 
final class UserInterface { 
    private static Console c = System.console();
    private final static int maxAttempt=3; 
    public static boolean hasConsole() {
        if( c!=null ) {
            return true; 
        }
        return false; 
    }
    public static boolean setMonth(BirthdayCalculation bc) {
        String num_str; 
        int num; 
        int attempt=0; 
        do {
            num_str = c.readLine("Please enter MONTH of your date of birth: "); 
            num = Integer.parseInt( num_str.trim() ); 
            if( bc.setMonth(num) ) {
                return true; 
            }
            attempt += 1; 
        } while( attempt<maxAttempt ); 
        return false; 
    } 
    public static boolean setDay(BirthdayCalculation bc) {
        String num_str; 
        int num; 
        int attempt=0; 
        do {
            num_str = c.readLine("Please enter DAY of your date of birth: "); 
            num = Integer.parseInt( num_str.trim() ); 
            if( bc.setDay(num) ) {
                return true; 
            }
            attempt += 1; 
        } while( attempt<maxAttempt ); 
        return false; 
    } 
    public static void print(BirthdayCalculation bc) {
        int ans = bc.calculator(); 
        if( ans==0 ) {
            c.format("Happy Birthday! %n"); 
        } else if( ans==1 ) { 
            c.format("Your Birthday Will Be %d Day Later. %n", ans); 
        } else if( ans>1 ) {
            c.format("Your Birthday Will Be %d Days Later. %n", ans); 
        }
    }
}

