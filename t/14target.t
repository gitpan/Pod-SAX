use Test;
BEGIN { plan tests => 5 }
use Pod::SAX;
use XML::SAX::Writer;

my $output = '';
my $p = Pod::SAX->new(
            Handler => XML::SAX::Writer->new(
                Output => \$output
                )
            );

ok($p);
$p->parse_file(\*DATA);
ok($output);
print "$output\n";
ok($output, qr/<pod>.*<\/pod>/s, "Matches basic pod outline");
ok($output, qr/<link/, "Contains a link");
ok($output, qr/<xlink\s+href=['"]http:\/\/axkit.org\/['"]/, "URL link");

__DATA__

=head1 NAME

SomePod - Some Pod to parse

=head1 DESCRIPTION

Foo here's a L<page1>

Here's a L<page2/mysection>

Here's a L<Some Text|page3/mysection>

And a URL L<http://axkit.org/>

A link with text L<Some Text|Link>

=head2 Sub Title

More

=over

=item Link in =item: L<link>

=item Link with text in =item: L<Some text|LinkHere>

=back

A really complex link example from TorgoX:

L<< SWITCH B<<< E<115>tatements >>>|perlsyn/Basic I<<<< BLOCKs >>>> and Switch StatementE<115> >>

=cut
