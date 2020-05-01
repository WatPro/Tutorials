class Foo {
    // mutex mtx;
    bool ready_second = false;
    bool ready_third  = false;
    // This is a simple implementation, but it is far from efficiency.
    // Assuming there is one processor, switching between threads will be decided by system. 
    // Let's say the current thread is runing an infinite loop. It will not give way to others until the system forces it to. 
    // Ideally, the thread should hold itself if it found no way to go ahead at the moment.
    
public:
    Foo() {
        
    }

    void first(function<void()> printFirst) {
        
        // printFirst() outputs "first". Do not change or remove this line.
        printFirst();
        
        ready_second = true; 
    }

    void second(function<void()> printSecond) {
        while ( ready_second == false ) ; 
        // printSecond() outputs "second". Do not change or remove this line.
        printSecond();
        
        ready_third = true;
    }

    void third(function<void()> printThird) {
        while ( ready_third == false ) ; 
        
        // printThird() outputs "third". Do not change or remove this line.
        printThird();
    }
};
