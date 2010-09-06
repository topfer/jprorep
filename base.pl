use POSIX qw(strftime);

$containerAttrs = ["cn","description"];
$propertyAttrs = ["cn","description","keyValue","keyType","valueType"];
$operationalAttrs = ['entryDN','creatorsName','createTimestamp','modifiersName','modifyTimestamp','childrenCount','aliasingEntryName'];
my @allAttributes = ("objectClass", @$propertyAttrs, @$operationalAttrs);

$ldap = Net::LDAP->new ("localhost", port => 389, version => 3 );

# associative array for the memberOf implementation
undef %isOperational;
for (@$operationalAttrs) { $isOperational{$_} = 1; }

sub printCurrTime() {
    my ($dateSpacer, $timeSpacer) = @_;

    if ( ! defined $dateSpacer ) {
        $dateSpacer = "/";
        $timeSpacer = ":";
    } else {
        $dateSpacer = $timeSpacer = "_";
    }

    return strftime("%Y".$dateSpacer."%b".$dateSpacer."%d".$timeSpacer."%H".$timeSpacer."%M".$timeSpacer."%S", localtime);
}

sub getLDAPEntry {
    my $nodeDN = $_[0];

    if ( ! defined $nodeDN || $nodeDN eq "" || $nodeDN eq "0" ) {
        $nodeDN = "dc=arcore,dc=amadeus,dc=com";
    }

    my $msg = $ldap->search(base => $nodeDN, scope => base, filter => "(objectclass=*)", attrs => \@allAttributes );
    #my $msg = $ldap->search(base => $nodeDN, , deref => never, scope => base, filter => "(objectclass=*)", attrs => \@allAttributes );

    return $msg->pop_entry();
}

sub generateInputLines {

    my ($ldapEntry, $elemArray, $elemType, $loadValue, $readOnly) = @_;

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

    my ($ldapEntry, $attributesArray, $classType, $loadValue, $readOnly, $predicate) = @_;

    print "\n<div class='ldapEntryEditHidden' id='".$classType."'>";
    print "<table border='1' width='100%'>\n";
    print "<form name='".$classType."' action='update.pl'>\n";
    print "<input type='hidden' name='predicate' value='".$predicate."'>\n";
    print "<input type='hidden' name='nodeDN' value='".$ldapEntry->get_value( "entryDN" )."'>";
    if ( $predicate eq 'create' ) {
        &generateClassTypeSelection($classType, 0);
    } else {
        &generateClassTypeSelection($classType, 1);
    };
    &generateInputLines($ldapEntry, $attributesArray, $classType, $loadValue, $readOnly);
}

sub generateClassTypeSelection {

    my $preselectedValue = $_[0];
    my $readOnly = $_[1];

    if ( $readOnly == 1 ) {
        print "<input type='hidden' name='objectClass' value='$preselectedValue'/>\n";
    }

    print "\n<tr><td width='150px' align='right'>objectClass</td>\n";
    print "<td><select name='objectClass' onchange='top.selectLDAPEntryForm(value)'";
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
    print "</select></td>\n</tr>";
}

sub generateCreateForm {

    my $ldapEntry = $_[0];

    &generateInputForm($ldapEntry, $containerAttrs, "propertyContainer", 0, 0, "create");
    print "</form></table></div>";
    &generateInputForm($ldapEntry, $propertyAttrs, "propertyObject", 0, 0, "create");
    print "</form></table></div>";
};

sub generateEditForm {

    my $ldapEntry = $_[0];

    if ($ldapEntry->get_value( "objectClass" ) eq "propertyContainer") {
        &generateInputForm($ldapEntry, $containerAttrs, "propertyContainer", 1, 0, "update");
    } else {
        &generateInputForm($ldapEntry, $propertyAttrs, "propertyObject", 1, 0, "update");
    }
    print "</form></table></div>";
};

sub generateViewForm {
    
    my $ldapEntry = $_[0];

    if ($ldapEntry->get_value( "objectClass" ) eq "propertyContainer") {
        &generateInputForm($ldapEntry, $containerAttrs, "propertyContainer", 1, 1, "view");
    } else {
        &generateInputForm($ldapEntry, $propertyAttrs, "propertyObject", 1, 1, "view");
    }
    
    &generateInputLines($ldapEntry, $operationalAttrs, "operational", 1, 1);
    print "</form></table></div>";
}

1;

