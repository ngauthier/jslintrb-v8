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
class JSLint
    # if ADsafe should be enforced
    attr_accessor :adsafe   
    # if bitwise operators should not be allowed
    attr_accessor :bitwise  
    # if the standard browser globals should be predefined
    attr_accessor :browser  
    # if upper case HTML should be allowed
    attr_accessor :cap      
    # if CSS workarounds should be tolerated
    attr_accessor :css      
    # if debugger statements should be allowed
    attr_accessor :debug    
    # if === should be required
    attr_accessor :eqeqeq   
    # if eval should be allowed
    attr_accessor :evil     
    # if for in statements must filter
    attr_accessor :forin    
    # if HTML fragments should be allowed
    attr_accessor :fragment 
    # if immediate invocations must be wrapped in parens
    attr_accessor :immed    
    # if line breaks should not be checked
    attr_accessor :laxbreak 
    # if constructor names must be capitalized
    attr_accessor :newcap   
    # if names should be checked
    attr_accessor :nomen    
    # if HTML event handlers should be allowed
    attr_accessor :on       
    # if only one var statement per function should be allowed
    attr_accessor :onevar   
    # if the scan should stop on first error
    attr_accessor :passfail 
    # if increment/decrement should not be allowed
    attr_accessor :plusplus 
    # if the . should not be allowed in regexp literals
    attr_accessor :regexp   
    # if the Rhino environment globals should be predefined
    attr_accessor :rhino    
    # if variables should be declared before used
    attr_accessor :undef    
    # if use of some browser features should be restricted
    attr_accessor :safe     
    # if the System object should be predefined
    attr_accessor :sidebar  
    # require the "use strict"; pragma
    attr_accessor :strict   
    # if all forms of subscript notation are tolerated
    attr_accessor :sub      
    # if strict whitespace rules apply
    attr_accessor :white    
    # if the Yahoo Widgets globals should be predefined
    attr_accessor :widget   

  def initialize(opts = {})
    @adsafe   = opts.fetch( :adsafe   ){ false } 
    @bitwise  = opts.fetch( :bitwise  ){ true  } 
    @browser  = opts.fetch( :browser  ){ false } 
    @cap      = opts.fetch( :cap      ){ false } 
    @css      = opts.fetch( :css      ){ false } 
    @debug    = opts.fetch( :debug    ){ false } 
    @eqeqeq   = opts.fetch( :eqeqeq   ){ true  } 
    @evil     = opts.fetch( :evil     ){ false } 
    @forin    = opts.fetch( :forin    ){ false } 
    @fragment = opts.fetch( :fragment ){ false } 
    @immed    = opts.fetch( :immed    ){ true  } 
    @laxbreak = opts.fetch( :laxbreak ){ false } 
    @newcap   = opts.fetch( :newcap   ){ true  } 
    @nomen    = opts.fetch( :nomen    ){ true  } 
    @on       = opts.fetch( :on       ){ false } 
    @onevar   = opts.fetch( :onevar   ){ true  } 
    @passfail = opts.fetch( :passfail ){ false } 
    @plusplus = opts.fetch( :plusplus ){ true  } 
    @regexp   = opts.fetch( :regexp   ){ true  } 
    @rhino    = opts.fetch( :rhino    ){ false } 
    @undef    = opts.fetch( :undef    ){ true  } 
    @safe     = opts.fetch( :safe     ){ false } 
    @sidebar  = opts.fetch( :sidebar  ){ false } 
    @strict   = opts.fetch( :strict   ){ true  } 
    @sub      = opts.fetch( :sub      ){ false } 
    @white    = opts.fetch( :white    ){ false } 
    @widget   = opts.fetch( :widget   ){ false } 
  end

  def check(input)
    errors = []
    V8::Context.new do |context|
      context.load(File.join(File.dirname(__FILE__), 'jslintrb-v8', 'jslint.js'))

      context['JSLintRBinput']    = lambda{ input }
      context['JSLintRBadsafe']   = @adsafe
      context['JSLintRBbitwise']  = @bitwise 
      context['JSLintRBbrowser']  = @browser 
      context['JSLintRBcap']      = @cap 
      context['JSLintRBcss']      = @css 
      context['JSLintRBdebug']    = @debug 
      context['JSLintRBeqeqeq']   = @eqeqeq 
      context['JSLintRBevil']     = @evil 
      context['JSLintRBforin']    = @forin 
      context['JSLintRBfragment'] = @fragment 
      context['JSLintRBimmed']    = @immed 
      context['JSLintRBlaxbreak'] = @laxbreak 
      context['JSLintRBnewcap']   = @newcap 
      context['JSLintRBnomen']    = @nomen 
      context['JSLintRBon']       = @on 
      context['JSLintRBonevar']   = @onevar 
      context['JSLintRBpassfail'] = @passfail 
      context['JSLintRBplusplus'] = @plusplus 
      context['JSLintRBregexp']   = @regexp 
      context['JSLintRBrhino']    = @rhino 
      context['JSLintRBundef']    = @undef 
      context['JSLintRBsafe']     = @safe 
      context['JSLintRBsidebar']  = @sidebar 
      context['JSLintRBstrict']   = @strict 
      context['JSLintRBsub']      = @sub 
      context['JSLintRBwhite']    = @white 
      context['JSLintRBwidget']   = @widget 
      context['JSLintRBreportErrors'] = lambda{|js_errors|
        js_errors.each do |e|
          if V8::Object === e
            e = V8::To.rb(e)
            errors << "Error at line #{e['line'].to_i + 1} " + 
              "character #{e['character'].to_i + 1}: #{e['reason']}"
            errors << "  #{e['evidence']}"
          end
        end
      }
      context.eval %{
        JSLINT(JSLintRBinput(), {
          adsafe   : JSLintRBadsafe,
          bitwise  : JSLintRBbitwise,
          browser  : JSLintRBbrowser,
          cap      : JSLintRBcap,
          css      : JSLintRBcss,
          debug    : JSLintRBdebug,
          eqeqeq   : JSLintRBeqeqeq,
          evil     : JSLintRBevil,
          forin    : JSLintRBforin,
          fragment : JSLintRBfragment,
          immed    : JSLintRBimmed,
          laxbreak : JSLintRBlaxbreak,
          newcap   : JSLintRBnewcap,
          nomen    : JSLintRBnomen,
          on       : JSLintRBon,
          onevar   : JSLintRBonevar,
          passfail : JSLintRBpassfail,
          plusplus : JSLintRBplusplus,
          regexp   : JSLintRBregexp,
          rhino    : JSLintRBrhino,
          undef    : JSLintRBundef,
          safe     : JSLintRBsafe,
          sidebar  : JSLintRBsidebar,
          strict   : JSLintRBstrict,
          sub      : JSLintRBsub,
          white    : JSLintRBwhite,
          widget   : JSLintRBwidget
        });
        JSLintRBreportErrors(JSLINT.errors);
      }
    end

    if errors.empty?
      return nil
    else
      return errors.join("\n")
    end
  end
end
