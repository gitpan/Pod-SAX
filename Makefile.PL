use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME' => 'Pod::SAX',
    'VERSION_FROM' => 'lib/Pod/SAX.pm',
    'PREREQ_PM' => { XML::SAX => 0.10, XML::SAX::Writer => 0.39, Pod::Parser => 0 },
    'ABSTRACT_FROM' => 'lib/Pod/SAX.pm',
    'AUTHOR' => 'Matt Sergeant <matt@sergeant.org>',
);
