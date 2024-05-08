#!/usr/local/dept/bin/mzscheme
#lang scheme/base

(require racket/system) ; support for (system ...)

(define csi (lambda (s) ; send an ANSI escape code to the terminal
    (display (string-append "\x1b[" s))))

(define initialize_terminal (lambda ()
    (system "/bin/stty raw") ; stop buffering keypresses
    (csi "?47h") ; save the current screen
    (csi "?25l"))) ; make the cursor invisible

(define restore_terminal (lambda ()
    (system "/bin/stty cooked")  ; restore keypress handling
    (csi "?25h") ; make the cursor visible again
    (csi "?47l"))) ; restore the original screen

(define draw_display (lambda (pos)
    (csi "2J") ; clear the screen
    (csi "H") ; move to the home position (row=1, col=1)

    (display "......\r\n")
    (display "......\r\n")
    (display ".....X\r\n")
  
    (csi "42m") ; green background color
    (display "press awsd to move, q to quit\r")
    (csi "49m") ; default background color
  
    (csi (string-append (number->string (car pos))
                        ";"
                        (number->string (cadr pos))
                        "H"))  ; move to the position given by pos
    (display "@\n")))

(define handle_arrow_keypress (lambda (c)
    (case c
        ((#"\e[A") 'up)      ; Up arrow key
        ((#"\e[B") 'down)    ; Down arrow key
        ((#"\e[C") 'right)   ; Right arrow key
        ((#"\e[D") 'left)    ; Left arrow key
        (else c))))           ; Handle other keys as is

(define handle_keypress (lambda (c pos)
    (let ((new_pos (cond
                     ((equal? "a" c) (list (car pos) (- (cadr pos) 1)))
                     ((equal? "w" c) (list (- (car pos) 1) (cadr pos)))
                     ((equal? "s" c) (list (+ (car pos) 1) (cadr pos)))
                     ((equal? "d" c) (list (car pos) (+ (cadr pos) 1)))
                     (else pos))))

        (cond ((equal? "q" c) (clean_exit "Bye!"))
              ((or (< (car new_pos) 1)
                   (> (car new_pos) 3)
                   (< (cadr new_pos) 1)
                   (> (cadr new_pos) 6))
                  (clean_exit "Oops-- fell off the edge of the board."))
              ((and (= (car new_pos) 3)
                    (= (cadr new_pos) 6)) (clean_exit "You won!"))
              (else new_pos)))))

(define clean_exit (lambda (message)
    (restore_terminal)
    (display message)
    (newline)
    (exit)))

(define (check_for_escape-key key-char)
    (char=? 27 (string-ref key-char 0)))

(define main_loop (lambda (pos arrow-key-handler)
    (let loop ((pos pos))
        (let ((c (string (read-char)))
              (new_pos (if (char=? 27 (string-ref c 0))
                          (arrow-key-handler (string-append c (read-line)))
                          (handle_keypress c pos))))
          (begin
            (draw_display new_pos)
            (loop new_pos))))))

(define main (lambda ()
    (initialize_terminal)
    (let ((pos '(2 2))) ; current position as row, column
      (draw_display pos)
      (main_loop pos handle_arrow_keypress)))) ; Pass the arrow key handler to main_loop

(main)
