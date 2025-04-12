// src/MyTests.java
import static org.junit.Assert.*;
import org.junit.Test;

public class MyTests {
    @Test
    public void testAddition() {
        assertEquals(5, Main.add(2, 3));
    }
}
