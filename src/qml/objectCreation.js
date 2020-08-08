var component;
var obj;

function createObject(objectLocation,parent,objectProperties) {
    component = Qt.createComponent(objectLocation);
    obj = component.createObject(parent,objectProperties);
    if (obj == null) {
        // Error Handling
        console.log("Error creating object");
    }
    else
    {
        return obj
    }

}

//function createObject(object,objectLocation,parent,objectProperties) {
//    component = Qt.createComponent(objectLocation);
//    if (component.status == Component.Ready)
//        return finishCreation(parent,objectProperties);
//    else
//        component.statusChanged.connect(finishCreation);
//}

//function finishCreation(object,parent,objectProperties) {
//    if (component.status == Component.Ready) {
//        object = component.createObject(parent,objectProperties);
//        if (object == null) {
//            // Error Handling
//            console.log("Error creating object");
//        }
//    } else if (component.status == Component.Error) {
//        // Error Handling
//        console.log("Error loading component:", component.errorString());
//    }
//}
