# $Id: SAX.pm,v 1.19 2002/08/30 15:15:22 matt Exp $

package Pod::SAX;

$VERSION = '0.11';
use XML::SAX::Base;
@ISA = qw(XML::SAX::Base);

use strict;
use XML::SAX::DocumentLocator;

sub _parse_bytestream {
    my ($self, $fh) = @_;
    my $parser = Pod::SAX::Parser->new();
    $parser->set_parent($self);
    $parser->parse_from_filehandle($fh, undef);
}

sub _parse_characterstream {
    my ($self, $fh) = @_;
    die "parse_characterstream not supported";
}

sub _parse_string {
    my ($self, $str) = @_;
    my $parser = Pod::SAX::Parser->new();
    $parser->set_parent($self);
    my $strobj = Pod::SAX::StringIO->new($str);
    $parser->parse_from_filehandle($strobj, undef);
}

sub _parse_systemid {
    my ($self, $sysid) = @_;
    my $parser = Pod::SAX::Parser->new();
    $parser->set_parent($self);
    $parser->parse_from_file($sysid, undef);
}

package Pod::SAX::Parser;

use Pod::Parser;
use vars qw(@ISA %HTML_Escapes);
@ISA = qw(Pod::Parser);

%HTML_Escapes = (
    'amp'       =>      '&',    #   ampersand
    'lt'        =>      '<',    #   left chevron, less-than
    'gt'        =>      '>',    #   right chevron, greater-than
    'quot'      =>      '"',    #   double quote
    'sol'       =>      '/',    #   slash
    'verbar'    =>      '|',    #   vertical bar

    "Aacute"    =>      "\xC1", #   capital A, acute accent
    "aacute"    =>      "\xE1", #   small a, acute accent
    "Acirc"     =>      "\xC2", #   capital A, circumflex accent
    "acirc"     =>      "\xE2", #   small a, circumflex accent
    "AElig"     =>      "\xC6", #   capital AE diphthong (ligature)
    "aelig"     =>      "\xE6", #   small ae diphthong (ligature)
    "Agrave"    =>      "\xC0", #   capital A, grave accent
    "agrave"    =>      "\xE0", #   small a, grave accent
    "Aring"     =>      "\xC5", #   capital A, ring
    "aring"     =>      "\xE5", #   small a, ring
    "Atilde"    =>      "\xC3", #   capital A, tilde
    "atilde"    =>      "\xE3", #   small a, tilde
    "Auml"      =>      "\xC4", #   capital A, dieresis or umlaut mark
    "auml"      =>      "\xE4", #   small a, dieresis or umlaut mark
    "Ccedil"    =>      "\xC7", #   capital C, cedilla
    "ccedil"    =>      "\xE7", #   small c, cedilla
    "Eacute"    =>      "\xC9", #   capital E, acute accent
    "eacute"    =>      "\xE9", #   small e, acute accent
    "Ecirc"     =>      "\xCA", #   capital E, circumflex accent
    "ecirc"     =>      "\xEA", #   small e, circumflex accent
    "Egrave"    =>      "\xC8", #   capital E, grave accent
    "egrave"    =>      "\xE8", #   small e, grave accent
    "ETH"       =>      "\xD0", #   capital Eth, Icelandic
    "eth"       =>      "\xF0", #   small eth, Icelandic
    "Euml"      =>      "\xCB", #   capital E, dieresis or umlaut mark
    "euml"      =>      "\xEB", #   small e, dieresis or umlaut mark
    "Iacute"    =>      "\xCD", #   capital I, acute accent
    "iacute"    =>      "\xED", #   small i, acute accent
    "Icirc"     =>      "\xCE", #   capital I, circumflex accent
    "icirc"     =>      "\xEE", #   small i, circumflex accent
    "Igrave"    =>      "\xCD", #   capital I, grave accent
    "igrave"    =>      "\xED", #   small i, grave accent
    "Iuml"      =>      "\xCF", #   capital I, dieresis or umlaut mark
    "iuml"      =>      "\xEF", #   small i, dieresis or umlaut mark
    "Ntilde"    =>      "\xD1",         #   capital N, tilde
    "ntilde"    =>      "\xF1",         #   small n, tilde
    "Oacute"    =>      "\xD3", #   capital O, acute accent
    "oacute"    =>      "\xF3", #   small o, acute accent
    "Ocirc"     =>      "\xD4", #   capital O, circumflex accent
    "ocirc"     =>      "\xF4", #   small o, circumflex accent
    "Ograve"    =>      "\xD2", #   capital O, grave accent
    "ograve"    =>      "\xF2", #   small o, grave accent
    "Oslash"    =>      "\xD8", #   capital O, slash
    "oslash"    =>      "\xF8", #   small o, slash
    "Otilde"    =>      "\xD5", #   capital O, tilde
    "otilde"    =>      "\xF5", #   small o, tilde
    "Ouml"      =>      "\xD6", #   capital O, dieresis or umlaut mark
    "ouml"      =>      "\xF6", #   small o, dieresis or umlaut mark
    "szlig"     =>      "\xDF",         #   small sharp s, German (sz ligature)
    "THORN"     =>      "\xDE", #   capital THORN, Icelandic
    "thorn"     =>      "\xFE", #   small thorn, Icelandic
    "Uacute"    =>      "\xDA", #   capital U, acute accent
    "uacute"    =>      "\xFA", #   small u, acute accent
    "Ucirc"     =>      "\xDB", #   capital U, circumflex accent
    "ucirc"     =>      "\xFB", #   small u, circumflex accent
    "Ugrave"    =>      "\xD9", #   capital U, grave accent
    "ugrave"    =>      "\xF9", #   small u, grave accent
    "Uuml"      =>      "\xDC", #   capital U, dieresis or umlaut mark
    "uuml"      =>      "\xFC", #   small u, dieresis or umlaut mark
    "Yacute"    =>      "\xDD", #   capital Y, acute accent
    "yacute"    =>      "\xFD", #   small y, acute accent
    "yuml"      =>      "\xFF", #   small y, dieresis or umlaut mark

    "lchevron"  =>      "\xAB", #   left chevron (double less than)
    "rchevron"  =>      "\xBB", #   right chevron (double greater than)
);

sub sex {
    require Data::Dumper;$Data::Dumper::Indent=1;warn(Data::Dumper::Dumper(@_));
}

sub set_parent {
    my $self = shift;
    $self->{parent} = shift;
}

sub parent {
    my $self = shift;
    return $self->{parent};
}

sub begin_pod {
    my $self = shift;
    my $sysid = $self->parent->{ParserOptions}->{Source}{SystemId};
    $self->parent->set_document_locator(
         XML::SAX::DocumentLocator->new(
            sub { "" },
            sub { $sysid },
            sub { $self->{line_number} },
            sub { 0 },
        ),
    );
    $self->parent->start_document({});
    $self->parent->start_element(_element('pod'));
    $self->parent->characters({Data => "\n"});
    $self->parent->comment({Data => " Pod::SAX v$Pod::SAX::VERSION, using POD::Parser v$Pod::Parser::VERSION "});
    $self->parent->characters({Data => "\n"});
}

sub end_pod {
    my $self = shift;
    if ($self->{in_verbatim}) {
	$self->parent->end_element(_element('verbatim', 1));
	$self->parent->characters({Data => "\n"});
    }
    while ($self->{in_list}) {
	$self->close_list();
    }
    $self->parent->end_element(_element('pod', 1));
    $self->parent->end_document({});
}

sub open_list {
    my $self = shift;
    my ($list_type) = @_;
    $self->{list_type}[$self->{in_list}] = $list_type;
    $self->parent->characters({Data => (" " x $self->{in_list})});
    my $el = _element($list_type);
    _add_attrib($el, indent_width => $self->{indent});
    $self->parent->start_element($el);
    $self->parent->characters({Data => "\n"});
    $self->{open_lists}--;
    return;
}

sub close_list {
    my $self = shift;
    
    if ($self->{in_item}) {
	$self->parent->end_element(_element('listitem', 1));
	$self->parent->characters({Data => "\n"});
	$self->{in_item}--;
    }
    
    my $list_type = $self->{list_type}[$self->{in_list}];
    $self->{list_type}[$self->{in_list}] = undef;
    $self->parent->characters({Data => (" " x $self->{in_list})});
    $self->{in_list}--;
    $self->parent->end_element(_element($list_type, 1));
    $self->parent->characters({Data => "\n"});
    return;
}

sub command { 
    my ($self, $command, $paragraph, $line_num) = @_;
    ## Interpret the command and its text; sample actions might be:
    $self->{line_number} = $line_num;
    $paragraph =~ s/\s*$//;
    $paragraph =~ s/^\s*//;
    
    if ($self->{in_verbatim}) {
	$self->parent->end_element(_element('verbatim', 1));
	$self->parent->characters({Data => "\n"});
	$self->{in_verbatim} = 0;
    }
    
    if ($command eq 'over') {
	$self->{in_list}++;
	$self->{open_lists}++;
	my $indent = ($paragraph ? $paragraph + 0 : 4);
	$self->{indent} = $indent;
	return;
    }
    elsif ($command eq 'back') {
	if ($self->{in_list}) {
	    $self->close_list();
	}
	else {
	    throw XML::SAX::Exception::Parse ( 
					      Message => "=back without =over",
					      LineNumber => $self->{line_number},
					      ColumnNumber => 0,
					      );
	}
	return;
    }
    elsif ($command eq 'item') {
	if (!$self->{in_list}) {
	    throw XML::SAX::Exception::Parse (
					      Message => "=item without =over",
					      LineNumber => $self->{line_number},
					      ColumnNumber => 0,
					      );
	}
	if ($self->{open_lists}) {
	    # determine list type, and open list tag
	    my $list_type = 'itemizedlist';
	    $paragraph =~ s|^\s* \*  \s*||x and $list_type = 'itemizedlist';
	    $paragraph =~ s|^\s* \d+\.? \s*||x and $list_type = 'orderedlist';
	    $self->open_list($list_type);
	}
	else {
	    if ($self->{list_type}[$self->{in_list}] eq 'itemizedlist') {
		$paragraph =~ s|^\s* \*  \s*||x;
	    }
	    elsif ($self->{list_type}[$self->{in_list}] eq 'orderedlist') {
		$paragraph =~ s|^\s* \d+\.? \s*||x;
	    }
	    
	    if ($self->{in_item}) {
		# close the last one
		$self->parent->end_element(_element('listitem', 1));
		$self->parent->characters({Data => "\n"});
		$self->{in_item}--;
	    }
	}
	
	$self->parent->characters({Data => " ".(" " x $self->{in_list})});
	
	$self->parent->start_element(_element('listitem'));
	if ($paragraph) {
	    $self->parse_text({ -expand_ptree => 'expand_ptree' }, $paragraph, $line_num);
	    $self->parent->characters({Data => "\n"});
	}
	$self->{in_item}++;
	return;
    }
    elsif ($command eq 'begin' || $command eq 'for') {
	if ($self->{open_lists}) {
	    # non =item command while in =over section - must be indented
	    my $list_type = 'indent';
	    $self->open_list($list_type);
	}
	
	my $el = _element('markup');
	$paragraph =~ s/^(\S*)\s*//;
	my $type = $1;
	my $process_paragraphs = 0;
	if ($type =~ /^:(.*)$/) {
	    $process_paragraphs = 1;
	    $type = $1;
	}
	_add_attrib($el, type => $type);
	_add_attrib($el, ordinary_paragraph => $process_paragraphs);
	$self->parent->start_element($el);
	if ($process_paragraphs) {
	    $self->parse_text({ -expand_ptree => 'expand_ptree' }, $paragraph, $line_num);
	}
	else {
	    $self->parent->characters({Data => $paragraph});
	}
	$self->parent->end_element(_element('markup', 1)) if $command eq 'for';
	$self->{in_begin_section} = 1 if $command eq 'begin';
	return;
    }
    elsif ($command eq 'end') {
	if ($self->{open_lists}) {
	    # non =item command while in =over section - must be indented
	    my $list_type = 'indent';
	    $self->open_list($list_type);
	}
	
	if ($self->{in_begin_section}) {
	    $self->parent->end_element(_element('markup'));
	    $self->{in_begin_section} = 0;
	}
	else {
	    throw XML::SAX::Exception::Parse (
					      Message => "=end without =begin",
					      LineNumber => $self->{line_number},
					      ColumnNumber => 0,
					      );
	}
	return;
    }
    elsif ($self->{in_list}) {
	throw XML::SAX::Exception::Parse (
					  Message => "=$command inside =over/=end block is not allowed",
					  LineNumber => $self->{line_number},
					  ColumnNumber => 0,
					  );
    }
    
    if ($command eq 'pod') {
	return;
    }
    
    $self->parent->start_element(_element($command));
    $self->parse_text({ -expand_ptree => 'expand_ptree' }, $paragraph, $line_num);
    $self->parent->end_element(_element($command, 1));
    $self->parent->characters({Data => "\n"});
}

sub verbatim { 
    my ($self, $paragraph, $line_num) = @_;
    $self->{line_number} = $line_num;
    
    my $text = $paragraph;
    $text =~ s/\n\z//;
    
    if ($self->{open_lists}) {
	# non =item command while in =over section - must be indented
	$self->open_list('indent');
    }
    
    return unless $paragraph =~ /\S/;
    
    my $last_verbatim = 0;
    if ($text =~ /\n\z/) {
	$last_verbatim = 1;
    }
    
    $self->parent->start_element(_element('verbatim')) unless $self->{in_verbatim};
    $self->parent->characters({Data => "\n\n"}) if $self->{in_verbatim};
    $self->{in_verbatim} = 1;
    
    if ($paragraph =~ s/^(\s*)//) {
        my $indent = $1;

        $paragraph =~ s/\s*$//;
        return unless length $paragraph;
        $paragraph =~ s/^$indent//mg; # un-indent
	$self->parent->characters({Data => $paragraph});
    }
    
    if ($last_verbatim) {
	$self->parent->end_element(_element('verbatim', 1));
	$self->parent->characters({Data => "\n"});
	$self->{in_verbatim} = 0;
    }
}

sub textblock { 
    my ($self, $paragraph, $line_num) = @_;
    $self->{line_number} = $line_num;

    if ($self->{open_lists}) {
	# non =item command while in =over section - must be indented
	my $list_type = 'indent';
	$self->{list_type}[$self->{in_list}] = $list_type;
	$self->parent->characters({Data => (" " x $self->{in_list})});
	my $el = _element($list_type);
	_add_attrib($el, indent_width => $self->{indent});
	$self->parent->start_element($el);
	$self->parent->characters({Data => "\n"});
	$self->{open_lists}--;
    }
    if ($self->{in_verbatim}) {
	$self->parent->end_element(_element('verbatim', 1));
	$self->parent->characters({Data => "\n"});
	$self->{in_verbatim} = 0;
    }
	
    
    $paragraph =~ s/^\s*//;
    $paragraph =~ s/\s*$//;
    
    $self->parent->start_element(_element('para'));
    $self->parse_text({ -expand_ptree => 'expand_ptree' }, $paragraph, $line_num);
    $self->parent->end_element(_element('para', 1));
    $self->parent->characters({Data => "\n"});
}

sub expand_ptree {
    my ($self, $ptree) = @_;
    foreach my $node ($ptree->children) {
	# warn("Expand_ptree($node)\n");
	if (ref($node)) {
	    $self->expand_seq($node);
	}
	else {
	    $self->parent->characters({Data => $node});
	}
    }
}

# Copied from Pod::Tree::Node
sub SplitTarget
{
    my $text = shift;
    my($page, $section);
    
    if ($text =~ /^"(.*)"$/s)     # L<"sec">;
    {
	$page    = '';
	$section = $1;
    }
    else                          # all other cases
    {
	($page, $section) = split m(/), $text, 2;
	
	# to quiet -w
	defined $page    or $page    = '';
	defined $section or $section = '';
	
	$page    =~ s/\s*\(\d\)$//;    # ls (1) -> ls
	$section =~ s( ^" | "$ )()xg;  # lose the quotes
	
	# L<section in this man page> (without quotes)
	if ($page !~ /^[\w.-]+(::[\w.-]+)*$/ and $section eq '')
	{
	    $section = $page;
	    $page = '';
	}
    }
    
    $section =~ s(   \s*\n\s*   )( )xg;  # close line breaks
    $section =~ s( ^\s+ | \s+$  )()xg;   # clip leading and trailing WS
    
    ($page, $section)
}

sub expand_seq {
    my ($self, $sequence) = @_;
    
    my $name = $sequence->cmd_name;
    my ($filename, $line_number) = $sequence->file_line();
    $self->{line_number} = $line_number;
    
    # warn("seq $name\n");
    
    if ($name eq 'L') {
	# link
	
	my $link = $sequence->raw_text;
	$link =~ s/^L<(.*)>$/$1/;
        $link =~ s/^<+\s(.*)\s>+$/$1/;
	my ($text, $inferred, $name, $section, $type) = parselink($link);
	$text = '' unless defined $text;
	$inferred = '' unless defined $inferred;
	$name = '' unless defined $name;
	$section = '' unless defined $section;
	$type = '' unless defined $type;

	# warn("Link L<$link> parsed into: '$text', '$inferred', '$name', '$section', '$type'\n");
	
	if ($type eq 'url') {
	    my $start = _element("xlink");
	    _add_attrib($start, href => $name);
	    
	    $self->parent->start_element($start);
	    $self->parse_text({ -expand_ptree => 'expand_ptree' }, $inferred, $line_number);
	    $self->parent->end_element(_element('xlink', 1));
	}
	else {
	    my $start = _element("link");
	    _add_attrib($start, page => $name);
	    _add_attrib($start, section => $section);
	    _add_attrib($start, type => $type);
	    
	    $self->parent->start_element($start);
            $self->parse_text({ -expand_ptree => 'expand_ptree' }, $inferred, $line_number);
	    $self->parent->end_element(_element('link', 1));
	}
    }
    elsif ($name eq 'E') {
	my $text = join('', $sequence->parse_tree->children);
	my $char;
	if ($text =~ /^\d+$/) {
	    $char = chr($text);
	}
	else {
	    $char = $HTML_Escapes{$text};
	}
        # warn("doing E<$text> = $char\n");
	    
	$self->parent->characters({Data => $char});
    }
    elsif ($name eq 'S') {
	my $spaces = join('', $sequence->parse_tree->children);
	$self->parent->characters({Data => "\160" x length($spaces)});
    }
    else {
	$self->parent->start_element(_element($name));
	$self->expand_ptree($sequence->parse_tree);
	$self->parent->end_element(_element($name, 1));
    }
}

sub expand_text {
    my ($self, $text, $ptree_node) = @_;
    $self->parent->characters({Data => $text});
}

sub _element {
    my ($name, $end) = @_;
    return { 
        Name => $name,
        LocalName => $name,
        $end ? () : (Attributes => {}),
        NamespaceURI => '',
        Prefix => '',
    };
}

sub _add_attrib {
    my ($el, $name, $value) = @_;
    
    $el->{Attributes}{"{}$name"} =
      {
	  Name => $name,
	    LocalName => $name,
	    Prefix => "",
	    NamespaceURI => "",
	    Value => $value,
      };
}

# Next three functions copied from Pod::ParseLink

# Parse the name and section portion of a link into a name and section.
sub _parse_section {
    my ($link) = @_;
    $link =~ s/^\s+//;
    $link =~ s/\s+$//;
    
    # If the whole link is enclosed in quotes, interpret it all as a section
    # even if it contains a slash.
    return (undef, $1) if ($link =~ /^"\s*(.*?)\s*"$/);
    
    # Split into page and section on slash, and then clean up quoting in the
    # section.  If there is no section and the name contains spaces, also
    # guess that it's an old section link.
    my ($page, $section) = split (/\s*\/\s*/, $link, 2);
    $section =~ s/^"\s*(.*?)\s*"$/$1/ if $section;
    if ($page && $page =~ / / && !defined ($section)) {
	$section = $page;
	$page = undef;
    } else {
	$page = undef unless $page;
	$section = undef unless $section;
    }
    return ($page, $section);
}

# Infer link text from the page and section.
sub _infer_text {
    my ($page, $section) = @_;
    my $inferred;
    if ($page && !$section) {
	$inferred = $page;
    } elsif (!$page && $section) {
	$inferred = '"' . $section . '"';
    } elsif ($page && $section) {
	$inferred = '"' . $section . '" in ' . $page;
    }
    return $inferred;
}

# Given the contents of an L<> formatting code, parse it into the link text,
# the possibly inferred link text, the name or URL, the section, and the type
# of link (pod, man, or url).
sub parselink {
    my ($link) = @_;
    $link =~ s/\s+/ /g;
    if ($link =~ /\A\w+:[^:\s]\S*\Z/) {
	return (undef, $link, $link, undef, 'url');
    } else {
	my $text;
	if ($link =~ /\|/) {
	    ($text, $link) = split (/\|/, $link, 2);
	}
	my ($name, $section) = _parse_section ($link);
	my $inferred = $text || _infer_text ($name, $section);
	my $type = ($name && $name =~ /\(\S*\)/) ? 'man' : 'pod';
	return ($text, $inferred, $name, $section, $type);
    }
}

package Pod::SAX::StringIO;

sub new {
    my $class = shift;
    my ($string) = @_;
    $string =~ s/\r//g;
    my @lines = split(/^/, $string);
    return bless \@lines, $class;
}

sub getline {
    my $self = shift;
    return shift @$self;
}

1;
__END__

=head1 NAME

Pod::SAX - a SAX parser for Pod

=head1 SYNOPSIS

  my $p = Pod::SAX->new( Handler => $h );
  $p->parse_fh($fh);

=head1 DESCRIPTION

Parses POD and generates SAX events.

=head1 AUTHOR

Matt Sergeant, matt@sergeant.org. Copyright AxKit.com Ltd 2002

=head1 BUGS

No known bugs at this time.

=head1 LICENSE

This is free software. You may use it and redistribute it under the same
terms as Perl itself.

=cut
