# $Id: SAX.pm,v 1.5 2002/06/12 22:59:41 matt Exp $

package Pod::SAX;

$VERSION = '0.02';
use XML::SAX::Base;
@ISA = qw(XML::SAX::Base);

use strict;
use Pod::Tree;
use XML::SAX::DocumentLocator;

sub _parse_bytestream {
    my ($self, $fh) = @_;
    my $tree = Pod::Tree->new();
    $tree->load_fh($fh);
    $self->parse_tree($tree->get_root);
}

sub _parse_characterstream {
    my ($self, $fh) = @_;
    die "parse_characterstream not supported";
}

sub _parse_string {
    my ($self, $str) = @_;
    my $tree = Pod::Tree->new();
    $str =~ s/\r//g;
    # NB: \n\n is a hack due to bugs in Pod::Tree
    $tree->load_string("\n\n$str");
    $self->{ParserOptions}{_stringmode} = 1;
    $self->parse_tree($tree->get_root);
}

sub _parse_systemid {
    my ($self, $sysid) = @_;
    my $tree = Pod::Tree->new();
    $tree->load_file($sysid);
    $self->parse_tree($tree->get_root);
}

sub parse_tree {
    my ($self, $root) = @_;
    
    my $sysid = $self->{ParserOptions}->{Source}{SystemId};
    $self->set_document_locator(
         XML::SAX::DocumentLocator->new(
            sub { "" },
            sub { $sysid },
            sub { 0 },
            sub { 0 },
        ),
    );
    $self->start_document({});
    $self->process_node($root);
    $self->end_document({});
}

sub process_node {
    my ($self, $node) = @_;
#    sex($node);
    my $type = $node->get_type;
    if ($type eq 'root') {
        $self->start_element(_element('pod'));
        if ($self->{ParserOptions}{_stringmode}) {
            # Work around horrible Pod::Tree bug with parsing strings!
            my @nodes = @{$node->get_children};
            shift @nodes;
            $self->process_node($_) for @nodes;
        }
        else {
            $self->process_node($_) for @{$node->get_children};
        }
        $self->end_element(_element('pod', 1));
    }
    elsif ($type eq 'code') {
        $self->comment({ Data => $node->get_text });
    }
    elsif ($type eq 'verbatim') {
        $self->start_element(_element('verbatim'));
        $self->characters({Data => $node->get_text});
        $self->end_element(_element('verbatim'));
        $self->characters({Data => "\n"});
    }
    elsif ($type eq 'ordinary') {
        $self->start_element(_element('para'));
        $self->process_node($_) for @{$node->get_children};
        $self->end_element(_element('para', 1));
        $self->characters({Data => "\n"});
    }
    elsif ($type eq 'command') {
        return if $node->is_c_cut;
        $self->start_element(_element($node->get_command));
        $self->process_node($_) for @{$node->get_children};
        $self->end_element(_element($node->get_command, 1));
        $self->characters({Data => "\n"});
    }
    elsif ($type eq 'sequence') {
        if ($node->is_link) {
            my $target = $node->get_target;
            if ($target->get_domain eq "POD") {
                my $start = _element("link");
                $start->{Attributes} = {
                    "{}page" => {
                        Name => "page",
                        LocalName => "page",
                        NamespaceURI => "",
                        Prefix => "",
                        Value => $target->get_page,
                    },
                    "{}section" => {
                        Name => "section",
                        LocalName => "section",
                        NamespaceURI => "",
                        Prefix => "",
                        Value => $target->get_section,
                    },
                };
                $self->start_element($start);
                $self->process_node($_) for @{$node->get_children};
                $self->end_element(_element("link",1));
            }
            elsif ($target->get_domain eq "HTTP") {
                my $start = _element("xlink");
                $start->{Attributes} = {
                    "{}href" => {
                        Name => "href",
                        LocalName => "href",
                        NamespaceURI => "",
                        Prefix => "",
                        Value => $target->get_page,
                    },
                };
                $self->start_element($start);
                $self->process_node($_) for @{$node->get_children};
                $self->end_element(_element("xlink"));
            }
        }
        else {
            $self->start_element(_element($node->get_letter));
            $self->process_node($_) for @{$node->get_children};
            $self->end_element(_element($node->get_letter, 1));
        }
    }
    elsif ($type eq 'text') {
        my $text = $node->get_text;
        $text =~ s/[\r\n]*$//; # strip trailing returns
        $self->characters({Data => $text});
    }
    elsif ($type eq 'list') {
        my $listtype = $node->get_list_type;
        my $elname;
        if ($listtype eq 'bullet') {
            $elname = 'itemizedlist';
        }
        elsif ($listtype eq 'number') {
            $elname = 'orderedlist';
        }
        elsif ($listtype eq 'text') {
            $elname = 'itemizedlist';
        }
        $self->start_element(_element($elname));
        foreach my $item (@{$node->get_children}) {
            $self->start_element(_element('listitem'));
            if ($item->get_item_type eq 'text') {
                $self->start_element(_element('itemtext'));
                $self->process_node($_) for @{$item->get_children};
                $self->end_element(_element('itemtext',1));
            }
            $self->process_node($_) for @{$item->get_siblings};
            $self->end_element(_element('listitem', 1));
        }
        $self->end_element(_element($elname, 1));
    }
    elsif ($type eq 'item') {
        warn("Should never get here");
    }
    elsif ($type eq 'for') {
        my $type = $node->get_arg;
        $self->start_element(
            {Name => 'external',
             LocalName => 'external',
             Attributes => {
                "{}type" => {
                    Name => "type",
                    LocalName => "type",
                    Prefix => "",
                    NamespaceURI => "",
                    Value => $type,
                }
             },
             Prefix => "",
             NamespaceURI => "",
            }
        );
        $self->characters({Data => $node->get_text});
        $self->end_element(_element('external',1));
    }
    else {
        warn("Unknown node type: $type");
    }
}

sub sex {
    use Data::Dumper;$Data::Dumper::Indent=1;warn(Dumper(@_));
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

Most bugs are in Pod::Tree which this module depends on. For example, 
"require 5.6.0" is a bug in my opinion. Also, Pod::Tree seems to do different
things depending on if you're parsing a string or a filehandle. Oddness.

=head1 LICENSE

This is free software. You may use it and redistribute it under the same
terms as Perl itself.

=cut
