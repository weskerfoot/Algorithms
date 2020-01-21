#lang racket
(require data/bit-vector)

; https://imgur.com/a/ClKK5Ac

; See http://fabiensanglard.net/floating_point_visually_explained/ for an intuitive explanation

(define (to-bin fl)
  (~r fl
      #:base 2
      #:precision 52))

(define (bit-vector->string bv)
 (list->string
  (for/list [(i (in-range (bit-vector-length bv)))]
   (cond
      [(bit-vector-ref bv i) #\1]
      [else #\0]))))

(define (bit-vector->posint bv)
  (string->number
   (format "#b~a"
     (bit-vector->string bv))))

(define (show-bv-slice bv start end)
  (bit-vector->list
   (bit-vector-copy bv start end)))

(define (bool->number b)
  (cond
    [b 1]
    [else 0]))

(define (number->bool n)
  (match n
    [0 #f]
    [1 #t]
    [_ #f]))

(define (sum xs)
  (foldr + 0 xs))

; conversion from base 10 functions

;; Have to calculate the number of digits to remove from
;; the precision based on how far the decimal point needs
;; to be moved left,
;; or else maybe just do the calculation, and lop off digits from the right?


(define (int->binary n)
  (let-values
      ([(q r) (quotient/remainder n 2)])
    (match q
      [0 (list r)]
      [_ (cons r (int->binary q))])))

(define (real->binary-frac n [precision 0])
  (define p
    (* 2 n))
  
  (displayln p)
  (cond
    [(= p 0.0) ""]
    [(> precision 51) ""]
    [(>= p 1)
     (string-append "1"
                    (real->binary-frac
                     (sub1 p)
                     (add1 precision)))]
    [(< p 1)
     (string-append "0"
                    (real->binary-frac
                     p
                     (add1 precision)))]))

; do the conversion from w.fff.. to binary
(define (real->bits whole fraction)
  (list
   (cond
     [(> whole 0) 0]
     [else 1])
   (bit-vector->string
    (list->bit-vector
     (map number->bool
          (reverse (int->binary whole)))))
   
   (real->binary-frac fraction)))


; Conversion from base-2 functions

(define (calculate-number bv)
  (define sign (bv-sign bv))
  (define mantissa (bv-mantissa bv))
  (define exponent (bv-exponent bv))

  (displayln (format "Sign = ~a" (cond ((= 0 sign) "positive") (else "negative"))))
  
  (displayln (format "Mantissa = ~a"
                     (exact->inexact
                      (calculate-mantissa mantissa))))
  
  (displayln (format "Exponent = ~a" exponent))
  
  (*
   (expt -1 sign)
   (calculate-mantissa mantissa)
   (expt 2 exponent)))

(define (exp-len bv)
  (match (bit-vector-length bv)
    [32 8]
    [64 11]))

(define (bv-mantissa bv)
   (bit-vector-copy bv
                   (add1 (exp-len bv))
                   (bit-vector-length bv)))


;; Floating point numbers

(define example
  (string->bit-vector
   ; 0.052 in binary
   ;seeeeeeeeeeemmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
   "0011111110101010100111111011111001110110110010001011010000111001"))

;; In this example, we are representing 0.052 as a 64 bit floating point number
;; The first bit is our sign
;; The next 11 bits are our exponent
;; The next 52 bits are our mantissa (also called the significand or fraction)

;; Starting with the sign, if it is 1 it is negative, otherwise positive

(define (bv-sign bv)
  (cond
   [(bit-vector-ref bv 0) -1]
   [else 0]))

;; The exponent (next 11 bits) is represented in a biased form, meaning there is a subtraction that occurs
;; So for 0.052, the exponent is -5
;; 01111111010 = 1018 in binary
;; the bias is 1023, so we do 1018 - (2^10-1) = 1028 - 1023 = -5

(define (bv-exponent bv)
  ; bias is basically half the range of the exp minus 1
  (define bias
    (sub1
     (expt 2
          (sub1 (exp-len bv)))))
  ; subtract bias from exponent
  (-
   (bit-vector->posint
    (bit-vector-copy bv 1 (add1 (exp-len bv))))
   bias))

;; The mantissa (next 52 bits) is usually represented in a *normalized* form, meaning 1.xxx... (52 bits for a 64 bit float)
;; The mantissa can be calculated in decimal using a summation, e.g. b1 / 2^1 + b2 / 2^2 + ... (b1 and b2 are bits)

(define (calculate-mantissa n)
  (define bits
    (map bool->number (bit-vector->list n)))
  (define powers
    (map add1 (range (length bits))))
  ; add 1 for the implicit 1.xxx
  ; sum of bits divided by increasing powers of 2
  ; basically each "place" in the binary digits
    (add1 (sum (map
     (lambda (b p)
       (/ b (expt 2 p)))
     bits powers))))

;;                                     s    m        exp
;; Putting that together, you get (-1)^0 * 1.664 * 2^(-5) = 0.052

;; Keep in mind that the computer does not do this conversion every time it calculates something
;; There are various algorithms for adding/multiplying binary floating point numbers efficiently (which I won't get into)

;; You may ask why there is always an implicit leading 1. in the mantissa/significand. The answer is that it's
;; somewhat arbitrary. There are things called subnormal, or denormalized numbers, which can change this.

;; From wikipedia:

;; In a denormal number, since the exponent is the least that it can be,
;; zero is the leading significand digit (0.m1m2m3...mp−2mp−1)
;; allowing the representation of numbers closer to zero than the smallest normal number.

;; 

;; Other fun things about floating point numbers

;; You may also notice that as the exponent gets larger and larger, the range of numbers between a given whole number
;; and the next one increases.

;; There is something called "epsilon" which essentially tells you which number is the upper bound on any rounding error
;; For example, on my machine 2.0 + 2.220446049250313e-16 = 2.0

;; Why? because 2.220446049250313e-16 (or anything smaller) is going to simply get rounded off.
;; This number basically tells you the limit of the precision for your floats on a given machine
;; It ends up being useful for various numerical algorithms that you probably don't need to care about.

;; It is important to understand that floating point intervals have an inherent limit to the range of numbers

;; NaN
;; NaNs are represented with an exponent that is all 1s, and a mantissa that is anything except all 0s
;; NaN == NaN is always false. This implies there is more than one NaN. Some software will actually use this
;; as a way of encoding error codes.

;; Infinity is represented with a mantissa of all 0s and an exponent of all 1s
;; We can have -/+ Infinity because of this

;; E.g.
;; NaN = 0111111111111000000000000000000000000000000000000000000000000000
;;-Inf = 1111111111110000000000000000000000000000000000000000000000000000

;; (note that my code does not properly handle infinity or NaNs)

;; Decimal floating point
;; There is an entire separate standard for this but all in Decimal, not Binary! Conceptually, you could do this
;; with any base. There are even hexadecimal floating point number systems.

;; If you need to deal with anything that must be exact, use rationals. If you need performance, use floats.
;; The problem with using floats is that some numbers can only be approximated, not perfectly accurately represented.
;; This is true of any base, not just base 2. It is also true of irrational numbers like pi.

;; There are things called "Minifloats" which are only 16 bits or smaller, and are non-standard, but useful
;; E.g. in graphics where you don't care too much about precision but performance matters a lot

(displayln
 (exact->inexact (calculate-number example)))