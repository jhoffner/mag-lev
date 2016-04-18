class ServiceObjectGenerator < Rails::Generators::NamedBase
  def create_context_file
    create_file "app/service_objects/#{model_path_root}/#{context_root.underscore}.rb", <<-FILE
class #{model_class_name}
  class #{context_root} < #{context_base_class_name}
    attr_reader :#{model_name}

    def initialize(#{model_name})
      MagLev::Guard.nil(:#{model_name}, #{model_name})
      @#{model_name} = #{model_name}
    end

    def logger_name
      #{model_name}.logger_name
    end

    def execute_async
      perform_async(#{model_name})
    end

    protected

    def on_execute
    end

    class Worker < ServiceObjectWorker
    end
  end
end
    FILE

  end

  def create_spec_file
    file_name = "spec/service_objects/#{model_path_root}/#{context_root.underscore}_spec.rb"
    create_file file_name, <<-FILE
require 'rails_helper'

describe #{context_class_name} do
  let(:#{model_name}) { create(:#{model_name}) }
  subject(:service) { #{context_class_name}.new(#{model_name}) }

  describe '#execute' do
    pending
  end

  describe '#execute_async' do
    it_behaves_like 'Service Object Worker'
  end
end
    FILE
  end

  protected

  def context_base_class_name
    @view_model_base_class_name ||= begin
      name = "#{model_class_name}::ServiceObject"
      begin
        name.to_const
      rescue
        'ServiceObject'
      end
    end
  end

  def context_class_name
    @view_model_class_name ||= "#{model_class_name}::#{context_root}"
  end

  def model_class_name
    @controller_class_name ||= "#{model_namespaced? ? model_namespace + '::' : ''}#{model_root}"
  end

  def model_path_root(suffix = '', prefix = '')
    "#{model_namespaced? ? model_name + '/' : ''}#{prefix}#{model_root.underscore}#{suffix}"
  end

  def model_root
    (model_namespaced? ? class_parts[1] : class_parts[0])
  end

  def context_root
    class_parts.last
  end

  def model_namespace
    model_namespaced? ? class_parts.first : ''
  end

  def model_namespaced?
    class_parts.length > 2
  end

  def class_parts
    @class_parts ||= class_name.split('::')
  end

  def model_name
    @model_name ||= (model_namespaced? ? class_parts[1] : class_parts[0]).underscore
  end
end
