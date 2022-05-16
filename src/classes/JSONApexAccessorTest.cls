/**
 * Test class for JSONApexAccessor
 */
@isTest
public class JSONApexAccessorTest {
    
    // https://www.learningcontainer.com/sample-json-file/
    private static final String JSON_EXAMPLE_1 = '{"firstName":"Rack","lastName":"Jackon","gender":"man","age":24,"address":{"streetAddress":"126","city":"San Jone","state":"CA","postalCode":"394221"},"phoneNumbers":[{"type":"home","number":"7383627627"}]}';
    private static final String JSON_EXAMPLE_2 = '{"users":[{"userId":1,"firstName":"Krish","lastName":"Lee","phoneNumber":"123456","emailAddress":"krish.lee@learningcontainer.com"},{"userId":2,"firstName":"racks","lastName":"jacson","phoneNumber":"123456","emailAddress":"racks.jacson@learningcontainer.com"}]}';
    //https://github.com/mdn/fetch-examples/blob/master/fetch-json/products.json
    private static final String JSON_EXAMPLE_3 = '{"products":[{"Name":"Cheese","Price":2.5,"Location":"Refrigerated foods"},{"Name":"Crisps","Price":3,"Location":"the Snack isle"},{"Name":"Pizza","Price":4,"Location":"Refrigerated foods"},{"Name":"Chocolate","Price":1.5,"Location":"the Snack isle"},{"Name":"Self-raising flour","Price":1.5,"Location":"Home baking"},{"Name":"Ground almonds","Price":3,"Location":"Home baking"}]}';
    
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
        
       	JSONApexAccessor.getValue('["Ford", "BMW", "Fiat"]', ''); // Just for coverage
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
        
        // Static way
        user = (UserWrapper) JSONApexAccessor.getTypedValue(UserWrapper.class, JSON_EXAMPLE_2, 'users[0]');
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
        
        // V1.1
        try {
            jsonAccessor.node('users').whereExpr('invalid').get();
        }
        catch (HandledException e) {
            System.assert(e.getMessage().contains('operator not found'));
        }
        
        try {
            jsonAccessor.node('users').whereExpr('a=').get();
        }
        catch (HandledException e) {
            System.assert(e.getMessage().contains('missing operand'));
        }
        
        System.assertEquals(null, jsonAccessor.node('notExists').whereExpr('a=b').get());
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
    
    // V1.1
    
    @isTest
    public static void buildPatternTest() {
        JSONApexAccessor j = new JSONApexAccessor(JSON_EXAMPLE_3);
        
        // This is the same as getValue(expr) but using builder pattern
        String productName = (String) j.node('products[0].Name').get();
        System.assertEquals('Cheese', productName);
        System.assertEquals(null, j.node(null).get()); // Just for coverage
        j.node('products[0].Name').getOne();
    }
    
    @isTest
    public static void whereTest() {
        JSONApexAccessor j = new JSONApexAccessor(JSON_EXAMPLE_3);
        
        // String search
        
        // Equals
        Map<String, Object> pizza = (Map<String, Object>) j.node('products').whereExpr('Name=Pizza').getOne();
        System.assertEquals(4, pizza.get('Price')); // getOne returns only one element
        
        List<Object> refFoods = (List<Object>) j.node('products').whereExpr('Location=Refrigerated foods').get();
        System.assertEquals(2, refFoods.size());
        
        // Not equals
        List<Object> notPizza = (List<Object>) j.node('products').whereExpr('Name!=Pizza').get();
        
        for (Object product : notPizza) {
            Map<String, Object> mapProduct = (Map<String, Object>) product;
            System.assertNotEquals('Pizza', mapProduct.get('Name'));
        }
        
        // Not valid for String (> operator)
        System.assertEquals(0, ((List<Object>) j.node('products').whereExpr('Name>Pizza').get()).size());
        
        // Number search
        
        // Equals
        List<Object> productsByPrice = (List<Object>) j.node('products').whereExpr('Price=1.5').get();
        System.assertEquals(2, productsByPrice.size());
        
        // Not equals
        productsByPrice = (List<Object>) j.node('products').whereExpr('Price!=1.5').get();
        System.assertEquals(4, productsByPrice.size());
        
        // >
        productsByPrice = (List<Object>) j.node('products').whereExpr('Price>1.5').get();
        System.assertEquals(4, productsByPrice.size());
        
        // >=
        productsByPrice = (List<Object>) j.node('products').whereExpr('Price>=1.5').get();
        System.assertEquals(6, productsByPrice.size());
        
        // <
        productsByPrice = (List<Object>) j.node('products').whereExpr('Price<1.5').get();
        System.assertEquals(0, productsByPrice.size());
        
        // <=
        productsByPrice = (List<Object>) j.node('products').whereExpr('Price<=1.5').get();
        System.assertEquals(2, productsByPrice.size());
    }
    
    private class UserWrapper {
        public Integer userId {get; set;}
        public String firstName {get; set;}
        public String lastName {get; set;}
        public String phoneNumber {get; set;}
        public String emailAddress {get; set;}
    }
    
}