require 'v8'
# JSLint bindings for ruby using v8.
#
# Usage:
#
#    require 'jslintrb-v8'
#    puts JSLint.new.check("var x = 5")
#
# will output:
#
#    Error at line 1 character 1: Missing "use strict" statement.
#      var x = 5
#    Error at line 1 character 10: Missing semicolon.
#      var x = 5
#
# Pass options into the constructor:
#
#   JSLint.new(:undef => false, :sub => true)
#
# Here is an example rake task:
#   require 'jslintrb-v8'
#   task :jslint do
#     jsl = JSLint.new(
#       :undef  => false,
#       :strict => false,
#       :nomen  => false,
#       :onevar => false,
#       :newcap => false
#     )
#     errors = []
#     path = File.join('javascripts', '**', '*.js')
#     Dir[path].each do |f|
#       e = jsl.check(File.read(f))
#       errors << "\nIn [#{f}]:\n#{e}\n" if e
#     end
#     if errors.empty?
#       puts "JSLinty-fresh!"
#     else
#       $stderr.write(errors.join("\n")+"\n");
#       raise "JSLint Errors Found"
#     end
#   end
#
class JSLint
  def initialize(opts = {})
    # default jslint settings
    @settings = {
      # if ADsafe should be enforced
      :adsafe     => false,
      # if bitwise operators should not be allowed
      :bitwise    => true,
      # if the standard browser globals should be predefined
      :browser    => false,
      # if upper case HTML should be allowed
      :cap        => false,
      # if CSS workarounds should be tolerated
      :css        => false,
      # if debugger statements should be allowed
      :debug      => false,
      # if === should be required
      :eqeqeq     => true,
      # if eval should be allowed
      :evil       => false,
      # if for in statements must filter
      :forin      => false,
      # if HTML fragments should be allowed
      :fragment   => false,
      # if immediate invocations must be wrapped in parens
      :immed      => true,
      # if line breaks should not be checked
      :laxbreak   => false,
      # if constructor names must be capitalized
      :newcap     => true,
      # if names shoudl be checked
      :nomen      => true,
      # if HTML event handlers should be allowed
      :on         => false,
      # if only one var statement per function should be allowed
      :onevar     => true,
      # if the scan should stop on first error
      :passfail   => false,
      # if increment/decrement should not be allowed
      :plusplus   => true,
      # if the . should not be allowed in regexp literals
      :regexp     => true,
      # if the Rhino environment globals should be predefined
      :rhino      => false,
      # if variables should be declared before used
      :undef      => true,
      # if use of some browser features should be restricted
      :safe       => false,
      # if the System object should be predefined
      :sidebar    => false,
      # require the "use strict"; pragma
      :strict     => true,
      # if all forms of subscript notation are tolerated
      :sub        => false,
      # if strict whitespace rules apply
      :white      => false,
      # if the Yahoo Widgets globals should be predefined
      :widget     => false
    }

    # override default settings with passed in options
    @settings.merge(opts);

    @settings.keys.each do |setting|
      self.create_method(setting) { @settings[setting] }
      self.create_method("#{setting}=") { |x| @settings[setting] = x }
    end
  end

  def create_method(name, &block)
    self.class.send(:define_method, name, block)
  end

  def check(input)
    errors = []

    V8::Context.new do |context|
      context.load(File.join(File.dirname(__FILE__), 'jslintrb-v8', 'jslint.js'))

      # prep the context object
      @settings.each do |opt, val|
        context["JSLintRB#{opt}"]  = val
      end

      context['JSLintRBinput'] = lambda { input }

      context['JSLintRBerrors'] = lambda { |js_errors|
        js_errors.each do |e|
          errors << "Error at line #{e['line'].to_i + 1} " +
            "character #{e['character'].to_i + 1}: #{e['reason']}"
          errors << "  #{e['evidence']}"
        end
      }

      # do it
      context.eval [
        "JSLINT(JSLintRBinput(), {",
          @settings.keys.map { |k| "#{k} : JSLintRB#{k}" }.join(",\n"),
        "});",
        "JSLintRBerrors(JSLINT.errors);"
      ].join("\n")
    end

    if errors.empty?
      return nil
    else
      return errors.join("\n")
    end
  end
end
