require 'jruby/kafka'

class KafkaProducer

  def initialize(host, port=9092, key_serializer = :string, value_serializer = :string)
    config = Java::JavaUtil::Properties.new
    config['bootstrap.servers'] = "#{host}:#{port}"

    case key_serializer
    when :string, "string"
      config['key.serializer'] = "org.apache.kafka.common.serialization.StringSerializer"
    when :byte_array, "byte_array"
      config['key.serializer'] = "org.apache.kafka.common.serialization.ByteArraySerializer"
    else
      raise ArgumentError, "key_serializer must be :string or :byte_array"
    end

    case value_serializer
    when :string, "string"
      config['value.serializer'] = "org.apache.kafka.common.serialization.StringSerializer"
    when :byte_array, "byte_array"
      config['value.serializer'] = "org.apache.kafka.common.serialization.ByteArraySerializer"
    else
      raise ArgumentError, "value_serializer must be :string or :byte_array"
    end

    @producer = Java::OrgApacheKafkaClientsProducer::KafkaProducer.new config
  end

  def send(queue, key, message)
    @producer.send Java::OrgApacheKafkaClientsProducer::ProducerRecord.new(queue, key, message)
  end

  def close
    @producer.close
  end

end
