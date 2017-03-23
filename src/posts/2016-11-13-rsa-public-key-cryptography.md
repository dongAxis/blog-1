<!--
{
  "title": "RSA public key cryptography",
  "date": "2016-11-13T01:21:00.000Z",
  "category": "",
  "tags": [
    "rsa",
    "security"
  ],
  "draft": false
}
-->

Here is how I played with `openssl` to generate and extract RSA keys, and check how RSA public/private key makes encryption/decryption by hand.

```
# ./script.py

# Exponentiation by Repeated Squaring and Multiplication
# ersm(x, e, n) == x ** e % n
def ersm(x, e, n):
    k = 0
    while (e &gt;&gt; k) &gt; 0:
        k += 1

    result = 1
    for i in range(k, -1, -1):
        result = result ** 2 % n
        if (e &gt;&gt; i) &amp; 1:
            result = result * x % n

    return result
```

```
$ openssl version
OpenSSL 1.0.2g  1 Mar 2016

$ openssl genpkey -algorithm RSA -outform PEM -out test.pem
................................++++++
...++++++

$ cat test.pem
-----BEGIN PRIVATE KEY-----
MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAK3obvaCCJT9yAPi
+y8CiT6QHyZke8yW8jDAO00wnGNlpPU+dgjAJLnT8cE7H6niRVuDya79ezvkv3M9
lSkX1wn7/LJxbXlOW9TZ+Yo97nLLQaqT+uK8qT7ZYuPu0MlC+9Gtt9yY7aItfWAK
XOSsF6G/Xp6lt6M7KcOQwaVL81MFAgMBAAECgYEApgFtArRnuslyB3vBKEO0fNsY
UQ60OjyQncayFOHlNuCNEWl5RKsdo6FUcY6dkA4lBNGNURQ4cZjOxBOx8dMG+bao
YCG+UYfDB59KnhCWtEfIiEJdODOi8TI6LvyUdXVuIREMzbbSERkXcXxiaRLJs1yP
MHYEEf9Tnl6IuGxn0lUCQQDc2Oty7fxzfhzQxD2cxEks7Gtf2Iem0zGxzysRY1YO
a6vRWgky9+zGVA7NTFHK9M67BjSn2pDa+xLOBCLhSa2jAkEAyZbUIBSQKlhqfAyI
MaBS1R6J96icxub+VyJhnx5sKcgwC59/UqEjAZFafMrBhEc3DWMBIC6gxbOiCmjb
Bvs3NwJAN356i4KpsQu7ieoF4WKhUJyHzqnGTHE9R4TbOZ9QfIcpwY1ySlBqOtvc
bFIFK46gc/Z3PMZ7J8t3SjVX3mx5KQJAbtU+S2UC3kU+RnWda6t53zKrKD7L84+M
xttgUNupHE+0Gq/WkNeHJ5WC6pmPS+rbmcCVHdyFCC17Kb38rhnwgQJAOlEj1IqP
UV5XvhF0Qu+0CM6AdmqYNnV6BE/59cPKuHjDaXgQIkKYAj5jm2O+oxi5ociKLHT9
Sqfc8LsUJXCymg==
-----END PRIVATE KEY-----

$ openssl asn1parse -in test.pem -inform PEM
    0:d=0  hl=4 l= 630 cons: SEQUENCE
    4:d=1  hl=2 l=   1 prim: INTEGER           :00
    7:d=1  hl=2 l=  13 cons: SEQUENCE
    9:d=2  hl=2 l=   9 prim: OBJECT            :rsaEncryption
   20:d=2  hl=2 l=   0 prim: NULL
   22:d=1  hl=4 l= 608 prim: OCTET STRING      [HEX DUMP]:3082025C02010002818100ADE86EF6820894FDC803E2FB2F02893E901F26647BCC96F230C03B4D309C6365A4F53E7608C024B9D3F1C13B1FA9E2455B83C9AEFD7B3BE4BF733D952917D709FBFCB2716D794E5BD4D9F98A3DEE72CB41AA93FAE2BCA93ED962E3EED0C942FBD1ADB7DC98EDA22D7D600A5CE4AC17A1BF5E9EA5B7A33B29C390C1A54BF35305020301000102818100A6016D02B467BAC972077BC12843B47CDB18510EB43A3C909DC6B214E1E536E08D11697944AB1DA3A154718E9D900E2504D18D5114387198CEC413B1F1D306F9B6A86021BE5187C3079F4A9E1096B447C888425D3833A2F1323A2EFC9475756E21110CCDB6D2111917717C626912C9B35C8F30760411FF539E5E88B86C67D255024100DCD8EB72EDFC737E1CD0C43D9CC4492CEC6B5FD887A6D331B1CF2B1163560E6BABD15A0932F7ECC6540ECD4C51CAF4CEBB0634A7DA90DAFB12CE0422E149ADA3024100C996D42014902A586A7C0C8831A052D51E89F7A89CC6E6FE5722619F1E6C29C8300B9F7F52A12301915A7CCAC18447370D6301202EA0C5B3A20A68DB06FB37370240377E7A8B82A9B10BBB89EA05E162A1509C87CEA9C64C713D4784DB399F507C8729C18D724A506A3ADBDC6C52052B8EA073F6773CC67B27CB774A3557DE6C792902406ED53E4B6502DE453E46759D6BAB79DF32AB283ECBF38F8CC6DB6050DBA91C4FB41AAFD690D787279582EA998F4BEADB99C0951DDC85082D7B29BDFCAE19F08102403A5123D48A8F515E57BE117442EFB408CE80766A9836757A044FF9F5C3CAB878C3697810224298023E639B63BEA318B9A1C88A2C74FD4AA7DCF0BB142570B29A

# NOTE: this set of 9 integers forms rsa keys defined here https://tools.ietf.org/html/rfc3447#appendix-A.1.2
$ openssl asn1parse -in test.pem -inform PEM -strparse 22
    0:d=0  hl=4 l= 604 cons: SEQUENCE
    4:d=1  hl=2 l=   1 prim: INTEGER           :00
    7:d=1  hl=3 l= 129 prim: INTEGER           :ADE86EF6820894FDC803E2FB2F02893E901F26647BCC96F230C03B4D309C6365A4F53E7608C024B9D3F1C13B1FA9E2455B83C9AEFD7B3BE4BF733D952917D709FBFCB2716D794E5BD4D9F98A3DEE72CB41AA93FAE2BCA93ED962E3EED0C942FBD1ADB7DC98EDA22D7D600A5CE4AC17A1BF5E9EA5B7A33B29C390C1A54BF35305
  139:d=1  hl=2 l=   3 prim: INTEGER           :010001
  144:d=1  hl=3 l= 129 prim: INTEGER           :A6016D02B467BAC972077BC12843B47CDB18510EB43A3C909DC6B214E1E536E08D11697944AB1DA3A154718E9D900E2504D18D5114387198CEC413B1F1D306F9B6A86021BE5187C3079F4A9E1096B447C888425D3833A2F1323A2EFC9475756E21110CCDB6D2111917717C626912C9B35C8F30760411FF539E5E88B86C67D255
  276:d=1  hl=2 l=  65 prim: INTEGER           :DCD8EB72EDFC737E1CD0C43D9CC4492CEC6B5FD887A6D331B1CF2B1163560E6BABD15A0932F7ECC6540ECD4C51CAF4CEBB0634A7DA90DAFB12CE0422E149ADA3
  343:d=1  hl=2 l=  65 prim: INTEGER           :C996D42014902A586A7C0C8831A052D51E89F7A89CC6E6FE5722619F1E6C29C8300B9F7F52A12301915A7CCAC18447370D6301202EA0C5B3A20A68DB06FB3737
  410:d=1  hl=2 l=  64 prim: INTEGER           :377E7A8B82A9B10BBB89EA05E162A1509C87CEA9C64C713D4784DB399F507C8729C18D724A506A3ADBDC6C52052B8EA073F6773CC67B27CB774A3557DE6C7929
  476:d=1  hl=2 l=  64 prim: INTEGER           :6ED53E4B6502DE453E46759D6BAB79DF32AB283ECBF38F8CC6DB6050DBA91C4FB41AAFD690D787279582EA998F4BEADB99C0951DDC85082D7B29BDFCAE19F081
  542:d=1  hl=2 l=  64 prim: INTEGER           :3A5123D48A8F515E57BE117442EFB408CE80766A9836757A044FF9F5C3CAB878C3697810224298023E639B63BEA318B9A1C88A2C74FD4AA7DCF0BB142570B29A

$ openssl asn1parse -in test.pem -inform PEM -strparse 22 -out test.pem.prkey.der

$ python
Python 2.7.12 (default, Jul  1 2016, 15:12:24)
[GCC 5.4.0 20160609] on linux2
Type &quot;help&quot;, &quot;copyright&quot;, &quot;credits&quot; or &quot;license&quot; for more information.
&gt;&gt;&gt; f = file(&#039;test.pem.prkey.der&#039;)
&gt;&gt;&gt; f.seek(276 + 2); p = eval(&#039;0x&#039; + binascii.b2a_hex(f.read(65)))
&gt;&gt;&gt; f.seek(343 + 2); q = eval(&#039;0x&#039; + binascii.b2a_hex(f.read(65)))
&gt;&gt;&gt; f.seek(7 + 3); n = eval(&#039;0x&#039; + binascii.b2a_hex(f.read(129)))
&gt;&gt;&gt; f.seek(139 + 2); e = eval(&#039;0x&#039; + binascii.b2a_hex(f.read(3)))
&gt;&gt;&gt; f.seek(144 + 3); d = eval(&#039;0x&#039; + binascii.b2a_hex(f.read(129)))
&gt;&gt;&gt; n == p * q
True
&gt;&gt;&gt; phi = (p - 1) * (q - 1) # Euler&#039;s totient function of n
&gt;&gt;&gt; d * e % phi
1L
&gt;&gt;&gt; from random import random
&gt;&gt;&gt; M = int(random() * n) # original message
&gt;&gt;&gt; M
76679876356419771287420599065181484956260965882856303750797271657295999331511915867674621229787330493719321478372508912037728967557975626730683431649452072816658293128489331243403038368333572933806638426863374970353742652528160409867522702574878131532689165825512284233735910735537834426649073463685854265344L
&gt;&gt;&gt; C = script.ersm(M, e, n) # encrypted message
&gt;&gt;&gt; M == script.ersm(C, d, n) # decrypted message coincides with original message
True
```

# TODO

- How additional data bundled with private key accelarates procedure?
  - d mod (p-1)
  - d mod (q-1)
  - (inverse of q) mod p
- What algorithm exactly `openssl genpkey` use for finding?
  - two primes _p_ and _q_
  - RSA paper didn't mention about "fixed" public exponent _e_ (this case 0x10001).
    how does it affect to finding _d_?
- Try other public key cryptography
  - DSA?, ECC?
- Try and understand for message signiture with private key in the wild (CAs).
- Implement primary testing

# Reference

- man 1 openssl

- RSA
  - RSA paper
      - http://people.csail.mit.edu/rivest/Rsapaper.pdf
  - Standrad for RSA
      - Abstract syntax of private key as ASN.1
          - https://tools.ietf.org/html/rfc3447#appendix-A.1.2 (RSA specific)
          - https://tools.ietf.org/html/rfc5958#section-2 (public key algorithm not only for RSA)
      - BER (or DER) encodes ASN.1
          - https://www.itu.int/ITU-T/studygroups/com17/languages/X.690-0207.pdf
      - .pem encodes BER (or DER)
          - https://tools.ietf.org/html/rfc7468#section-10

- ASN.1 and DER parser
  - https://github.com/openssl/openssl/blob/44c83ebd7089825a82545c9cacc4c4e2de81d001/apps/asn1pars.c

- Good introduction of ASN.1, BER, and DER
  - http://luca.ntop.org/Teaching/Appunti/asn1.html