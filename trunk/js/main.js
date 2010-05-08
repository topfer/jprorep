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
    var str = "action : " + actForm.action + "\n";

    str += "name : " + actForm.name + "\n";

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

function selectOptionForValue(selectionControl, objClassValue) {
    if ( selectionControl && selectionControl.options)
        for(i=0;i<selectionControl.options.length;i++)
            if (selectionControl.options[i].value == objClassValue)
                selectionControl.options[i].selected = 'true';
}

function selectLDAPEntryForm(objClassValue) {
    //get list of currently visible divs (normally there should be just one)
    var completeVisibleList = top.details.detailsMainFrame.document.getElementsByClassName("ldapEntryEditVisible");

    for (i = 0; i < completeVisibleList.length; i++)
        completeVisibleList[i].className = "ldapEntryEditHidden";

    var activeDiv = top.details.detailsMainFrame.document.getElementById(objClassValue);
    if ( activeDiv ) {
        activeDiv.className = "ldapEntryEditVisible";

        top.details.document.forms.nodeForm.elements.objectClass.value = objClassValue;

        selectOptionForValue(top.details.detailsMainFrame.document.forms[objClassValue].elements.objectClass, objClassValue);
    }
}

function setDetailsControlForm() {
    var controlsForm = top.details.document.forms.detailsControlForm;

    if ( top.details.document.forms.nodeForm.elements.predicate.value === "view" ) {
        controlsForm.elements.edit.removeAttribute("checked");
        controlsForm.elements.save.setAttribute("disabled", "true");
    } else {
        controlsForm.elements.edit.setAttribute("checked", "true");
        controlsForm.elements.save.removeAttribute("disabled");       
    }
}

function updateJSTree( updateJSTreeAction ) {
    //alert("jstreeAction : _" + updateJSTreeAction + "_");
    //var updateJSTreeAction = top.details.document.forms.nodeForm.elements.updateJSTree;
    if ( updateJSTreeAction && updateJSTreeAction.value != "" ) {
        var objClassValue = top.details.document.forms.nodeForm.elements.objectClass.value;
        var nodeTitle = top.details.detailsMainFrame.document.forms[objClassValue].elements.cn.value;
        var nodeID = top.details.detailsMainFrame.document.forms[objClassValue].elements.nodeDN.value;
        if ( updateJSTreeAction === "add") {
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

function selectLDAPObjType(objClassValue) {

    selectLDAPEntryForm(objClassValue);

    setDetailsControlForm();

    updateJSTree();
}

function commitLDAPEntryChange() {

    ldapEntryForm = top.details.detailsMainFrame.document.forms[top.details.document.forms.nodeForm.elements.objectClass.value];
    //ldapEntryForm.elements.action='update';

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

function exportRequest(exportType) {
    var nodeForm = top.details.document.forms.nodeForm;
    var extractForm = top.details.document.forms.extractForm;

    extractForm.elements.tab.value = nodeForm.elements.tab.value = 'keylist';
    extractForm.elements.predicate.value = nodeForm.elements.predicate.value = 'export';
    extractForm.elements.exportType.value = exportType;
    extractForm.action = nodeForm.action = 'keylist.pl';

    extractForm.elements.nodeDN.value = nodeForm.elements.nodeDN.value

    extractForm.submit();
}
