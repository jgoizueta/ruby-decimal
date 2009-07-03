require 'bigfloat/num'

module BigFloat

class BinFloat < Num

  class << self
    # Numerical base of Decimal.
    def radix
      2
    end

    # Integral power of the base: radix**n for integer n; returns an integer.
    def int_radix_power(n)
      (n < 0) ? (2**n) : (1<<n)
    end

    # Multiply by an integral power of the base: x*(radix**n) for x,n integer;
    # returns an integer.
    def int_mult_radix_power(x,n)
      x * ((n < 0) ? (2**n) : (1<<n))
    end

    # Divide by an integral power of the base: x/(radix**n) for x,n integer;
    # returns an integer.
    def int_div_radix_power(x,n)
      x / ((n < 0) ? (2**n) : (1<<n))
    end
  end

  # The context defines the arithmetic context: rounding mode, precision,...
  # Decimal.context is the current (thread-local) context.
  class Context < Num::ContextBase

    def initialize(*options)
      super(BinFloat, *options)
    end

  end

  class <<self

    def base_coercible_types
      unless defined? @base_coercible_types
        @base_coercible_types = super.merge(
          Float=>lambda{|x, context|
            if x.nan?
              BinFloat.nan
            elsif x.infinite?
              BinFloat.infinity(x<0 ? -1 : +1)
            elsif x.zero?
              BinFloat.zero((x.to_s[0,1].strip=="-") ? -1 : +1)
            else
              coeff, exp = Math.frexp(x)
              coeff = Math.ldexp(coeff, Float::MANT_DIG).to_i
              exp -= Float::MANT_DIG
              if coeff < 0
                sign = -1
                coeff = -coeff
              else
                sign = +1
              end
              BinFloat(sign, coeff, exp)
            end
          }
        )
      end
      @base_coercible_types
    end
  end

  # the DefaultContext is the base for new contexts; it can be changed.
  # DefaultContext = BinFloat::Context.new(
  #                            :precision=>113,
  #                            :emin=> -16382, :emax=>+16383,
  #                            :rounding=>:half_even,
  #                            :flags=>[],
  #                            :traps=>[DivisionByZero, Overflow, InvalidOperation],
  #                            :ignored_flags=>[],
  #                            :capitals=>true,
  #                            :clamp=>true)
  DefaultContext = BinFloat::Context.new(
                             :exact=>false, :precision=>53, :rounding=>:half_even,
                             :emin=> -1025, :emax=>+1023,                             :flags=>[],
                             :traps=>[DivisionByZero, Overflow, InvalidOperation],
                             :ignored_flags=>[],
                             :capitals=>true,
                             :clamp=>true)

  ExtendedContext = BinFloat::Context.new(DefaultContext,
                             :traps=>[], :flags=>[], :clamp=>false)

  IEEEHalfContext = BinFloat::Context.new(
                            :precision=>1,
                            :emin=> -14, :emax=>+15,
                            :rounding=>:half_even,
                            :flags=>[],
                            :traps=>[DivisionByZero, Overflow, InvalidOperation],
                            :ignored_flags=>[],
                            :capitals=>true,
                            :clamp=>true)

  IEEESingleContext = BinFloat::Context.new(
                            :precision=>24,
                            :emin=> -126, :emax=>+127,
                            :rounding=>:half_even,
                            :flags=>[],
                            :traps=>[DivisionByZero, Overflow, InvalidOperation],
                            :ignored_flags=>[],
                            :capitals=>true,
                            :clamp=>true)

  IEEEDoubleContext = BinFloat::Context.new(
                            :precision=>53,
                            :emin=> -1022, :emax=>+1023,
                            :rounding=>:half_even,
                            :flags=>[],
                            :traps=>[DivisionByZero, Overflow, InvalidOperation],
                            :ignored_flags=>[],
                            :capitals=>true,
                            :clamp=>true)

  IEEEQuadContext = BinFloat::Context.new(
                            :precision=>113,
                            :emin=> -16382, :emax=>+16383,
                            :rounding=>:half_even,
                            :flags=>[],
                            :traps=>[DivisionByZero, Overflow, InvalidOperation],
                            :ignored_flags=>[],
                            :capitals=>true,
                            :clamp=>true)

  IEEEExtendedContext = BinFloat::Context.new(
                            :precision=>64,
                            :emin=> -16382, :emax=>+16383,
                            :rounding=>:half_even,
                            :flags=>[],
                            :traps=>[DivisionByZero, Overflow, InvalidOperation],
                            :ignored_flags=>[],
                            :capitals=>true,
                            :clamp=>true)

  if Float::RADIX==2
    FloatContext = BinFloat::Context.new(
                               :precision=>Float::MANT_DIG,
                               :rounding=>Support::AuxiliarFunctions.detect_float_rounding,
                               :emin=>Float::MIN_EXP-1, :emax=>Float::MAX_EXP+1,
                               :flags=>[],
                               :traps=>[DivisionByZero, Overflow, InvalidOperation],
                               :ignored_flags=>[],
                               :capitals=>true,
                               :clamp=>true)
  end


  def initialize(*args)
    super(*args)
  end

  def number_of_digits
    @coeff.is_a?(Integer) ? _nbits(@coeff) : 0
  end

  # Ruby-style to string conversion.
  def to_s(*args)
    eng=false
    context=nil

    # admit legacy arguments eng, context in that order
    if [true,false].include?(args.first)
      eng = args.shift
    end
    if args.first.is_a?(BinFloat::Context)
      context = args.shift
    end
    # admit also :eng to specify the eng mode
    if args.first == :eng
      eng = true
      args.shift
    end
    raise TypeError, "Invalid arguments to BinFloat#to_s" if args.size>1 || (args.size==1 && !args.first.is_a?(Hash))
    # an admit arguments through a final parameters Hash
    options = args.first || {}
    context = options.delete(:context) if options.has_key?(:context)
    eng = options.delete(:eng) if options.has_key?(:eng)

    # TODO: eng formatting
    format(context, options)
  end

  # Specific to_f conversion TODO: check if it represents an optimization
  if Float::RADIX==2
    def to_f
      if special?
        super
      else
        Math.ldexp(@sign*@coeff, @exp)
      end
    end
  end

  # BinFloat - Decimal conversions

  # Exact conversion: preserve BinFloat value.
  # The current Decimal.context determines the valid range and the precision
  #(if not :exact the result will be rounded)
  def to_decimal_exact()
    if special?
      if nan?
        Decimal.nan
      else # infinite?
        Decimal.infinite(self.sign)
      end
    elsif zero?
      Decimal.zero(self.sign)
    else
      Decimal(@sign*@coeff)*Decimal(2)**@exp
    end
  end

  # Convert to decimal so that if the decimal is converted to a BinFloat of the same precision
  # and with same rounding (i.e. BinFloat.from_decimal(x, context)) the value of the BinFloat
  # is preserved, but use as few decimal digits as possible.
  def to_decimal(binfloat_context=nil, any_rounding=false)
    if special?
      if nan?
        Decimal.nan
      else # infinite?
        Decimal.infinite(self.sign)
      end
    elsif zero?
      Decimal.zero(self.sign)
    else
      context = define_context(binfloat_context)
      Decimal(format(context, :base=>10, :all_digits=>false, :any_rounding=>any_rounding))
    end
  end

  # Convert to decimal so that if the decimal is converted to a BinFloat of the same precision
  # and with any rounding the value of the BinFloat is preserved, but use as few decimal digits
  # as possible.
  def to_decimal_any_rounding(binfloat_context=nil)
    to_decimal(binfloat_context, true)
  end

  # Convert Decimal to BinFloat
  def BinFloat.from_decimal(x, binfloat_context=nil)
    BinFloat(x.to_s, binfloat_context)
  end

  private

  # Convert to a text literal in the specified base. If the result is
  # converted to BinFloat with the specified context rounding and the
  # same precision that self has (self.number_of_digits), the same
  # number will be produced.
  #
  # Options:
  # :base output base, 10 by default
  #
  # :any_rounding if true he text literal will have enough digits to be
  # converted back to self in any rounding mode. Otherwise only enough
  # digits for conversion in the rounding mode specified by the context
  # are produced.
  #
  # :all_digits if true all significant digits are shown. A digit
  # is considere as significant here if when used on input, cannot
  # arbitrarily change its value and preserve the parsed value of the
  # floating point number.
  def format(binfloat_context, options={})
    output_radix = options[:base] || 10
    all_digits = options[:all_digits]
    any_rounding = options[:any_rounding]

    sgn = sign<0 ? '-' : ''
    if special?
      if @exp==:inf
        return "#{sgn}Infinity"
      elsif @exp==:nan
        return "#{sgn}NaN#{@coeff}"
      else # exp==:snan
        return "#{sgn}sNaN#{@coeff}"
      end
    end

    context = define_context(binfloat_context)
    inexact = true
    rounding = context.rounding unless any_rounding
    if @sign == -1
      if rounding == :ceiling
        rounding = :floor
      elsif rounding == :floor
        rounding = :ceiling
      end
    end
    x = self.abs # .to_f

    p = self.number_of_digits

      dec_pos,round_needed,*digits = Support::BurgerDybvig.float_to_digits(x,@coeff,@exp,rounding,
                               context.etiny,p,num_class.radix,output_radix, all_digits)
    # TODO: format properly
    digits = digits.map{|d| d.to_s(output_radix)}.join
    if dec_pos <= 0
      if dec_pos >= -4 && digits.length <= 15
        digits = "0." + "0"*(-dec_pos) + digits
      else
        digits = digits[0,1]+"."+digits[1..-1]+"E#{dec_pos-1}"
      end
    elsif dec_pos > digits.length
      if dec_pos <= 20
        digits = digits + "0"*(dec_pos-digits.length)
      else
        # TODO: if digits.length == 1
        digits = digits[0,1]+"."+digits[1..-1]+"E#{dec_pos-1}"
      end
    elsif dec_pos != digits.length
      digits = digits[0...dec_pos] + "." + digits[dec_pos..-1]
    end
    ((sign==-1) ? '-' : '') + digits
  end

end

def BinFloat(*args)
  BinFloat.Num(*args)
end


end # BigFloat