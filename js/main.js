var currentJSTree;
var currentJSTreeNode;
var currentJSTreeAction;

function debugObject(obj) {
    var str = "";

    for(i=0;i<obj.length;i++) {
        str += obj[i].name + " : " + obj[i].value + "\n"; 
    }
    
    alert(str);
}

function debugForm(actForm) {
    var str = "action" + " : " + actForm.action + "\n";

    for(i=0;i<actForm.elements.length;i++) {
        str += actForm.elements[i].name + " : " + actForm.elements[i].value + "\n"; 
    }
    
    alert(str);
}

function editFunc(actValue) {
    var nodeForm = top.details.document.forms.nodeForm;
    nodeForm.elements.predicate.value="edit";
    nodeForm.submit();
}

function removeName(el, name) {

  var i, curList, newList;

  // Remove the given class name from the element's className property.
  newList = new Array();
  curList = el.className.split(" ");
  for (i = 0; i < curList.length; i++)
    if (curList[i] != name)
      newList.push(curList[i]);
  el.className = newList.join(" ");
}

function resetControls() {
    detailsControlForm = top.details.document.forms.detailsControlForm;
    detailsControlForm.elements.edit.checked = '';
    detailsControlForm.elements.save.disabled= 'true';
}

function selectLDAPObjType(objClassValue) {

    //debugForm(top.details.document.forms.nodeForm);

    if ( ! objClassValue ) {
        objClassValue = top.details.detailsMainFrame.document.forms.classTypeSelectionForm.elements.objectClass.value;
    }

    var completeList = top.details.detailsMainFrame.document.getElementsByClassName("ldapEntryEdit");
    for (i = 0; i < completeList.length; i++)
        if ( completeList[i].id == objClassValue ) {
            completeList[i].style.visibility = "visible";
        }
        else {
            completeList[i].style.visibility = "hidden";
        }

    var controlsForm = top.details.document.forms.detailsControlForm;

    if ( top.details.document.forms.nodeForm.elements.predicate.value === "view" ) {
        controlsForm.elements.edit.removeAttribute("checked");
        controlsForm.elements.save.setAttribute("disabled", "true");
    } else {
        controlsForm.elements.edit.setAttribute("checked", "true");
        controlsForm.elements.save.removeAttribute("disabled");       
    }

    var updateJSTreeAction = top.details.document.forms.nodeForm.elements.updateJSTree;
    if ( updateJSTreeAction.value != "" ) {
        var nodeTitle = top.details.detailsMainFrame.document.forms[objClassValue].elements.cn.value;
        var nodeID = top.details.detailsMainFrame.document.forms[objClassValue].elements.nodeDN.value;
        if ( updateJSTreeAction.value === "add") {
            if ( objClassValue === "propertyObject") { 
                currentJSTree.create({ attributes : { 'class' : 'leaf', 'state' : 'leaf', 'id' : nodeID }, data: { title : nodeTitle, icon : 'icons/key-icon.png'} }, currentJSTreeNode, "inside");
            } else {
                //debugObject(currentJSTreeNode[0]);
                //currentJSTree.create(false, currentJSTree.get_node(currentJSTreeNode));
                currentJSTree.create({ attributes : { 'class' : 'closed', 'state' : 'closed', 'id' : nodeID }, data: { title : nodeTitle } }, currentJSTreeNode, "inside");                
                
                //currentJSTree.open_branch(currentJSTreeNode);
            }
        }
        currentJSTree.get_node(currentJSTreeNode).removeClass('leaf');

        updateJSTreeAction.value = "";
    }
}

function commitLDAPEntryChange() {

    var classTypeSelectionForm, objType;

    classTypeSelectionForm = top.details.detailsMainFrame.document.forms.classTypeSelectionForm;
    objType = classTypeSelectionForm.elements.objectClass.value;

//     for(i=0;i<top.details.detailsMainFrame.document.forms.length;i++) {
//         alert(top.details.detailsMainFrame.document.forms[i].name);
//     }

    ldapEntryForm = top.details.detailsMainFrame.document.forms[objType];
    //ldapEntryForm.elements.action='update';

    //debugForm(ldapEntryForm);

    ldapEntryForm.submit();
}

function blockOnTab(tabName) {

    // Exit if no frame name was given.
    if (tabName == null)
        return;

    var nodeForm = top.details.document.forms.nodeForm;
    nodeForm.elements.tab.value = nodeForm.elements.predicate.value = tabName;
    nodeForm.action = tabName + ".pl";
    nodeForm.submit();

    // Check all links
    var elList = top.details.document.getElementsByTagName("a");

    for (i = 0; i < elList.length; i++)

        // Check if the link's target matches the frame being loaded
        if (elList[i].getAttribute('action') == tabName) {
            elList[i].className += " activeTab";
            elList[i].blur();
        }
        else
            removeName(elList[i], "activeTab");

    // Check all control bars
    elList = top.details.document.getElementsByClassName("controlBar");

    for (i = 0; i < elList.length; i++)

        // Check if the link's target matches the frame being loaded
        if (elList[i].getAttribute('id') == tabName)
            elList[i].style.visibility = "visible";
        else
            elList[i].style.visibility = "hidden";


}
