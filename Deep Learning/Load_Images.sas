cas mysess;

caslib _all_ assign;
proc cas ;
   loadactionset 'image';
   loadImages / casout={name='_images_', caslib='casuser',replace=1} 
   path="/viyafiles/ankram/data/isic_images"
   labellevels=1
   recurse=True;
run;

proc print data=casuser._images_;
var _path_;
run;




cas mysess terminate;
