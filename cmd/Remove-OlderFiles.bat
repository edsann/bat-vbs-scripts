GOTO COMMENT
Syntax
		FORFILES [/p Path] [/m SrchMask] [/s] [/c Command] [/d [+ | -] {date | dd}]   

	Key
	   /p Path      The Path to search  (default=current folder)
	   /m SrchMask  Select files matching the specified search mask
                default = *.*
	   /s           Recurse into sub-folders
	   /C command   The command to execute for each file.
                Wrap the command string in double quotes.
                Default = "cmd /c echo @file"
                The Command variables listed below can also be used in the
                command string.
	   /D date      Select files with a last modified date greater than or 
                equal to (+), or less than or equal to (-),
                the specified date, using the region specific date format
                typically "MM/DD/yyyy" or "DD/MM/yyyy"
	   /D + dd      Select files with a last modified date greater than or
                equal to the current date plus "dd" days. (in the future)
	   /D - dd      Select files with a last modified date less than or
                equal to the current date minus "dd" days. (in the past)
		A valid "dd" number of days can be any number in
                the range of 0 to 32768.   (89 years)
                "+" is taken as default sign if not specified.

	   Command Variables:
	      @file    The name of the file.
	      @fname   The file name without extension.                
	      @ext     Only the extension of the file.                  
	      @path    Full path of the file.
	      @relpath Relative path of the file.          
	      @isdir   Returns "TRUE" if a file type is a directory,
	               and "FALSE" for files.
	      @fsize   Size of the file in bytes.
	      @fdate   Last modified date of the file.
	      @ftime   Last modified time of the file.
 :COMMENT
 
 :: come test: printa tutti i file nel percorso indicato che soddisfano la condizione
 forfiles /p "C:\PATH\TO\FILE" /s /m *.* /D -NNNN /C "cmd /c echo @FILE"
	
 :: per cancellare tutti i file del percorso indicato che soddisfano la condizione
 forfiles /p "C:\PATH\TO\FILE" /s /m *.* /D -NNNN /C "cmd /c del @PATH"	
