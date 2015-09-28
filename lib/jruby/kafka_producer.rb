require 'jruby/kafka'

class KafkaProducer

  def initialize(host, port=9092, key_serializer = :string, value_serializer = :string, schema_repo_url=nil)
    config = Java::JavaUtil::Properties.new
    config['bootstrap.servers'] = "#{host}:#{port}"

    case key_serializer
    when :string, "string"
      config['key.serializer'] = "org.apache.kafka.common.serialization.StringSerializer"
    when :byte_array, "byte_array"
      config['key.serializer'] = "org.apache.kafka.common.serialization.ByteArraySerializer"
    when :avro, "avro"
      require 'jruby/avro_serializer'
      config['key.serializer'] = "io.confluent.kafka.serializers.KafkaAvroSerializer"
    else
      raise ArgumentError, "key_serializer must be :string, :byte_array, or :avro"
    end

    case value_serializer
    when :string, "string"
      config['value.serializer'] = "org.apache.kafka.common.serialization.StringSerializer"
    when :byte_array, "byte_array"
      config['value.serializer'] = "org.apache.kafka.common.serialization.ByteArraySerializer"
    when :avro, "avro"
      require 'jruby/avro_serializer'
      config['value.serializer'] = "io.confluent.kafka.serializers.KafkaAvroSerializer"
    else
      raise ArgumentError, "value_serializer must be :string, :byte_array, or :avro"
    end

    if key_serializer.to_s == "avro" || value_serializer.to_s == "avro"
      raise ArgumentError, "schema_repo_url required with avro serializer" unless schema_repo_url
      config['schema.registry.url'] = schema_repo_url
      if $DEBUG
        l = Java::OrgApacheLog4j::Logger.get_logger "io.confluent"
        l.set_level(Java::OrgApacheLog4j::Level::DEBUG)
        l.add_appender Java::OrgApacheLog4j::ConsoleAppender.new(Java::OrgApacheLog4j::SimpleLayout.new, Java::OrgApacheLog4j::ConsoleAppender::SYSTEM_OUT)
      end
    end

    @producer = Java::OrgApacheKafkaClientsProducer::KafkaProducer.new config
  end

  def send(topic, key, message)
    @producer.send Java::OrgApacheKafkaClientsProducer::ProducerRecord.new(topic, key, message)
  end

  def send_to_partition(topic, partition, message)
    partition_ids = get_partition_ids(topic)
    raise ArgumentError, "Not a partition: #{topic}, #{partition_ids}.include?(#{partition})" unless partition_ids.include?(partition)
    @producer.send Java::OrgApacheKafkaClientsProducer::ProducerRecord.new(topic, partition, nil, message)
  end

  def round_robin(topic, message)
    @message_counts ||= Hash.new
    @message_counts[topic] ||= 0
    partition_ids = get_partition_ids(topic)
    count = @message_counts[topic]
    offset = count.modulo partition_ids.length
    partition_id = partition_ids[offset]
    send_to_partition(topic, partition_id, message)
    @message_counts[topic] += 1
    return partition_id
  end

  def get_partition_ids(topic)
    partitions = @producer.partitions_for(topic)
    active_partitions = partitions.find_all {|p| p.leader}
    active_partitions.map {|p| p.partition}
  end

  def close
    @producer.close
  end

end
