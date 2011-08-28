(load "table.rkt")

(define eval-table (make-table))
(define (get type) 
  (let ((binding (table-get eval-table type)))
    (if (null? binding)
        #f
        (binding-value binding))))
(define (put type item) (table-put! eval-table type item))

(define (eval-quote exp env)
  (text-of-quotation exp))
(define (eval-lambda exp env)
  (make-procedure (lambda-parameters exp)
                  (lambda-body exp)
                  env))
(define (eval-begin exp env)
  (eval-sequence (begin-actions exp) env))
(define (eval-cond exp env)
  (eval (cond->if exp) env))

(put 'quote eval-quote)
(put 'set! eval-assignment)
(put 'define eval-definition)
(put 'if eval-if)
(put 'lambda eval-lambda)
(put 'begin eval-begin)
(put 'cond eval-cond)

(define (eval exp env)
  (cond ((self-evaluating? exp) exp)
        ((variable? exp) (lookup-variable-value exp env))
        ((get (car exp))
         ((get (car exp)) exp env))
        ((application? exp)
         (apply (eval (operator exp) env)
                (list-of-values (operands exp) env)))
        (else
         (error "Unkown expressioin type -- EVAL" exp))))
         