$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'request_signing'

require 'minitest/autorun'

TEST_RSA_PUBKEY = <<-RSAKEY
-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDCFENGw33yGihy92pDjZQhl0C3
6rPJj+CvfSC8+q28hxA161QFNUd13wuCTUcq0Qd2qsBe/2hFyc2DCJJg0h1L78+6
Z4UMR7EOcpfdUE9Hf3m/hs+FUR45uBJeDK1HSFHD8bHKD6kv8FPGfJTotc+2xjJw
oYi+1hqp1fIekaxsyQIDAQAB
-----END PUBLIC KEY-----
RSAKEY

TEST_RSA_PRIVATE_KEY = <<-RSAKEY
-----BEGIN RSA PRIVATE KEY-----
MIICXgIBAAKBgQDCFENGw33yGihy92pDjZQhl0C36rPJj+CvfSC8+q28hxA161QF
NUd13wuCTUcq0Qd2qsBe/2hFyc2DCJJg0h1L78+6Z4UMR7EOcpfdUE9Hf3m/hs+F
UR45uBJeDK1HSFHD8bHKD6kv8FPGfJTotc+2xjJwoYi+1hqp1fIekaxsyQIDAQAB
AoGBAJR8ZkCUvx5kzv+utdl7T5MnordT1TvoXXJGXK7ZZ+UuvMNUCdN2QPc4sBiA
QWvLw1cSKt5DsKZ8UETpYPy8pPYnnDEz2dDYiaew9+xEpubyeW2oH4Zx71wqBtOK
kqwrXa/pzdpiucRRjk6vE6YY7EBBs/g7uanVpGibOVAEsqH1AkEA7DkjVH28WDUg
f1nqvfn2Kj6CT7nIcE3jGJsZZ7zlZmBmHFDONMLUrXR/Zm3pR5m0tCmBqa5RK95u
412jt1dPIwJBANJT3v8pnkth48bQo/fKel6uEYyboRtA5/uHuHkZ6FQF7OUkGogc
mSJluOdc5t6hI1VsLn0QZEjQZMEOWr+wKSMCQQCC4kXJEsHAve77oP6HtG/IiEn7
kpyUXRNvFsDE0czpJJBvL/aRFUJxuRK91jhjC68sA7NsKMGg5OXb5I5Jj36xAkEA
gIT7aFOYBFwGgQAQkWNKLvySgKbAZRTeLBacpHMuQdl1DfdntvAyqpAZ0lY0RKmW
G6aFKaqQfOXKCyWoUiVknQJAXrlgySFci/2ueKlIE1QqIiLSZ8V8OlpFLRnb1pzI
7U1yQXnTAEFYM560yJlzUpOb1V4cScGd365tiSMvxLOvTA==
-----END RSA PRIVATE KEY-----
RSAKEY

TEST_DSA_PUBKEY = <<-DSAKEY
-----BEGIN PUBLIC KEY-----
MIIBtjCCASsGByqGSM44BAEwggEeAoGBAMKYCShRoh99eUP6Gvcr2R1810lXtnQd
N6E7vHzd6gyXCeZ88ImCde5jwUBcg7xnD6xjKFH9BieO2+y0XAlBjrgICQksq1T3
Y3dt+A3BxRCc+h3XUzWWU+kMAW+mSrGiyEnJnWyUtfdAA+B153f0spfXGLIokeme
j7vSuWlyKCr7AhUApVrimMqXao2Nl/OEhmMg+Yc3+IECgYBrIuwz/ulXrNJJw41O
gugvEuWxznu+R5Nx7M6NLkputK6t/dNaHP9TzytU9gy+NhzCZ7eynF82Ur6zRRE9
15+mC6OkhTAU/9Z1tdoyf6dY9l5xo8zunok9I83E4Cq7IvOeAMBb9NU6rwL9n8mR
FnzO0Nto1eD05Smmdq2EprXisgOBhAACgYBN48h53slhGrz/3bS72mYe3D774XIH
aP+DdluK8RGOgvWwWryP26ABzlsEOWF0K4WZ0lFMlLjyexndb73PTfnh56M4hLnS
LqEfna1qYWeEktnsFv+VLkaXRbhTVPckA1jLCL2LrZ3N+ECZ68ysntZ1UIAFyKNY
Hn0Rlgbx2rgPXQ==
-----END PUBLIC KEY-----
DSAKEY

TEST_DSA_PRIVATE_KEY = <<-DSAKEY
-----BEGIN DSA PRIVATE KEY-----
MIIBugIBAAKBgQDCmAkoUaIffXlD+hr3K9kdfNdJV7Z0HTehO7x83eoMlwnmfPCJ
gnXuY8FAXIO8Zw+sYyhR/QYnjtvstFwJQY64CAkJLKtU92N3bfgNwcUQnPod11M1
llPpDAFvpkqxoshJyZ1slLX3QAPgded39LKX1xiyKJHpno+70rlpcigq+wIVAKVa
4pjKl2qNjZfzhIZjIPmHN/iBAoGAayLsM/7pV6zSScONToLoLxLlsc57vkeTcezO
jS5KbrSurf3TWhz/U88rVPYMvjYcwme3spxfNlK+s0URPdefpgujpIUwFP/WdbXa
Mn+nWPZecaPM7p6JPSPNxOAquyLzngDAW/TVOq8C/Z/JkRZ8ztDbaNXg9OUppnat
hKa14rICgYBN48h53slhGrz/3bS72mYe3D774XIHaP+DdluK8RGOgvWwWryP26AB
zlsEOWF0K4WZ0lFMlLjyexndb73PTfnh56M4hLnSLqEfna1qYWeEktnsFv+VLkaX
RbhTVPckA1jLCL2LrZ3N+ECZ68ysntZ1UIAFyKNYHn0Rlgbx2rgPXQIUU/gUS/hR
H2RCOHGYqLlN7fNhAYI=
-----END DSA PRIVATE KEY-----
DSAKEY

TEST_HMAC_SECRET = <<-HMAC
T2IFlfrSeE4ZfpPiksWW7LccBqUyKd8I
HMAC

class Test < Minitest::Test
  class << self
    def test(name, &block)
      block ||= proc { skip "Pending" }
      define_method("test_#{name}", &block)
    end

    def xtest(name)
      test(name)
    end
  end
end
