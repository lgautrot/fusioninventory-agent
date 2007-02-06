package Ocsinventory::Agent::AccountInfo;

use strict;
use warnings;

use Data::Dumper; # XXX Debug

sub new {
  my (undef,$params) = @_;

  my $self = {};
  bless $self;

  $self->{params} = $params->{params};
  $self->{logger} = $params->{logger};

  my $logger = $self->{logger} = $params->{logger};

  $logger->debug ('Accountinfo file: '. $self->{params}->{accountinfofile});

  if (! -f $self->{params}->{accountinfofile}) {
      $logger->info ("Accountinfo file doesn't exist. I create an empty one.");
      $self->write();
  } else {

    my $xmladm = XML::Simple::XMLin(
      $self->{params}->{accountinfofile},
      ForceArray => [ 'ACCOUNTINFO' ]
    );

    # Store the XML content in a local HASH
    for(@{$xmladm->{ACCOUNTINFO}}){
      if (!$_->{KEYNAME}) {
	$logger->debug ("Incorrect KEYNAME in ACCOUNTINFO");
      }
      $self->{accountinfo}{ $_->{KEYNAME} } = $_->{KEYVALUE};
    }
  }

  $self;
}

sub get {
  my ($self, $keyname) = @_;

  return $self->{accountinfo}{$keyname} if $keyname;
}

sub getAll {
  my ($self, $name) = @_;

  return $self->{accountinfo};
}

sub set {
  my ($self, $name, $value) = @_;

  $self->{accountinfo}->{$name} = $value;
  $self->write();
}

sub reSetAll {
  my ($self, $hash) = @_;

  foreach (keys %$hash) {
    $self->set($_, $hash->{$_});
    print "$_ => $hash->{$_}\n";
  }
}

# Add accountinfo stuff to an inventary
sub setAccountInfo {
  my $self = shift;
  my $inventary = shift;

  my $ai = $self->getAll();
  $self->{h}{'CONTENT'}{ACCOUNTINFO} = [];

  return unless $ai;

  foreach (keys %$ai) {
    push @{$inventary->{h}{'CONTENT'}{ACCOUNTINFO}}, {
      KEYNAME => [$_],
      KEYVALUE => [$ai->{$_}],
    };
  }
}


sub write {
  my ($self, $args) = @_;
  
  my $logger = $self->{logger};

  my $tmp;
  $tmp->{ACCOUNTINFO} = [];

  foreach (keys %{$self->{accountinfo}}) {
    push @{$tmp->{ACCOUNTINFO}}, {KEYNAME => [$_], KEYVALUE =>
      [$self->{accountinfo}{$_}]}; 
  }

  my $xml=XML::Simple::XMLout( $tmp, RootName => 'ADM' );


  my $fault;
  if (!open ADM, ">".$self->{params}->{accountinfofile}) {

    $fault = 1;

  } else {

    print ADM $xml;
    $fault = 1 unless close ADM;

  }

  if (!$fault) {
    $logger->debug ("Account info updated successfully");
  } else {
    $logger->error ("Can't save account info in `".
      $self->{params}->{accountinfofile});
  }
}

1;
