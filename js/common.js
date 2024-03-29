/********************************************************************
 * function to show all the properties of an object. 
 * This function recursively takes properties that 
 * are objects themselves and shows their properties.
********************************************************************/
function _orig_dumpProps(obj, parent) {
   // Go through all the properties of the passed-in object
   for (var i in obj) {
      // if a parent (2nd parameter) was passed in, then use that to
      // build the message. Message includes i (the object's property name)
      // then the object's property value on a new line
      if (parent) { 
          var msg = parent + "." + i + "\n" + obj[i]; 
      } else { 
          var msg = i + "\n" + obj[i]; 
      }
      // Display the message. If the user clicks "OK", then continue. If they
      // click "CANCEL" then quit this level of recursion
      if (!confirm(msg)) { 
          return; 
      }
      // If this property (i) is an object, then recursively process the object
      if (typeof obj[i] == "object") {
         if (parent) { 
             dumpProps(obj[i], parent + "." + i); 
         } else { 
             dumpProps(obj[i], i); 
         }
      }
   }
}

function appendLog(str) {
    //alert(top.info.document.address);
    top.info.document.write(str);
}

function dumpProps(obj, depth) {
    var str = "";
    if ( depth < 16 ) {
        // Go through all the properties of the passed-in object
        for (var i in obj) {
            str += "[" + depth + "]" + i + " : ";
            if (typeof obj[i] == "object") {
                str += "<br/>" + dumpProps(obj[i], depth + 1);
            } else {
                str += obj[i];
            }
            str += "<br/>";
        }
    }
    return str;
}
