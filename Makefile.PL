use ExtUtils::MakeMaker;
WriteMakefile(
	NAME => 'JSON::signature-to-image',
	#VERSION_FROM => 'signature-to-image.pl',
	VERSION => '1.0',
	EXE_FILES => ['signature-to-image.pl'],
	'dist' => { COMPRESS=>'gzip -9f', SUFFIX => 'gz' },
	($ExtUtils::MakeMaker::VERSION gt '6.30'? 
	  ('LICENSE'		=> 'perl', ) : ()),
	PREREQ_PM    => {
	  'GD'              => '0',
	  'JSON::Parse'     => '0',
	}
);
