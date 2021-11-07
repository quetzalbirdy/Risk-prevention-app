import "dart:convert";

class Formularios {
  String formAvanzado = json.encode([
    {
      "type": "Dropdown",
      "title": "Tipo de incidente",
      "value": "",
      "list": [
        {
          "title": "Plataformas de Trabajo",
          "value": 1,
        },   
        {
          "title": "Trabajo Distinto Nivel",
          "value": 2,
        },    
        {
          "title": "Maniobras de Izaje",
          "value": 3,
        },    
        {
          "title": "Excavaciones",
          "value": 4,
        },    
        {
          "title": "Falta Protección de Shaft, Vanos, Bordes",
          "value": 5,
        },    
        {
          "title": "Trabajos con Maquinarias y Equipos",
          "value": 6,
        },    
        {
          "title": "Descarga y Traslado de Material",
          "value": 7,
        },    
        {
          "title": "Trabajos Eléctricos",
          "value": 8,
        },    
        {
          "title": "Orden y Aseo",
          "value": 9,
        },    
        {
          "title": "Uso correcto EPP",
          "value": 10,
        },    
        {
          "title": "Otros",
          "value": 11,
        },         
      ]
    },     
    {"type": "FechaHora"},    
    {
      "type": "Dropdown",
      "title": "Responsable",
      "value": "",
      "list": [
        {
          "title": "Pablo Escobar",
          "value": 1,
        },
        {
          "title": "Carlos Gonzales",
          "value": 2,
        },
        {
          "title": "Eduardo Reyes",
          "value": 3,
        },             
      ]
    },         
    {
      "type": "Dropdown",
      "title": "Fase constructiva",
      "value": "",
      "list": [
        {
          "title": "Obras previas",
          "value": 1,
        },
        {
          "title": "Obra gruesa",
          "value": 2,
        },
        {
          "title": "Terminaciones",
          "value": 3,
        },                      
        {
          "title": "Postventa",
          "value": 6,
        },         
      ]
    }, 
    {
      "type": "Dropdown",
      "title": "Gravedad",
      "value": "",
      "list": [
        {
          "title": "Alta",
          "value": 1,
        },
        {
          "title": "Media",
          "value": 2,
        },
        {
          "title": "Baja",
          "value": 3,
        },        
      ]
    },       
    {"type": "TextArea", "placeholder": "Descripción"},                            
  ]);  

  String formComunicar = json.encode([
    {
      "type": "DropdownComunicar",
      "title": "Comunicar a",
      "value": "",
      "list": [
        {
          "title": "Usuario",
          "value": 1,
        },
        {
          "title": "Supervisor de obra",
          "value": 2,
        },
        {
          "title": "Administrador de obra",
          "value": 3,
        },        
      ]
    }, 
  ]);

  String formEstadoSolucion = json.encode([
    {
      "type": "Dropdown",
      "title": "Reportar estado de solucion",
      "value": "",
      "list": [
        {
          "title": "Pendiente",
          "value": 1,
        },
        {
          "title": "En proceso",
          "value": 2,
        },
        {
          "title": "Resuelto",
          "value": 3,
        },        
      ]
    }, 
  ]);

  String formAgregarInfo = json.encode([                                   
    {"type": "Input", "title": "Trabajadores Involucrados", "alturalinea": 3, "placeholder": ""},
    {"type": "Input", "title": "¿Por qué ocurrió?", "alturalinea": 3, "placeholder": ""},
    {"type": "Input", "title": "Acción Inmediata", "alturalinea": 3, "placeholder": ""},
    {"type": "Input", "title": "Acción Correctiva", "alturalinea": 3, "placeholder": ""},                   
  ]); 

  String formBasico = json.encode([
    {
      "type": "Dropdown",
      "title": "Tipo de incidente",
      "value": "",
      "list": [
        {
          "title": "Plataformas de Trabajo",
          "value": 1,
        },   
        {
          "title": "Trabajo Distinto Nivel",
          "value": 2,
        },    
        {
          "title": "Maniobras de Izaje",
          "value": 3,
        },    
        {
          "title": "Excavaciones",
          "value": 4,
        },    
        {
          "title": "Falta Protección de Shaft, Vanos, Bordes",
          "value": 5,
        },    
        {
          "title": "Trabajos con Maquinarias y Equipos",
          "value": 6,
        },    
        {
          "title": "Descarga y Traslado de Material",
          "value": 7,
        },    
        {
          "title": "Trabajos Eléctricos",
          "value": 8,
        },    
        {
          "title": "Orden y Aseo",
          "value": 9,
        },    
        {
          "title": "Uso correcto EPP",
          "value": 10,
        },    
        {
          "title": "Otros",
          "value": 11,
        },         
      ]
    },     
    {"type": "FechaHora"},    
    {
      "type": "Dropdown",
      "title": "Responsable",
      "value": "",
      "list": [
        {
          "title": "Pablo Escobar",
          "value": 1,
        },
        {
          "title": "Carlos Gonzales",
          "value": 2,
        },
        {
          "title": "Eduardo Reyes",
          "value": 3,
        },             
      ]
    },         
    {
      "type": "Dropdown",
      "title": "Fase constructiva",
      "value": "",
      "list": [
        {
          "title": "Obras previas",
          "value": 1,
        },
        {
          "title": "Obra gruesa",
          "value": 2,
        },
        {
          "title": "Terminaciones",
          "value": 3,
        },                      
        {
          "title": "Postventa",
          "value": 6,
        },         
      ]
    }, 
    {
      "type": "Dropdown",
      "title": "Gravedad",
      "value": "",
      "list": [
        {
          "title": "Alta",
          "value": 1,
        },
        {
          "title": "Media",
          "value": 2,
        },
        {
          "title": "Baja",
          "value": 3,
        },        
      ]
    },       
    {"type": "TextArea", "placeholder": "Descripción"},                      
  ]);  
}