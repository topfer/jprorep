// var currentJSTree;
// var currentJSTreeNode;
// var currentJSTreeAction;

/*
 * Returns string with all the input names and values of the selected form
 */
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

/*
 * Removes the given class name from the element's className property.
 */
function removeClassName(el, name) {

  var i, curList, newList;

  newList = new Array();
  curList = el.className.split(" ");
  for (i = 0; i < curList.length; i++)
    if (curList[i] != name)
      newList.push(curList[i]);
  el.className = newList.join(" ");
}

/*
 * As name suggestsm restets controlls of the controls form to a default state
 */
function resetControls() {
    detailsControlForm = top.details.document.forms.detailsControlForm;
    detailsControlForm.elements.edit.checked = '';
    detailsControlForm.elements.save.disabled= 'true';
}

/*
 * Selects the value of the LDAP object type selection control of the currently visible LDAP object details form
 *
 * This action is necessary because in order for a user to jump from on LDAP type to the other
 * it has to select a different object type in the selection control. This function makes sure
 * than whenever the user return to the current form the correct LDAP object type is selected
 * in the form
 */
function selectOptionForValue(selectionControl, objClassValue) {
    if ( selectionControl && selectionControl.options)
        for(i=0;i<selectionControl.options.length;i++)
            if (selectionControl.options[i].value == objClassValue)
                selectionControl.options[i].selected = 'true';
}

/*
 * Reveals input form corresponding to the selected object type (Hides all the other)
 */
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

/*
 * Updates JSTree in tle left navigation pane
 */
function updateJSTree( updateJSTreeAction ) {
    //alert("JSTreeAction : " + updateJSTreeAction);

    var objClassValue, nodeTitle, nodeId;

    if ( top.details.document.forms.nodeForm ) {
        objClassValue = top.details.document.forms.nodeForm.elements.objectClass.value;
    }

    if ( objClassValue && objClassValue != "" && top.details.detailsMainFrame.document.forms[objClassValue] ) {
        nodeTitle = top.details.detailsMainFrame.document.forms[objClassValue].elements.cn.value;
        nodeID = top.details.detailsMainFrame.document.forms[objClassValue].elements.nodeDN.value;
    }

    var actionData = top.navigation.jQuery.tree.plugins.arcorectxmenu.privdata;
    
    switch ( updateJSTreeAction ) {

    case "create" :
        if ( objClassValue === "propertyObject") { 
            actionData.TREE_OBJ.create({ attributes : { 'class' : 'leaf', 'state' : 'leaf', 'id' : nodeID }, data: { title : nodeTitle, icon : 'icons/key-icon.png'} }, actionData.REF_NODE, actionData.TYPE);
        } else {
            actionData.TREE_OBJ.create({ attributes : { 'class' : 'leaf', 'state' : 'leaf', 'id' : nodeID }, data: { title : nodeTitle } }, actionData.REF_NODE, actionData.TYPE);
        }
        
        break;

    case "link" :
        actionData.TREE_OBJ.create({ attributes : { 'class' : 'link', 'state' : 'leaf', 'id' : nodeID }, data: { title : nodeTitle, icon : 'icons/link.png'} }, actionData.REF_NODE, actionData.TYPE);
        break;

    case "remove" :
        actionData.TREE_OBJ.remove(actionData.NODE);
        break;
    }
}

function _disabled__updateJSTree( updateJSTreeAction ) {    
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
                currentJSTree.create({ attributes : { 'class' : 'closed', 'state' : 'closed', 'id' : nodeID }, data: { title : nodeTitle } }, currentJSTreeNode, "inside");
            }
        } else if ( updateJSTreeAction === "link") {
            currentJSTree = top.navigation.jQuery.tree.plugins.arcorectxmenu.privdata.TREE_OBJ;
            currentJSTreeNode = top.navigation.jQuery.tree.plugins.arcorectxmenu.privdata.REF_NODE;
            type = top.navigation.jQuery.tree.plugins.arcorectxmenu.privdata.TYPE;
            currentJSTree.create({ attributes : { 'class' : 'link', 'state' : 'leaf', 'id' : nodeID }, data: { title : nodeTitle, icon : 'icons/link.png'} }, currentJSTreeNode, type);
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

/*
 * Main function that initiates a tab change
 */
function callTab(tabName) {
    callDefaultTabAction(tabName);
    activateTab(tabName);
}

/*
 * Resubmits http request according to the currently selected tab
 */
function callDefaultTabAction(tabName) {
    // Exit if no frame name was given.
    if (tabName == null)
        return;

    var nodeForm = top.details.document.forms.nodeForm;
    nodeForm.elements.tab.value = nodeForm.elements.predicate.value = tabName;
    nodeForm.action = tabName + ".pl";
    nodeForm.submit();
}

/*
 * Highlights the active tab (based on frame name that's being loaded)
 */
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
            removeClassName(elList[i], "activeTab");

    // Check all control bars
    elList = top.details.document.getElementsByClassName("controlBar");

    for (i = 0; i < elList.length; i++)

        // Check if the link's target matches the frame being loaded
        if (elList[i].getAttribute('id') == tabName)
            elList[i].style.visibility = "visible";
        else
            elList[i].style.visibility = "hidden";
}

/*
 * Saves the status of on checkbox
 */
function saveExportSettingsCheckbox(srcEl, trgEl) {
    if ( srcEl.checked == 1 ) {
        trgEl.value = 1;
    } else {
        trgEl.value = 0;
    }
}

/*
 * Sets checkbox status according to a value
 */
function loadExportSettingsCheckbox(srcEl, trgEl) {
    if ( srcEl.value == 1 ) {
        trgEl.setAttribute("checked", "1");
    } else {
        trgEl.removeAttribute("checked");
    }
}

/*
 * Save export settings
 */
function saveExportSettings(sourceForm, targetForm) {
    saveExportSettingsCheckbox(sourceForm.elements.includeContainerComment, targetForm.elements.includeContainerComment);
    saveExportSettingsCheckbox(sourceForm.elements.includePropertyComment, targetForm.elements.includePropertyComment);
    saveExportSettingsCheckbox(sourceForm.elements.dereferenceLinks, targetForm.elements.dereferenceLinks);
    saveExportSettingsCheckbox(sourceForm.elements.prefixKeys, targetForm.elements.prefixKeys);

    targetForm.elements.prefixKeysSeparator.value = sourceForm.elements.prefixKeysSeparator.value;
}

/*
 * Load export settings
 */
function loadExportSettings(sourceForm, targetForm) {
    loadExportSettingsCheckbox(sourceForm.elements.includeContainerComment, targetForm.elements.includeContainerComment);
    loadExportSettingsCheckbox(sourceForm.elements.includePropertyComment, targetForm.elements.includePropertyComment);
    loadExportSettingsCheckbox(sourceForm.elements.dereferenceLinks, targetForm.elements.dereferenceLinks);
    loadExportSettingsCheckbox(sourceForm.elements.prefixKeys, targetForm.elements.prefixKeys);

    targetForm.elements.prefixKeysSeparator.value = sourceForm.elements.prefixKeysSeparator.value;
}

/*
 * Generate export request based on curent settings
 */
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
