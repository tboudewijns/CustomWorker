#Get the arguments passed to the script
$input_file=$ARGV[0];
$output_file=$ARGV[1];

$timerstart="C:\\ptc\\custom_workers\\AutoCADWorker\\temp\\timerstart";
$timerstop="C:\\ptc\\custom_workers\\AutoCADWorker\\temp\\timerstop";
$timerstopped="C:\\ptc\\custom_workers\\AutoCADWorker\\temp\\timerstopped";
$timerstarted="C:\\ptc\\custom_workers\\AutoCADWorker\\temp\\timerstarted";
$PDFFailed="C:\\ptc\\custom_workers\\AutoCADWorker\\temp\\pdffailed";

$sleepcmd="C:\\ptc\\custom_workers\\AutoCADWorker\\sleep.exe";
$sleepamount=1;

#first - let's set up a temporary log file based on date and time
($sec,$min,$hour,$mday,$mon,$year) = localtime();

$year=$year+1900;
$stub = sprintf("%02d%02d%02d@%02d%02d%02d", $year,$mon,$mday,$hour,$min,$sec);

$logdir = "log/";

$log_file_name = $logdir.$stub.'log';

#open the file in append mode - we'll need it ater on
open(LOGFILE,	">> $log_file_name");

#Define the name of the input file
#print "input file $input_file\n";
print LOGFILE "***** CUSTOM WORKER *****\n";
print LOGFILE "input_file  = $input_file\n";

#read the ini file and get all the data about the conversion - what Windchill has provided and what Windchill expects back
open(LIST,      "< $input_file") || die("can't open datafile: $!");
  @list_data=<LIST>;
  $total_in_list=scalar(@list_data);
      $listelement=$list_data[0];
      chomp($listelement);
      print LOGFILE "listelement $listelement\n";
      ($sw_object,$sw_ext,$rep_name,$number,$temp_dir_name,$temp_dir_name_two)=split(/ /,$listelement);
      # this gives a list of objects
      # sw_object - the filename
      # sw_ext - the extension
      # rep_name - the rep number
      # number - unused
      # temp_dir_name - input directory
      # temp_dir_two_name - output directory.
      #
      print LOGFILE "Parameters : \n\tOBJ: $sw_object\n\tEXT: $sw_ext\n\tREP: $rep_name\n\tNUM: $number\n\tDIR: $temp_dir_name\n\tDIR: $temp_dir_name_two\n";
close LIST;

#this regular expression replaces @_ with space
$sw_object=~ s/\@_/ /g;
print LOGFILE "OBJ translates as :" . $sw_object . "\n";

#Now we need to create the pdf file
#rebuild the name of the document to be converted to a pdf
$convert_name=join "",$temp_dir_name,"\\",$sw_object,".",$sw_ext;

print LOGFILE "Converting : $convert_name to PDF\n";

#$ed_temp_dir="D:\\ptc\\custom_workers\\AutoCADWorker\\temp\\";
$ed_temp_dir = $temp_dir_name_two;
#the name of the ed files should be

#build the name of the file we are going to create
$ed_file_name=join "",$temp_dir_name_two,"\\",$sw_object,".pdf";
print LOGFILE "and generating : $ed_file_name\n";

# This lot seems to be specifying special behaviour for VISIO file objects.
# temporarily commented out
#if ( $sw_ext eq 'vsd' )
#{
#$ed_file_name=join("",$temp_dir_name,"\\","Visio-",$sw_object,".pdf");
#}

#$ed_file_name=join "",$convert_name,".ed";
print LOGFILE "ed_file_name $ed_file_name\n";

#start the converter as soon as the timer has started

#start the timer 
#let the other script know that the timer has to be started
#this is done by creating a file called timerstart
#as soon as the file exists the timer will start up
open(STARTTIMER,      "> $timerstart") || die("can't open datafile: $!");
print STARTTIMER "start";
close STARTTIMER;

#continue as soon as we know that the timer has started
#the timer creates a file called timerstarted
#as soon as the file exists we can continue
$counter=1;
while($counter>0)
{
   print "w";
   system ("$sleepcmd $sleepamount");
   if (-e $timerstarted) 
     {
     print "Timer Started!";
     $counter=0;
     } 
}
#print LOGFILE "\"C:\\program files\\VeryPDF PDFcamp Printer Pro v2.3\\BatchPDF.exe\" $convert_name $temp_dir_name\n";
#system ("\"C:\\program files\\VeryPDF PDFcamp Printer Pro v2.3\\BatchPDF.exe\" $convert_name $temp_dir_name");

# Log the activity and attempt the execution
print LOGFILE " Executing \"D:\\ptc\\custom_workers\\AutoCADWorker\\doc2pdf.vbs\" \"$convert_name\"\n";
system ("\"D:\\ptc\\custom_workers\\AutoCADWorker\\doc2pdf.vbs\" \"$convert_name\"");
print LOGFILE "conversion has completed good or bad \n";

#the conversion has comp[leted or failed
#now we need to shut down the timer
#this is done by creating the file timerstop
open(STARTTIMER,      "> $timerstop") || die("can't open datafile: $!");
print STARTTIMER "start";
close STARTTIMER;

#Now we need to wait for the timer to be stopped
#the timer will create a file called timerstopped
#as soon as this file is created we can continue
$counter=1;
while($counter>0)
{
   print "w";
   system ("$sleepcmd $sleepamount");
   if (-e $timerstopped) 
     {
     print "Timer Stopped!";
     $counter=0;
     } 
}

#now we need to cleanup the timer files
system ("del /F /Q $timerstart $timerstop $timerstarted $timerstopped");


#let's get a copy of the output to see what's going on.
#system ("mkdir $temp_dir_name-new");
#system ("copy $temp_dir_name\\*.* $temp_dir_name-new");


#system ("copy $ed_file_name D:\\ptc\\proe-stepworker\\");

#Define the name of the PDMLink output file
($out_base,$out_ext)=split('.in',$input_file);
print LOGFILE "out_base = $out_base\n";
$output_file=join "",$out_base,".out";

print LOGFILE "output_file $output_file\n";
#open(OUTPUTFILE,      "> $output_file") || die("can't open datafile: $!");
#   print OUTPUTFILE "0 $ed_file_name";
#   print LOGFILE "0 $ed_file_name\n";

# backup up the output file for debug use
#system ("copy $output_file C:\\ptc\\custom_workers\\AutoCADWorker\\convert");

if (-e $PDFFailed) 
  {
  #conversion failed and create the output file
  system ("echo 1 Conversion Failed due to timeout in PDF creation. > $output_file");
  #print "FAILED ed_file_name $ed_file_name $output_file\n";
  print LOGFILE "FAILED - ed_file_name [$ed_file_name] $output_file\n";
  } 
else
  {
  
  if (-e $ed_file_name) {
     #conversion successful create output file
     system ("echo 0 $ed_file_name > $output_file");
     print LOGFILE "SUCCESS ed_file_name [$ed_file_name] $output_file\n";
  } else {
     system ("echo 1 Conversion failed due to error creating $ed_file_name");
     print LOGFILE "FAILED - 1 error creating $ed_file_name\n";
  }
}

#now we need to cleanup the timer files
system ("del /F /Q $PDFFailed");

#close OUTPUTFILE;
close LOGFILE;
