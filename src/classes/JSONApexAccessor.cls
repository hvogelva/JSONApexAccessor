/**
 * This utility class looks up and gets a value from a given JSON
 * using a String (expression) in javascript style
 * 
 * See the test class for examples
 * 
 * @author Hernán Vogel <hernan.vogel@gmail.com>
 * created on 05/05/2022
 * modified 08/07/2022
 * @version 1.2
 */
public class JSONApexAccessor {
    
    private Object jsonObj;
    private String nodeExpr;
    private String whereExpr;
    
    // Supported operators: <=, <, >, >=, !=, =
    // AND/OR not supported yet
    private static final String SUPPORTED_OPERATORS_REGEX = '<=|>=|<|>|!=|=';
    
    // Constructor, receives the JSON string
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
    
    // V1.2
    public Object getTypedValue(Type T) {
        if (nodeExpr == null) {
            return null;
        }
        
        return JSON.deserialize(JSON.serialize(get()), T);
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
            Integer idx;
            
            if (!String.isEmpty(nodeStr)) {
                idx = Integer.valueOf(nodeStr);
            } else if (inputNodes.size() == pos + 1) {
                return jsonList;
            }
            
            if (inputNodes.size() != pos + 1) {
                return getNodeValue(jsonList.get(idx), inputNodes, ++pos);
            }
            else {
                return jsonList.get(idx);
            }
        }
        
        return null;
    }
    
    // V1.1
    
    public JSONApexAccessor node(String nodeExpr) {
        this.nodeExpr = nodeExpr;
        this.whereExpr = null;
        return this;
    }
    
    public JSONApexAccessor whereExpr(String whereExpr) {
        this.whereExpr = whereExpr;
        return this;
    }
    
    public Object get() {
        if (nodeExpr == null) {
            return null;
        }
        
        Object value = getValue(nodeExpr);
        
        if (whereExpr == null) {
            // If no whereExpr is found, just return the getValue
            return value;
        }
        else if (value != null) {
            // Search section starts
            
            // Assuming that node is a List
            List<Object> values = (List<Object>) value;
            
            // Gets operator and operands
            // E.g. userId=2
            String operator = getExprOperator(whereExpr); // E.g. =
            String[] operands = getOperands(whereExpr);   // E.g. operands[0] -> userId, operands[1] -> 2
            
            //System.debug('operator value: ' + operator);
            //System.debug('operands value: ' + operands);
            
            if (operator == null) {
                throw new HandledException('Invalid whereExpr: operator not found/not supported');
            }
            
            if (operands.size() != 2) {
                throw new HandledException('Invalid whereExpr: missing operand(s)');
            }
                        
            // Matches
            List<Object> matches = new List<Object>();
            
            for (Object obj : values) {
                // In each iteration, cast to a Map<String, Object>
                Map<String, Object> element = (Map<String, Object>) obj;
                //System.debug('element value: ' + element);
                
                if (element.containsKey(operands[0]) &&
                        compare(element.get(operands[0]), operands[1], operator)) {
                    matches.add(element);
                }
            }
            
            return matches;
        }
        
        return null;
    }
    
    public Object getOne() {
        Object getResult = get();
        
        if (getResult != null && getResult instanceof List<Object>) {
            return ((List<Object>) getResult).get(0);
        }
        
        return getResult;
    }
    
    // V1.2 - Primitive extraction
    // Boolean
    
    public Boolean getBooleanValue() {
        return (Boolean) get();
    }
    
    public Boolean getBooleanValue(String expr) {
        return (Boolean) getNodeValue(jsonObj, exprToArray(expr), 0);
    }
    
    public static Boolean getBooleanValue(String jsonStr, String expr) {
        Object jsonObj = JSON.deserializeUntyped(jsonStr);
        return (Boolean) getNodeValue(jsonObj, exprToArray(expr), 0);
    }
    
    // Decimal
    
    public Decimal getDecimalValue() {
        return (Decimal) get();
    }
    
    public Decimal getDecimalValue(String expr) {
        return (Decimal) getNodeValue(jsonObj, exprToArray(expr), 0);
    }
    
    public static Decimal getDecimalValue(String jsonStr, String expr) {
        Object jsonObj = JSON.deserializeUntyped(jsonStr);
        return (Decimal) getNodeValue(jsonObj, exprToArray(expr), 0);
    }
    
    // Double
    
    public Double getDoubleValue() {
        return (Double) get();
    }
    
    public Double getDoubleValue(String expr) {
        return (Double) getNodeValue(jsonObj, exprToArray(expr), 0);
    }
    
    public static Double getDoubleValue(String jsonStr, String expr) {
        Object jsonObj = JSON.deserializeUntyped(jsonStr);
        return (Double) getNodeValue(jsonObj, exprToArray(expr), 0);
    }
    
    // Integer
    
    public Integer getIntegerValue() {
        return (Integer) get();
    }
    
    public Integer getIntegerValue(String expr) {
        return (Integer) getNodeValue(jsonObj, exprToArray(expr), 0);
    }
    
    public static Integer getIntegerValue(String jsonStr, String expr) {
        Object jsonObj = JSON.deserializeUntyped(jsonStr);
        return (Integer) getNodeValue(jsonObj, exprToArray(expr), 0);
    }
    
    // String
    
    public String getStringValue() {
        return (String) get();
    }
    
    public String getStringValue(String expr) {
        return (String) getNodeValue(jsonObj, exprToArray(expr), 0);
    }
    
    public static String getStringValue(String jsonStr, String expr) {
        Object jsonObj = JSON.deserializeUntyped(jsonStr);
        return (String) getNodeValue(jsonObj, exprToArray(expr), 0);
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
    
    // V1.1
    
    private String getExprOperator(String whereExpr) {
        Matcher matcher = Pattern.compile(SUPPORTED_OPERATORS_REGEX).matcher(whereExpr);
        
        if (matcher.find()) {
            return matcher.group(0);
        }
        
        return null;
    }
    
    private String[] getOperands(String whereExpr) {
        return whereExpr.split(SUPPORTED_OPERATORS_REGEX);
    }
    
    private Boolean compare(Object sourceValue, String compareValue, String operator) {
        if (sourceValue instanceof Decimal) {
            switch on operator {
                when '<=' {
                    return (Decimal) sourceValue <= Decimal.valueOf(compareValue);
                }
                when '<' {
                    return (Decimal) sourceValue < Decimal.valueOf(compareValue);
                }
                when '>' {
                    return (Decimal) sourceValue > Decimal.valueOf(compareValue);
                }
                when '>=' {
                    return (Decimal) sourceValue >= Decimal.valueOf(compareValue);
                }
                when '!=' {
                    return (Decimal) sourceValue != Decimal.valueOf(compareValue);
                }
                when '=' {
                    return (Decimal) sourceValue == Decimal.valueOf(compareValue);
                }
            }
        }
        
        if (sourceValue instanceof String) {
            switch on operator {
                when '!=' {
                    return (String) sourceValue != compareValue;
                }
                when '=' {
                    return (String) sourceValue == compareValue;
                }
            }
        }
        
        return false;
    }
    
}