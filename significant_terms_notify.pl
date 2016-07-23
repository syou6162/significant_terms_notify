#!/usr/bin/env perl
use strict;
use warnings;
use Search::Elasticsearch;
use utf8;
use Encode;

my $e = Search::Elasticsearch->new(
    nodes => [ 'localhost:9200', ]
);

my $hour = 6;

my $results = $e->search(
    index => 'twitter_public_timeline',
    type => "tweet",
    body  => {
        query => {
            query_string => {
                query => "\"yasuhisay/\" OR \"syou6162/\" -RT",
                analyze_wildcard => 1,
            },
        },
        "aggs" => {
            "range"=> {
                filter => {
                    range => {
                        time => {
                            gte => "now-" . $hour . "H/H",
                            lte => "now",
                            time_zone => "+09:00",
                        },
                    },
                },
                "aggs" => {
                    terms => {
                        "significant_terms" => {
                            "field" => "text",
                            "size" => 10,
                        }
                    },
                },
            },
        },
    },
);

foreach my $bucket (@{$results->{aggregations}->{range}->{terms}->{buckets}}) {
    print encode_utf8 $bucket->{key} . "(" . $bucket->{doc_count} . "件)\n";
}
