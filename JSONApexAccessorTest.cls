/**
 * Test class for JSONApexAccessor
 */
@isTest
public class JSONApexAccessorTest {
    
    // https://www.learningcontainer.com/sample-json-file/
    private static final String JSON_EXAMPLE_1 = '{"firstName":"Rack","lastName":"Jackon","gender":"man","age":24,"address":{"streetAddress":"126","city":"San Jone","state":"CA","postalCode":"394221"},"phoneNumbers":[{"type":"home","number":"7383627627"}]}';
    private static final String JSON_EXAMPLE_2 = '{"users":[{"userId":1,"firstName":"Krish","lastName":"Lee","phoneNumber":"123456","emailAddress":"krish.lee@learningcontainer.com"},{"userId":2,"firstName":"racks","lastName":"jacson","phoneNumber":"123456","emailAddress":"racks.jacson@learningcontainer.com"}]}';
    
    @isTest
    public static void simpleValuesTest() {
        JSONApexAccessor jsonAccessor = new JSONApexAccessor(JSON_EXAMPLE_1);
        
        // Root value example
        String firstName = (String) jsonAccessor.getValue('firstName');
        System.assertEquals('Rack', firstName);
        
        // Integer
        Integer age = (Integer) jsonAccessor.getValue('age');
        System.assertEquals(24, age);
        
        // Nested value example
        String city = (String) jsonAccessor.getValue('address.city');
        System.assertEquals('San Jone', city);
       	
        // Nested value example (brackets)
        System.assertEquals('San Jone', (String) jsonAccessor.getValue('address[city]'));
    }
    
    @isTest
    public static void arrayValuesTest() {
        // Get property from array
        String firstName = (String) JSONApexAccessor.getValue(JSON_EXAMPLE_2, 'users[1].firstName'); // Also static way
        System.assertEquals('racks', firstName);
        
        // Other combinations
        System.assertEquals('racks', (String) JSONApexAccessor.getValue(JSON_EXAMPLE_2, 'users[1][firstName]'));
        System.assertEquals('racks', (String) JSONApexAccessor.getValue(JSON_EXAMPLE_2, 'users[1][\'firstName\']'));
        
        // Simple array
        String bmw = (String) JSONApexAccessor.getValue('["Ford", "BMW", "Fiat"]', '[1]');
        System.assertEquals('BMW', bmw);
    }
    
    @isTest
    public static void castingTest() {
        JSONApexAccessor jsonAccessor = new JSONApexAccessor(JSON_EXAMPLE_2);
        
        // Casting into a wrapper class
        List<UserWrapper> userList = (List<UserWrapper>) jsonAccessor.getTypedValue(List<UserWrapper>.class, 'users');
        System.assertEquals(2, userList.size());
        System.assertEquals('123456', userList.get(0).phoneNumber);
        
       	UserWrapper user = (UserWrapper) jsonAccessor.getTypedValue(UserWrapper.class, 'users[0]');
        System.assertEquals(user.phoneNumber, userList.get(0).phoneNumber);
        
        // Casting into Map
        Map<String, Object> mapUser = (Map<String, Object>) jsonAccessor.getValue('users[1]');
        System.assertEquals(2, mapUser.get('userId'));
    }
    
    @isTest
    public static void negativeTest() {
        // Bad JSON
        try {
       		JSONApexAccessor jsonAccessor = new JSONApexAccessor('[Not a valid JSON]');
        } catch (Exception e) {
            System.assert(e instanceof JSONException);
        }
        
        JSONApexAccessor jsonAccessor = new JSONApexAccessor(JSON_EXAMPLE_2);
        
        // Non existing expression will return null
        System.assertEquals(null, jsonAccessor.getValue('not.exists'));
        System.assertEquals(null, jsonAccessor.getValue('users[0].car'));
        
        // Bad array indexs will throw exception
        try {
            jsonAccessor.getValue('users[x]');
        } catch (Exception e) {
            // x is not a valid integer
            System.assert(e instanceof TypeException);
        }
        
        try {
            jsonAccessor.getValue('users[10]');
        } catch (Exception e) {
            // Index out of bounds
            System.assert(e instanceof ListException);
        }
    }
    
    @isTest
    public static void performanceTest() {
        // Regular way
        Integer start = Datetime.now().millisecond();
        Map<String, Object> mapJson = (Map<String, Object>) JSON.deserializeUntyped(JSON_EXAMPLE_1);
        Map<String, Object> mapAddress = (Map<String, Object>) mapJson.get('address');
        String cityA = (String) mapAddress.get('city');
        Integer finish = Datetime.now().millisecond();
        
        Integer total = finish - start;
        System.debug('Total time (regular way): ' + total);
        
        // With utility
        start = Datetime.now().millisecond();
        JSONApexAccessor jsonAccessor = new JSONApexAccessor(JSON_EXAMPLE_1);
        String cityB = (String) jsonAccessor.getValue('address.city');
        finish = Datetime.now().millisecond();
        
        total = finish - start;
        System.debug('Total time (with utility): ' + total);
        
        System.assertEquals(cityA, cityB);
    }
    
    private class UserWrapper {
        public Integer userId {get; set;}
        public String firstName {get; set;}
        public String lastName {get; set;}
        public String phoneNumber {get; set;}
        public String emailAddress {get; set;}
    }
    
}