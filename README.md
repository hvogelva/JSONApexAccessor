# JSONApexAccessor
APEX utility class to easy access/search JSON data
(Pending english README)

### Introducción
He desarrollado esta utilidad como una alternativa para acceder a un valor dado de un JSON (desde APEX) con menos código. Por ejemplo, dado el siguiente JSON:
``` js
{
  "widget": {
    "debug": "on",
    "window": {
      "title": "Sample Konfabulator Widget",
      ...
    }
  }
}
```

En APEX para acceder al valor de la propiedad 'title' tendríamos que escribir el siguiente código:

``` apex
Map<String, Object> mapJson = (Map<String, Object>) JSON.deserializeUntyped(JSON_STR);
Map<String, Object> mapWidget = (Map<String, Object>) mapJson.get('widget');
Map<String, Object> mapWindow = (Map<String, Object>) mapWidget.get('window');
String title = mapWindow.get('title');
```

En cambio, con esta utilidad se podría hacer así:
``` apex
new JSONApexAccessor(JSON_STR).getValue('widget.window.title');
```
En pocas palabras, la idea es poder acceder a cualquier valor dentro del JSON utilizando la **notación JS**. Dicho esto, también es posible acceder a valores dentro de un array (conociendo su posición). Por ejemplo: 
`users[1].firstName`

**En la clase de Test se pueden encontrar más ejemplos de uso** - La clase principal provee métodos estáticos para un uso rápido y simple, y métodos de instancia para un uso más completo.

### Búsqueda de valores
Satisfecho con el resultado inicial, en la **versión 1.1** he decidido incorporar búsqueda de valores dentro de listas. Por ejemplo, dado el siguiente JSON:

``` js
{
  "products": [
    {
      "Name": "Cheese",
      "Price": 2.5,
      "Location": "Refrigerated foods"
    },
    {
      "Name": "Crisps",
      "Price": 3,
      "Location": "the Snack isle"
    } ...
  ]
}
```

Es posible obtener un elemento concreto (igual a, distinto de) a partir de una expresión similar a la siguiente:

``` apex
Map<String, Object> pizza = (Map<String, Object>) j.node('products').whereExpr('Name=Pizza').getOne();
List<Object> notPizza = (List<Object>) j.node('products').whereExpr('Name!=Pizza').get();
```

O búsqueda de valores numéricos utilizando los operadores de comparación **>, <, >=, <=**

``` apex
j.node('products').whereExpr('Price!=1.5').get();
j.node('products').whereExpr('Price>1.5').get();
j.node('products').whereExpr('Price>=1.5').get();
j.node('products').whereExpr('Price<1.5').get();
j.node('products').whereExpr('Price<=1.5').get();
```
En la **versión 1.2** se ha actualizado el método **getTypedValue** para facilitar la conversión del retorno a una clase wrapper. Por ejemplo:

``` apex
List<ProductWrapper> products = (List<ProductWrapper>) 
j.node('products').whereExpr('Price<=1.5').getTypedValue(List<ProductWrapper>.class);
System.assertEquals(2, products.size());
System.assertEquals(1.5, products[0].Price);
```

### Retorno en valores primitivos

En la **versión 1.2** se ha agregado una característica que hacía falta: el retorno de datos en valores primitivos (**Boolean, Decimal, Double, Integer y String**, de momento). Por ejemplo:

``` apex
JSONApexAccessor j = new JSONApexAccessor(JSON_EXAMPLE_1);
String state = j.getStringValue('address.state'));
j.getBooleanValue(...); 
j.getDecimalValue(...);
j.getDoubleValue(...);
j.getStringValue(...);
```

### Conclusión

Esta clase provee una forma alternativa de obtener determinados valores de un JSON en APEX que espero que pueda ser de utilidad para quien decida utilizarla, No espero que sea un reemplazo de utilizar la deserialización en un Map<String, Object> o el uso de una clase wrapper.

[![Deploy](https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png)](https://githubsfdeploy.herokuapp.com/?owner=hvogelva&repo=JSONApexAccessor&ref=main)
