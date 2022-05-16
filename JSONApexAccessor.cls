/**
 * This utility class looks up and gets a value from a given JSON
 * using a String (expression) in javascript style
 * 
 * See the test class for examples
 * 
 * @author Hernán Vogel <hernan.vogel@gmail.com>
 * created on 05/05/2022
 * @version 1.0
 */
public class JSONApexAccessor {
    
    private Object jsonObj;
    
    // Constructor, recieves the JSON string
    public JSONApexAccessor(String jsonStr) {
        this.jsonObj = JSON.deserializeUntyped(jsonStr);
    }
    
    // getValue - The main method. Obtains the given expr, then searchs in the JSON and returns the value
    
    // Instance method
    public Object getValue(String expr) {
        //System.debug('expr original value: ' + expr);
        return getNodeValue(jsonObj, exprToArray(expr), 0);
    }
    
    // Static method
    public static Object getValue(String jsonStr, String expr) {
        //System.debug('expr original value: ' + expr);
        Object jsonObj = JSON.deserializeUntyped(jsonStr);
        return getNodeValue(jsonObj, exprToArray(expr), 0);
    }
    
    // getTypedValue - Same as getValue, but returns the result with a given Type
    
    // Instance method
    public Object getTypedValue(Type T, String expr) {
        return JSON.deserialize(JSON.serialize(getValue(expr)), T);
    }
    
    // Static method
    public static Object getTypedValue(Type T, String jsonStr, String expr) {
        return JSON.deserialize(JSON.serialize(getValue(jsonStr, expr)), T);
    }
	
    private static Object getNodeValue(Object jsonNode, List<String> inputNodes, Integer pos) {
        //System.debug('Entry - getNodeValue');
        
        String nodeStr = inputNodes.get(pos);
        //System.debug('Current nodeStr value: ' + nodeStr);
        
        if (jsonNode instanceof Map<String, Object>) {
            //System.debug('jsonNode instanceof Map: ' + jsonNode);
            Map<String, Object> jsonMap = (Map<String, Object>) jsonNode;
            
            if (inputNodes.size() != pos + 1) {
                return getNodeValue(jsonMap.get(nodeStr), inputNodes, ++pos);
            }
            else {
                return jsonMap.get(nodeStr);
            }
        }
        else if (jsonNode instanceof List<Object>) {
            //System.debug('jsonNode instanceof List: ' + jsonNode);
            
            List<Object> jsonList = (List<Object>) jsonNode;
            Integer idx = Integer.valueOf(nodeStr);
            
            if (inputNodes.size() != pos + 1) {
                return getNodeValue(jsonList.get(idx), inputNodes, ++pos);
            }
            else {
                return jsonList.get(idx);
            }
        }
        
        return null;
    }
    
    // Private utility methods
    
    private static List<String> exprToArray(String expr) {
        // Replaces brackets with dots
        expr = replaceBracketsWithDots(expr);
        //System.debug('expr formatted value: ' + expr);
        
        // Creates an array splitted by dots
        List<String> inputNodes = expr.split('\\.');
        //System.debug('inputNodes value: ' + inputNodes);
        return inputNodes;
    }
    
    private static String replaceBracketsWithDots(String expr) {
        // If contains square brackets
        if (expr.containsAny('[]')) {
            expr = expr.replace('[\'', '[').replace('\']', ']');
            expr = expr.replaceAll('[\\[\\]]', '.'); // Replaces [text] into .text.
            expr = expr.replaceAll('\\.{2,}', '.');  // Replaces two dots or more with . (one dot)
            //System.debug('expr value w/o brackets: ' + expr);
        }
        
        // Remove first char if a dot
        if (expr.startsWith('.')) {
            expr = expr.substring(1);
        }
        
        // Remove last char if a dot
        if (expr.endsWith('.')) {
            expr = expr.substring(0, expr.length() - 1);
        }
        
        return expr;
    }
    
}