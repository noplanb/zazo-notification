module PhoneNumberHelpers
  # TODO: GlobalPhone is a port of androids java lib PhoneNumberUtil this class has a method getExampleNumber.
  # That method was not ported in the GlobalPhone gem. One day when we are a big well funded company can port it.
  # and give it back to the community.
  SAMPLE_NUMBERS = {
    us: '+1 650 245 3537',
    ch: '+41 315 280 352',
    cn: '+86 1301 765 8654',
    de: '+49 303 080 7241',
    dk: '+45 8988 0571',
    es: '+34 961 125 502',
    fi: '+358 942 415 734',
    fr: '+33 413 681 052',
    gb: '+44 122 445 9553',
    hk: '+852 300 85782',
    il: '+972 2374 0114',
    it: '+39 095 293 6941',
    jp: '+81 456 702 264',
    nl: '+31 202 410 957',
    nz: '+64 3 288 0103',
    se: '+46 406 060 647',
    in: '+91 98336 95651'
  }

  def sample_number(cc_iso)
    SAMPLE_NUMBERS[cc_iso]
  end
end

RSpec.configure do |config|
  config.include PhoneNumberHelpers
end
