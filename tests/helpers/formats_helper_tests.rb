Shindo.tests('test_helper', 'meta') do

  tests('comparing welcome data against schema') do
    data = {:welcome => "Hello" }
    data_matches_schema(:welcome => String) { data }
  end

  tests('Pacto::Contracts use Pacto for validation') do
    data = {:welcome => "Hello" }
    schema = Pacto.load('hello_contract')
    data_matches_schema(schema) { data }
  end

  tests('Pacto supports many validations (json-schema support)') do
    schema = Pacto.load('strict_contract')
    # I can't test easily test this via the helper
    # So I'm demoing behaving by calling the validator directly

    validator = Fog::Schema::PactoDataValidator.new
    returns(true, 'can validate complex schemas') do
      validator.validate({'devices' => ['/dev/1', '/dev/2'] }, schema)
    end
    returns(true, 'detects missing required elements') do
      valid = validator.validate({'devicess' => ['/dev/1', '/dev/2'] }, schema)
      validator.message.include? "The property '#/' did not contain a required property of 'devices'"
    end
    returns(true, 'detects minimum number of items') do
      valid = validator.validate({'devices' => ['/dev/1'] }, schema)
      validator.message.include? "The property '#/devices' did not contain a minimum number of items 2"
    end
    returns(true, 'detects a regex mismatch') do
      valid = validator.validate({'devices' => ['/abc/1', '/abc/2'] }, schema)
      validator.message.include? "The property '#/devices/1' value \"/abc/2\" did not match the regex '^/dev/[^/]+(/[^/]+)*$'"
    end
  end

  tests('#data_matches_schema') do
    tests('when value matches schema expectation') do
      data_matches_schema({"key" => String}) { {"key" => "Value"} }
    end

    tests('when values within an array all match schema expectation') do
      data_matches_schema({"key" => [Integer]}) { {"key" => [1, 2]} }
    end

    tests('when nested values match schema expectation') do
      data_matches_schema({"key" => {:nested_key => String}}) { {"key" => {:nested_key => "Value"}} }
    end

    tests('when collection of values all match schema expectation') do
      data_matches_schema([{"key" => String}]) { [{"key" => "Value"}, {"key" => "Value"}] }
    end

    tests('when collection is empty although schema covers optional members') do
      data_matches_schema([{"key" => String}], {:allow_optional_rules => true}) { [] }
    end

    tests('when additional keys are passed and not strict') do
      data_matches_schema({"key" => String}, {:allow_extra_keys => true}) { {"key" => "Value", :extra => "Bonus"} }
    end

    tests('when value is nil and schema expects NilClass') do
      data_matches_schema({"key" => NilClass}) { {"key" => nil} }
    end

    tests('when value and schema match as hashes') do
      data_matches_schema({}) { {} }
    end

    tests('when value and schema match as arrays') do
      data_matches_schema([]) { [] }
    end

    tests('when value is a Time') do
      data_matches_schema({"time" => Time}) { {"time" => Time.now} }
    end

    tests('when key is missing but value should be NilClass (#1477)') do
      data_matches_schema({"key" => NilClass}, {:allow_optional_rules => true}) { {} }
    end

    tests('when key is missing but value is nullable (#1477)') do
      data_matches_schema({"key" => Fog::Nullable::String}, {:allow_optional_rules => true}) { {} }
    end
  end

  tests('#formats backwards compatible changes') do

    tests('when value matches schema expectation') do
      formats({"key" => String}) { {"key" => "Value"} }
    end

    tests('when values within an array all match schema expectation') do
      formats({"key" => [Integer]}) { {"key" => [1, 2]} }
    end

    tests('when nested values match schema expectation') do
      formats({"key" => {:nested_key => String}}) { {"key" => {:nested_key => "Value"}} }
    end

    tests('when collection of values all match schema expectation') do
      formats([{"key" => String}]) { [{"key" => "Value"}, {"key" => "Value"}] }
    end

    tests('when collection is empty although schema covers optional members') do
      formats([{"key" => String}]) { [] }
    end

    tests('when additional keys are passed and not strict') do
      formats({"key" => String}, false) { {"key" => "Value", :extra => "Bonus"} }
    end

    tests('when value is nil and schema expects NilClass') do
      formats({"key" => NilClass}) { {"key" => nil} }
    end

    tests('when value and schema match as hashes') do
      formats({}) { {} }
    end

    tests('when value and schema match as arrays') do
      formats([]) { [] }
    end

    tests('when value is a Time') do
      formats({"time" => Time}) { {"time" => Time.now} }
    end

    tests('when key is missing but value should be NilClass (#1477)') do
      formats({"key" => NilClass}) { {} }
    end

    tests('when key is missing but value is nullable (#1477)') do
      formats({"key" => Fog::Nullable::String}) { {} }
    end

  end


end
