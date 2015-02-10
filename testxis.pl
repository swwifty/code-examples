# This script tests XiSecure to validate it is working as expected. It does this by encrypting some fake credit 
# cards in the cards file ($INPUTFILE) then attempts to decrypt them and compare the original input file with the
# output of the decrypted cards ($OUTPUTFILE2). The encrypted cards are stored in $OUTPUTFILE.
#
# To make this script work, install the XiSecure client. Then simply copy the test card file to the appropriate directory
# and set the host variable in this script to the appropriate XiSecure Server you wish to test. This can be a single server
# or even the load balancer IP.
#
# Last modified by David Gottschalk 1/15/2014

use File::Path;
use File::Copy;

# Set the java home directory
$java_home='"C:/Program Files/Java/jre7/bin"';

# Drive location for test case files
$drive="E:";
# This is the server we will test XiSecure against
$HOST="da-wb43";

# Set the directory for the input/output files (based on the host variable)
$MYMAPDIR="$drive\\testcases\\xisecure\\$HOST";

# URL that test will hit
$URLLOCATION="https://$HOST/XiSecureWS";

# This file contains the CCs to test encrypt
$INPUTFILE="$MYMAPDIR\\cards";

# This variable contains the path to the XiSecure Client jar file
$DIRTORUN="$drive\\testcases\\xisecure\\prdxisecure\\bin";

# The file below contains the encrypted CC output
$OUTPUTFILE="$MYMAPDIR\\outputcards";

# The file below contains the decrypted CC output (this should match the original unencrypted card file)
$OUTPUTFILE2="$MYMAPDIR\\outputcards2";

# Before we get started, we need to delete the outputfiles from the last instance of this script. (We don't want our comparisons to be false if XiSecureClient fails)
$del1="del $OUTPUTFILE";
$del2="del $OUTPUTFILE2";
# Delete the output files now
$delout1 = system($del1);
$delout2 = system($del2);

# here we test encrypting cards
$encryptcmd="$java_home//java -jar $DIRTORUN\\XiSecureClient.jar -i $INPUTFILE -o $OUTPUTFILE -u $URLLOCATION -d 0 -v -t 10 -p 1";
$encryptrun = system ($encryptcmd);

# now we verify XiSecure Client, command ran above, is working properly to encrypt cards
if ($encryptrun != 0) {
       die "Critical: XiSecure Client Failed for $HOST: Single Encrypt is having issues.";
  }

# here we test decrypting the cards we just encrypted
$decryptcmd="$java_home\\java -jar $DIRTORUN\\XiSecureClient.jar -i $OUTPUTFILE -o $OUTPUTFILE2 -u $URLLOCATION -d 0 -v -t 10 -p 0,1";
$decryptrun= system ($decryptcmd);

# now we verify XiSecure Client, command ran above, is working properly to decrypt cards
if ($decryptrun != 0) {
       die "Critical: XiSecure Client Failed for $HOST: Single Decrypt is having issues.";
  }

# here is logic to modify the output file (this is commented out unless you need to test. If it is not, it will give false 
# readings), and confirm our test logic is working properly. This simulates a XiSecure problem related to
# the output file (decrypted cards) not matching the input file (unencrypted cards)

# open the current decrypted cards file (this is after we have already done a encrypt/decrypt)
#open (FILEH, "$OUTPUTFILE2");
#@TMP = <FILEH>;
#close (FILEH); 

# Now reopen the output file, and filter out one of the credit cards.
#open OUTPUT, '>', $OUTPUTFILE2;
#foreach $line (@TMP) {
    # modify this line below to select which card to remove, or remove all cards, etc.
#   if ($line =~ m/4111111111111111/) {
#        next;
#	 } else {
#        print OUTPUT $line;
#	}
#}
#close OUTPUT;

# now we compare the original input CC file with the decrypted CC card to confirm XiSecure is working
# First we must load the files into arrays
open (INPUTF, "$INPUTFILE") || die ("Critical: XiSecure Test for $HOST: Cannot open input card file for comparision");
open (OUTPUTF2, "$OUTPUTFILE2") || die ("Critical: XiSecure Test for $HOST: Cannot open decrypted credit card file for comparision");
@FILEONE = <INPUTF>;
@FILETWO = <OUTPUTF2>;
close (INPUTF);
close (OUTPUTF2);

# Now we sort that array so we can properly compare
@file1 = sort { $a <=> $b } @FILEONE;
@file2 = sort { $a <=> $b } @FILETWO;

# Now load the arrays into a scalar context
$arrlength=scalar @file1-1;
$errorcount=0;
# Now loop to compare the lines and check for differences
for ($count = 0; $count <= $arrlength; $count++) {
  if ($file2[$count] =~ $file1[$count]){
   } else {
  $errorcount++;
  }
}

# Now we report back if the files are the same or not, based on our error count.
if ($errorcount > 0){
  die "Critical: XiSecure Data Validation Failed for $HOST: input/output files DO NOT MATCH.";
   } else {
  print "OK:  XiSecure Data Validation Passed for $HOST: Single Encrypt/Decrypt appear to be working";
  exit;
}
