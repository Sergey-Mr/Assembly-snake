; SYSTEM MEMORY ALLOCATIONS
B start_game

ORG 0
SNAKE_HEAD DATA 0xFF00   ; Snake's starting position (initially at cell 0)
WAIT_COUNT DATA 0
TICK_LIMIT DATA 10
CURRENT_DIRECTION DATA 8
SCREEN_START DEFW 0xFF00
SCREEN_END DEFW 0xFF3F
SNAKE_POS DATA 0xFF00
DISTANCE DATA 0
COUNTER_ADDR_DUMMY DATA 0xFFA4
APPLE_POS DATA 0
COUNTER_ADDR DATA 0xFFA4
TURN_COORD DATA 0
TAIL_POS DATA 0
SNAKE_SIZE DATA 0
BUZZER DATA 0xFF93

ORG 16
SNAKE_LOC DEFW 0
          DEFW 0 
          DEFW 0 
          DEFW 0
          DEFW 0 
          DEFW 0
          DEFW 0
          DEFW 0
          DEFW 0
          DEFW 0

ORG 26
; Start the game (initialize snake position)
start_game
  ; Initialise the wait counter 
  LD R1, [R0, #1]
  MOV R2, #0 
  ST R2, [R1]
  
  ;MOV R5, #0             ; Set snake's initial position (top-left corner)
  MOV R4, #8             ; Default direction (8 = down)
  ;LD R1, [R0, #0]        ; SNAKE_HEAD   
  ;ST R5, [R1]            
  LD R1, [R0, #3]        ; CURRENT_DIRECTION
  ST R4, [R1]            ; save the initial direction   
  ; B main_game           

BOARD_SIZE DATA 0x40
MASK DATA 0x3F
 
generate_apple
  LD R1, [R0, #10]  ; read value of the free running counter
  LD R2, [R1] 
  LD R3, MASK
  AND R2, R2, R3 ; Use bitwise AND to limit value from free-running counter
  LD R3, [R0, #4]
  ADD R2, R2, R3
  
;reduce_counter
;  LD R4, [R0, #6]
;  CMP R2, R4
;  BLT check_collision
;  SUB R2, R2, R3
;  B reduce_counter

check_collision
  LD R4, [R0, #6]
  CMP R2, R4
  BEQ generate_apple  ; collision detected - generate apple again
  
  ; Update apple`s position
  ST R2, [R0, #9]
  B main_game

; Main game loop (will be constantly running)
main_game
  LD R1, [R0, #1]  ; wait count
  LD R2, [R0, #2]  ; tick limit
  CMP R1, R2
  BGE update_snake   ; if enoug time passed, move the snake
  ADD R1, R1, #1   ; increment the wait count 
  LD R3, [R0, #1]
  ST R1, [R3]      ; update the WAIT_COUNT 

  B handle_input       
  ; B update_snake      
  ; B refresh_screen     
  ; B main_game           

; Button definitions for movement
UP_BTN DATA 0x04
RIGHT_BTN DATA 0x40
DOWN_BTN DATA 0x100
LEFT_BTN DATA 0x10
BUTTON_ADDR DATA 0xFF94   ; Address of the keypad

; Handle user input to update the direction
handle_input
  LD R2, BUTTON_ADDR
  LD R1, [R2]             ; Read the button input
  LD R3, [R0, #3]         ; CURRENT_DIRECTION
  LD R4, [R3]             ; Load the current direction

  ; Check button presses and update direction
  LD R3, UP_BTN
  CMP R1, R3
  BEQ change_up

  LD R3, RIGHT_BTN
  CMP R1, R3
  BEQ change_right

  LD R3, DOWN_BTN
  CMP R1, R3
  BEQ change_down

  LD R3, LEFT_BTN
  CMP R1, R3
  BEQ change_left
  B input_done            ; No valid input, keep current direction

change_up
  ; CMP R4, #8              ; Prevent reverse direction
  ; BEQ input_done
  MOV R4, #-8             ; Change direction to Up
  B save_direction

change_right
  ; CMP R4, #-1             ; Prevent reverse direction
  ; BEQ input_done
  MOV R4, #1              ; Change direction to Right
  B save_direction

change_down
  ; CMP R4, #-8             ; Prevent reverse direction
  ; BEQ input_done
  MOV R4, #8              ; Change direction to Down
  B save_direction

change_left
  ; CMP R4, #1              ; Prevent reverse direction
  ; BEQ input_done
  MOV R4, #-1             ; Change direction to Left

save_direction
  ; LD R3, [R0, #3]         ; CURRENT_DIRECTION
  ST R4, [R0, #3]             ; Save the new direction

input_done
  B update_snake
generate_apple_path
  B generate_apple
continue_after_update
  B refresh_screen
continue_after_screen_refresh
;set the delay
CONST_1000 DATA 200
  LD R1, CONST_1000
  LD R2, CONST_1000

delay_loop_1 
  CMP R1, #0
  BEQ main_game
  SUB R1, R1, #1
  LD R2, CONST_1000

delay_loop_2
  CMP R2, #0
  BEQ delay_loop_1
  SUB R2, R2, #1
  B delay_loop_2

; Update snake position
update_snake
  ;LD R3, [R0, #3]         ; CURRENT_DIRECTION
  LD R4, [R0, #7]         ; store direction needed for boundary checks
  ;ADD R4, R4, R3           ; update the current direction needed
  ;ST R4, [R0, #7]

boundary_check
  LD R5, [R0, #6]  ; head
  LD R3, [R0, #3]  ; current directoin
  ADD R5, R5, R3   ; find next position
  ST R5, [R0, #6]  ; temporarily store the updated position
 
  ; check vertical wrapping ( moving off the top or bottom)
  CMP R3, #8
  BEQ check_vertical
  CMP R3, #-8
  BEQ check_vertical 

  ; check horizontal wrapping
  AND R4, R5, #0x07
  CMP R3, #1
  BEQ check_horizontal
  CMP R3, #-1 
  BEQ check_horizontal

  ; no wrapping needed 
  B update_done
 
check_vertical
  LD R2, [R0, #4]  ; SCREEN_START 
  CMP R5, R2 
  BLT wrap_to_bottom 
 
  LD R2, [R0, #5]
  CMP R5, R2 
  BGT wrap_to_top
  B update_done

check_horizontal
  CMP R4, #0
  BEQ wrap_to_left
  
  CMP R4, #7
  BEQ wrap_to_right
  B update_done

wrap_to_bottom
CONST_60 DATA 0x40
  LD R1, CONST_60
  ADD R5, R5, R1  ; add 56 to move the corresponding column in the bottom raw
  ST R5, [R0, #6]
  B update_done

wrap_to_top
  LD R1, CONST_60
  SUB R5, R5, R1
  ST R5, [R0, #6]
  B update_done

wrap_to_left
  ADD R5, R5, #7
  ST R5, [R0, #6]
  B update_done

wrap_to_right
  SUB R5, R5, #7
  ; ADD R5, R5, #7 
  ST R5, [R0, #6]
  
update_done
  ST R5, [R0, #6]
  B continue_after_update

generate_apple_path_2
  B generate_apple_path

refresh_screen 
  ; Clear the screen
  LD R1, [R0, #4]  ; SCREEN_START
  MOV R2, #0
  LD R3, [R0, #5]  ; SCREEN_END

clear_loop
  ST R2, [R1]  ; clear the current pixel
  ADD R1, R1, #1  ; move to the next one
  CMP R1, R3
  BLT clear_loop

GREEN DATA 0xE0
  ; Draw the apple 
  LD R2, [R0, #9]
  LD R3, GREEN
  ST R3, [R2]
   
  ; Draw the snake`s new position
  LD R2, [R0, #6]    ; SNAKE_HEAD
  MOV R3, #1         ; Pixel value for the snake
  ST R3, [R2]        ; draw the snake`s head
 
  LD R4, [R0, #3]    ; direction
  NEG R4, R4 
  LD R5, [R0, #13]   ; loop counter - snake size
  CMP R5, R3
  BGE snake_gen_loop

  ; Check for collisions
  B check_snake_apple_collision

after_drawing
  B continue_after_screen_refresh

; generate every cell of the snake
snake_gen_loop
   
  ; drawing done
  B check_snake_apple_collision
 
check_snake_apple_collision
  LD R1, [R0, #6]
  LD R2, [R0, #9]
  CMP R1, R2
  BEQ handle_collision
  B after_drawing         ; proceed to drawign the snake if no collision


; LCD display
lcd_b DATA 0xFF40
lcd_e DATA 0xFF90

handle_collision
  ; Update snake`s size
  LD R1, [R0, #13]  
  ADD R1, R1, #1
  ST R1, [R0, #13]
  
  ; Add the tail
  
  
  ; check if the buzzer is busy  
  LD R1, [R0, #14] 
  LD R2, [R1]
  CMP R2, #0
  BNE skip_sound

SOUND DATA 0x8457
  SUB R1, R1, #1
  LD R2, SOUND
  ST R2, [R1]

skip_sound

LCD_BASE DEFW lcd_b
LCD_END DEFW lcd_e

S DATA 'S'
c DATA 'c'
  
  LD R1, LCD_BASE
  LD R2, LCD_END

  LD R1, [R1] 
  LD R2, [R2]

  MOV R3, R7
  B clear_lcd
 
  ; Display "Score: " on the first line 
  LD R2, LCD_BASE
  LD R2, [R2]
  LD R1, S
  ST R1, [R2]
  ADD R2, R2, #1

  LD R1, c
  ST R1, [R2]
  ADD R2, R2, #1

o DATA 'o'
r DATA 'r'
e DATA 'e'

  LD R1, o
  ST R1, [R2] 
  ADD R2, R2, #1
  
  LD R1, r
  ST R1, [R2]
  ADD R2, R2, #1
  
  LD R1, e
  ST R1, [R2]
  ADD R2, R2, #1 

  LD R1, [R0, #13]  ; current size
  CMP R1, #9
  BGE end_game
 
NUMBER_ASCII DATA 0x30
  LD R3, NUMBER_ASCII
  ADD R3, R3, R1
  ST R3, [R2]
  
  ; increase snake visually 
  ; find previous position of tail usign reverse of direction 
  LD R2, [R0, #3]  ; snake direction
  LD R3, [R0, #6]  ; snake head position 
  LD R1, [R0, #13]
  NEG R2, R2       ; negate the direction
  
  ; create tail if the first apple eaten 
  CMP R1, #1
  ;BGT update_tail 

  ; create the tail
  ADD R3, R3, R2
  MOV R4, #1
  ST R4, [R3]
  ST R3, [R0, #12]  ; update the value stored at tail
 ; B generate_apple_path_2
  B generate_apple_path_2

update_tail  ; tail is already created
  LD R3, [R0, #6]  ; tail
  ADD R3, R3, R2   ; new tail
  ST R3, [R0, #6]  ; update the address of tail
  MOV R4, #1
  ST R4, [R3]      ; light up the new tail
 
  B generate_apple_path_2
  
; LCD display
lcd_ba DATA 0xFF40
lcd_en DATA 0xFF90

end_game
  LD R1, lcd_ba
  MOV R3, R7
  B clear_lcd
  LD R2, lcd_ba
  
  LD R1, V1 
  ST R1, [R2]
  ADD R2, R2, #1

  LD R1, i1
  ST R1, [R2]
  ADD R2, R2, #1 
  
  LD R1, c1
  ST R1, [R2]
  ADD R2, R2, #1

V1 DATA 'V'
i1 DATA 'i'
c1 DATA 'c'
t1 DATA 't'
o1 DATA 'o'
r1 DATA 'r'
y1 DATA 'y'


  LD R1, t1
  ST R1, [R2]
  ADD R2, R2, #1

  LD R1, o1
  ST R1, [R2]
  ADD R2, R2, #1

  LD R1, r1
  ST R1, [R2]
  ADD R2, R2, #1
  
  LD R1, y1
  ST R1, [R2]
  ADD R2, R2, #1 


clear_lcd 
  ST R0, [R1]
  ADD R1, R1, #1
  CMP R1, R2
  BNE clear_lcd
  ADD R3, R3, #1
  MOV R7, R3

