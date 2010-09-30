use Test::More tests => 4;
use Test::Exception;

BEGIN { use_ok('Net::APNS::Persistent') };

SKIP: {
    if (!($ENV{APNS_TEST_DEVICETOKEN} && $ENV{APNS_TEST_CERT} && $ENV{APNS_TEST_KEY})) {
        # make sure cpan installers see this
        my $msg = "skipping - can't make connection without environment variables: APNS_TEST_DEVICETOKEN APNS_TEST_CERT, APNS_TEST_KEY and (if needed) APNS_TEST_KEY_PASSWD";
        diag $msg;
        skip $msg, 3;
    }

    my %args = (
        sandbox => 1,
        cert => $ENV{APNS_TEST_CERT},
        key => $ENV{APNS_TEST_KEY},
       );

    $args{passwd} = $ENV{APNS_TEST_KEY_PASSED}
      if $ENV{APNS_TEST_KEY_PASSWD};
    
    isa_ok(
        my $apns = Net::APNS::Persistent->new(\%args),
        'Net::APNS::Persistent',
        "created Net::APNS::Persistent object"
       );

    sleep 5;
    
    lives_ok {
        $apns->queue_notification(
            $ENV{APNS_TEST_DEVICETOKEN},
            {
                aps => {
                    alert => "small",
                },
                custom => ("l" x 512),
            },
           );
    } "queued notification with oversize custom payload";

    dies_ok { $apns->send_queue } "exception on send";
}
