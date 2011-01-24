use Switch;
use POSIX qw(strftime);

open(CGILOG, ">> /tmp/cgi.log");

$containerAttrs = ["cn","description"];
$aliasAttrs = ["cn","aliasedObjectName","inheritLevel"];
$propertyAttrs = ["cn","description","keyValue","keyType","valueType","aliasedObjectName","inheritLevel"];
$operationalAttrs = ['entryDN','creatorsName','createTimestamp','modifiersName','modifyTimestamp','childrenCount','aliasingEntryName'];
my @allAttributes = ("objectClass", @$propertyAttrs, @$operationalAttrs);

$ldap = Net::LDAP->new ("localhost", port => 389, version => 3 );

# associative array for the memberOf implementation
undef %isOperational;
for (@$operationalAttrs) { $isOperational{$_} = 1; }

#the last two arguments are not actually used yet
sub printCurrTime {
    my ($dateSpacer, $timeSpacer, $dateTimeSpacer) = @_;

    if ( scalar(@_) == 0 ) {
        $dateSpacer = "/";
        $timeSpacer = ":";
        $dateTimeSpacer = " ";
    } else {
        $dateSpacer = $timeSpacer = $dateTimeSpacer = "_";
    }

    return strftime("%Y".$dateSpacer."%b".$dateSpacer."%d".$dateTimeSpacer."%H".$timeSpacer."%M".$timeSpacer."%S", localtime);
}

sub logtime {
    return "[".printCurrTime()."] ";
}

sub getLDAPEntry {
    my ($nodeDN, $derefLink) = @_;
    my $msg;

    if ( ! defined $nodeDN || $nodeDN eq "" || $nodeDN eq "0" ) {
        $nodeDN = "dc=arcore,dc=amadeus,dc=com";
    }

    if ( defined $derefLink ) {
        $msg = $ldap->search(base => $nodeDN, scope => base, filter => "(objectclass=*)", attrs => \@allAttributes, deref => "never" );
    } else {
        $msg = $ldap->search(base => $nodeDN, scope => base, filter => "(objectclass=*)", attrs => \@allAttributes );
    }
    #my $msg = $ldap->search(base => $nodeDN, scope => base, filter => "(objectclass=*)", attrs => \@allAttributes );
    #my $msg = $ldap->search(base => $nodeDN, scope => base, filter => "(objectclass=*)", attrs => \@allAttributes, deref => never );

    return $msg->pop_entry();
}

sub generateInputLines {

    my ($ldapEntry, $elemArray, $elemType, $loadValue, $readOnly) = @_;

    my ($trStyle, $inputStyle, $currAttrVal);

    my $lineClass = "ldapEntryAttrInput ".$elemType;
    
    if ( $readOnly == 1 ) {
        $lineClass = $lineClass." readOnly";
    }

    foreach $attr (@$elemArray) {

        if ( $loadValue ) {
            $currAttrVal = $ldapEntry->get_value( $attr );
        }

        if (! defined $currAttrVal) {
            $currAttrVal = "";
        }

        #print CGILOG logtime().$attr."=".$myAttrVal."\n";
        print "\n<tr class='".$lineClass."'>";
        print "<td width='150px' align='right'>".$attr."</td>";
        print "<td><input type='text' style='width:100%' name='".$attr."' ";
        if ( $loadValue ) {
            print "value='".$currAttrVal."' ";
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
        generateClassTypeSelection($classType, 0);
    } else {
        generateClassTypeSelection($classType, 1);
    };
    generateInputLines($ldapEntry, $attributesArray, $classType, $loadValue, $readOnly);
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
    print "<option value='inheritingAlias'";
    if ($preselectedValue eq "inheritingAlias") {
        print " selected='true'";
    }
    print ">alias</option>";
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

    #print CGILOG logtime().$ldapEntry->dn()." type ".$ldapEntry->get_value("objectClass")."\n";

    switch ( $ldapEntry->get_value( "objectClass" ) ) {
        case "propertyContainer" {
            generateInputForm($ldapEntry, $containerAttrs, "propertyContainer", 1, 0, "update");
        }
        case "propertyObject" {
            generateInputForm($ldapEntry, $propertyAttrs, "propertyObject", 1, 0, "update");
        }
        case "inheritingAlias" {
            generateInputForm($ldapEntry, $aliasAttrs, "inheritingAlias", 1, 0, "update");
        }
        else {
            print "\n<h2>Unknown LDAP entry type:".$ldapEntry->get_value( "objectClass" )."</h2>";
            #generateInputForm($ldapEntry, $propertyAttrs, "propertyObject", 1, 1, "update");
        }
    }

    print "</form></table></div>";
};

sub generateViewForm {
    
    my $ldapEntry = $_[0];

    #print CGILOG logtime().$ldapEntry->dn()." type ".$ldapEntry->get_value("objectClass")."\n";

    switch ( $ldapEntry->get_value( "objectClass" ) ) {
        case "propertyContainer" {
            generateInputForm($ldapEntry, $containerAttrs, "propertyContainer", 1, 1, "view");
        }
        case "propertyObject" {
            generateInputForm($ldapEntry, $propertyAttrs, "propertyObject", 1, 1, "view");
        }
        case "inheritingAlias" {
            generateInputForm($ldapEntry, $aliasAttrs, "inheritingAlias", 1, 1, "view");
        }
        else {
            print "\n<h2>Unknown LDAP entry type:".$ldapEntry->get_value( "objectClass" )."</h2>";
            #generateInputForm($ldapEntry, $propertyAttrs, "propertyObject", 1, 1, "view");
        }
    }
    
    &generateInputLines($ldapEntry, $operationalAttrs, "operational", 1, 1);
    print "</form></table></div>";
}

1;

