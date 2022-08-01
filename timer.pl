#Get the arguments passed to the script
$input_file=$ARGV[0];
$output_file=$ARGV[1];

$sleepcmd="D:\\ptc\\custom_workers\\AutoCADWorker\\sleep.exe";
$sleepamount=1;
$timeout=150;
$killcommand="D:\\ptc\\custom_workers\\AutoCADWorker\\pskill.exe";
$timerstart="D:\\ptc\\custom_workers\\AutoCADWorker\\temp\\timerstart";
#$timerstart="D:\ptc\custom_workers\AutoCADWorker\temp\timerstart";
$timerstarted="D:\\ptc\\custom_workers\\AutoCADWorker\\temp\\timerstarted";
$timerstop="D:\\ptc\\custom_workers\\AutoCADWorker\\temp\\timerstop";
$timerstopped="D:\\ptc\\custom_workers\\AutoCADWorker\\temp\\timerstopped";
$PDFFailed="D:\\ptc\\custom_workers\\AutoCADWorker\\temp\\pdffailed";

$timerlog="D:\\ptc\\custom_workers\\AutoCADWorker\\temp\\timerlog.txt";

open(TIMERLOG,      "> $timerlog") || die("can't open datafile: $!");
print TIMERLOG "initialize";

#start the timer if the timestart file exists
$counter=1;
while($counter>0)
{
   print "w";
   system ("$sleepcmd $sleepamount");
   if (-e $timerstart) 
     {
     print TIMERLOG "File Exists!";
     $counter=0;
     } 
}

#let the other script know that the timer has started
open(TIMER,      "> $timerstarted") || die("can't open datafile: $!");
print TIMER "started";
print TIMERLOG "started";
close TIMER;

#first - let's set up a temporary log file based on date and time
($sec,$min,$hour,$mday,$mon,$year) = localtime();
print TIMERLOG "seconds $sec minutes $min\n";

$baseseconds=$min*60+$sec;
print TIMERLOG "baseseconds $baseseconds\n";

$counter=1;
while($counter>0)
{
   system ("$sleepcmd $sleepamount");
   print "z";

   #get new time
   ($secnew,$minnew,$hournew,$mdaynew,$monnew,$yearnew) = localtime();
   print TIMERLOG "seconds $secnew minutes $minnew\n";



   if ( $minnew < $min ) 
      { 
      $minnew=$minnew+60;
      }
   #Now convert to current seconds
   $newseconds=$minnew*60+$secnew;
   print TIMERLOG "newseconds $newseconds\n";
   
   #find the difference
   $difference=$newseconds-$baseseconds;
   if ( $difference > $timeout )
      {
      print TIMERLOG "timeout exceeded - conversion failed\n";
      print TIMERLOG "newseconds=$newseconds baseseconds=$baseseconds difference=$difference\n";
      #this means the conversion has failed
      #now create a file to show that the conversion has failed
      open(PDFFAILED,      "> $PDFFailed") || die("can't open datafile: $!");
      print PDFFAILED "failed";
      close PDFFAILED;      
      
      system "($killcommand visio.exe)";
      system "($killcommand pdfcreator.exe)";
      system "($killcommand wscript.exe)";
      
      open(STOPTIMER,      "> $timerstopped") || die("can't open datafile: $!");
      print STOPTIMER "stopped";
      close STOPTIMER;
      $counter=0;
      }
      
      #let the other script know that the timer has started
      
         if (-e $timerstop) 
           {
           print TIMERLOG "Stop Timer command received!";
           open(STOPTIMER,      "> $timerstopped") || die("can't open datafile: $!");
	   print STOPTIMER "stopped";
           close STOPTIMER;
           $counter=0;
     } 
 
}
close TIMERLOG;
