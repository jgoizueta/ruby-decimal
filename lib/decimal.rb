require 'flt/dec_num'

Decimal = Flt::DecNum
DecimalSupport = Flt::Support

def Decimal(*args)
  Flt::DecNum[*args]
end
