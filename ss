input {
  file {
    path => "/path/to/your/logfile.log"
    start_position => "beginning"
    sincedb_path => "/dev/null"
  }
}

filter {
  grok {
    match => { "message" => "date: %{TIMESTAMP_ISO8601:timestamp} \| %{GREEDYDATA:keyvalues}" }
    overwrite => [ "message" ]
  }
  
  kv {
    source => "keyvalues"
    field_split => "\|"
    value_split => ":"
    trim_key => " "
    trim_value => " "
  }

  mutate {
    convert => { "error" => "integer" }
  }

  date {
    match => ["timestamp", "yyyy/MM/dd HH:mm:ss"]
    target => "@timestamp"
    remove_field => ["message", "timestamp"]
  }
}

output {
  elasticsearch {
    hosts => ["http://localhost:9200"]
    index => "your_index_name"
  }

  stdout {
    codec => rubydebug
  }
}
