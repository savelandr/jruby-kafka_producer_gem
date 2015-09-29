#Kafka Producer
##Description
Helper to send messages to a Kafka cluster
##Example
```
require 'jruby/kafka_producer'

                                  #Broker URL             , Key Enc, Val Enc
string_producer=KafkaProducer.new("some.host.aol.com:9092", :string, :string)
string_producer.send "my_queue", "key", "my exciting message"
string_producer.close

                                    #Broker URL                            ,  Key Enc,     Val Enc
byte_ary_producer=KafkaProducer.new("host1.aol.com:9092,host2.aol.com:9092", :byte_array, :byte_array)
byte_ary_producer.send "my_queue", "key".to_java_bytes, "my exciting message".to_java_bytes
byte_ary_producer.close
```
