module PACKMAN
  class Os
    attr_reader :normal, :active_spec

    def initialize requested_spec = nil
      hand_over_spec :normal

      set_active_spec requested_spec

      active_spec.check_blocks.each do |name, block|
        active_spec.checked_items[name] = block.call
      end
      active_spec.version ||= VersionSpec.new active_spec.checked_items[:version].strip
    end

    def hand_over_spec name
      tmp = self.class.to_s.gsub(/PACKMAN::/, '')
      return if not self.class.class_variable_defined? :"@@#{tmp}_#{name}"
      spec = self.class.class_variable_get(:"@@#{tmp}_#{name}").clone
      self.class.ancestors.each do |x|
        next if x == self.class
        next if x == Os
        next if not x.to_s =~ /^PACKMAN/
        tmp = x.to_s.gsub(/PACKMAN::/, '')
        ancestor_spec = self.class.class_variable_get(:"@@#{tmp}_#{name}").clone
        spec.inherit ancestor_spec
      end
      instance_variable_set "@#{name}", spec
    end

    def set_active_spec requested_spec
      if requested_spec
        if self.respond_to? requested_spec
          @active_spec = self.send requested_spec
        end
      else
        @active_spec = normal
      end
    end

    def vendor; active_spec.vendor; end
    def type; active_spec.type; end
    def distro; active_spec.distro; end
    def version; active_spec.version; end
    def package_managers; active_spec.package_managers; end
    def check item
      if not active_spec.checked_items.has_key? item
        PACKMAN.report_error "There is no #{PACKMAN.red item} to check!"
      end
      active_spec.checked_items[item]
    end
    def x86_64?; active_spec.arch == 'x86_64' ? true : false; end

    class << self
      def normal
        eval "@@#{self.to_s.gsub(/PACKMAN::/, '')}_normal ||= OsAtom.new"
      end

      def vendor val; normal.vendor = val; end
      def type val; normal.type = val; end
      def package_manager name, detail
        `which #{detail[:query_command].split.first} 2>&1`
        if $?.success?
        #if PACKMAN.does_command_exist? detail[:query_command].split.first
          normal.package_managers[name] = detail
        end
      end
      def version
        normal.version ||= VersionSpec.new normal.check_blocks[:version].call.strip
      end
      def check item, &block
        normal.check_blocks[item] = block
      end
    end
  end
end
