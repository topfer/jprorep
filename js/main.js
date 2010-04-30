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

function callTab(tabName) {
    callDefaultTabAction(tabName);
    activateTab(tabName);
}

function callDefaultTabAction(tabName) {
    // Exit if no frame name was given.
    if (tabName == null)
        return;

    var nodeForm = top.details.document.forms.nodeForm;
    nodeForm.elements.tab.value = nodeForm.elements.predicate.value = tabName;
    nodeForm.action = tabName + ".pl";
    nodeForm.submit();
}

function activateTab(tabName) {
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

function saveExportSettingsCheckbox(srcEl, trgEl) {
    if ( srcEl.checked == 1 ) {
        trgEl.value = 1;
    } else {
        trgEl.value = 0;
    }
}

function loadExportSettingsCheckbox(srcEl, trgEl) {
    if ( srcEl.value == 1 ) {
        trgEl.setAttribute("checked", "1");
    } else {
        trgEl.removeAttribute("checked");
    }
}


function saveExportSettings(sourceForm, targetForm) {
    saveExportSettingsCheckbox(sourceForm.elements.includeContainerComment, targetForm.elements.includeContainerComment);
    saveExportSettingsCheckbox(sourceForm.elements.includePropertyComment, targetForm.elements.includePropertyComment);
    saveExportSettingsCheckbox(sourceForm.elements.dereferenceLinks, targetForm.elements.dereferenceLinks);
    saveExportSettingsCheckbox(sourceForm.elements.prefixKeys, targetForm.elements.prefixKeys);

    targetForm.elements.prefixKeysSeparator.value = sourceForm.elements.prefixKeysSeparator.value;
}

function loadExportSettings(sourceForm, targetForm) {
    loadExportSettingsCheckbox(sourceForm.elements.includeContainerComment, targetForm.elements.includeContainerComment);
    loadExportSettingsCheckbox(sourceForm.elements.includePropertyComment, targetForm.elements.includePropertyComment);
    loadExportSettingsCheckbox(sourceForm.elements.dereferenceLinks, targetForm.elements.dereferenceLinks);
    loadExportSettingsCheckbox(sourceForm.elements.prefixKeys, targetForm.elements.prefixKeys);

    targetForm.elements.prefixKeysSeparator.value = sourceForm.elements.prefixKeysSeparator.value;
}

function exportRequest() {
    var nodeForm = top.details.document.forms.nodeForm;
    var extractForm = top.details.document.forms.extractForm;

    extractForm.elements.tab.value = nodeForm.elements.tab.value = 'keylist';
    extractForm.elements.predicate.value = nodeForm.elements.predicate.value = 'export';
    extractForm.action = nodeForm.action = 'keylist.pl';

    extractForm.elements.nodeDN.value = nodeForm.elements.nodeDN.value

    extractForm.submit();
}
