# find /mnt2/asf-mail-archives-7-18-2011 -type f |sort |perl inserter.pl /mnt2/asf-mail-archives-7-18-2011/axis.apache.org/ >> log
#
use common::sense;

use Data::Dumper;
use Mail::Mbox::MessageParser;
use Email::MIME;
use Hash::MultiValue;
use JSON::XS;
use LWP::UserAgent;

my $start_file = shift;

my $ua = LWP::UserAgent->new;

foreach my $filename (<STDIN>) {
  chomp $filename;

  next if defined $start_file && $filename lt $start_file;

  # trafficserver.apache.org/commits/2009?07 <-- has a newline in it, skip file that aren't there...
  next if !-e $filename;
  
  # axis.apache.org/java-dev/201002 has both plain and .gz, just skip the plain ones
  next if -e "$filename.gz";

  # /mnt2/asf-mail-archives-7-18-2011/jakarta.apache.org/notifications/201010.gz
  next unless $filename =~ m{^/mnt2/asf-mail-archives-7-18-2011/(.*/\d{6})(?:\.gz|)$};
  my $resource = $1;

  my $mbox_parser = Mail::Mbox::MessageParser->new({ file_name => $filename, enable_cache => 0 });
  next if !ref $mbox_parser;

  my $curr = 0;
  my @batch;

  while(!$mbox_parser->end_of_file()) {
    my $email = $mbox_parser->read_next_email();
    my $parsed = Email::MIME->new($$email);

    my $name = "${resource}_$curr";
    $name =~ s{/}{_}g;

    my $document = {
      _id => $name,
      headers => [ Hash::MultiValue->new($parsed->header_str_pairs)->as_hashref_mixed ],
      body => $parsed->body,
    };

    push @batch, $document;
    $curr++;
  }

  my $encoded = encode_json({ docs => \@batch });

  my $url = "http://127.0.0.1:5984/asf/_bulk_docs";

  print "$filename - POSTing $url ... ";

  my $req = HTTP::Request->new(POST => $url);
  $req->content_type('application/json');
  $req->content($encoded);

  my $res = $ua->request($req);

  if ($res->is_success) {
    my $decoded = decode_json($res->content);

    my $num_ok = scalar grep { exists $_->{ok} } @$decoded;

    print "  OK $num_ok / " . @batch;
  } else {
    die "error POSTing: " . $res->status_line;
  }

  say;
}
