use Test;
BEGIN { plan tests => 7 }
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
ok($output, qr/<link(\s+section=['"]['"]|\s+page=['"]page1['"]){2,2}/, "First link");
ok($output, qr/<link(\s+section=['"]mysection['"]|\s+page=['"]page2['"]){2,2}/, "Section and page valid");
ok($output, qr/<xlink\s+href=['"]http:\/\/axkit.org\/['"]/, "URL link");

__DATA__

=head1 NAME

SomePod - Some Pod to parse

=head1 DESCRIPTION

Foo here's a L<page1>

Here's a L<page2/mysection>

And a URL L<http://axkit.org/>

=head2 Sub Title

More

=cut
