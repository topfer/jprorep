$containerAttrs = ["cn","description"];
$propertyAttrs = ["cn","description","keyValue","keyType","valueType"];
$operationalAttrs = ['entryDN','creatorsName','createTimestamp','modifiersName','modifyTimestamp'];
my @allAttributes = ("objectClass", @$propertyAttrs, @$operationalAttrs);

# associative array for the memberOf implementation
undef %isOperational;
for (@$operationalAttrs) { $isOperational{$_} = 1; }

sub getLDAPEntry {

    my $nodeDN = $_[0];

    if ( ! defined $nodeDN || $nodeDN eq "" || $nodeDN eq "0" ) {
        $nodeDN = "dc=arcore,dc=amadeus,dc=com";
    }

    my $ldap = Net::LDAP->new ("localhost", port => 389, version => 3 );

    my $msg = $ldap->search(base => $nodeDN, scope => base, filter => "(objectclass=*)", attrs => \@allAttributes );

    return $msg->pop_entry();
}

sub generateInputLines {

    my $ldapEntry = $_[0];
    my $elemArray = $_[1];
    my $elemType = $_[2];
    my $loadValue = $_[3];
    my $readOnly = $_[4];

    my ($trStyle, $inputStyle);

    my $lineClass = "ldapEntryAttrInput ".$elemType;
    
    if ( $readOnly == 1 ) {
        $lineClass = $lineClass." readOnly";
    }

    foreach $attr (@$elemArray) {
        print "\n<tr class='".$lineClass."'>";
        print "<td width='150px' align='right'>".$attr."</td>";
        print "<td><input type='text' style='width:100%' name='".$attr."' ";
        if ( $loadValue ) {
            print "value='".$ldapEntry->get_value( $attr )."' ";
        };
        if ( $readOnly ) {
            print "readonly='true' ";
        };
        print "attibuteType='$elemType'/></td></tr>";
        #print "' value='".$ldapEntry->get_value( $attr )."' operational=";
        # style='background-color:#e0e0e0'
    }
};

sub generateInputForm {

    my $ldapEntry = $_[0];
    my $attributesArray = $_[1];
    my $classType = $_[2];
    my $loadValue = $_[3];
    my $readOnly = $_[4];
    my $predicate = $_[5];

    print "<div class='ldapEntryEdit' id='".$classType."'>";
    print "<table border='1' width='100%'>\n";
    print "<form name='".$classType."' action='update.pl'>\n";
    print "<input type='hidden' name='objectClass' value='".$classType."'>\n";
    print "<input type='hidden' name='predicate' value='".$predicate."'>\n";
    print "<input type='hidden' name='nodeDN' value='".$ldapEntry->get_value( "entryDN" )."'>";
    &generateInputLines($ldapEntry, $attributesArray, $classType, $loadValue, $readOnly);
    print "</form></table></div>";
}

sub generateClassTypeSelectionForm {

    my $preselectedValue = $_[0];
    my $readOnly = $_[1];

    print "\n<table border='1' width='100%'>";
    print "\n<form name='classTypeSelectionForm'>\n<tr><td width='150px' align='right'>objectClass</td>";
    print "<td><select name='objectClass' onchange='top.selectLDAPObjType(value)'";
    if ( $readOnly == 1 ) {
        print " disabled='true'";
    }
    print "><option></option>";
    print "<option value='propertyContainer'";
    if ($preselectedValue eq "propertyContainer") {
        print " selected='true'";
    }
    print ">propertyContainer</option>";
    print "<option value='propertyObject'";
    if ($preselectedValue eq "propertyObject") {
        print " selected='true'";
    }
    print ">propertyObject</option>";
    print "</select></td></tr>\n</form></table>\n";
}

sub generateCreateForm {

    my $ldapEntry = &getLDAPEntry($_[0]);

    &generateClassTypeSelectionForm;

    &generateInputForm($ldapEntry, $containerAttrs, "propertyContainer", 0, 0, "create");
    &generateInputForm($ldapEntry, $propertyAttrs, "propertyObject", 0, 0, "create");

    #&generateInputLines($operationalAttrs, "operational", 1, 1);

    print "</form>\n";
};

sub generateEditForm {

    my $ldapEntry = &getLDAPEntry($_[0]);

    &generateClassTypeSelectionForm($ldapEntry->get_value( "objectClass" ), 1);

    &generateInputForm($ldapEntry, $containerAttrs, "propertyContainer", 1, 0, "update");
    &generateInputForm($ldapEntry, $propertyAttrs, "propertyObject", 1, 0, "update");

    print "</form>\n";
};

sub generateViewForm {
    
    my $ldapEntry = &getLDAPEntry($_[0]);

    &generateClassTypeSelectionForm($ldapEntry->get_value( "objectClass" ), 1);

    if ($ldapEntry->get_value( "objectClass" ) eq "propertyContainer") {
        &generateInputForm($ldapEntry, $containerAttrs, "propertyContainer", 1, 1, "view");
    } else {
        &generateInputForm($ldapEntry, $propertyAttrs, "propertyObject", 1, 1, "view");
    }

    &generateInputLines($ldapEntry, $operationalAttrs, "operational", 1, 1);
}

1;

