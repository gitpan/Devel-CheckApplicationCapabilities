use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'Devel::CheckApplicationCapabilities',
    META_MERGE => {
        license => 'other',
        resource => {
	    repository => 'https://github.com/DrHyde/perl-modules-Devel-CheckApplicationCapabilities'
        }
    },
    VERSION_FROM => 'lib/Devel/CheckApplicationCapabilities.pm',
    PREREQ_PM    => {
        'Test::More'       => 0.62,
        'File::Temp'       => 0.19,
        'File::Spec'       => 0,
        'File::Find::Rule' => 0,
    },
    clean         => { FILES => 't/morelib' },
);
